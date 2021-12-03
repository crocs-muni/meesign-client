import 'package:flutter/foundation.dart';

abstract class Protocol {
  final int keygenRounds;
  final int signRounds;
  const Protocol({
    required this.keygenRounds,
    required this.signRounds,
  });
}

class Ecdsa extends Protocol {
  const Ecdsa() : super(keygenRounds: 2, signRounds: 3);
}

class Group {
  String name;
  List<Cosigner> members;
  Protocol protocol;
  int threshold;
  int round = 0;

  bool get isFinished => round == protocol.keygenRounds;

  Group(
    this.name,
    this.members,
    this.protocol,
    this.threshold,
  );
}

enum CosignerType {
  peer,
  card,
}

class Cosigner {
  String name;
  CosignerType type;
  Cosigner(this.name, this.type);
}

class SignedFile {
  String path;
  Group group;
  List<Cosigner> cosigners;
  int round = 0;

  bool get isFinished => round == group.protocol.signRounds;

  SignedFile(this.path, this.group, this.cosigners);
}

class MpcModel with ChangeNotifier {
  final cosigners = [];
  final groups = [];

  var files = [];

  List<Cosigner> searchForPeers(String query) {
    List<Cosigner> cosigners = [];
    for (int i = 0; i < 5; i++) {
      cosigners.add(Cosigner('User $i', CosignerType.peer));
    }
    return cosigners;
  }
}
