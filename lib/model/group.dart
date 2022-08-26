import 'dart:typed_data';

import '../util/uuid.dart';
import 'device.dart';

class GroupBase {
  String name;
  List<Device> members;
  int threshold;

  GroupBase(
    this.name,
    this.members,
    this.threshold,
  );
}

class Group extends GroupBase {
  List<int> id;
  Uint8List context;

  Group(this.id, this.context, GroupBase base)
      : super(base.name, base.members, base.threshold);

  hasMember(Uuid id) {
    for (final member in members) {
      if (member.id == id) return true;
    }
    return false;
  }
}
