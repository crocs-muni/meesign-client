import 'dart:collection';
import 'dart:typed_data';

import 'package:meesign_native/meesign_native.dart';
import 'package:meta/meta.dart';
import 'package:meesign_network/grpc.dart' as rpc;
import 'package:rxdart/subjects.dart';

import '../model/task.dart';
import '../util/default_map.dart';
import '../util/uuid.dart';

class StateException implements Exception {}

// TODO: create DeviceTaskRepository to simplify did handling?
abstract class TaskRepository<T> {
  final rpc.MPCClient _rpcClient;

  final DefaultMap<Uuid, Map<Uuid, Task<T>>> _tasks =
      DefaultMap(HashMap(), () => HashMap());
  final DefaultMap<Uuid, BehaviorSubject<List<Task<T>>>> _tasksSubjects =
      DefaultMap(HashMap(), () => BehaviorSubject.seeded([]));

  TaskRepository(this._rpcClient);

  // TODO: move this, approve, ack to TaskRemoteSource?
  // TODO: TaskRemoteSource could also be used to cache tasks,
  // as the server does not atm support fetching just a specific type of tasks
  Future<rpc.Resp> _sendUpdate(Uuid did, Uuid tid, List<int> data) =>
      _rpcClient.updateTask(
        rpc.TaskUpdate(
          deviceId: did.bytes,
          task: tid.bytes,
          data: data,
        ),
      );

  Future<void> _approve(Uuid did, Uuid tid, {required bool agree}) =>
      _sendUpdate(
          did, tid, rpc.TaskAgreement(agreement: agree).writeToBuffer());

  Future<void> _acknowledge(Uuid did, Uuid tid) =>
      _sendUpdate(did, tid, rpc.TaskAcknowledgement().writeToBuffer());

  @visibleForOverriding
  Future<Task<T>> createTask(Uuid did, rpc.Task rpcTask);
  @visibleForOverriding
  Future<void> finishTask(Uuid did, Task<T> task, rpc.Task rpcTask);

  @protected
  void registerTask(Uuid did, Task<T> task) {
    _tasks[did][task.id] = task;
    _emit(did);
  }

  // TODO: better way to compare states?

  Future<Task<T>?> _syncCreated(
      Uuid did, Task<T>? task, rpc.Task rpcTask) async {
    assert(rpcTask.round == 0);
    if (task != null) return null; // nothing to do
    return await createTask(did, rpcTask);
  }

  Future<Task<T>?> _syncFailed(Task<T>? task, rpc.Task rpcTask) async {
    return task?.copyWith(context: Uint8List(0), state: TaskState.failed);
  }

  Future<Task<T>?> _syncFinished(
      Uuid did, Task<T>? task, rpc.Task rpcTask) async {
    if (task == null) throw StateException();
    if (task.state != TaskState.running) throw StateException();

    // FIXME: how to rollback if one of these fails?
    await finishTask(did, task, rpcTask);
    await _acknowledge(did, task.id);

    return task.copyWith(context: Uint8List(0), state: TaskState.finished);
  }

  Future<Task<T>?> _syncRunning(
      Uuid did, Task<T>? task, rpc.Task rpcTask) async {
    if (task == null) throw StateException();
    if (task.state != TaskState.created && task.state != TaskState.running) {
      throw StateException();
    }
    if (!task.approved) return null;
    if (task.round >= rpcTask.round) return null; // nothing to do
    if (task.round != rpcTask.round - 1) throw StateException();

    final res = await ProtocolWrapper.advance(
      task.context,
      rpcTask.data as Uint8List,
    );
    // TODO: rollback if we fail to deliver the update
    await _sendUpdate(did, task.id, res.data);

    return task.copyWith(
      state: TaskState.running,
      round: task.round + 1,
      context: res.context,
    );
  }

  Future<void> _syncTask(Uuid did, rpc.Task rpcTask) async {
    final tid = Uuid(rpcTask.id);
    final task = _tasks[did][tid];

    late final Task<T>? newTask;

    try {
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
      // FIXME: create new failed task when task = null?
      newTask = task?.copyWith(context: Uint8List(0), state: TaskState.failed);
      rethrow;
    } finally {
      if (newTask != null) {
        _tasks[did][tid] = newTask;
      }
    }
  }

  void _emit(Uuid did) {
    // TODO: transform tasks to public model
    _tasksSubjects[did].add(_tasks[did].values.toList(growable: false));
  }

  @visibleForOverriding
  bool isSyncable(rpc.Task rpcTask);

  Future<void> sync(Uuid did) async {
    final rpcTasks = await _rpcClient.getTasks(
      rpc.TasksRequest(deviceId: did.bytes),
    );

    // TODO: lock the repository while sync in progress?

    await Future.wait(
      rpcTasks.tasks.where(isSyncable).map((t) => _syncTask(did, t)),
    );
    _emit(did);
  }

  Future<void> approveTask(Uuid did, Uuid tid, {required bool agree}) async {
    final task = _tasks[did][tid];
    if (task == null) throw StateException();
    if (task.approved) return;

    await _approve(did, tid, agree: agree);
    _tasks[did][tid] = task.copyWith(approved: true);
    _emit(did);
  }

  Stream<List<Task<T>>> observeTasks(Uuid did) => _tasksSubjects[did].stream;

  // TODO: provide finer control? expose just list of task ids?
}
