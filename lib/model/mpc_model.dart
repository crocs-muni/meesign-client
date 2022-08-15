import 'dart:async';
import 'dart:collection';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';
import 'package:path/path.dart' as path_pkg;

import '../data/file_store.dart';
import '../data/device_repository.dart';
import '../grpc/generated/mpc.pbgrpc.dart' as rpc;
import '../util/uuid.dart';
import 'device.dart';
import 'group.dart';
import 'file.dart';
import 'tasks.dart';

export 'device.dart';
export 'group.dart';
export 'file.dart';

class MpcModel with ChangeNotifier {
  static const maxFileSize = 8 * 1024 * 1024;

  // FIXME: make these private
  final List<Group> groups = [];
  final List<File> files = [];

  late ClientChannel _channel;
  late rpc.MPCClient _client;
  late Device thisDevice;

  late DeviceRepository _deviceRepository;

  final StreamController<GroupTask> _groupReqsController = StreamController();
  Stream<GroupTask> get groupRequests => _groupReqsController.stream;

  final StreamController<SignTask> _signReqsController = StreamController();
  Stream<SignTask> get signRequests => _signReqsController.stream;

  final _fileStore = FileStore();

  final Map<Uuid, MpcTask> _tasks = HashMap();

  // TODO: store the tasks separately to avoid filtering?
  Iterable<GroupTask> get groupTasks => _tasks.values.whereType<GroupTask>();
  Iterable<SignTask> get signTasks => _tasks.values.whereType<SignTask>();

  final ValueNotifier<int> lastUpdate = ValueNotifier(0);

  Future<void> register(String name, String host) async {
    _channel = ClientChannel(
      host,
      port: 1337,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );

    _client = rpc.MPCClient(_channel);
    _deviceRepository = DeviceRepository(_client);

    thisDevice = await _deviceRepository.register(name);

    _schedulePoll();
  }

  Future<Iterable<Device>> findDeviceByName(String query) =>
      _deviceRepository.findDeviceByName(query);

  Future<void> addGroup(
      String name, List<Device> members, int threshold) async {
    final rpcTask = await _client.group(rpc.GroupRequest(
      deviceIds: members.map((m) => m.id.bytes),
      name: name,
      threshold: threshold,
    ));

    // FIXME: maybe the group should be added right when the user requests it?
    // FIXME: repeptition
    final uuid = Uuid(rpcTask.id);
    final group = GroupBase(name, members, threshold);
    final task = GroupTask(uuid, group);
    _tasks[uuid] = task;

    approveTask(task, agree: true);
    notifyListeners();
  }

  Future<void> sign(String path, Group group) async {
    // FIXME: oom for large files
    final bytes = await io.File(path).readAsBytes();
    String basename = path_pkg.basename(path);

    final rpcTask = await _client.sign(
      rpc.SignRequest(
        groupId: group.id,
        name: basename,
        data: bytes,
      ),
    );

    // FIXME: so much repetition
    final uuid = Uuid(rpcTask.id);
    path = await _fileStore.storeFile(Uuid([]), uuid, basename, bytes);
    final file = File(path, group);

    final task = SignTask(uuid, file);
    _tasks[uuid] = task;

    approveTask(task, agree: true);
    notifyListeners();
  }

  Future<rpc.Resp> _sendUpdate(MpcTask task, List<int> data) async {
    try {
      return await _client.updateTask(rpc.TaskUpdate(
        deviceId: thisDevice.id.bytes,
        task: task.id.bytes,
        data: data,
      ));
    } catch (e) {
      task.error();
      rethrow;
    }
  }

  Future<void> approveTask(MpcTask task, {required bool agree}) async {
    task.approve();
    final update = rpc.TaskAgreement(agreement: agree);
    await _sendUpdate(task, update.writeToBuffer());
  }

  Future<MpcTask> _handleNewTask(rpc.Task rpcTask) async {
    assert(rpcTask.state == rpc.Task_TaskState.CREATED);
    assert(rpcTask.round == 0);

    final uuid = Uuid(rpcTask.id);
    late MpcTask task;

    switch (rpcTask.type) {
      case rpc.Task_TaskType.GROUP:
        {
          final req = rpc.GroupRequest.fromBuffer(rpcTask.data);

          final registered = Map<Uuid, Device>.fromIterable(
            await _deviceRepository.getDevices(),
            key: (dev) => dev.id,
          );
          final members =
              req.deviceIds.map((id) => registered[Uuid(id)]!).toList();

          final group = GroupBase(req.name, members, req.threshold);
          task = GroupTask(uuid, group);
          break;
        }
      case rpc.Task_TaskType.SIGN:
        {
          final req = rpc.SignRequest.fromBuffer(rpcTask.data);

          // FIXME: groups should probably be hashed by their id
          final group = groups.firstWhere((g) => listEquals(g.id, req.groupId));
          final path = await _fileStore.storeFile(
              Uuid([]), uuid, req.name, rpcTask.data);
          final file = File(path, group);

          task = SignTask(uuid, file);
        }
    }

    _tasks[uuid] = task;
    if (task is GroupTask) _groupReqsController.add(task);
    if (task is SignTask) _signReqsController.add(task);
    notifyListeners();
    return task;
  }

  Future<void> _updateTask(MpcTask task, rpc.Task rpcTask) async {
    // old data
    if (rpcTask.round <= task.round) return;

    if (rpcTask.state == rpc.Task_TaskState.FAILED) task.error();

    final update = await task.update(rpcTask.round, rpcTask.data);
    if (update == null) return;
    await _sendUpdate(task, update);
  }

  Future<void> _finishTask(MpcTask task, rpc.Task rpcTask) async {
    if (task.status != TaskStatus.working) return;

    if (task is GroupTask) {
      Group group = await task.finish(rpcTask.data);
      groups.add(group);
    } else if (task is SignTask) {
      File file = await task.finish(rpcTask.data);
      files.add(file);
    }

    final update = rpc.TaskAcknowledgement();
    await _sendUpdate(task, update.writeToBuffer());

    notifyListeners();
  }

  Future<void> _processTasks(rpc.Tasks rpcTasks) async {
    for (final rpcTask in rpcTasks.tasks) {
      final uuid = Uuid(rpcTask.id);
      final task = _tasks[uuid];

      // FIXME: also consider the state
      // TODO: maybe add some kind of task pool to move the code out of model?
      if (task == null) {
        try {
          // need to await here to avoid interpreting
          // the same task as new multiple times
          await _handleNewTask(rpcTask);
        } catch (e) {
          print(e);
        }
      } else {
        if (rpcTask.state == rpc.Task_TaskState.FINISHED) {
          _finishTask(task, rpcTask);
        } else {
          _updateTask(task, rpcTask);
        }
      }
    }
  }

  Timer _schedulePoll() => Timer(const Duration(seconds: 1), _poll);

  Future<void> _poll() async {
    try {
      final rpcTasks = await _client.getTasks(
        rpc.TasksRequest(deviceId: thisDevice.id.bytes),
      );
      lastUpdate.value = 0;
      await _processTasks(rpcTasks);
    } catch (e) {
      --lastUpdate.value;
      rethrow;
    } finally {
      _schedulePoll();
    }
  }
}
