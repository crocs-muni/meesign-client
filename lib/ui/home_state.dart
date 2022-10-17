import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meesign_core/meesign_data.dart';

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
    this._groupRepository,
    this._fileRepository,
    this._challengeRepository,
  ) {
    prefRepository.getDevice().then((value) {
      device = value;
      if (value != null) _listen(value);
    });
  }

  void _listen(Device device) {
    final groupTasksStream = _groupRepository.observeTasks(device.id);
    final signTasksStream = _fileRepository.observeTasks(device.id);
    final loginTasksStream = _challengeRepository.observeTasks(device.id);

    int pending(List<Task<dynamic>> tasks) =>
        tasks.where((task) => task.approvable).length;
    nGroupReqs = groupTasksStream.map(pending);
    nSignReqs = signTasksStream.map(pending);
    nLoginReqs = loginTasksStream.map(pending);

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

    _groupRepository.observeGroups(device.id).listen((groups) {
      this.groups = groups;
      notifyListeners();
    });
    _fileRepository.observeFiles(device.id).listen((files) {
      this.files = files;
      notifyListeners();
    });
  }

  Future<void> addGroup(String name, List<Device> members, int threshold) =>
      _groupRepository.group(name, members, threshold, Protocol.gg18);

  Future<void> sign(String path, Group group) =>
      _fileRepository.sign(path, group.id);

  Future<void> joinGroup(Task<GroupBase> task, {required bool agree}) =>
      _groupRepository.approveTask(device!.id, task.id, agree: agree);
  Future<void> joinSign(Task<File> task, {required bool agree}) =>
      _fileRepository.approveTask(device!.id, task.id, agree: agree);
  Future<void> joinLogin(Task<Challenge> task, {required bool agree}) =>
      _challengeRepository.approveTask(device!.id, task.id, agree: agree);
}
