import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path_pkg;

import '../util/uuid.dart';
import 'tmp_dir_provider.dart';

abstract class DirProvider {
  Future<Directory> getStoreDirectory();
}

class FileStore {
  static final FileStore _instance = FileStore._internal();

  // FIXME: set it in constructor, use DI instead of singleton
  final DirProvider _dirProvider = TmpDirProvider();

  FileStore._internal();

  factory FileStore() => _instance;

  Future<String> getFilePath(Uuid id, String name) async {
    return path_pkg.join(
      (await _dirProvider.getStoreDirectory()).path,
      base64Url.encode(id.bytes),
      name,
    );
  }

  Future<String> storeFile(Uuid id, String name, List<int> data) async {
    final path = await getFilePath(id, name);
    await Directory(path_pkg.dirname(path)).create(recursive: true);
    await File(path).writeAsBytes(data, flush: true);
    return path;
  }
}
