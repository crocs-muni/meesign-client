import 'dart:ffi';
import 'dart:io';
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
  TaskStatus get status => _status;
  int get round => _round;

  MpcTask(this.id);

  Never _throw(Object e) {
    _status = TaskStatus.error;
    notifyListeners();
    throw e;
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
    if (status != TaskStatus.working && status != TaskStatus.waiting) {
      _throw(StateError('Invalid task state for update'));
    }
    if (round != _round + 1) {
      _throw(StateError('Invalid round'));
    }

    ++_round;
    _status = TaskStatus.working;
    notifyListeners();

    try {
      return await _update(round, data);
    } catch (e) {
      _throw(e);
    }
  }

  Future<void> _initWorker();

  // FIXME: avoid dynamic
  Future<dynamic> _finish(List<int> data);

  Future<dynamic> finish(List<int> data) async {
    if (_status != TaskStatus.working) {
      _throw(StateError('Invalid task state for finish'));
    }
    _status = TaskStatus.finished;

    try {
      return await _finish(data);
    } catch (e) {
      _throw(e);
    } finally {
      _worker.stop();
      notifyListeners();
    }
  }

  void approve() {
    if (_status != TaskStatus.unapproved) return;
    _status = TaskStatus.waiting;
    notifyListeners();
  }
}

class GroupTask extends MpcTask {
  final GroupBase groupBase;

  @override
  double get progress => _round / 6;

  GroupTask(Uuid uuid, this.groupBase) : super(uuid);

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
  Future<Group> _finish(List<int> data) async {
    final TransferableTypedData trans =
        await _worker.enqueueRequest(TaskFinishMsg());

    // FIXME: when to do copy when receiving data using grpc?
    // group.context = mpcLib.protocol_result_group(_proto);
    final id = data;
    final context = trans.materialize().asUint8List();
    return Group(id, context, groupBase);
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
      SignInitMsg(Algorithm.Gg18, file.group.context, file.path),
    );
  }

  @override
  Future<SignedFile> _finish(List<int> data) async {
    await _worker.enqueueRequest(TaskFinishMsg());
    await File(file.path).writeAsBytes(data, flush: true);
    return file;
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
    assert(_proto != nullptr);
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
    assert(_proto != nullptr);
    mpcLib.protocol_free(_proto);
  }

  static void entryPoint(SendPort sendPort) {
    SignWorkerThread(sendPort);
  }
}
