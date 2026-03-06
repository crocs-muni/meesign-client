import 'dart:typed_data';

import 'package:meesign_core/src/util/uuid.dart';

class FileStore {
  // Matches native FileStore constructor signature for conditional imports.
  // ignore: avoid_unused_constructor_parameters
  FileStore([String? dirPath]);

  Future<void> init() async {}

  String getFilePath(Uuid did, Uuid id, String name, {bool work = false}) {
    throw UnsupportedError('FileStore not available on this platform.');
  }

  Future<String> storeFile(
    Uuid did,
    Uuid id,
    String name,
    List<int> data, {
    bool work = false,
  }) async {
    throw UnsupportedError('FileStore not available on this platform.');
  }

  Uint8List? getFileBytes(String path) {
    throw UnsupportedError('FileStore not available on this platform.');
  }

  Future<void> deleteDirectory(String path) async {
    throw UnsupportedError('FileStore not available on this platform.');
  }
}
