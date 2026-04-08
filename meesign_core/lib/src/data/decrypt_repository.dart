import 'package:drift/drift.dart';
import 'package:meesign_core/src/data/key_store.dart';
import 'package:meesign_core/src/data/network_dispatcher.dart';
import 'package:meesign_core/src/data/task_repository.dart';
import 'package:meesign_core/src/database/daos.dart';
import 'package:meesign_core/src/database/database.dart' as db;
import 'package:meesign_core/src/model/decrypt.dart';
import 'package:meesign_core/src/model/group.dart';
import 'package:meesign_core/src/model/key_type.dart';
import 'package:meesign_core/src/model/protocol.dart';
import 'package:meesign_core/src/model/task.dart';
import 'package:meesign_core/src/util/mime_type.dart';
import 'package:meesign_core/src/util/uuid.dart';
import 'package:meesign_native/meesign_native.dart';
import 'package:meesign_network/grpc.dart' as rpc;

class DecryptRepository extends TaskRepository<Decrypt> {
  DecryptRepository(
    this._dispatcher,
    this._keyStore,
    TaskSource taskSource,
    this._taskDao,
  ) : super(rpc.TaskType.DECRYPT, taskSource, _taskDao);
  final TaskDao _taskDao;
  final NetworkDispatcher _dispatcher;
  final KeyStore _keyStore;

  /// Encrypt data for the given group. Returns the server task ID.
  /// Uses authenticated dispatcher so server can track the creator as observer.
  Future<List<int>> encrypt(
    Uuid did,
    String description,
    MimeType dataType,
    List<int> data,
    List<int> gid,
  ) async {
    final enc = ElGamalWrapper.encrypt(data, gid);
    final rpcTask = await _dispatcher[did].decrypt(
      rpc.DecryptRequest()
        ..groupId = gid
        ..name = description
        ..dataType = dataType.value
        ..data = enc,
    );
    return rpcTask.id.toList();
  }

  /// Fetch a task by ID from the server (no auth/participation required).
  Future<rpc.Task> fetchTaskById(List<int> taskId) =>
      _dispatcher.unauth.getTask(rpc.TaskRequest()..taskId = taskId);

