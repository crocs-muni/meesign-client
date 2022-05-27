import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

import '../native/generated/mpc_sigs_lib.dart';
import '../native/worker.dart';
import '../util/uuid.dart';
import 'group.dart';
import 'signed_file.dart';

enum TaskStatus { unapproved, waiting, working, finished, error }

abstract class MpcTask with ChangeNotifier {
  Uuid id;
  TaskStatus _status = TaskStatus.unapproved;
  int _round = 0;
  late final Worker _worker;

  double get progress;

  MpcTask(this.id);

  Future<T> _tryChange<T>(Future<T> Function() op) async {
    try {
      return await op();
    } catch (e) {
      _status = TaskStatus.error;
      notifyListeners();
      rethrow;
    }
  }

  Future<List<int>?> _update(int round, List<int> data) async {
    if (_round == 1) await _initWorker();

    final ProtocolUpdate resp = await _worker.enqueueRequest(
      // FIXME: change types
      ProtocolUpdate(data as Uint8List),
    );

    return resp.deliver();
  }

  Future<List<int>?> update(int round, List<int> data) async {
    if (round <= _round) return null;
    _round = round;
    _status = TaskStatus.working;
    notifyListeners();

    return _tryChange(() => _update(round, data));
  }

  Future<void> _initWorker();

  Future<void> _finish(List<int> data);

  Future<void> finish(List<int> data) async {
    if (_status == TaskStatus.finished) return;
    _status = TaskStatus.finished;

    await _tryChange(() => _finish(data));

    _worker.stop();
    notifyListeners();
  }

  void approve() {
    _status = TaskStatus.waiting;
    notifyListeners();
  }

  TaskStatus get status => _status;
}

class GroupTask extends MpcTask {
  final Group group;

  @override
  double get progress => _round / 6;

  GroupTask(Uuid uuid, this.group) : super(uuid);

  @override
  Future<void> _initWorker() async {
    _worker = Worker(
      GroupWorkerThread.entryPoint,
      debugName: 'group worker',
    );
    await _worker.start();
    await _worker.enqueueRequest(GroupInitMsg(Algorithm.Gg18));
  }

  @override
  Future<void> _finish(List<int> data) async {
    final TransferableTypedData trans =
        await _worker.enqueueRequest(TaskFinishMsg());

    // FIXME: when to do copy when receiving data using grpc?
    // group.context = mpcLib.protocol_result_group(_proto);
    group.id = data;
    group.context = trans.materialize().asUint8List();
  }
}

class SignTask extends MpcTask {
  final SignedFile file;

  @override
  double get progress => _round / 10;

  SignTask(Uuid uuid, this.file) : super(uuid);

  @override
  Future<void> _initWorker() async {
    _worker = Worker(
      SignWorkerThread.entryPoint,
      debugName: 'sign worker',
    );
    await _worker.start();
    await _worker.enqueueRequest(
      SignInitMsg(Algorithm.Gg18, file.group.context!, file.path),
    );
  }

  @override
  Future<void> _finish(List<int> data) async {
    await _worker.enqueueRequest(TaskFinishMsg());
    file.isFinished = true;
  }
}

class GroupInitMsg {
  int algorithm;
  GroupInitMsg(this.algorithm);
}

class PayloadMsg {
  TransferableTypedData data;

  PayloadMsg(Uint8List data) : data = TransferableTypedData.fromList([data]);

  Uint8List deliver() => data.materialize().asUint8List();
}

class SignInitMsg extends PayloadMsg {
  int algorithm;
  String path;

  SignInitMsg(this.algorithm, Uint8List groupData, this.path)
      : super(groupData);
}

class ProtocolUpdate extends PayloadMsg {
  ProtocolUpdate(Uint8List data) : super(data);
}

class TaskFinishMsg {}

class NativeException implements Exception {
  final String message;
  NativeException(this.message);
}

final MpcSigsLib mpcLib = MpcSigsLib(dlOpen('mpc_sigs'));

abstract class TaskWorkerThread extends WorkerThread {
  Pointer<ProtoWrapper> _proto = nullptr;

  TaskWorkerThread(SendPort sendPort) : super(sendPort);

  void _throw() {
    final errMsg = mpcLib.protocol_error(_proto).cast<Utf8>().toDartString();
    throw NativeException(errMsg);
  }

  ProtocolUpdate _updateProtocol(ProtocolUpdate update) {
    assert(_proto != nullptr);
    final data = update.deliver();

    // TODO: can we avoid some of these copies?
    return using((Arena alloc) {
      final buf = alloc<Uint8>(data.length);
      buf.asTypedList(data.length).setAll(0, data);

      print('update protocol');
      final outBuf = mpcLib.protocol_update(_proto, buf, data.length);
      if (outBuf.ptr == nullptr) _throw();

      return ProtocolUpdate(
        outBuf.ptr.asTypedList(outBuf.len),
      );
    });
  }
}

class GroupWorkerThread extends TaskWorkerThread {
  GroupWorkerThread(SendPort sendPort) : super(sendPort);

  @override
  handleMessage(message) {
    if (message is GroupInitMsg) return _init(message);
    if (message is ProtocolUpdate) return _updateProtocol(message);
    if (message is TaskFinishMsg) return _finish();
    assert(false);
  }

  void _init(GroupInitMsg message) {
    _proto = mpcLib.protocol_new(message.algorithm);
  }

  // TODO: add wrapper class?
  TransferableTypedData _finish() {
    final buf = mpcLib.protocol_result(_proto);
    if (buf.ptr == nullptr) _throw();

    final trans = TransferableTypedData.fromList(
      [buf.ptr.asTypedList(buf.len)],
    );

    mpcLib.protocol_free(_proto);
    _proto = nullptr;

    return trans;
  }

  static void entryPoint(SendPort sendPort) {
    GroupWorkerThread(sendPort);
  }
}

class SignWorkerThread extends TaskWorkerThread {
  SignWorkerThread(SendPort sendPort) : super(sendPort);

  @override
  handleMessage(message) {
    if (message is SignInitMsg) return _init(message);
    if (message is ProtocolUpdate) return _updateProtocol(message);
    if (message is TaskFinishMsg) return _finish();
  }

  void _init(SignInitMsg message) {
    // TODO: same as above, how to avoid copies?
    final data = message.deliver();
    using((Arena alloc) {
      final buf = alloc<Uint8>(data.length);
      buf.asTypedList(data.length).setAll(0, data);
      _proto = mpcLib.group_sign(message.algorithm, buf, data.length);
    });
  }

  void _finish() {
    // TODO: insert signature
    mpcLib.protocol_free(_proto);
  }

  static void entryPoint(SendPort sendPort) {
    SignWorkerThread(sendPort);
  }
}
