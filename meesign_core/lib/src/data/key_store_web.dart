import 'dart:typed_data';

import 'package:meesign_core/meesign_data.dart';

/// Web implementation of KeyStore using in-memory storage.
/// Keys are persisted via the web database (Drift wasm) through
/// the application's session management.
class KeyStore {
  // Parameter unused on web but matches native KeyStore constructor signature.
  // ignore: avoid_unused_constructor_parameters
  KeyStore([String? dirPath]);

  final Map<String, List<int>> _keys = {};
  final Map<String, String> _tokens = {};

  Future<void> store(Uuid did, List<int> key) async {
    _keys[did.encode()] = Uint8List.fromList(key);
  }

  List<int> load(Uuid did) {
    final key = _keys[did.encode()];
    if (key == null) {
      throw Exception('Key not found for device ${did.encode()}');
    }
    return key;
  }

  Future<void> storeToken(Uuid did, String token) async {
    _tokens[did.encode()] = token;
  }

  String? loadToken(Uuid did) {
    return _tokens[did.encode()];
  }
}
