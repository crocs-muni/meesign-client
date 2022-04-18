import '../util/uuid.dart';
import 'group.dart';
import 'signed_file.dart';

enum TaskStatus { unapproved, waiting, finished }

abstract class MpcTask {
  Uuid id;
  TaskStatus _status = TaskStatus.unapproved;
  int _round = 0;

  MpcTask(this.id);

  Future<List<int>?> update(int round, List<int> data);

  void approve() => _status = TaskStatus.waiting;
  TaskStatus get status => _status;
}

class GroupTask extends MpcTask {
  final Group group;

  GroupTask(Uuid uuid, this.group) : super(uuid);

  @override
  Future<List<int>?> update(int round, List<int> data) async {
    // TODO: implement update
    throw UnimplementedError();
  }
}

class SignTask extends MpcTask {
  final SignedFile file;

  SignTask(Uuid uuid, this.file) : super(uuid);

  @override
  Future<List<int>?> update(int round, List<int> data) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
