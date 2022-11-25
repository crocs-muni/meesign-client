import 'dart:collection';

import 'package:meesign_core/meesign_data.dart';

class KeyException implements Exception {}

class KeyStore {
  final Map<Uuid, List<int>> _keys = HashMap();

  void store(Uuid did, List<int> key) {
    _keys[did] = key;
  }

  List<int> load(Uuid did) {
    final key = _keys[did];
    if (key == null) throw KeyException();
    return key;
  }
}
