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
  static var cosigners = [
    Cosigner('user 1', CosignerType.peer),
    Cosigner('user 2', CosignerType.peer),
    Cosigner('user 3', CosignerType.peer),
    Cosigner('user 4', CosignerType.card),
    Cosigner('user 5', CosignerType.card),
  ];

  static var groups = [
    Group(
      'Group 1',
      [
        cosigners[0],
        cosigners[2],
        cosigners[3],
      ],
      const Ecdsa(),
      2,
    )
  ];

  static var files = [
    SignedFile(
      'signed-document',
      groups[0],
      [cosigners[0], cosigners[2]],
    )..round = 2,
  ];
}
