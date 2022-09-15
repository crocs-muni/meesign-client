import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

// TODO: use uuid package?
@immutable
class Uuid {
  final Uint8List bytes;
  Uuid(List<int> bytes) : bytes = Uint8List.fromList(bytes);

  @override
  bool operator ==(other) {
    if (other is! Uuid) return false;
    return (const ListEquality()).equals(bytes, other.bytes);
  }

  // FIXME: is this useable in a hashmap?
  @override
  int get hashCode => (const ListEquality()).hash(bytes);
}
