import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../database/daos.dart';
import '../database/database.dart' as db;
import '../util/uuid.dart';
import 'device.dart';
import 'key_type.dart';
import 'protocol.dart';

@immutable
class Member {
  final Device device;
  final int shares;

  const Member(this.device, this.shares);
}

@immutable
class Group {
  final List<int> id;
  final String name;
  final List<Member> members;
  final int threshold;
  final Protocol protocol;
  final KeyType keyType;

  const Group(
    this.id,
    this.name,
    this.members,
    this.threshold,
    this.protocol,
    this.keyType,
  );

  int get shares => members.map((m) => m.shares).sum;

  hasMember(Uuid id) => members.any((member) => member.device.id == id);
}

extension GroupConversion on db.Group {
  Group toModel({List<Member> members = const []}) => Group(
        id ?? [],
        name,
        members,
        threshold,
        protocol,
        keyType,
      );
}

extension PopulatedGroupConversion on PopulatedGroup {
  Group toModel() => group.toModel(
        members: members
            .map(
              (m) => Member(m.device.toModel(), m.shares),
            )
            .toList(),
      );
}
