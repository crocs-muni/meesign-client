import 'package:meta/meta.dart';

import '../database/database.dart' as db;
import '../util/uuid.dart';

@immutable
class Device {
  final String name;
  final Uuid id;
  final DateTime lastActive;

  const Device(this.name, this.id, this.lastActive);
}

extension DeviceConversion on db.Device {
  Device toModel() => Device(name, Uuid.take(id), DateTime.now());
}
