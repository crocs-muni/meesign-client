extension Intersperse<T> on List<T> {
  List<T> intersperse(T inter) {
    final res = <T>[];
    for (final item in this) {
      res
        ..add(item)
        ..add(inter);
    }
    if (res.isNotEmpty) res.removeLast();
    return res;
  }
}
