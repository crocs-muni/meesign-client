import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:meesign_core/src/data/indexed_db_store.dart';
import 'package:meesign_core/src/util/uuid.dart';

/// Web implementation of FileStore backed by IndexedDB.
///
/// All entries are loaded into an in-memory cache during [init] so that
/// the synchronous [getFileBytes] method works without async DB access.
class FileStore {
  // Parameter unused on web but matches native FileStore constructor signature.
  // ignore: avoid_unused_constructor_parameters
  FileStore([String? dirPath]);

  final Map<String, Uint8List> _files = {};
  late IndexedDbStore _db;

  /// Load all persisted files into the in-memory cache.
  /// Must be called once at startup before any [getFileBytes] calls.
  Future<void> init() async {
    _db = await IndexedDbStore.open();
    final entries = await _db.getAll(IndexedDbStore.filesStore);
    for (final entry in entries) {
      final path = (entry['path']! as JSString).toDart;
      _files[path] = (entry['data']! as JSUint8Array).toDart;
    }
  }

  String getFilePath(Uuid did, Uuid id, String name, {bool work = false}) {
    final prefix = work ? 'workfiles' : 'outputs';
    return '${did.encode()}/$prefix/${id.encode()}/$name';
  }

  Future<String> storeFile(
    Uuid did,
    Uuid id,
    String name,
    List<int> data, {
    bool work = false,
  }) async {
    final path = getFilePath(did, id, name, work: work);
    final bytes = Uint8List.fromList(data);
    _files[path] = bytes;
    await _db.put(
      IndexedDbStore.filesStore,
      makeFileEntry(path: path, data: bytes),
    );
    return path;
  }

  Future<void> deleteDirectory(String path) async {
    _files.removeWhere((key, _) => key.startsWith(path));
    await _db.deleteByPrefix(IndexedDbStore.filesStore, path);
  }

  Uint8List? getFileBytes(String path) => _files[path];
}
