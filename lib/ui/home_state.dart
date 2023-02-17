import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meesign_core/meesign_data.dart';
import 'package:rxdart/rxdart.dart';

extension TaskDetails on Task {
  bool get approvable =>
      !approved && (state == TaskState.created || state == TaskState.running);
}

class HomeState with ChangeNotifier {
  static const maxFileSize = FileRepository.maxFileSize;

  // TODO: migrate from ChangeNotifier to streams

  List<Group> groups = [];
  List<File> files = [];

  Device? device;

  final GroupRepository _groupRepository;
  final FileRepository _fileRepository;
  final ChallengeRepository _challengeRepository;

  Stream<int> nGroupReqs = const Stream.empty();
  Stream<int> nSignReqs = const Stream.empty();
  Stream<int> nLoginReqs = const Stream.empty();

  List<Task<GroupBase>> groupTasks = [];
  List<Task<File>> signTasks = [];
  List<Task<Challenge>> loginTasks = [];

  HomeState(
    PrefRepository prefRepository,
    DeviceRepository deviceRepository,
    this._groupRepository,
    this._fileRepository,
    this._challengeRepository,
  ) {
    prefRepository.getDid().then((did) async {
      if (did == null) return;
      _listen(did);
      device = await deviceRepository.findDeviceById(did);
    });
  }

  void _listen(Uuid did) {
    final groupTasksStream = _groupRepository.observeTasks(did);
    final signTasksStream = _fileRepository.observeTasks(did);
    final loginTasksStream = _challengeRepository.observeTasks(did);

    int pending(List<Task<dynamic>> tasks) =>
        tasks.where((task) => task.approvable).length;
    nGroupReqs = groupTasksStream.map(pending).shareValue();
    nSignReqs = signTasksStream.map(pending).shareValue();
    nLoginReqs = loginTasksStream.map(pending).shareValue();
    notifyListeners();

    groupTasksStream.listen((tasks) {
      groupTasks = tasks;
      notifyListeners();
    });
    signTasksStream.listen((tasks) {
      signTasks = tasks;
      notifyListeners();
    });
    loginTasksStream.listen((tasks) {
      loginTasks = tasks;
      notifyListeners();
    });

    // FIXME: there is no link between tasks and their results (groups, files)
    // this can lead to inconsistencies in the ui when one stream gets updated
    // and the other one does not

    _groupRepository.observeGroups(did).listen((groups) {
      this.groups = groups;
      notifyListeners();
    });
    _fileRepository.observeFiles(did).listen((files) {
      this.files = files;
      notifyListeners();
    });
  }

  Future<void> addGroup(String name, List<Device> members, int threshold,
          Protocol protocol, KeyType keyType) =>
      _groupRepository.group(name, members, threshold, protocol, keyType);

  Future<void> sign(String path, Group group) =>
      _fileRepository.sign(path, group.id);

  Future<void> joinGroup(Task<GroupBase> task, {required bool agree}) =>
      _groupRepository.approveTask(device!.id, task.id, agree: agree);
  Future<void> joinSign(Task<File> task, {required bool agree}) =>
      _fileRepository.approveTask(device!.id, task.id, agree: agree);
  Future<void> joinLogin(Task<Challenge> task, {required bool agree}) =>
      _challengeRepository.approveTask(device!.id, task.id, agree: agree);
}
