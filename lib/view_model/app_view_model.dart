import 'dart:async';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:meesign_client/enums/task_type.dart';
import 'package:meesign_client/services/local_auth_service.dart';
import 'package:meesign_client/services/settings_controller.dart';
import 'package:meesign_client/util/extensions/task_approvable.dart';
import 'package:meesign_core/meesign_card.dart';
import 'package:meesign_core/meesign_data.dart';
import 'package:rxdart/rxdart.dart';

class TaskStream {
  TaskStream({
    required this.showArchived,
    required this.decryptTasks,
    required this.signTasks,
    required this.challengeTasks,
  });
  final bool showArchived;
  final List<Task<Decrypt>> decryptTasks;
  final List<Task<File>> signTasks;
  final List<Task<Challenge>> challengeTasks;
}

class AppViewModel with ChangeNotifier {
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
  // Limit reduced from 8MB to 3MB to account for encryption overhead
  // and stay under gRPC's 4MB message size limit.
  // Currently it is not possible to configure dart's gRPC message size.
  // TODO(dev): Verify encryption overhead / JSON encoding overhead to find find optimal buffer.
  // Please follow: https://github.com/grpc/grpc-dart/issues/551
  static const int maxDataSize = 3 * 1024 * 1024; // 3MB
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

  // Decrypt tasks stream (regular + observed)
  final BehaviorSubject<List<Task<Decrypt>>> _decryptTasksController =
      BehaviorSubject<List<Task<Decrypt>>>();
  final BehaviorSubject<List<Task<Decrypt>>> _observedDecryptTasksController =
      BehaviorSubject<List<Task<Decrypt>>>.seeded([]);
  Stream<List<Task<Decrypt>>> get decryptTasksStream => Rx.combineLatest2<
          List<Task<Decrypt>>, List<Task<Decrypt>>, List<Task<Decrypt>>>(
        _decryptTasksController.stream,
        _observedDecryptTasksController.stream,
        (regular, observed) => [...regular, ...observed],
      );
  List<Task<Decrypt>> get decryptTasks => [
        ..._decryptTasksController.valueOrNull ?? [],
        ..._observedDecryptTasksController.valueOrNull ?? [],
      ];

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

  // External groups (decrypt groups user is NOT a member of)
  final BehaviorSubject<List<Group>> _externalGroupsController =
      BehaviorSubject<List<Group>>.seeded([]);
  Stream<List<Group>> get externalGroupsStream =>
      _externalGroupsController.stream;
  List<Group> get externalGroups => _externalGroupsController.valueOrNull ?? [];

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

  void _listen(Uuid did) {
    final groupTasksStream = _groupRepository.observeTasks(did);
    final signTasksStream = _fileRepository.observeTasks(did);
    final challengeTasksStream = _challengeRepository.observeTasks(did);
    final decryptTasksStream = _decryptRepository.observeTasks(did);

    int pending(List<Task<dynamic>> tasks) => tasks
        .where(
          (task) =>
              (task.approvable || task.state == TaskState.needsCard) &&
              !task.archived,
        )
        .length;
    nGroupReqs = groupTasksStream.map(pending).shareValue();
    nSignReqs = signTasksStream.map(pending).shareValue();
    nChallengeReqs = challengeTasksStream.map(pending).shareValue();
    nDecryptReqs = decryptTasksStream.map(pending).shareValue();

    notifyListeners();

    groupTasksStream.listen((tasks) {
      _groupTasksController.add(tasks);
      final currentSettings = _settingsController.currentSettings;

      for (final task in tasks) {
        if (task.approvable) {
          if (currentSettings.autoJoinGroups) {
            _groupRepository.approveTask(device!.id, task.id, agree: true);
          } else if (currentSettings.autoRejectGroups) {
            _groupRepository.approveTask(device!.id, task.id, agree: false);
          }
        }
      }
    });

    signTasksStream.listen(_signTasksController.add);

    challengeTasksStream.listen(_challengeTasksController.add);

    decryptTasksStream.listen(_decryptTasksController.add);

    _decryptRepository
        .observeObservedTasks(did, () => externalGroups)
        .listen(_observedDecryptTasksController.add);

    _settingsController.settingsStream.listen((settings) {
      _showArchivedController.add(settings.showArchivedItems);
    });

    fetchExternalGroups();
    _decryptRepository.pollObservedTasks(did);

    combinedTaskStream.listen((allTaskStream) {
      allTasks
        ..clear()
        ..addAll(allTaskStream.decryptTasks)
        ..addAll(allTaskStream.signTasks)
        ..addAll(allTaskStream.challengeTasks);
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
        await _decryptRepository.pollObservedTasks(_userDid);
      }
    } on Exception catch (e) {
      debugPrint('Polling error: $e');
    }
  }

