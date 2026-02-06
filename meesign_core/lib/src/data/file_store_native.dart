import 'dart:io' as io;

import 'package:meesign_core/src/util/uuid.dart';
import 'package:path/path.dart' as path_pkg;

class FileStore {
  FileStore(String dirPath) : _dirPath = dirPath;
  final String _dirPath;

  // TODO(dev): when to remove work files? (issues with file locks,
  // https://github.com/crocs-muni/meesign-client/issues/3)

  String getFilePath(Uuid did, Uuid id, String name, {bool work = false}) {
    return path_pkg.join(
      _dirPath,
      did.encode(),
      work ? 'workfiles' : 'outputs',
      id.encode(),
      name,
    );
  }

  Future<String> storeFile(
    Uuid did,
    Uuid id,
    String name,
    List<int> data, {
    bool work = false,
  }) async {
    final path = getFilePath(did, id, name, work: work);
    await io.Directory(path_pkg.dirname(path)).create(recursive: true);
    await io.File(path).writeAsBytes(data, flush: true);
    return path;
  }

  Future<void> deleteDirectory(String path) async {
    final dir = io.Directory(path);
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }
}
