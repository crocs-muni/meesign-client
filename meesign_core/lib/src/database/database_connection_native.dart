import 'dart:io' as io;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:meesign_core/src/database/database.dart';
import 'package:path/path.dart' as path_pkg;

QueryExecutor openDatabaseConnection(String dirPath) {
  return LazyDatabase(() async {
    final file = io.File(path_pkg.join(dirPath, Database.fileName));
    return NativeDatabase.createInBackground(file);
  });
}
