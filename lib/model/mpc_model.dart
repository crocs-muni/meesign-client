import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';

import '../file_storage.dart';
import '../grpc/generated/mpc.pbgrpc.dart' as rpc;
import 'cosigner.dart';
import 'group.dart';
import 'signed_file.dart';

export 'cosigner.dart';
export 'group.dart';
export 'signed_file.dart';

class MpcModel with ChangeNotifier {
  final List<Group> groups = [];
  final List<SignedFile> files = [];

  late ClientChannel _channel;
  late rpc.MPCClient _client;
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

    _client = rpc.MPCClient(_channel);

    thisDevice = Cosigner.random(name, CosignerType.app);

    final resp = await _client.register(
      rpc.RegistrationRequest(id: thisDevice.id, name: name),
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
    final devices = await _client.getDevices(rpc.DevicesRequest());
    return devices.devices
        .map((device) => Cosigner(device.name, device.id, CosignerType.app));
  }

  Future<void> addGroup(
      String name, List<Cosigner> members, int threshold) async {
    final rpcTask = await _client.group(rpc.GroupRequest(
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

  Future<void> _processTasks(rpc.Tasks rpcTasks) async {}

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
