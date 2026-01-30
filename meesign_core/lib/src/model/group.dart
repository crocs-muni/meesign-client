import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meesign_core/src/database/daos.dart';
import 'package:meesign_core/src/database/database.dart' as db;
import 'package:meesign_core/src/model/device.dart';
import 'package:meesign_core/src/model/key_type.dart';
import 'package:meesign_core/src/model/protocol.dart';
import 'package:meesign_core/src/util/uuid.dart';

part 'group.freezed.dart';

@freezed
abstract class Member with _$Member {
  const factory Member(Device device, int shares) = _Member;
}

@freezed
abstract class Group with _$Group {
  const factory Group({
    required List<int> id,
    required String name,
    required List<Member> members,
    required int threshold,
    required Protocol protocol,
    required KeyType keyType,
    String? note,
  }) = _Group;

  const Group._();

  int get shares => members.map((m) => m.shares).sum;

  bool hasMember(Uuid id) => members.any((member) => member.device.id == id);
}

extension GroupConversion on db.Group {
  Group toModel({List<Member> members = const []}) => Group(
        id: id ?? [],
        name: name,
        members: members,
        threshold: threshold,
        protocol: protocol,
        keyType: keyType,
        note: note,
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
