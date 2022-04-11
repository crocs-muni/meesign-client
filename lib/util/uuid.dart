import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

// TODO: use uuid package?
class Uuid {
  final Uint8List bytes;
  Uuid(List<int> bytes) : bytes = Uint8List.fromList(bytes);

  @override
  bool operator ==(other) {
    if (other is! Uuid) return false;
    return listEquals(bytes, other.bytes);
  }

  // FIXME: is this useable in a hashmap?
  @override
  int get hashCode => hashList(bytes);
}
