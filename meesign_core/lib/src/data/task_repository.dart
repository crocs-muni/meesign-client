import 'dart:async';
import 'dart:collection';

import 'package:drift/drift.dart';
import 'package:meesign_core/src/database/daos.dart';
import 'package:meesign_native/meesign_native.dart';
import 'package:meesign_network/meesign_network.dart'
    show BcastRespStream, BcastRespStreamExt, GrpcError;
import 'package:meesign_network/grpc.dart' as rpc;
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

import '../database/database.dart' as db;
import '../model/task.dart';
import '../util/default_map.dart';
import '../util/uuid.dart';
import 'network_dispatcher.dart';

class StateException implements Exception {}

class TaskSource {
  final NetworkDispatcher _dispatcher;

  final Map<Uuid, BcastRespStream<rpc.Task>> _streams = HashMap();

  TaskSource(this._dispatcher);

  Future<rpc.Resp> update(
          Uuid did, Uint8List tid, List<int> data, int attempt) =>
      _dispatcher[did].updateTask(
        rpc.TaskUpdate()
          ..task = tid
          ..data = data
          ..attempt = attempt,
      );

  Future<void> approve(Uuid did, Uuid tid, {required bool agree}) =>
      _dispatcher[did].decideTask(
        rpc.TaskDecision()
          ..task = tid.bytes
          ..accept = agree,
      );

  Future<void> acknowledge(Uuid did, Uint8List tid) =>
      _dispatcher[did].acknowledgeTask(
        rpc.TaskAcknowledgement()..taskId = tid,
      );

  /// retrieve the task including all its details
  Future<rpc.Task> fetch(Uuid did, Uuid tid) => _dispatcher[did].getTask(
        rpc.TaskRequest()
          ..deviceId = did.bytes
          ..taskId = tid.bytes,
      );

  Future<List<rpc.Task>> fetchAll(Uuid did) async {
    final rpcTasks = await _dispatcher[did].getTasks(
      rpc.TasksRequest()..deviceId = did.bytes,
    );
    return rpcTasks.tasks;
  }

  BcastRespStream<rpc.Task> subscribe(Uuid did) {
    return _streams.putIfAbsent(did, () {
      return _dispatcher[did]
          .subscribeUpdates(
        rpc.SubscribeRequest(),
      )
          .asBcastRespStream(
        onCancel: (subscription) {
          _streams.remove(did);
          subscription.cancel();
        },
      );
    });
  }
}

// TODO: create DeviceTaskRepository to simplify did handling?
abstract class TaskRepository<T> {
  final rpc.TaskType _taskType;
  final TaskSource _taskSource;
  final TaskDao _taskDao;

  final DefaultMap<Uuid, DefaultMap<Uuid, Lock>> _taskLocks =
      DefaultMap(HashMap(), () => DefaultMap(HashMap(), () => Lock()));

  final Map<Uuid, StreamSubscription<rpc.Task>> _subscriptions = HashMap();

  TaskRepository(this._taskType, this._taskSource, this._taskDao);

  @visibleForOverriding
  Future<void> createTask(Uuid did, rpc.Task rpcTask);
  @visibleForOverriding
  Future<db.Task> initTask(Uuid did, db.Task task);
  @visibleForOverriding
  Future<void> finishTask(Uuid did, db.Task task, rpc.Task rpcTask);

  // TODO: better way to compare states?

  Future<db.Task> _syncCreated(Uuid did, db.Task task, rpc.Task rpcTask) async {
    return task;
  }

  Future<db.Task> _syncFailed(db.Task task, rpc.Task rpcTask) async {
    return task.copyWith(context: Value(null), state: TaskState.failed);
  }

  Future<db.Task> _syncFinished(
      Uuid did, db.Task task, rpc.Task rpcTask) async {
    if (task.state == TaskState.finished || task.state == TaskState.failed) {
      return task;
    }

    // FIXME: how to rollback if one of these fails?
    await finishTask(did, task, rpcTask);
    await _taskSource.acknowledge(did, task.id);

    return task.copyWith(context: Value(null), state: TaskState.finished);
  }

