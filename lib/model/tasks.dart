import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../data/file_store.dart';
import '../native/generated/mpc_sigs_lib.dart';
import '../native/mpc_sigs_wrapper.dart';
import '../util/uuid.dart';
import 'group.dart';
import 'signed_file.dart';

enum TaskStatus { unapproved, waiting, working, finished, error }

abstract class MpcTask with ChangeNotifier {
  Uuid id;
  TaskStatus _status = TaskStatus.unapproved;
  int _round = 0;
  DateTime timeCreated = DateTime.now();
  Uint8List context;

  double get progress;
  TaskStatus get status => _status;
  int get round => _round;

  MpcTask(this.id, this.context);

  void error() {
    _status = TaskStatus.error;
    notifyListeners();
  }

  Never _throw(Object e) {
    error();
    throw e;
  }

  Future<List<int>?> _update(int round, List<int> data) async {
    final res = await ProtocolWrapper.advance(context, data as Uint8List);
    context = res.context;
    return res.data;
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

  // FIXME: avoid dynamic
  Future<dynamic> _finish(List<int> data);

  Future<dynamic> finish(List<int> data) async {
    if (_status != TaskStatus.working) {
      _throw(StateError('Invalid task state for finish'));
    }
    _status = TaskStatus.finished;

    try {
      final res = await _finish(data);
      notifyListeners();
      return res;
    } catch (e) {
      _throw(e);
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

  GroupTask(Uuid uuid, this.groupBase)
      : super(uuid, ProtocolWrapper.keygen(ProtocolId.Gg18));

  @override
  Future<Group> _finish(List<int> data) async {
    // FIXME: when to do copy when receiving data using grpc?
    final id = data;
    final context = ProtocolWrapper.finish(this.context);
    return Group(id, context, groupBase);
  }
}

class SignTask extends MpcTask {
  final SignedFile file;

  @override
  double get progress => _round / 10;

  SignTask(Uuid uuid, this.file)
      : super(uuid, ProtocolWrapper.sign(ProtocolId.Gg18, file.group.context));

  @override
  Future<SignedFile> _finish(List<int> data) async {
    ProtocolWrapper.finish(context);
    await FileStore().storeFile(id, file.basename, data);
    return file;
  }
}
