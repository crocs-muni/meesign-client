import 'dart:math';

import '../util/uuid.dart';

enum DeviceType {
  app,
  card,
}

class Device {
  String name;
  Uuid id;
  DeviceType type;
  DateTime lastActive;

  static const int idLen = 16;

  Device(this.name, this.id, this.type, this.lastActive);
  Device.random(this.name, this.type)
      : id = _randomId(),
        lastActive = DateTime.now();

  static Uuid _randomId() {
    final rnd = Random.secure();
    final bytes = List.generate(idLen, (i) => rnd.nextInt(256));
    return Uuid(bytes);
  }
}
