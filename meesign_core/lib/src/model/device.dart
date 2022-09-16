import 'dart:math';

import 'package:meta/meta.dart';

import '../util/uuid.dart';

enum DeviceType {
  app,
  card,
}

@immutable
class Device {
  final String name;
  final Uuid id;
  final DeviceType type;
  final DateTime lastActive;

  static const int idLen = 16;

  const Device(this.name, this.id, this.type, this.lastActive);
  Device.random(this.name, this.type)
      : id = _randomId(),
        lastActive = DateTime.now();

  static Uuid _randomId() {
    final rnd = Random.secure();
    final bytes = List.generate(idLen, (i) => rnd.nextInt(256));
    return Uuid(bytes);
  }
}
