import 'dart:collection';
import 'dart:typed_data';

import 'package:meesign_native/meesign_native.dart';
import 'package:meta/meta.dart';
import 'package:meesign_network/grpc.dart' as rpc;
import 'package:rxdart/subjects.dart';
import 'package:synchronized/synchronized.dart';

import '../model/task.dart';
import '../util/default_map.dart';
import '../util/uuid.dart';

class StateException implements Exception {}

class TaskSource {
  final rpc.MPCClient _rpcClient;

  TaskSource(this._rpcClient);

  Future<rpc.Resp> update(Uuid did, Uuid tid, List<int> data) =>
      _rpcClient.updateTask(rpc.TaskUpdate(
        deviceId: did.bytes,
        task: tid.bytes,
        data: data,
      ));

  Future<void> approve(Uuid did, Uuid tid, {required bool agree}) =>
      _rpcClient.decideTask(rpc.TaskDecision(
        task: tid.bytes,
        device: did.bytes,
        accept: agree,
      ));

  Future<void> acknowledge(Uuid did, Uuid tid) =>
      _rpcClient.acknowledgeTask(rpc.TaskAcknowledgement(
        taskId: tid.bytes,
        deviceId: did.bytes,
      ));

  /// retrieve the task including all its details
  Future<rpc.Task> fetch(Uuid did, Uuid tid) =>
      _rpcClient.getTask(rpc.TaskRequest(
        deviceId: did.bytes,
        taskId: tid.bytes,
      ));

  Future<List<rpc.Task>> fetchAll(Uuid did) async {
    final rpcTasks = await _rpcClient.getTasks(
      rpc.TasksRequest(deviceId: did.bytes),
    );
    return rpcTasks.tasks;
  }
}

// TODO: create DeviceTaskRepository to simplify did handling?
abstract class TaskRepository<T> {
  final TaskSource _taskSource;

  final DefaultMap<Uuid, Map<Uuid, Task<T>>> _tasks =
      DefaultMap(HashMap(), () => HashMap());
  final DefaultMap<Uuid, BehaviorSubject<List<Task<T>>>> _tasksSubjects =
      DefaultMap(HashMap(), () => BehaviorSubject.seeded([]));
  final DefaultMap<Uuid, DefaultMap<Uuid, Lock>> _taskLocks =
      DefaultMap(HashMap(), () => DefaultMap(HashMap(), () => Lock()));

  TaskRepository(this._taskSource);

  @visibleForOverriding
  Future<Task<T>> createTask(Uuid did, rpc.Task rpcTask);
  @visibleForOverriding
  Task<T> initTask(Task<T> task);
  @visibleForOverriding
  Future<void> finishTask(Uuid did, Task<T> task, rpc.Task rpcTask);

  // TODO: better way to compare states?

  Future<Task<T>> _syncCreated(Uuid did, Task<T> task, rpc.Task rpcTask) async {
    if (task.state != TaskState.created) throw StateException();
    return task;
  }

  Future<Task<T>> _syncFailed(Task<T> task, rpc.Task rpcTask) async {
    return task.copyWith(context: Uint8List(0), state: TaskState.failed);
  }

  Future<Task<T>> _syncFinished(
      Uuid did, Task<T> task, rpc.Task rpcTask) async {
    if (task.state == TaskState.failed) throw StateException();
    if (task.state == TaskState.finished) return task;

    // FIXME: how to rollback if one of these fails?
    await finishTask(did, task, rpcTask);
    await _taskSource.acknowledge(did, task.id);

    return task.copyWith(context: Uint8List(0), state: TaskState.finished);
  }

  Future<Task<T>> _syncRunning(Uuid did, Task<T> task, rpc.Task rpcTask) async {
    if (task.state != TaskState.created && task.state != TaskState.running) {
      throw StateException();
    }

    bool activeParticipant = task.context.isNotEmpty || rpcTask.hasData();
    if (!activeParticipant) {
      return task.copyWith(
        state: TaskState.running,
        round: rpcTask.round,
      );
    }

    if (!task.approved) throw StateException();
    if (!rpcTask.hasData()) return task; // nothing to do
    if (task.round != rpcTask.round - 1) throw StateException();

    if (task.round == 0) task = initTask(task);
    final res = await ProtocolWrapper.advance(
      task.context,
      rpcTask.data as Uint8List,
    );
    // TODO: rollback if we fail to deliver the update
    await _taskSource.update(did, task.id, res.data);

    return task.copyWith(
      state: TaskState.running,
      round: task.round + 1,
      context: res.context,
    );
  }

  Future<void> _syncTaskUnsafe(Uuid did, Uuid tid, rpc.Task rpcTask) async {
    var task = _tasks[did][tid];

    late final Task<T>? newTask;

    try {
      if (task == null) {
        rpcTask = await _taskSource.fetch(did, tid);
        task = await createTask(did, rpcTask);
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
      newTask = task?.copyWith(context: Uint8List(0), state: TaskState.failed);
      rethrow;
    } finally {
      if (newTask != null) {
        _tasks[did][tid] = newTask;
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

  void _emit(Uuid did) {
    // TODO: transform tasks to public model
    _tasksSubjects[did].add(_tasks[did].values.toList(growable: false));
  }

  @visibleForOverriding
  bool isSyncable(rpc.Task rpcTask);

  Future<void> sync(Uuid did) async {
    final rpcTasks = await _taskSource.fetchAll(did);
    try {
      await Future.wait(
        rpcTasks.where(isSyncable).map((t) => _syncTask(did, t)),
      );
    } finally {
      _emit(did);
    }
  }

  Future<void> _approveTaskUnsafe(Uuid did, Uuid tid, bool agree) async {
    final task = _tasks[did][tid];
    if (task == null) throw StateException();
    if (task.approved) return;

    await _taskSource.approve(did, tid, agree: agree);
    _tasks[did][tid] = task.copyWith(approved: true);
    _emit(did);
  }

  Future<void> approveTask(Uuid did, Uuid tid, {required bool agree}) =>
      _taskLocks[did][tid].synchronized(
        () => _approveTaskUnsafe(did, tid, agree),
      );

  Stream<List<Task<T>>> observeTasks(Uuid did) => _tasksSubjects[did].stream;

  // TODO: provide finer control? expose just list of task ids?
}
