import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:meesign_core/meesign_card.dart';
import 'package:meesign_core/meesign_data.dart';
import 'package:rxdart/rxdart.dart';

import '../services/settings_controller.dart';
import '../util/extensions/task_approvable.dart';

class AppViewModel with ChangeNotifier {
  static const maxDataSize = FileRepository.maxFileSize;

  // TODO: migrate from ChangeNotifier to streams

  Device? device;

  final GroupRepository _groupRepository;
  final FileRepository _fileRepository;
  final ChallengeRepository _challengeRepository;
  final DecryptRepository _decryptRepository;
  final SettingsController _settingsController;

  Stream<int> nGroupReqs = const Stream.empty();
  Stream<int> nSignReqs = const Stream.empty();
  Stream<int> nChallengeReqs = const Stream.empty();
  Stream<int> nDecryptReqs = const Stream.empty();

  List<Task<Group>> groupTasks = [];
  List<Task<File>> signTasks = [];
  List<Task<Challenge>> challengeTasks = [];
  List<Task<Decrypt>> decryptTasks = [];

  bool _showArchived = false;
  bool get showArchived => _showArchived;

  AppViewModel(
    User user,
    DeviceRepository deviceRepository,
    this._groupRepository,
    this._fileRepository,
    this._challengeRepository,
    this._decryptRepository,
    this._settingsController,
  ) {
    _listen(user.did);
    deviceRepository.getDevice(user.did).then((value) {
      device = value;
      notifyListeners();
    });
  }

  void _listen(Uuid did) {
    final groupTasksStream = _groupRepository.observeTasks(did);
    final signTasksStream = _fileRepository.observeTasks(did);
    final challengeTasksStream = _challengeRepository.observeTasks(did);
    final decryptTasksStream = _decryptRepository.observeTasks(did);

    int pending(List<Task<dynamic>> tasks) => tasks
        .where((task) =>
            (task.approvable || task.state == TaskState.needsCard) &&
            !task.archived)
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

    _settingsController.settingsStream.listen((settings) {
      _showArchived = settings.showArchivedItems;
      notifyListeners();
    });
  }

  bool hasGroup(KeyType type, {bool? inclArchived}) => groupTasks.any((task) =>
      task.info.keyType == type &&
      task.state == TaskState.finished &&
      (!task.archived || (inclArchived ?? _showArchived)));

  Future<void> addGroup(String name, List<Member> members, int threshold,
          Protocol protocol, KeyType keyType, String? note) =>
      _groupRepository.group(name, members, threshold, protocol, keyType,
          note: note);

  Future<void> sign(XFile file, Group group) async {
    await _fileRepository.sign(file.name, await file.readAsBytes(), group.id);
  }

  Future<void> challenge(String name, Uint8List data, Group group) =>
      _challengeRepository.sign(name, data, group.id);

  Future<void> encrypt(
          String description, MimeType mimeType, Uint8List data, Group group) =>
      _decryptRepository.encrypt(description, mimeType, data, group.id);

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

  TaskRepository<T> _selectRepository<T>() {
    return switch (T) {
      const (Group) => _groupRepository,
      const (File) => _fileRepository,
      const (Challenge) => _challengeRepository,
      const (Decrypt) => _decryptRepository,
      _ => throw TypeError(),
    } as TaskRepository<T>;
  }

  Future<void> archiveTask<T>(Task<T> task, {required bool archive}) async {
    _selectRepository<T>().archiveTask(device!.id, task.id, archive: archive);
  }
}
