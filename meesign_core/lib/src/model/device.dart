import 'package:meesign_network/grpc.dart' as rpc;
import 'package:meta/meta.dart';

import '../database/database.dart' as db;
import '../util/uuid.dart';

enum DeviceKind { user, bot }

extension DeviceKindConversion on DeviceKind {
  static DeviceKind fromNetwork(rpc.DeviceKind kind) => switch (kind) {
        rpc.DeviceKind.USER => DeviceKind.user,
        rpc.DeviceKind.BOT => DeviceKind.bot,
        _ => throw ArgumentError('Unknown device kind'),
      };

  rpc.DeviceKind toNetwork() => switch (this) {
        DeviceKind.user => rpc.DeviceKind.USER,
        DeviceKind.bot => rpc.DeviceKind.BOT,
      };
}

@immutable
class Device {
  final String name;
  final Uuid id;
  final DeviceKind kind;
  final DateTime lastActive;

  const Device(this.name, this.id, this.kind, this.lastActive);

  Device copyWith({
    String? name,
    Uuid? id,
    DeviceKind? kind,
    DateTime? lastActive,
  }) {
    return Device(
      name ?? this.name,
      id ?? this.id,
      kind ?? this.kind,
      lastActive ?? this.lastActive,
    );
  }
}

extension DeviceConversion on db.Device {
  Device toModel() => Device(name, Uuid.take(id), kind, DateTime.now());
}
