import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../util/uuid.dart';
import 'device.dart';
import 'key_type.dart';
import 'protocol.dart';

@immutable
class Group {
  final List<int> id;
  final String name;
  final List<Device> members;
  final int threshold;
  final Protocol protocol;
  final KeyType keyType;
  final Uint8List context;

  const Group(
    this.id,
    this.name,
    this.members,
    this.threshold,
    this.protocol,
    this.keyType,
    this.context,
  );

  hasMember(Uuid id) => members.any((member) => member.id == id);
}
