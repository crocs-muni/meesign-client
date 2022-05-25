import 'dart:math';

import '../util/uuid.dart';

enum CosignerType {
  app,
  card,
}

class Cosigner {
  String name;
  Uuid id;
  CosignerType type;
  DateTime lastActive;

  static const int idLen = 16;

  Cosigner(this.name, this.id, this.type, this.lastActive);
  Cosigner.random(this.name, this.type)
      : id = _randomId(),
        lastActive = DateTime.now();

  static Uuid _randomId() {
    final rnd = Random.secure();
    final bytes = List.generate(idLen, (i) => rnd.nextInt(256));
    return Uuid(bytes);
  }
}
