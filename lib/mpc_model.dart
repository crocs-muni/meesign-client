import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';
import 'package:mpc_demo/dylib_manager.dart';
import 'package:mpc_demo/grpc/mpc.pbgrpc.dart';
import 'package:mpc_demo/rnd_name_generator.dart';
import 'package:path/path.dart' as path_pkg;
import 'package:path_provider/path_provider.dart';

class Group {
  List<int>? id;
  String name;
  List<Cosigner> members;
  int threshold;
  int? taskId;

  bool get isFinished => id != null;

  Group(
    this.name,
    this.members,
    this.threshold,
  );

  hasMember(List<int> id) {
    for (final member in members) {
      if (listEquals(member.id, id)) return true;
    }
    return false;
  }

  static Group _fromTask(Task task, Devices devices) {
    // work format: null-terminated name + list of device ids
    int iNameEnd = task.work.indexOf(0);
    String name = (const AsciiDecoder()).convert(task.work, 0, iNameEnd);

    int idsLen = task.work.length - (iNameEnd + 1);
    assert(idsLen % Cosigner.idLen == 0);
    int nCosigners = idsLen ~/ Cosigner.idLen;

    List<Cosigner> members = [];
    for (int i = 0, start = iNameEnd + 1;
        i < nCosigners;
        i++, start += Cosigner.idLen) {
      List<int> id = task.work.getRange(start, start + Cosigner.idLen).toList();
      final dev = devices.devices.firstWhere((dev) => listEquals(dev.id, id));
      members.add(Cosigner(dev.name, id, CosignerType.app));
    }

    return Group(name, members, -1)..taskId = task.id;
  }
}

enum CosignerType {
  app,
  card,
}

class Cosigner {
  String name;
  List<int> id;
  CosignerType type;

  static const int idLen = 16;

  Cosigner(this.name, this.id, this.type);
  Cosigner.random(this.name, this.type) : id = _randomId();
  Cosigner.fromHex(this.name, this.type, String hex) : id = _decodeHexId(hex);

  static List<int> _randomId() {
    final rnd = Random.secure();
    return List.generate(idLen, (i) => rnd.nextInt(256));
  }

  static List<int> _decodeHexId(String hex) => List.generate(hex.length ~/ 2,
      (i) => int.parse(hex.substring(2 * i, 2 * (i + 1)), radix: 16));

  String get hexId =>
      id.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

class SignedFile {
  String path;
  Group group;
  int? taskId;
  bool isFinished = false;

  SignedFile(this.path, this.group);

  String get basename => path_pkg.basename(path);
}

class MpcModel with ChangeNotifier {
  final List<Group> groups = [];
  final List<SignedFile> files = [];

  late ClientChannel _channel;
  late MPCClient _client;
  late Cosigner thisDevice;

  Timer? _pollTimer;

  final StreamController<Group> _groupReqsController = StreamController();
  Stream<Group> get groupRequests => _groupReqsController.stream;

  final StreamController<SignedFile> _signReqsController = StreamController();
  Stream<SignedFile> get signRequests => _signReqsController.stream;

  late Directory _tmpDir;
  late Directory _signedDir;

  final DylibManager _dylibManager = DylibManager();

  MpcModel() {
    _createDirs();
  }

  Future<void> register(String name, String host) async {
    _channel = ClientChannel(
      host,
      port: 1337,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );

    _client = MPCClient(_channel);

    thisDevice = Cosigner.random(name, CosignerType.app);

    final resp = await _client.register(
      RegistrationRequest(id: thisDevice.id, name: name),
    );
    if (resp.hasFailure()) throw Exception(resp.failure);

    _startPoll();
  }

  Future<Iterable<Cosigner>> searchForPeers(String query) => getRegistered();

  Future<Iterable<Cosigner>> getRegistered() async {
    final devices = await _client.getDevices(DevicesRequest());
    return devices.devices
        .map((device) => Cosigner(device.name, device.id, CosignerType.app));
  }

  Future<void> addGroup(
      String name, List<Cosigner> members, int threshold) async {
    final task = await _client.group(GroupRequest(
      deviceIds: members.map((m) => m.id),
      name: name,
      threshold: threshold,
    ));

    final newGroup = Group(name, members, threshold)..taskId = task.id;
    groups.add(newGroup);
    notifyListeners();

    joinGroup(newGroup);
  }

  Future<void> joinGroup(Group group) async {
    final resp = await _client.updateTask(TaskUpdate(
      device: thisDevice.id,
      task: group.taskId,
      data: [1],
    ));
  }

  Future<void> sign(String path, Group group) async {
    final file = SignedFile(path, group);
    final task = await _client.sign(await _encodeSignRequest(file));
    file.taskId = task.id;
    files.add(file);
    notifyListeners();

    cosign(file);
  }

