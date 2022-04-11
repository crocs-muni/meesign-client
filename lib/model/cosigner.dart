import 'dart:math';

enum CosignerType {
  app,
  card,
}

class Cosigner {
  String name;
  List<int> id;
  CosignerType type;

  static const int idLen = 16;

  Cosigner(this.name, this.id, this.type);
  Cosigner.random(this.name, this.type) : id = _randomId();

  static List<int> _randomId() {
    final rnd = Random.secure();
    return List.generate(idLen, (i) => rnd.nextInt(256));
  }
}
