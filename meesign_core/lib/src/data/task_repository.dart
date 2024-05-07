import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:convert/convert.dart';
import 'package:drift/drift.dart';
import 'package:meesign_core/src/database/daos.dart';
import 'package:meesign_native/meesign_native.dart';
import 'package:meesign_network/meesign_network.dart'
    show BcastRespStream, BcastRespStreamExt, GrpcError;
import 'package:meesign_network/grpc.dart' as rpc;
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

import '../card/apdu.dart';
import '../card/card.dart';
import '../card/iso7816.dart';
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
          Uuid did, Uint8List tid, List<List<int>> data, int attempt) =>
      _dispatcher[did].updateTask(
        rpc.TaskUpdate(data: data)
          ..task = tid
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

  @protected
  final DefaultMap<Uuid, DefaultMap<Uuid, Lock>> taskLocks =
      DefaultMap(HashMap(), () => DefaultMap(HashMap(), () => Lock()));

  final Map<Uuid, StreamSubscription<rpc.Task>> _subscriptions = HashMap();

  TaskRepository(this._taskType, this._taskSource, this._taskDao);

  Future<db.Group> _getAssociatedGroup(Uuid did, db.Task task) {
    // FIXME: unify group references
    return task.gid != null
        ? _taskDao.getGroup(did.bytes, gid: task.gid)
        // applies for unfinished group tasks
        : _taskDao.getGroup(did.bytes, tid: task.id);
  }

  @visibleForOverriding
  Future<void> createTask(Uuid did, rpc.Task rpcTask);
  @visibleForOverriding
  Future<db.Task> initTask(Uuid did, db.Task task, rpc.Task rpcTask);
  @visibleForOverriding
  Future<void> finishTask(Uuid did, db.Task task, rpc.Task rpcTask);

  // TODO: better way to compare states?

  Future<db.Task> _syncCreated(Uuid did, db.Task task, rpc.Task rpcTask) async {
    return task;
  }

  Future<db.Task> _syncFailed(Uuid did, db.Task task, rpc.Task rpcTask) async {
    final group = await _getAssociatedGroup(did, task);
    final members = await _taskDao.getGroupMembers(group.tid);
    final shareCount = members.map((m) => m.shares).sum;

    TaskError? error;
    if (rpcTask.reject > shareCount - group.threshold) {
      error = TaskError.rejected;
    }

    return task.copyWith(
      context: Value(null),
      state: TaskState.failed,
      error: Value(error),
    );
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

    bool activeParticipant = task.context != null || rpcTask.data.isNotEmpty;
    if (!activeParticipant) {
      return task.copyWith(
        state: TaskState.running,
        round: rpcTask.round,
      );
    }

    if (!task.approved) throw StateException();
    if (rpcTask.data.isEmpty) return task; // nothing to do
    if (rpcTask.round <= task.round) return task;
    if (rpcTask.round != task.round + 1) throw StateException();

    if (task.round == 0) task = await initTask(did, task, rpcTask);
    final res = await ProtocolWrapper.advance(
      task.context!,
      rpcTask.data,
    );
    // TODO: rollback if we fail to deliver the update
    bool forCard = res.recipient == Recipient.Card;
    if (forCard) {
      if (res.data.length == 1) throw StateException();
    } else {
      try {
        await _taskSource.update(did, task.id, res.data, task.attempt);
      } on GrpcError catch (e) {
        // FIXME: avoid matching error strings
        if (e.message == 'Stale update') return task;
        rethrow;
      }
    }

    return task.copyWith(
      state: forCard ? TaskState.needsCard : TaskState.running,
      round: task.round + 1,
      context: Value(res.context),
      data: Value(forCard ? res.data.first : null),
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
          newTask = await _syncFailed(did, task, rpcTask);
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
    await taskLocks[did][tid].synchronized(
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

  @protected
  Future<void> approveTaskUnsafe(Uuid did, Uuid tid, bool agree) async {
    final task = await _taskDao.getTask(did.bytes, tid.bytes);
    if (task == null) throw StateException();
    if (task.approved) return;

    await _taskSource.approve(did, tid, agree: agree);
    await _taskDao.upsertTask(task.copyWith(approved: true).toCompanion(true));
  }

  Future<void> approveTask(Uuid did, Uuid tid, {required bool agree}) =>
      taskLocks[did][tid].synchronized(
        () => approveTaskUnsafe(did, tid, agree),
      );

  Future<void> archiveTask(Uuid did, Uuid tid, {required bool archive}) =>
      taskLocks[did][tid].synchronized(
        () => _taskDao.updateTask(db.TasksCompanion(
          id: Value(tid.bytes),
          did: Value(did.bytes),
          archived: Value(archive),
        )),
      );

  Stream<List<Task<T>>> observeTasks(Uuid did);

  Stream<List<T>> observeResults(Uuid did) =>
      observeTasks(did).map((tasks) => tasks
          .where((task) => task.state == TaskState.finished)
          .map((task) => task.info)
          .toList());

  // TODO: provide finer control? expose just list of task ids?

  Future<void> _advanceTaskWithCardUnsafe(Uuid did, Uuid tid, Card card) async {
    final task = await _taskDao.getTask(did.bytes, tid.bytes);
    if (task == null || task.state != TaskState.needsCard) {
      throw StateException();
    }
    final group = await _getAssociatedGroup(did, task);

    final aid = hex.decode(group.protocol.aid!);
    final resp = await card.send(CommandApdu(
      Iso7816.claIso7816,
      Iso7816.insSelect,
      p1: 0x04,
      data: aid,
    ));
    if (resp.status != Iso7816.swNoError) throw SelectException();

    try {
      Uint8List context = task.context!, data = task.data!;
      int recipient;
      do {
        final resp = await card.transceive(data);
        final res = await ProtocolWrapper.advance(context, [resp]);
        // TODO: save intermediate res to db?
        context = res.context;
        data = res.data.first;
        recipient = res.recipient;
      } while (recipient != Recipient.Server);

      await _taskSource.update(did, task.id, [data], task.attempt);

      final newTask = task.copyWith(
        state: TaskState.running,
        context: Value(context),
        data: Value(null),
      );
      await _taskDao.upsertTask(newTask.toCompanion(true));
    } on Exception {
      final newTask = task.copyWith(
        state: TaskState.failed,
        context: Value(null),
        data: Value(null),
      );
      await _taskDao.upsertTask(newTask.toCompanion(true));
      rethrow;
    }
  }

  Future<void> advanceTaskWithCard(Uuid did, Uuid tid, Card card) =>
      taskLocks[did][tid].synchronized(
        () => _advanceTaskWithCardUnsafe(did, tid, card),
      );
}
