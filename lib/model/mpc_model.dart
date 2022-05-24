import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';

import '../file_storage.dart';
import '../grpc/generated/mpc.pbgrpc.dart' as rpc;
import '../util/uuid.dart';
import 'cosigner.dart';
import 'group.dart';
import 'signed_file.dart';
import 'tasks.dart';

export 'cosigner.dart';
export 'group.dart';
export 'signed_file.dart';

class MpcModel with ChangeNotifier {
  // FIXME: make these private
  final List<Group> groups = [];
  final List<SignedFile> files = [];

  late ClientChannel _channel;
  late rpc.MPCClient _client;
  late Cosigner thisDevice;

  Timer? _pollTimer;

  final StreamController<GroupTask> _groupReqsController = StreamController();
  Stream<GroupTask> get groupRequests => _groupReqsController.stream;

  final StreamController<SignTask> _signReqsController = StreamController();
  Stream<SignTask> get signRequests => _signReqsController.stream;

  final _fileStorage = FileStorage();

  final Map<Uuid, MpcTask> _tasks = HashMap();

  Future<void> register(String name, String host) async {
    _channel = ClientChannel(
      host,
      port: 1337,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );

    _client = rpc.MPCClient(_channel);

    thisDevice = Cosigner.random(name, CosignerType.app);

    final resp = await _client.register(
      rpc.RegistrationRequest(identifier: thisDevice.id, name: name),
    );
    if (resp.hasFailure()) throw Exception(resp.failure);

    _startPoll();
  }

  Future<List<Cosigner>> searchForPeers(String query) async {
    final res = (await getRegistered())
        .where((cosigner) =>
            cosigner.name.startsWith(query) ||
            cosigner.name.split(' ').any(
                  (word) => word.startsWith(query),
                ))
        .toList();
    res.sort((a, b) => a.name.compareTo(b.name));
    return res;
  }

  Future<Iterable<Cosigner>> getRegistered() async {
    final devices = await _client.getDevices(rpc.DevicesRequest());
    return devices.devices.map(
        (device) => Cosigner(device.name, device.identifier, CosignerType.app));
  }

  Future<void> addGroup(
      String name, List<Cosigner> members, int threshold) async {
    final rpcTask = await _client.group(rpc.GroupRequest(
      deviceIds: members.map((m) => m.id),
      name: name,
      threshold: threshold,
    ));

    // FIXME: maybe the group should be added right when the user requests it?
    // FIXME: repeptition
    final uuid = Uuid(rpcTask.id);
    final group = Group(name, members, threshold);
    final task = GroupTask(uuid, group);
    groups.add(group);
    _tasks[uuid] = task;

    approveTask(task, agree: true);
    notifyListeners();
  }

  Future<void> sign(String path, Group group) async {
    final file = SignedFile(path, group);

    if (Platform.isWindows || Platform.isLinux) {
      String newPath = await _fileStorage.getTmpFilePath(file.basename);
      await File(path).copy(newPath);
      file.path = newPath;
    }

    // FIXME: oom for large files
    final bytes = await File(file.path).readAsBytes();

    final rpcTask = await _client.sign(
      rpc.SignRequest(
        groupId: group.id,
        name: file.basename,
        data: bytes,
      ),
    );

    // FIXME: so much repetition
    final uuid = Uuid(rpcTask.id);
    final task = SignTask(uuid, file);
    files.add(file);
    _tasks[uuid] = task;

    approveTask(task, agree: true);
    notifyListeners();
  }

  Future<void> approveTask(MpcTask task, {required bool agree}) async {
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
          final members = req.deviceIds
              .map(
                // TODO: fetch names from server
                (id) => Cosigner('unknown', id, CosignerType.app),
              )
              .toList();
          final group = Group(req.name, members, req.threshold);
          task = GroupTask(uuid, group);
          groups.add(group);
          break;
        }
      case rpc.Task_TaskType.SIGN:
        {
          final req = rpc.SignRequest.fromBuffer(rpcTask.data);

          // TODO: who should be responsible for saving files?
          String path = await _fileStorage.getTmpFilePath(req.name);
          await File(path).writeAsBytes(rpcTask.data, flush: true);

          // FIXME: groups should probably be hashed by their id
          final group = groups.firstWhere((g) => listEquals(g.id, req.groupId));
          final file = SignedFile(path, group);
          task = SignTask(uuid, file);
          files.add(file);
        }
    }

    _tasks[uuid] = task;
    if (task is GroupTask) _groupReqsController.add(task);
    if (task is SignTask) _signReqsController.add(task);
    notifyListeners();
    return task;
  }

  Future<void> _updateTask(MpcTask task, rpc.Task rpcTask) async {
    // TODO: check status for errors
    final update = await task.update(rpcTask.round, rpcTask.data);
    if (update == null) return;
    await _sendUpdate(task, update);
  }

  Future<void> _finishTask(MpcTask task, rpc.Task rpcTask) async {
    await task.finish(rpcTask.data);

    if (task is SignTask) {
      await File(task.file.path).writeAsBytes(rpcTask.data, flush: true);
    }

    final update = rpc.TaskAcknowledgement();
    await _sendUpdate(task, update.writeToBuffer());

    notifyListeners();
  }

  Future<rpc.Resp> _sendUpdate(MpcTask task, List<int> data) async =>
      _client.updateTask(rpc.TaskUpdate(
        deviceId: thisDevice.id,
        task: task.id.bytes,
        data: data,
      ));

  Future<void> _processTasks(rpc.Tasks rpcTasks) async {
    for (final rpcTask in rpcTasks.tasks) {
      final uuid = Uuid(rpcTask.id);
      final task = _tasks[uuid];

      // FIXME: also consider the state
      // TODO: maybe add some kind of task pool to move the code out of model?
      if (task == null) {
        _handleNewTask(rpcTask);
      } else {
        if (rpcTask.state == rpc.Task_TaskState.FINISHED) {
          _finishTask(task, rpcTask);
        } else {
          _updateTask(task, rpcTask);
        }
      }
    }
  }

  void _startPoll() {
    if (_pollTimer != null) return;
    _pollTimer = Timer.periodic(const Duration(seconds: 1), _poll);
  }

  void _stopPoll() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _poll(Timer timer) async {
    final rpcTasks = await _client.getTasks(
      rpc.TasksRequest(deviceId: thisDevice.id),
    );
    await _processTasks(rpcTasks);
  }
}
