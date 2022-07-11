import 'dart:io';
import 'dart:math';

import 'package:async/async.dart';
import 'package:path/path.dart' as path_pkg;
import 'package:path_provider/path_provider.dart';

import 'file_store.dart';

class TmpDirProvider implements DirProvider {
  final _tmpDirMemo = AsyncMemoizer<Directory>();

  Future<Directory> _getTmpDir() async {
    final tmp = await getTemporaryDirectory();
    final unique = Random().nextInt(1 << 32);
    final tmpName = path_pkg.join(tmp.path, 'meesign_client-$unique');
    return Directory(tmpName);
  }

  @override
  Future<Directory> getStoreDirectory() =>
      _tmpDirMemo.runOnce(() => _getTmpDir());
}
