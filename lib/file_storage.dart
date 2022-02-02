import 'dart:io';
import 'dart:math';

import 'package:async/async.dart';
import 'package:path/path.dart' as path_pkg;
import 'package:path_provider/path_provider.dart';

class FileStorage {
  final _tmpDirMemo = AsyncMemoizer<Directory>();
  Future<Directory> get _tmpDir async =>
      _tmpDirMemo.runOnce(() => _createTmpDir());
  final _signedDirMemo = AsyncMemoizer<Directory>();
  Future<Directory> get _signedDir async =>
      _signedDirMemo.runOnce(() => _createSignedDir());

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

  Future<String> getTmpFilePath(String basename) async {
    final tmpDir = await _tmpDir;
    // TODO: this should be the place to handle name conflicts etc.
    return path_pkg.join(
      tmpDir.path,
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