  Future<void> cosign(SignedFile file) async {
    final resp = await _client.updateTask(TaskUpdate(
      device: thisDevice.id,
      task: file.taskId,
      data: [1],
    ));
    assert(resp.hasSuccess());
  }

  Future<Task> _getTask(int id) => _client.getTask(TaskRequest(
        taskId: id,
        deviceId: thisDevice.id,
      ));

  // TODO: fix type; change protocol to avoid this stupid find?
  Group _findExistingGroup(groupMsg) {
    for (final group in groups) {
      if (group.name != groupMsg.name) continue;
      if (group.members.length != groupMsg.deviceIds.length) continue;

      bool all = true;
      for (int i = 0; i < groupMsg.deviceIds.length; i++) {
        if (!group.hasMember(groupMsg.deviceIds[i])) {
          all = false;
          break;
        }
      }

      if (all) return group;
    }
    throw Exception('Group not found');
  }

  bool _updateGroups(Info info) {
    bool change = false;

    // update details of newly created groups
    for (final group in info.groups) {
      final existing = _findExistingGroup(group);
      if (existing.id != null) continue;

      existing.id = group.id;
      existing.threshold = group.threshold;
      change = true;
    }

    return change;
  }

  Future<bool> _processTasks(Info info) async {
    bool change = false;

    // TODO: cache these?
    final devices = await _client.getDevices(DevicesRequest());

    // only contains tasks that require action = waiting for us
    for (var task in info.tasks) {
      switch (task.type) {
        case Task_TaskType.GROUP:
          {
            Group? group = groups.cast<Group?>().firstWhere(
                  (group) => group!.taskId == task.id,
                  orElse: () => null,
                );
            // already handled
            if (group != null) continue;
            change = true;

            // new task, we need to fetch it's details
            task = await _getTask(task.id);

            final newGroup = Group._fromTask(task, devices);
            groups.add(newGroup);
            _groupReqsController.add(newGroup);
            break;
          }
        case Task_TaskType.SIGN:
          {
            SignedFile? file = files.cast<SignedFile?>().firstWhere(
                  (file) => file!.taskId == task.id,
                  orElse: () => null,
                );
            if (file != null) continue;
            change = true;

            task = await _getTask(task.id);
            final newFile = await _decodeSignRequest(task);
            files.add(newFile);
            _signReqsController.add(newFile);
            break;
          }
      }
    }

    // FIXME: this should be in the info probably
    for (final file in files.where((f) => !f.isFinished)) {
      final task = await _getTask(file.taskId!);
      if (task.state == Task_TaskState.FINISHED) {
        await _insertSignature(file);
        file.isFinished = true;
        change = true;
      }
    }

    return change;
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
    final info = await _client.getInfo(InfoRequest(deviceId: thisDevice.id));

    bool change = false;
    change |= _updateGroups(info);
    change |= await _processTasks(info);

    if (change) notifyListeners();
  }

  Future<void> _createDirs() async {
    final tmp = await getTemporaryDirectory();
    final unique = Random().nextInt(1 << 32);
    _tmpDir =
        await Directory(path_pkg.join(tmp.path, 'mpc_demo-$unique')).create();
    _signedDir =
        await Directory(path_pkg.join(_tmpDir.path, 'signed')).create();
  }

  Future<SignRequest> _encodeSignRequest(SignedFile file) async {
    List<int> data = [];

    List<int> id = file.group.id!;
    data.add(id.length ~/ 256);
    data.add(id.length % 256);
    data.addAll(id);

    data.addAll(const AsciiEncoder().convert(file.basename));
    data.add(0);

    // FIXME: oom for large files
    final bytes = await File(file.path).readAsBytes();
    data.addAll(bytes);

    return SignRequest(groupId: id, data: data);
  }

  Future<SignedFile> _decodeSignRequest(Task task) async {
    final data = task.work;
    int idLen = 256 * data[0] + data[1];
    int iIdEnd = 2 + idLen;
    List<int> id = data.getRange(2, iIdEnd).toList();

    int iNull = data.indexOf(0, iIdEnd);
    String baseName = const AsciiDecoder().convert(data, iIdEnd, iNull);

    String path = path_pkg.join(
      _tmpDir.path,
      baseName,
    );
    final fileData = Uint8List.sublistView(data as TypedData, iNull + 1);
    await File(path).writeAsBytes(fileData, flush: true);

    final group = groups.firstWhere((g) => listEquals(g.id, id));

    return SignedFile(path, group)..taskId = task.id;
  }

  Future<void> _insertSignature(SignedFile file) async {
    final outPath = path_pkg.join(_signedDir.path, file.basename);

    final signers = file.group.members.map((m) => '    - ${m.name}').join('\n');
    final msg = 'Signed using MPC Demo by:\n' + signers;

    await _dylibManager.signPdf(file.path, outPath, message: msg);
    file.path = outPath;
  }
}
