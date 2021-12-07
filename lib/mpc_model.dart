import 'package:flutter/foundation.dart';

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

  bool get isFinished => false;

  SignedFile(this.path, this.group, this.cosigners);
}

class MpcModel with ChangeNotifier {
  final List<Group> groups = [];
  final List<SignedFile> files = [];

  List<Cosigner> searchForPeers(String query) {
    return [];
  }

  void addGroup(String name, List<Cosigner> members, int threshold) {
    groups.add(Group(name, members, threshold));
    notifyListeners();
  }
}
