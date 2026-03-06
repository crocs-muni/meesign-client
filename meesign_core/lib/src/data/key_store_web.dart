import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:meesign_core/meesign_data.dart';
import 'package:meesign_core/src/data/indexed_db_store.dart';

/// Web implementation of KeyStore backed by IndexedDB.
///
/// All entries are loaded into an in-memory cache during [init] so that
/// the synchronous [load] method works without async DB access.
class KeyStore {
  // Parameter unused on web but matches native KeyStore constructor signature.
  // ignore: avoid_unused_constructor_parameters
  KeyStore([String? dirPath]);

  final Map<String, List<int>> _keys = {};
  final Map<String, String> _tokens = {};
  late IndexedDbStore _db;

  /// Load all persisted keys into the in-memory cache.
  /// Must be called once at startup before any [load] calls.
  Future<void> init() async {
    _db = await IndexedDbStore.open();
    final entries = await _db.getAll(IndexedDbStore.keysStore);
    for (final entry in entries) {
      final id = (entry['id']! as JSString).toDart;
      _keys[id] = (entry['key']! as JSUint8Array).toDart;
      final token = entry['token'];
      if (token != null && !token.isUndefined) {
        _tokens[id] = (token as JSString).toDart;
      }
    }
  }

  Future<void> store(Uuid did, List<int> key) async {
    final encoded = did.encode();
    final bytes = Uint8List.fromList(key);
    _keys[encoded] = bytes;
    await _db.put(
      IndexedDbStore.keysStore,
      makeKeyEntry(id: encoded, key: bytes, token: _tokens[encoded]),
    );
  }

  List<int> load(Uuid did) {
    final key = _keys[did.encode()];
    if (key == null) {
      throw Exception('Key not found for device ${did.encode()}');
    }
    return key;
  }

  Future<void> storeToken(Uuid did, String token) async {
    final encoded = did.encode();
    _tokens[encoded] = token;
    final existingKey = _keys[encoded];
    if (existingKey != null) {
      await _db.put(
        IndexedDbStore.keysStore,
        makeKeyEntry(
          id: encoded,
          key: Uint8List.fromList(existingKey),
          token: token,
        ),
      );
    }
  }

  String? loadToken(Uuid did) {
    return _tokens[did.encode()];
  }
}
