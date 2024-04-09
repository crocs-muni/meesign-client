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
import 'network_dispatcher.dart';
import 'task_repository.dart';

class ChallengeRepository extends TaskRepository<Challenge> {
  final NetworkDispatcher _dispatcher;
  final TaskDao _taskDao;

  ChallengeRepository(
    this._dispatcher,
    TaskSource taskSource,
    this._taskDao,
  ) : super(rpc.TaskType.SIGN_CHALLENGE, taskSource, _taskDao);

  // FIXME: same as file repo
  Future<void> sign(String name, List<int> data, List<int> gid) async {
    await _dispatcher.unauth.sign(
      rpc.SignRequest()
        ..groupId = gid
        ..name = name
        ..data = data,
    );
  }

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
          gid: Value(req.groupId as Uint8List),
          state: TaskState.created,
        ),
      );

      await _taskDao.insertChallenge(
        db.ChallengesCompanion.insert(
          tid: tid,
          did: did.bytes,
          name: req.name,
          data: req.data as Uint8List,
        ),
      );
    });
  }

  @override
  Future<db.Task> initTask(Uuid did, db.Task task, rpc.Task rpcTask) async {
    final group = await _taskDao.getGroup(did.bytes, gid: task.gid);
    return task.copyWith(
      context: Value(ProtocolWrapper.init(
        group.protocol.toNative(),
        group.context,
        shares: rpcTask.data.length,
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
