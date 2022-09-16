import 'dart:convert';
import 'dart:io' as io;

import 'package:path/path.dart' as path_pkg;

import '../util/uuid.dart';

abstract class DirProvider {
  Future<io.Directory> getStoreDirectory();
}

class FileStore {
  final DirProvider _dirProvider;

  FileStore(this._dirProvider);

  Future<String> getFilePath(Uuid did, Uuid id, String name) async {
    return path_pkg.join(
      (await _dirProvider.getStoreDirectory()).path,
      base64Url.encode(did.bytes),
      base64Url.encode(id.bytes),
      name,
    );
  }

  Future<String> storeFile(
      Uuid did, Uuid id, String name, List<int> data) async {
    final path = await getFilePath(did, id, name);
    await io.Directory(path_pkg.dirname(path)).create(recursive: true);
    await io.File(path).writeAsBytes(data, flush: true);
    return path;
  }
}
