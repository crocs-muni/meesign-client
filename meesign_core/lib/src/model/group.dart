import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../util/uuid.dart';
import 'device.dart';
import 'key_type.dart';
import 'protocol.dart';

@immutable
class GroupBase {
  final String name;
  final List<Device> members;
  final int threshold;
  final Protocol protocol;
  final KeyType keyType;

  const GroupBase(
    this.name,
    this.members,
    this.threshold,
    this.protocol,
    this.keyType,
  );

  hasMember(Uuid id) => members.any((member) => member.id == id);
}

@immutable
class Group extends GroupBase {
  final List<int> id;
  final Uint8List context;

  Group(this.id, this.context, GroupBase base)
      : super(base.name, base.members, base.threshold, base.protocol,
            base.keyType);
}