  Future<void> fetchExternalGroups() async {
    try {
      final allGroups = await _groupRepository.fetchAllGroups();
      final external = allGroups
          .where(
            (g) => !g.hasMember(_userDid) && g.keyType == KeyType.decrypt,
          )
          .toList();
      _externalGroupsController.add(external);
    } on Exception catch (e) {
      debugPrint('Failed to fetch external groups: $e');
    }
  }

  bool hasGroup(KeyType type, {bool? inclArchived}) => groupTasks.any(
        (task) =>
            task.info.keyType == type &&
            task.state == TaskState.finished &&
            (!task.archived || (inclArchived ?? showArchived)),
      );

  Future<void> addGroup(
    String name,
    List<Member> members,
    int threshold,
    Protocol protocol,
    KeyType keyType,
    String? note,
  ) =>
      _groupRepository.group(
        name,
        members,
        threshold,
        protocol,
        keyType,
        note: note,
      );

  Future<void> sign(XFile file, Group group) async {
    await _fileRepository.sign(file.name, await file.readAsBytes(), group.id);
  }

  Future<void> challenge(String name, Uint8List data, Group group) =>
      _challengeRepository.sign(name, data, group.id);

  Future<void> encrypt(
    String description,
    MimeType mimeType,
    Uint8List data,
    Group group,
  ) async {
    final taskId = await _decryptRepository.encrypt(
      _userDid,
      description,
      mimeType,
      data,
      group.id,
    );

    // If this is an external group, save as observed task
    final isExternal = !group.hasMember(_userDid);
    if (isExternal) {
      await _decryptRepository.saveObservedTask(
        _userDid,
        taskId,
        group.id,
        description,
        mimeType.value,
        data,
      );
    }
  }

  Future<void> joinGroup(
    Task<Group> task, {
    required bool agree,
    bool withCard = false,
  }) async {
    if (!agree || await LocalAuthService.authUser(_settingsController)) {
      _groupRepository.approveTask(
        device!.id,
        task.id,
        agree: agree,
        withCard: withCard,
      );
    }
  }

  Future<void> joinSign(Task<File> task, {required bool agree}) async {
    if (!agree || await LocalAuthService.authUser(_settingsController)) {
      _fileRepository.approveTask(device!.id, task.id, agree: agree);
    }
  }

  Future<void> joinChallenge(
    Task<Challenge> task, {
    required bool agree,
  }) async {
    if (!agree || await LocalAuthService.authUser(_settingsController)) {
      _challengeRepository.approveTask(device!.id, task.id, agree: agree);
    }
  }

  Future<void> joinDecrypt(Task<Decrypt> task, {required bool agree}) async {
    if (!agree || await LocalAuthService.authUser(_settingsController)) {
      _decryptRepository.approveTask(device!.id, task.id, agree: agree);
    }
  }

  // FIXME: avoid this repetition
  Future<void> advanceGroupWithCard(Task<Group> task, Card card) async {
    if (await LocalAuthService.authUser(_settingsController)) {
      _groupRepository.advanceTaskWithCard(device!.id, task.id, card);
    }
  }

  Future<void> advanceChallengeWithCard(Task<Challenge> task, Card card) async {
    if (await LocalAuthService.authUser(_settingsController)) {
      _challengeRepository.advanceTaskWithCard(device!.id, task.id, card);
    }
  }

  TaskRepository<T> _selectRepository<T>(T info) {
    return switch (info) {
      Group() => _groupRepository,
      File() => _fileRepository,
      Challenge() => _challengeRepository,
      Decrypt() => _decryptRepository,
      _ => throw TypeError(),
    } as TaskRepository<T>;
  }

  Future<void> archiveTask<T>(Task<T> task, {required bool archive}) async {
    _selectRepository<T>(task.info)
        .archiveTask(device!.id, task.id, archive: archive);
  }

  bool joinedGroupForTaskTypeExists(KeyType type) {
    final temp = groupTasks.where(
      (task) => task.info.keyType == type && task.state == TaskState.finished,
    );

    final hasOwn =
        showArchived ? temp.isNotEmpty : temp.any((task) => !task.archived);

    // For decrypt, also consider external groups
    if (type == KeyType.decrypt && !hasOwn) {
      return externalGroups.any((g) => g.keyType == KeyType.decrypt);
    }

    return hasOwn;
  }

  bool anyGroupJoined() {
    final temp = groupTasks.where((task) => task.state == TaskState.finished);

    if (showArchived) {
      return temp.isNotEmpty;
    } else {
      return temp.any((task) => !task.archived);
    }
  }
}
