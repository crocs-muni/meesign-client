import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';
import 'package:path/path.dart' as path_pkg;

import '../file_storage.dart';
import '../grpc/generated/mpc.pbgrpc.dart';

class Group {
  List<int>? id;
  String name;
  List<Cosigner> members;
  int threshold;

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

  static List<int> _randomId() {
    final rnd = Random.secure();
    return List.generate(idLen, (i) => rnd.nextInt(256));
  }
}

class SignedFile {
  String path;
  Group group;
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

  final _fileStorage = FileStorage();

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

  Future<List<Cosigner>> searchForPeers(String query) async {
    final res = (await getRegistered())
        .where((cosigner) =>
            cosigner.name.startsWith(query) ||
            cosigner.name.split(' ').any(
                  (word) => word.startsWith(query),
                ))
        .toList();
    res.sort((a, b) => a.name.compareTo(b.name));
    return res;
  }

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

    notifyListeners();
  }

  Future<void> sign(String path, Group group) async {
    final file = SignedFile(path, group);
    notifyListeners();
  }

  Future<void> _processTasks(Tasks tasks) async {}

  void _startPoll() {
    if (_pollTimer != null) return;
    _pollTimer = Timer.periodic(const Duration(seconds: 1), _poll);
  }

  void _stopPoll() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _poll(Timer timer) async {}
}
