import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:convert/convert.dart';
import 'package:meta/meta.dart';

// TODO(dev): use uuid package?
@immutable
class Uuid {
  Uuid(List<int> bytes) : bytes = Uint8List.fromList(bytes);
  const Uuid.take(this.bytes);
  final Uint8List bytes;

  @override
  bool operator ==(Object other) {
    if (other is! Uuid) return false;
    return (const ListEquality<int>()).equals(bytes, other.bytes);
  }

  // FIXME: is this useable in a hashmap?
  @override
  int get hashCode => (const ListEquality<int>()).hash(bytes);

  String encode({Codec<List<int>, String> codec = hex}) => codec.encode(bytes);
}