  /// Save an observed task (created for a group we're not a member of).
  Future<void> saveObservedTask(
    Uuid did,
    List<int> taskId,
    List<int> groupId,
    String name,
    String dataType,
    List<int> data,
  ) async {
    await _taskDao.insertObservedTask(
      db.ObservedTasksCompanion.insert(
        tid: Uint8List.fromList(taskId),
        did: did.bytes,
        gid: Uint8List.fromList(groupId),
        name: name,
        dataType: dataType,
        data: Uint8List.fromList(data),
        state: TaskState.created,
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Poll all observed tasks from the server and update local state.
  Future<void> pollObservedTasks(Uuid did) async {
    final observed = await _taskDao.getObservedTasks(did.bytes);
    for (final task in observed) {
      // Skip terminal states
      if (task.state == TaskState.finished || task.state == TaskState.failed) {
        continue;
      }
      try {
        final rpcTask = await fetchTaskById(task.tid.toList());
        final newState = _mapRpcState(rpcTask.state);
        await _taskDao.updateObservedTask(
          db.ObservedTasksCompanion(
            tid: Value(task.tid),
            did: Value(task.did),
            state: Value(newState),
            acceptCount: Value(rpcTask.accept),
            rejectCount: Value(rpcTask.reject),
          ),
        );
      } on Exception {
        // Server may be unreachable — skip this task
      }
    }
  }

  /// Watch observed tasks and convert to [Task] models.
  Stream<List<Task<Decrypt>>> observeObservedTasks(
    Uuid did,
    List<Group> Function() getExternalGroups,
  ) {
    return _taskDao.watchObservedTasks(did.bytes).map((observedList) {
      final externalGroups = getExternalGroups();
      return observedList.map((ot) {
        final group = _findGroup(ot.gid.toList(), externalGroups);
        final decrypt = Decrypt(
          ot.name,
          group,
          MimeType(ot.dataType),
          ot.data,
        );
        return Task<Decrypt>(
          id: Uuid.take(ot.tid),
          round: ot.acceptCount,
          nRounds: group.threshold,
          info: decrypt,
          createdAt: ot.createdAt.millisecondsSinceEpoch,
          state: ot.state,
          approved: true, // prevents approve/decline buttons
        );
      }).toList();
    });
  }

  Group _findGroup(List<int> gid, List<Group> externalGroups) {
    for (final g in externalGroups) {
      if (_listEquals(g.id, gid)) return g;
    }
    // Fallback if group not in cache
    return Group(
      id: gid,
      name: 'Unknown group',
      members: [],
      threshold: 0,
      protocol: Protocol.elgamal,
      keyType: KeyType.decrypt,
    );
  }

  static bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static TaskState _mapRpcState(rpc.Task_TaskState state) => switch (state) {
        rpc.Task_TaskState.CREATED => TaskState.created,
        rpc.Task_TaskState.RUNNING => TaskState.running,
        rpc.Task_TaskState.FINISHED => TaskState.finished,
        rpc.Task_TaskState.FAILED => TaskState.failed,
        _ => TaskState.failed,
      };

  @override
  Future<bool> handleSubscriptionUpdate(Uuid did, rpc.Task rpcTask) async {
    final tid = rpcTask.id as Uint8List;
    final observed = await _taskDao.getObservedTasks(did.bytes);
    final match =
        observed.where((ot) => _listEquals(ot.tid.toList(), tid.toList()));
    if (match.isEmpty) return false;

    // This is an observed task — update its state
    await _taskDao.updateObservedTask(
      db.ObservedTasksCompanion(
        tid: Value(tid),
        did: Value(did.bytes),
        state: Value(_mapRpcState(rpcTask.state)),
        acceptCount: Value(rpcTask.accept),
        rejectCount: Value(rpcTask.reject),
      ),
    );
    return true;
  }

  @override
  Future<void> createTask(Uuid did, rpc.Task rpcTask) async {
    final req = rpc.DecryptRequest.fromBuffer(rpcTask.request);

    // FIXME: too similar to files?
    final tid = rpcTask.id as Uint8List;

    await _taskDao.transaction(() async {
      await _taskDao.upsertTask(
        db.TasksCompanion.insert(
          id: tid,
          did: did.bytes,
          gid: Value(req.groupId as Uint8List),
          state: TaskState.created,
          createdAt: DateTime.now(),
        ),
      );

      await _taskDao.insertDecrypt(
        db.DecryptsCompanion.insert(
          tid: tid,
          did: did.bytes,
          name: req.name,
          data: req.data as Uint8List,
          dataType: req.dataType,
        ),
      );
    });
  }

  @override
  Future<db.Task> initTask(Uuid did, db.Task task, rpc.Task rpcTask) async {
    final group = await _taskDao.getGroup(did.bytes, gid: task.gid);
    return task.copyWith(
      context: Value(
        ProtocolWrapper.init(
          group.protocol.toNative(),
          group.context,
          group.certificates!,
          _keyStore.load(did) as Uint8List,
          shares: rpcTask.data.length,
        ),
      ),
    );
  }

  @override
  Future<void> finishTask(Uuid did, db.Task task, rpc.Task rpcTask) async {
    final context = task.context;
    if (context != null) ProtocolWrapper.finish(context);
    await _taskDao.updateDecrypt(
      db.DecryptsCompanion(
        tid: Value(task.id),
        did: Value(task.did),
        data: Value(rpcTask.data.first as Uint8List),
      ),
    );
  }

  @override
  Stream<List<Task<Decrypt>>> observeTasks(Uuid did) {
    Task<Decrypt> toModel(DecryptTask dt) {
      final group = dt.group.toModel();
      final decrypt = Decrypt(
        dt.decrypt.name,
        group,
        MimeType(dt.decrypt.dataType),
        dt.decrypt.data,
      );
      // During voting (created state), show accept count / threshold.
      // During protocol execution (running+), show protocol rounds.
      final nRounds = dt.task.state == TaskState.created
          ? group.threshold
          : group.protocol.signRounds;
      return TaskConversion.fromEntity(
        dt.task,
        nRounds,
        decrypt,
      );
    }

    return _taskDao
        .watchDecryptTasks(did.bytes)
        .map((list) => list.map(toModel).toList());
  }

  Stream<List<Decrypt>> observeDecrypts(Uuid did) => observeResults(did);
}
