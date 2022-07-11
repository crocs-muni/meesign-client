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
      _tmpDirMemo.runOnce(() => _createTmpDir());

  FileStore._internal();

  factory FileStore() => _instance;

  Future<Directory> _createTmpDir() async {
    final tmp = await getTemporaryDirectory();
    final unique = Random().nextInt(1 << 32);
    final tmpName = path_pkg.join(tmp.path, 'meesign_client-$unique');
    return Directory(tmpName).create();
  }

  Future<String> getTaskFilePath(String basename, Uuid taskId) async {
    final tmpDir = await _tmpDir;
    final taskDir = Directory(
      path_pkg.join(tmpDir.path, base64Url.encode(taskId.bytes)),
    );
    await taskDir.create();
    return path_pkg.join(
      taskDir.path,
      basename,
    );
  }
}
