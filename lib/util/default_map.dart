import 'dart:collection';

class DefaultMap<K, V> extends MapView<K, V> {
  final V Function() defaultValue;

  DefaultMap(Map<K, V> map, this.defaultValue) : super(map);

  @override
  V operator [](Object? key) {
    if (key is! K) throw ArgumentError();
    return putIfAbsent(key, defaultValue);
  }
}
