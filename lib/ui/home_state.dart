import 'dart:async';
import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:meesign_core/meesign_card.dart';
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

  Device? device;

  final GroupRepository _groupRepository;
  final FileRepository _fileRepository;
  final ChallengeRepository _challengeRepository;
  final DecryptRepository _decryptRepository;

  Stream<int> nGroupReqs = const Stream.empty();
  Stream<int> nSignReqs = const Stream.empty();
  Stream<int> nChallengeReqs = const Stream.empty();
  Stream<int> nDecryptReqs = const Stream.empty();

  List<Task<Group>> groupTasks = [];
  List<Task<File>> signTasks = [];
  List<Task<Challenge>> challengeTasks = [];
  List<Task<Decrypt>> decryptTasks = [];

  HomeState(
    UserRepository userRepository,
    DeviceRepository deviceRepository,
    this._groupRepository,
    this._fileRepository,
    this._challengeRepository,
    this._decryptRepository,
  ) {
    userRepository.getUser().then((user) async {
      if (user == null) return;
      _listen(user.did);
      device = await deviceRepository.getDevice(user.did);
    });
  }

  void _listen(Uuid did) {
    final groupTasksStream = _groupRepository.observeTasks(did);
    final signTasksStream = _fileRepository.observeTasks(did);
    final challengeTasksStream = _challengeRepository.observeTasks(did);
    final decryptTasksStream = _decryptRepository.observeTasks(did);

    int pending(List<Task<dynamic>> tasks) => tasks
        .where((task) => task.approvable || task.state == TaskState.needsCard)
        .length;
    nGroupReqs = groupTasksStream.map(pending).shareValue();
    nSignReqs = signTasksStream.map(pending).shareValue();
    nChallengeReqs = challengeTasksStream.map(pending).shareValue();
    nDecryptReqs = decryptTasksStream.map(pending).shareValue();
    notifyListeners();

    groupTasksStream.listen((tasks) {
      groupTasks = tasks;
      notifyListeners();
    });
    signTasksStream.listen((tasks) {
      signTasks = tasks;
      notifyListeners();
    });
    challengeTasksStream.listen((tasks) {
      challengeTasks = tasks;
      notifyListeners();
    });
    decryptTasksStream.listen((tasks) {
      decryptTasks = tasks;
      notifyListeners();
    });

    // FIXME: there is no link between tasks and their results (groups, files)
    // this can lead to inconsistencies in the ui when one stream gets updated
    // and the other one does not

    _groupRepository.observeGroups(did).listen((groups) {
      this.groups = groups;
      notifyListeners();
    });
  }

  Future<void> addGroup(String name, List<Device> members, int threshold,
          Protocol protocol, KeyType keyType) =>
      _groupRepository.group(name, members, threshold, protocol, keyType);

  Future<void> sign(XFile file, Group group) async {
    await _fileRepository.sign(file.name, await file.readAsBytes(), group.id);
  }

  Future<void> challenge(String name, String message, Group group) =>
      _challengeRepository.sign(name, utf8.encode(message), group.id);

  Future<void> encrypt(String description, String message, Group group) =>
      _decryptRepository.encrypt(
        description,
        MimeType.textUtf8,
        utf8.encode(message),
        group.id,
      );

  Future<void> joinGroup(Task<Group> task,
          {required bool agree, bool withCard = false}) =>
      _groupRepository.approveTask(device!.id, task.id,
          agree: agree, withCard: withCard);
  Future<void> joinSign(Task<File> task, {required bool agree}) =>
      _fileRepository.approveTask(device!.id, task.id, agree: agree);
  Future<void> joinChallenge(Task<Challenge> task, {required bool agree}) =>
      _challengeRepository.approveTask(device!.id, task.id, agree: agree);
  Future<void> joinDecrypt(Task<Decrypt> task, {required bool agree}) =>
      _decryptRepository.approveTask(device!.id, task.id, agree: agree);
  // FIXME: avoid this repetition
  Future<void> advanceGroupWithCard(Task<Group> task, Card card) =>
      _groupRepository.advanceTaskWithCard(device!.id, task.id, card);
  Future<void> advanceChallengeWithCard(Task<Challenge> task, Card card) =>
      _challengeRepository.advanceTaskWithCard(device!.id, task.id, card);
}
