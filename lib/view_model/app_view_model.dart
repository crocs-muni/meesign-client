import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:meesign_core/meesign_card.dart';
import 'package:meesign_core/meesign_data.dart';
import 'package:rxdart/rxdart.dart';

import '../enums/task_type.dart';
import '../services/settings_controller.dart';
import '../util/extensions/task_approvable.dart';

class TaskStream {
  final bool showArchived;
  final List<Task<Decrypt>> decryptTasks;
  final List<Task<File>> signTasks;
  final List<Task<Challenge>> challengeTasks;

  TaskStream({
    required this.showArchived,
    required this.decryptTasks,
    required this.signTasks,
    required this.challengeTasks,
  });
}

class AppViewModel with ChangeNotifier {
  static const maxDataSize = FileRepository.maxFileSize;
  Device? device;

  final List<Task> allTasks = [];

  final GroupRepository _groupRepository;
  final FileRepository _fileRepository;
  final ChallengeRepository _challengeRepository;
  final DecryptRepository _decryptRepository;
  final SettingsController _settingsController;

  late Uuid _userDid;

  Stream<int> nGroupReqs = const Stream.empty();
  Stream<int> nSignReqs = const Stream.empty();
  Stream<int> nChallengeReqs = const Stream.empty();
  Stream<int> nDecryptReqs = const Stream.empty();
  Stream<int> get nAllReqs => Rx.combineLatest3(
        nSignReqs,
        nChallengeReqs,
        nDecryptReqs,
        (int s, int c, int d) => s + c + d,
      ).asBroadcastStream();

  // Show archived items stream
  final BehaviorSubject<bool> _showArchivedController = BehaviorSubject<bool>();
  Stream<bool> get showArchivedStream => _showArchivedController.stream;
  bool get showArchived => _showArchivedController.valueOrNull ?? false;

  // Decrypt tasks stream
  final BehaviorSubject<List<Task<Decrypt>>> _decryptTasksController =
      BehaviorSubject<List<Task<Decrypt>>>();
  Stream<List<Task<Decrypt>>> get decryptTasksStream =>
      _decryptTasksController.stream;
  List<Task<Decrypt>> get decryptTasks =>
      _decryptTasksController.valueOrNull ?? [];

  // Group tasks stream
  final BehaviorSubject<List<Task<Group>>> _groupTasksController =
      BehaviorSubject<List<Task<Group>>>();
  Stream<List<Task<Group>>> get groupTasksStream =>
      _groupTasksController.stream;
  List<Task<Group>> get groupTasks => _groupTasksController.valueOrNull ?? [];

  // Sign tasks stream
  final BehaviorSubject<List<Task<File>>> _signTasksController =
      BehaviorSubject<List<Task<File>>>();
  Stream<List<Task<File>>> get signTasksStream => _signTasksController.stream;
  List<Task<File>> get signTasks => _signTasksController.valueOrNull ?? [];

  // Challenge tasks stream
  final BehaviorSubject<List<Task<Challenge>>> _challengeTasksController =
      BehaviorSubject<List<Task<Challenge>>>();
  Stream<List<Task<Challenge>>> get challengeTasksStream =>
      _challengeTasksController.stream;
  List<Task<Challenge>> get challengeTasks =>
      _challengeTasksController.valueOrNull ?? [];

  // General stream of all tasks + the show archived items setting
  Stream<TaskStream> get combinedTaskStream => Rx.combineLatest5<
          bool,
          List<Task<Decrypt>>,
          List<Task<Group>>,
          List<Task<File>>,
          List<Task<Challenge>>,
          TaskStream>(
        showArchivedStream,
        decryptTasksStream,
        groupTasksStream,
        signTasksStream,
        challengeTasksStream,
        (showArchived, decryptTasks, groupTasks, signTasks, challengeTasks) =>
            TaskStream(
          showArchived: showArchived,
          decryptTasks: decryptTasks,
          signTasks: signTasks,
          challengeTasks: challengeTasks,
        ),
      );

  AppViewModel(
    User user,
    DeviceRepository deviceRepository,
    this._groupRepository,
    this._fileRepository,
    this._challengeRepository,
    this._decryptRepository,
    this._settingsController,
  ) {
    _userDid = user.did;
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
      _groupTasksController.add(tasks);
    });

    signTasksStream.listen((tasks) {
      _signTasksController.add(tasks);
    });

    challengeTasksStream.listen((tasks) {
      _challengeTasksController.add(tasks);
    });

    decryptTasksStream.listen((tasks) {
      _decryptTasksController.add(tasks);
    });

    _settingsController.settingsStream.listen((settings) {
      _showArchivedController.add(settings.showArchivedItems);
    });

    combinedTaskStream.listen((allTaskStream) {
      allTasks.clear();
      allTasks.addAll(allTaskStream.decryptTasks);
      allTasks.addAll(allTaskStream.signTasks);
      allTasks.addAll(allTaskStream.challengeTasks);
    });
  }

  Future<void> refetchTasks(TaskType poolTarget) async {
    try {
      if (poolTarget == TaskType.group) {
        await _groupRepository.sync(_userDid);
      }
      if (poolTarget == TaskType.sign) {
        await _fileRepository.sync(_userDid);
      }
      if (poolTarget == TaskType.challenge) {
        await _challengeRepository.sync(_userDid);
      }
      if (poolTarget == TaskType.decrypt) {
        await _decryptRepository.sync(_userDid);
      }
    } catch (e) {
      debugPrint('Polling error: $e');
    }
  }

  bool hasGroup(KeyType type, {bool? inclArchived}) => groupTasks.any((task) =>
      task.info.keyType == type &&
      task.state == TaskState.finished &&
      (!task.archived || (inclArchived ?? showArchived)));

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

  bool joinedGroupForTaskTypeExists(KeyType type) {
    var temp = groupTasks.where((task) =>
        task.info.keyType == type && task.state == TaskState.finished);

    if (showArchived) {
      return temp.isNotEmpty;
    } else {
      return temp.any((task) => !task.archived);
    }
  }
}
