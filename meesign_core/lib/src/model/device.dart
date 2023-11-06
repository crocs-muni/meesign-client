import 'dart:math';

import 'package:meta/meta.dart';

import '../database/database.dart' as db;
import '../util/uuid.dart';

@immutable
class Device {
  final String name;
  final Uuid id;
  final DateTime lastActive;

  static const int idLen = 16;

  const Device(this.name, this.id, this.lastActive);
  Device.random(this.name)
      : id = _randomId(),
        lastActive = DateTime.now();

  static Uuid _randomId() {
    final rnd = Random.secure();
    final bytes = List.generate(idLen, (i) => rnd.nextInt(256));
    return Uuid(bytes);
  }
}

extension DeviceConversion on db.Device {
  Device toModel() => Device(name, Uuid.take(id), DateTime.now());
}
