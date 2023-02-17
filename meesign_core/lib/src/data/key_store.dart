import 'dart:convert';
import 'dart:io' as io;

import 'package:meesign_core/meesign_data.dart';
import 'package:path/path.dart' as path_pkg;

class KeyStore {
  final io.Directory _dir;

  static const String fileName = 'key.p12';

  KeyStore(this._dir);

  io.File _getFile(Uuid did) {
    return io.File(
      path_pkg.join(
        _dir.path,
        base64Url.encode(did.bytes),
        fileName,
      ),
    );
  }

  Future<void> store(Uuid did, List<int> key) async {
    final file = _getFile(did);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(key);
  }

  List<int> load(Uuid did) {
    // FIXME: blocks
    return _getFile(did).readAsBytesSync();
  }
}
