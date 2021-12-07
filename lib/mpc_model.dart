import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart';
import 'package:mpc_demo/grpc/mpc.pbgrpc.dart';
import 'package:mpc_demo/rnd_name_generator.dart';

class Group {
  String name;
  List<Cosigner> members;
  int threshold;

  bool get isFinished => false;

  Group(
    this.name,
    this.members,
    this.threshold,
  );
}

enum CosignerType {
  app,
  card,
}

class Cosigner {
  String name;
  List<int> id;
  CosignerType type;

  Cosigner(this.name, this.id, this.type);
  Cosigner.random(this.name, this.type) : id = _randomId();
  Cosigner.fromHex(this.name, this.type, String hex) : id = _decodeHexId(hex);

  static List<int> _randomId() {
    final rnd = Random.secure();
    return List.generate(8, (i) => rnd.nextInt(256));
  }

  static List<int> _decodeHexId(String hex) => List.generate(
      hex.length ~/ 2, (i) => int.parse(hex.substring(i, i + 2), radix: 16));

  String get hexId =>
      id.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

class SignedFile {
  String path;
  Group group;
  List<Cosigner> cosigners;

  bool get isFinished => false;

  SignedFile(this.path, this.group, this.cosigners);
}

class MpcModel with ChangeNotifier {
  final List<Group> groups = [];
  final List<SignedFile> files = [];

  late ClientChannel _channel;
  late MPCClient _client;
  late Cosigner thisDevice;

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
  }

  Future<void> register(Cosigner cosigner) async {
    final resp = await _client.register(
      RegistrationRequest(id: cosigner.id, name: cosigner.name),
    );
    if (resp.hasFailure()) throw Exception(resp.failure);
  }

  List<Cosigner> searchForPeers(String query) {
    return [];
  }

  void addGroup(String name, List<Cosigner> members, int threshold) {
    groups.add(Group(name, members, threshold));
    notifyListeners();
  }
}
