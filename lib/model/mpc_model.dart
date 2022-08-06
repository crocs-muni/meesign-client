import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';

import '../data/file_repository.dart';
import '../data/file_store.dart';
import '../data/group_repository.dart';
import '../data/device_repository.dart';
import '../grpc/generated/mpc.pbgrpc.dart' as rpc;
import 'device.dart';
import 'group.dart';
import 'file.dart';
import 'task.dart';

export 'device.dart';
export 'group.dart';
export 'file.dart';
export 'task.dart';

class MpcModel with ChangeNotifier {
  static const maxFileSize = FileRepository.maxFileSize;

  // TODO: migrate from ChangeNotifier to streams

  List<Group> groups = [];
  List<File> files = [];

  late ClientChannel _channel;
  late rpc.MPCClient _client;
  late Device thisDevice;

  late DeviceRepository _deviceRepository;
  late GroupRepository _groupRepository;
  late FileRepository _fileRepository;

  late final Stream<int> nGroupReqs;
  late final Stream<int> nSignReqs;

  List<Task<GroupBase>> groupTasks = [];
  List<Task<File>> signTasks = [];

  final ValueNotifier<int> lastUpdate = ValueNotifier(0);

  void _init(String host) {
    _channel = ClientChannel(
      host,
      port: 1337,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );

    _client = rpc.MPCClient(_channel);
    _deviceRepository = DeviceRepository(_client);
    _groupRepository = GroupRepository(_client, _deviceRepository);
    _fileRepository = FileRepository(_client, FileStore(), _groupRepository);
  }

  Future<void> register(String name, String host) async {
    _init(host);
    thisDevice = await _deviceRepository.register(name);
    _listen();
  }

  void _listen() {
    final groupTasksStream = _groupRepository.observeTasks(thisDevice.id);
    final signTasksStream = _fileRepository.observeTasks(thisDevice.id);

    int unapproved(List<Task<dynamic>> tasks) =>
        tasks.where((task) => task.state == TaskState.created).length;
    nGroupReqs = groupTasksStream.map(unapproved);
    nSignReqs = signTasksStream.map(unapproved);

    groupTasksStream.listen((tasks) {
      groupTasks = tasks;
      notifyListeners();
    });
    signTasksStream.listen((tasks) {
      signTasks = tasks;
      notifyListeners();
    });

    // FIXME: there is no link between tasks and their results (groups, files)
    // this can lead to inconsistencies in the ui when one stream gets updated
    // and the other one does not

    _groupRepository.observeGroups(thisDevice.id).listen((groups) {
      this.groups = groups;
      notifyListeners();
    });
    _fileRepository.observeFiles(thisDevice.id).listen((files) {
      this.files = files;
      notifyListeners();
    });

    _scheduleSync();
  }

  Future<Iterable<Device>> findDeviceByName(String query) =>
      _deviceRepository.findDeviceByName(query);

  Future<void> addGroup(String name, List<Device> members, int threshold) =>
      _groupRepository.group(name, members, threshold);

  Future<void> sign(String path, Group group) =>
      _fileRepository.sign(path, group);

  Future<void> joinGroup(Task<GroupBase> task, {required bool agree}) =>
      _groupRepository.approveTask(thisDevice.id, task.id, agree: agree);
  Future<void> joinSign(Task<File> task, {required bool agree}) =>
      _fileRepository.approveTask(thisDevice.id, task.id, agree: agree);

  Timer _scheduleSync() => Timer(const Duration(seconds: 1), _sync);

  Future<void> _sync() async {
    try {
      await _groupRepository.sync(thisDevice.id);
      await _fileRepository.sync(thisDevice.id);
      lastUpdate.value = 0;
    } catch (e) {
      --lastUpdate.value;
      rethrow;
    } finally {
      _scheduleSync();
    }
  }
}
