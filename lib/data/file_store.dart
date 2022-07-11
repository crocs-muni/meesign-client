import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:async/async.dart';
import 'package:path/path.dart' as path_pkg;
import 'package:path_provider/path_provider.dart';

import '../util/uuid.dart';

class FileStore {
  static final FileStore _instance = FileStore._internal();

  final _tmpDirMemo = AsyncMemoizer<Directory>();
  Future<Directory> get _tmpDir async =>
      _tmpDirMemo.runOnce(() => _getTmpDir());

  FileStore._internal();

  factory FileStore() => _instance;

  Future<Directory> _getTmpDir() async {
    final tmp = await getTemporaryDirectory();
    final unique = Random().nextInt(1 << 32);
    final tmpName = path_pkg.join(tmp.path, 'meesign_client-$unique');
    return Directory(tmpName);
  }

  Future<String> getFilePath(Uuid id, String name) async {
    return path_pkg.join(
      (await _tmpDir).path,
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
