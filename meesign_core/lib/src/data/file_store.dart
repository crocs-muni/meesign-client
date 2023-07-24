import 'dart:io' as io;

import 'package:path/path.dart' as path_pkg;

import '../util/uuid.dart';

class FileStore {
  final io.Directory _dir;

  FileStore(this._dir);

  String getFilePath(Uuid did, Uuid id, String name) {
    return path_pkg.join(
      _dir.path,
      did.encode(),
      id.encode(),
      name,
    );
  }

  Future<String> storeFile(
      Uuid did, Uuid id, String name, List<int> data) async {
    final path = getFilePath(did, id, name);
    await io.Directory(path_pkg.dirname(path)).create(recursive: true);
    await io.File(path).writeAsBytes(data, flush: true);
    return path;
  }
}
