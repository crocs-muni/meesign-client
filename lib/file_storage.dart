import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:async/async.dart';
import 'package:path/path.dart' as path_pkg;
import 'package:path_provider/path_provider.dart';

import 'util/uuid.dart';

class FileStorage {
  static final FileStorage _instance = FileStorage._internal();

  final _tmpDirMemo = AsyncMemoizer<Directory>();
  Future<Directory> get _tmpDir async =>
      _tmpDirMemo.runOnce(() => _createTmpDir());
  final _signedDirMemo = AsyncMemoizer<Directory>();
  Future<Directory> get _signedDir async =>
      _signedDirMemo.runOnce(() => _createSignedDir());

  FileStorage._internal();

  factory FileStorage() => _instance;

  Future<Directory> _createTmpDir() async {
    final tmp = await getTemporaryDirectory();
    final unique = Random().nextInt(1 << 32);
    final tmpName = path_pkg.join(tmp.path, 'meesign_client-$unique');
    return Directory(tmpName).create();
  }

  Future<Directory> _createSignedDir() async {
    final signedName = path_pkg.join((await _tmpDir).path, 'signed');
    return Directory(signedName).create();
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

  Future<String> getSignedFilePath(String basename) async {
    final signedDir = await _signedDir;
    return path_pkg.join(
      signedDir.path,
      basename,
    );
  }
}
