import 'dart:typed_data';

import 'package:meesign_core/src/util/uuid.dart';

/// Web implementation of FileStore using in-memory storage.
/// Files are kept in memory and can be downloaded via browser APIs.
class FileStore {
  // Parameter unused on web but matches native FileStore constructor signature.
  // ignore: avoid_unused_constructor_parameters
  FileStore([String? dirPath]);

  final Map<String, Uint8List> _files = {};

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
    _files[path] = Uint8List.fromList(data);
    return path;
  }

  Future<void> deleteDirectory(String path) async {
    _files.removeWhere((key, _) => key.startsWith(path));
  }

  Uint8List? getFileBytes(String path) => _files[path];
}