  Future<db.Task> _syncRunning(Uuid did, db.Task task, rpc.Task rpcTask) async {
    if (task.state == TaskState.finished || task.state == TaskState.failed) {
      return task;
    }

    bool activeParticipant = task.context != null || rpcTask.hasData();
    if (!activeParticipant) {
      return task.copyWith(
        state: TaskState.running,
        round: rpcTask.round,
      );
    }

    if (!task.approved) throw StateException();
    if (!rpcTask.hasData()) return task; // nothing to do
    if (rpcTask.round <= task.round) return task;
    if (rpcTask.round != task.round + 1) throw StateException();

    if (task.round == 0) task = await initTask(did, task);
    final res = await ProtocolWrapper.advance(
      task.context!,
      rpcTask.data as Uint8List,
    );
    // TODO: rollback if we fail to deliver the update
    try {
      await _taskSource.update(did, task.id, res.data, task.attempt);
    } on GrpcError catch (e) {
      // FIXME: avoid matching error strings
      if (e.message == 'Stale update') return task;
      rethrow;
    }

    return task.copyWith(
      state: TaskState.running,
      round: task.round + 1,
      context: Value(res.context),
    );
  }

  db.Task _restart(db.Task task, rpc.Task rpcTask) {
    return task.copyWith(
      state: TaskState.created,
      round: 0,
      attempt: rpcTask.attempt,
      context: Value(null),
    );
  }

  Future<void> _syncTaskUnsafe(Uuid did, Uuid tid, rpc.Task rpcTask) async {
    var task = await _taskDao.getTask(did.bytes, tid.bytes);

    late final db.Task? newTask;

    try {
      if (task == null) {
        rpcTask = await _taskSource.fetch(did, tid);
        await createTask(did, rpcTask);
        task = (await _taskDao.getTask(did.bytes, tid.bytes))!;
      }

      if (task.attempt < rpcTask.attempt) {
        task = _restart(task, rpcTask);
      } else if (task.attempt > rpcTask.attempt) {
        newTask = null;
        return;
      }

      switch (rpcTask.state) {
        case rpc.Task_TaskState.CREATED:
          newTask = await _syncCreated(did, task, rpcTask);
          break;
        case rpc.Task_TaskState.FAILED:
          newTask = await _syncFailed(task, rpcTask);
          break;
        case rpc.Task_TaskState.FINISHED:
          newTask = await _syncFinished(did, task, rpcTask);
          break;
        case rpc.Task_TaskState.RUNNING:
          newTask = await _syncRunning(did, task, rpcTask);
          break;
      }
    } on Exception {
      // TODO: some errors need to be reported to the server,
      // sometimes we can rollback (e.g. in case of network errors)
      newTask = task?.copyWith(context: Value(null), state: TaskState.failed);
      rethrow;
    } finally {
      if (newTask != null) {
        await _taskDao.upsertTask(newTask.toCompanion(true));
      }
    }
  }

  Future<void> _syncTask(Uuid did, rpc.Task rpcTask) async {
    final tid = Uuid(rpcTask.id);
    await _taskLocks[did][tid].synchronized(
      () => _syncTaskUnsafe(did, tid, rpcTask),
    );
    // FIXME: when to remove task lock?
  }

  Future<void> sync(Uuid did) async {
    final rpcTasks = await _taskSource.fetchAll(did);
    await Future.wait(
      rpcTasks.where((t) => t.type == _taskType).map((t) => _syncTask(did, t)),
    );
  }

  Future<void> subscribe(
    Uuid did, {
    void Function(Object, StackTrace)? onError,
    void Function()? onDone,
  }) async {
    if (_subscriptions.containsKey(did)) return;

    final stream = _taskSource.subscribe(did);

    _subscriptions[did] = stream.listen(
      (rpcTask) async {
        if (rpcTask.type != _taskType) return;
        await _syncTask(did, rpcTask);
      },
      onDone: () {
        _subscriptions.remove(did);
        if (onDone != null) onDone();
      },
      onError: onError,
    );

    await stream.headers;
  }

  Future<void> unsubscribe(Uuid did) async =>
      _subscriptions.remove(did)?.cancel();

  Future<void> _approveTaskUnsafe(Uuid did, Uuid tid, bool agree) async {
    final task = await _taskDao.getTask(did.bytes, tid.bytes);
    if (task == null) throw StateException();
    if (task.approved) return;

    await _taskSource.approve(did, tid, agree: agree);
    await _taskDao.upsertTask(task.copyWith(approved: true).toCompanion(true));
  }

  Future<void> approveTask(Uuid did, Uuid tid, {required bool agree}) =>
      _taskLocks[did][tid].synchronized(
        () => _approveTaskUnsafe(did, tid, agree),
      );

  Stream<List<Task<T>>> observeTasks(Uuid did);

  Stream<List<T>> observeResults(Uuid did) =>
      observeTasks(did).map((tasks) => tasks
          .where((task) => task.state == TaskState.finished)
          .map((task) => task.info)
          .toList());

  // TODO: provide finer control? expose just list of task ids?
}
