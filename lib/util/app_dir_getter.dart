import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_pkg;

class AppDirGetter {
  static Future<Directory> getAppDir() async {
    if (Platform.isIOS || Platform.isMacOS) {
      return getLibraryDirectory();
    }

    if (Platform.isAndroid) {
      return getApplicationSupportDirectory();
    }

    final path = path_pkg.join(
      path_pkg.dirname(Platform.resolvedExecutable),
      'app',
    );
    return Directory(path);
  }
}
