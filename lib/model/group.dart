import 'package:flutter/foundation.dart';

import 'cosigner.dart';

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
