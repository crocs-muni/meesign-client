// IndexedDB's callback API requires referencing `request` inside its own
// event handlers, which prevents cascading and requires nullable casts.
// ignore_for_file: cascade_invocations, cast_nullable_to_non_nullable

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Thin wrapper around IndexedDB for persisting keys and files on the web.
///
/// Database: `meesign_storage` (v1)
/// Object stores:
///   - `keys` (keyPath: `id`) — PKCS#12 certs + JWT tokens
///   - `files` (keyPath: `path`) — task files (PDFs, outputs, workfiles)
class IndexedDbStore {
  IndexedDbStore._(this._db);

  final web.IDBDatabase _db;

  static const _dbName = 'meesign_storage';
  static const _dbVersion = 1;
  static const keysStore = 'keys';
  static const filesStore = 'files';

  static Future<IndexedDbStore> open() async {
    final completer = Completer<web.IDBDatabase>();
    final request = web.window.indexedDB.open(_dbName, _dbVersion);

    request.onupgradeneeded = (web.IDBVersionChangeEvent _) {
      final db = request.result as web.IDBDatabase;
      if (!db.objectStoreNames.contains(keysStore)) {
        db.createObjectStore(
          keysStore,
          web.IDBObjectStoreParameters(keyPath: 'id'.toJS),
        );
      }
      if (!db.objectStoreNames.contains(filesStore)) {
        db.createObjectStore(
          filesStore,
          web.IDBObjectStoreParameters(keyPath: 'path'.toJS),
        );
      }
    }.toJS;
    request.onsuccess = (web.Event _) {
      completer.complete(request.result as web.IDBDatabase);
    }.toJS;
    request.onerror = (web.Event _) {
      completer.completeError(
        Exception('Failed to open IndexedDB: ${request.error}'),
      );
    }.toJS;

    return IndexedDbStore._(await completer.future);
  }

  Future<void> put(String storeName, JSObject value) {
    final completer = Completer<void>();
    final tx = _db.transaction(storeName.toJS, 'readwrite');
    final request = tx.objectStore(storeName).put(value);

    request.onsuccess = (web.Event _) {
      completer.complete();
    }.toJS;
    request.onerror = (web.Event _) {
      completer.completeError(
        Exception('IndexedDB put failed: ${request.error}'),
      );
    }.toJS;

    return completer.future;
  }

  Future<List<JSObject>> getAll(String storeName) {
    final completer = Completer<List<JSObject>>();
    final tx = _db.transaction(storeName.toJS, 'readonly');
    final request = tx.objectStore(storeName).getAll();

    request.onsuccess = (web.Event _) {
      final result = request.result;
      if (result.isUndefinedOrNull) {
        completer.complete([]);
      } else {
        completer.complete((result as JSArray).toDart.cast<JSObject>());
      }
    }.toJS;
    request.onerror = (web.Event _) {
      completer.completeError(
        Exception('IndexedDB getAll failed: ${request.error}'),
      );
    }.toJS;

    return completer.future;
  }

  Future<void> delete(String storeName, String key) {
    final completer = Completer<void>();
    final tx = _db.transaction(storeName.toJS, 'readwrite');
    final request = tx.objectStore(storeName).delete(key.toJS);

    request.onsuccess = (web.Event _) {
      completer.complete();
    }.toJS;
    request.onerror = (web.Event _) {
      completer.completeError(
        Exception('IndexedDB delete failed: ${request.error}'),
      );
    }.toJS;

    return completer.future;
  }

  /// Delete all entries whose key starts with [prefix].
  Future<void> deleteByPrefix(String storeName, String prefix) {
    final completer = Completer<void>();
    final tx = _db.transaction(storeName.toJS, 'readwrite');
    final request = tx.objectStore(storeName).openCursor();

    request.onsuccess = (web.Event _) {
      final result = request.result;
      if (result.isUndefinedOrNull) {
        if (!completer.isCompleted) completer.complete();
        return;
      }
      final cursor = result as web.IDBCursorWithValue;
      final cursorKey = (cursor.key! as JSString).toDart;
      if (cursorKey.startsWith(prefix)) {
        cursor.delete();
      }
      cursor.continue_();
    }.toJS;
    request.onerror = (web.Event _) {
      if (!completer.isCompleted) {
        completer.completeError(
          Exception('IndexedDB deleteByPrefix failed: ${request.error}'),
        );
      }
    }.toJS;

    return completer.future;
  }
}

/// Create a JS object for the `keys` store.
JSObject makeKeyEntry({
  required String id,
  required Uint8List key,
  String? token,
}) {
  final obj = JSObject()
    ..['id'] = id.toJS
    ..['key'] = key.toJS;
  if (token != null) {
    obj['token'] = token.toJS;
  }
  return obj;
}

/// Create a JS object for the `files` store.
JSObject makeFileEntry({
  required String path,
  required Uint8List data,
}) {
  return JSObject()
    ..['path'] = path.toJS
    ..['data'] = data.toJS;
}
