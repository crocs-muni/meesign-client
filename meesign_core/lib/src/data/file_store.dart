import 'dart:io' as io;

import 'package:path/path.dart' as path_pkg;

import '../util/uuid.dart';

class FileStore {
  final io.Directory _dir;

  FileStore(this._dir);

  // TODO: when to remove work files? (issues with file locks,
  // https://github.com/crocs-muni/meesign-client/issues/3)

  String getFileId(Uuid did, Uuid id, String name, {bool work = false}) {
    return path_pkg.join(
      _dir.path,
      did.encode(),
      work ? 'workfiles' : 'outputs',
      id.encode(),
      name,
    );
  }

  Future<String> storeFile(Uuid did, Uuid id, String name, List<int> data,
      {bool work = false}) async {
    final path = getFileId(did, id, name, work: work);
    await io.Directory(path_pkg.dirname(path)).create(recursive: true);
    await io.File(path).writeAsBytes(data, flush: true);
    return path;
  }

  Future<Uri> accessFile(String id) async => Uri.file(id);
}
