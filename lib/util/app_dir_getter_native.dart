import 'dart:io';

import 'package:path/path.dart' as path_pkg;
import 'package:path_provider/path_provider.dart';

class AppDirGetter {
  static Future<String> getAppDir() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final dir = await getLibraryDirectory();
      return dir.path;
    }

    if (Platform.isAndroid) {
      final dir = await getApplicationSupportDirectory();
      return dir.path;
    }

    return path_pkg.join(
      path_pkg.dirname(Platform.resolvedExecutable),
      'app',
    );
  }
}
