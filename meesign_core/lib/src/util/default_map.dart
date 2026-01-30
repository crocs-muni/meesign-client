import 'dart:collection';

class DefaultMap<K, V> extends MapView<K, V> {
  DefaultMap(super.map, this.defaultValue);
  final V Function() defaultValue;

  @override
  V operator [](Object? key) {
    if (key is! K) throw ArgumentError();
    return putIfAbsent(key, defaultValue);
  }
}
