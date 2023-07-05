import 'package:drift/drift.dart';
import 'package:meesign_native/meesign_native.dart';
import 'package:meesign_network/grpc.dart' as rpc;

import '../database/daos.dart';
import '../database/database.dart' as db;
import '../model/challenge.dart';
import '../model/group.dart';
import '../model/protocol.dart';
import '../model/task.dart';
import '../util/uuid.dart';
import 'task_repository.dart';

class ChallengeRepository extends TaskRepository<Challenge> {
  final TaskDao _taskDao;

  ChallengeRepository(
    TaskSource taskSource,
    this._taskDao,
  ) : super(rpc.TaskType.SIGN_CHALLENGE, taskSource, _taskDao);

  @override
  Future<void> createTask(Uuid did, rpc.Task rpcTask) async {
    final req = rpc.SignRequest.fromBuffer(rpcTask.request);

    // FIXME: too similar to files?
    final tid = rpcTask.id as Uint8List;

    await _taskDao.transaction(() async {
      await _taskDao.upsertTask(
        db.TasksCompanion.insert(
          id: tid,
          did: did.bytes,
          state: TaskState.created,
        ),
      );

      await _taskDao.insertChallenge(
        db.ChallengesCompanion.insert(
          tid: tid,
          did: did.bytes,
          gid: req.groupId as Uint8List,
          name: req.name,
          data: req.data as Uint8List,
        ),
      );
    });
  }

  @override
  Future<db.Task> initTask(Uuid did, db.Task task) async {
    final challenge = await _taskDao.getChallenge(did.bytes, task.id);
    final group = await _taskDao.getGroup(did.bytes, gid: challenge.gid);
    return task.copyWith(
      context: Value(ProtocolWrapper.init(
        group.protocol.toNative(),
        group.context,
      )),
    );
  }

  @override
  Future<void> finishTask(Uuid did, db.Task task, rpc.Task rpcTask) async {
    final context = task.context;
    if (context != null) ProtocolWrapper.finish(context);
  }

  @override
  Stream<List<Task<Challenge>>> observeTasks(Uuid did) {
    Task<Challenge> toModel(ChallengeTask ct) {
      final group = ct.group.toModel();
      final challenge = Challenge(ct.challenge.name, group, ct.challenge.data);
      return TaskConversion.fromEntity(
          ct.task, group.protocol.signRounds, challenge);
    }

    return _taskDao
        .watchChallengeTasks(did.bytes)
        .map((list) => list.map((toModel)).toList());
  }
}
