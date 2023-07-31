import 'dart:io' as io;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path_pkg;

QueryExecutor constructDatabase(String? dirPath, String fileName) =>
    LazyDatabase(() async {
      final file = io.File(path_pkg.join(dirPath ?? '', fileName));
      return NativeDatabase.createInBackground(file);
    });
