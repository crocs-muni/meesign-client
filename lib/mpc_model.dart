import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';
import 'package:mpc_demo/grpc/mpc.pbgrpc.dart';
import 'package:mpc_demo/rnd_name_generator.dart';

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
  List<Cosigner> cosigners;
  int? taskId;

  bool get isFinished => false;

  SignedFile(this.path, this.group, this.cosigners);
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

  MpcModel() {
    _channel = ClientChannel(
      'localhost',
      port: 1337,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );

    _client = MPCClient(_channel);

    // TODO: there should be a setup page for this
    thisDevice = Cosigner.random(RndNameGenerator().next(), CosignerType.app);
    register(thisDevice);

    _startPoll();
  }

  Future<void> register(Cosigner cosigner) async {
    final resp = await _client.register(
      RegistrationRequest(id: cosigner.id, name: cosigner.name),
    );
    if (resp.hasFailure()) throw Exception(resp.failure);
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

  void _startPoll() {
    if (_pollTimer != null) return;
    _pollTimer = Timer.periodic(const Duration(seconds: 1), _poll);
  }

  void _stopPoll() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _poll(Timer timer) async {
    bool change = false;

    // TODO: cache these?
    final devices = await _client.getDevices(DevicesRequest());
    final info = await _client.getInfo(InfoRequest(deviceId: thisDevice.id));

    // update details of newly created groups
    for (final group in info.groups) {
      final existing = _findExistingGroup(group);
      if (existing.id != null) continue;

      existing.id = group.id;
      existing.threshold = group.threshold;
      change = true;
    }

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
            task = await _client.getTask(TaskRequest(
              taskId: task.id,
              deviceId: thisDevice.id,
            ));

            final newGroup = Group._fromTask(task, devices);
            groups.add(newGroup);
            _groupReqsController.add(newGroup);
            break;
          }
        case Task_TaskType.SIGN:
          {
            // TODO: Handle this case.
            break;
          }
      }
    }

    if (change) notifyListeners();
  }

  Future<void> joinGroup(Group group) async {
    final resp = await _client.updateTask(TaskUpdate(
      device: thisDevice.id,
      task: group.taskId,
      data: [1],
    ));
  }
}
