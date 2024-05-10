import 'dart:collection';

class DefaultMap<K, V> extends MapView<K, V> {
  final V Function() defaultValue;

  DefaultMap(super.map, this.defaultValue);

  @override
  V operator [](Object? key) {
    if (key is! K) throw ArgumentError();
    return putIfAbsent(key, defaultValue);
  }
}
