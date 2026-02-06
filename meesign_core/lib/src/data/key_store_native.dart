import 'dart:io' as io;

import 'package:meesign_core/meesign_data.dart';
import 'package:path/path.dart' as path_pkg;

class KeyStore {
  KeyStore(String dirPath) : _dirPath = dirPath;
  final String _dirPath;

  static const String fileName = 'key.p12';

  io.File _getFile(Uuid did) {
    return io.File(
      path_pkg.join(
        _dirPath,
        did.encode(),
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

  Future<void> storeToken(Uuid did, String token) async {
    // Native clients use mTLS, tokens are not needed.
  }

  String? loadToken(Uuid did) {
    // Native clients use mTLS, tokens are not needed.
    return null;
  }
}
