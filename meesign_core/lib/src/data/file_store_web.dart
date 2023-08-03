import 'dart:html';
import 'dart:indexed_db';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';

import '../util/uuid.dart';

class FileStore {
  // TODO: get rid of io dependency
  FileStore(io.Directory dir);

  static const _dbName = 'file_store_db';
  static const _storeName = 'file_store';

  Database? _db;

  Future<Database> open() async {
    _db ??= await window.indexedDB?.open(
      _dbName,
      version: 1,
      onUpgradeNeeded: (event) {
        Database db = event.target.result;
        db.createObjectStore(_storeName);
      },
    );
    return _db!;
  }

  void close() {
    _db?.close();
    _db = null;
  }

  Future<ObjectStore> _openStore({bool write = false}) async {
    final mode = write ? 'readwrite' : 'readonly';
    final db = await open();
    return db.transaction([_storeName], mode).objectStore(_storeName);
  }

  String getFileId(Uuid did, Uuid id, String name, {bool work = false}) {
    return did.encode() + id.encode();
  }

  Future<String> storeFile(Uuid did, Uuid id, String name, List<int> data,
      {bool work = false}) async {
    final store = await _openStore(write: true);
    final fid = getFileId(did, id, name);
    await store.put(data, fid);
    return fid;
  }

  Future<Uri> accessFile(String id) async {
    final store = await _openStore();
    final data = await store.getObject(id);
    final file = XFile.fromData(
      Uint8List.fromList(data),
      mimeType: 'application/pdf',
    );
    return Uri.parse(file.path);
  }
}
