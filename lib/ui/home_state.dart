import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/file_repository.dart';
import '../data/group_repository.dart';
import '../data/pref_repository.dart';
import '../model/device.dart';
import '../model/group.dart';
import '../model/file.dart';
import '../model/task.dart';

export '../model/device.dart';
export '../model/group.dart';
export '../model/file.dart';
export '../model/task.dart';

class HomeState with ChangeNotifier {
  static const maxFileSize = FileRepository.maxFileSize;

  // TODO: migrate from ChangeNotifier to streams

  List<Group> groups = [];
  List<File> files = [];

  Device? device;

  final GroupRepository _groupRepository;
  final FileRepository _fileRepository;

  Stream<int> nGroupReqs = const Stream.empty();
  Stream<int> nSignReqs = const Stream.empty();

  List<Task<GroupBase>> groupTasks = [];
  List<Task<File>> signTasks = [];

  HomeState(
    PrefRepository prefRepository,
    this._groupRepository,
    this._fileRepository,
  ) {
    prefRepository.getDevice().then((value) {
      device = value;
      if (value != null) _listen(value);
    });
  }

  void _listen(Device device) {
    final groupTasksStream = _groupRepository.observeTasks(device.id);
    final signTasksStream = _fileRepository.observeTasks(device.id);

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
      _groupRepository.group(name, members, threshold);

  Future<void> sign(String path, Group group) =>
      _fileRepository.sign(path, group);

  Future<void> joinGroup(Task<GroupBase> task, {required bool agree}) =>
      _groupRepository.approveTask(device!.id, task.id, agree: agree);
  Future<void> joinSign(Task<File> task, {required bool agree}) =>
      _fileRepository.approveTask(device!.id, task.id, agree: agree);
}
