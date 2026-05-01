import 'dart:io';

import 'package:path_provider/path_provider.dart';

class AppDirGetter {
  static Future<Directory> _resolve(
    String? override,
    Future<Directory> Function() fallback,
  ) async {
    if (override != null) {
      final dir = Directory(override);
      await dir.create(recursive: true);
      return dir;
    }
    return fallback();
  }

  static Future<Directory> getAppDir({String? override}) {
    return _resolve(override, () async {
      // iOS/macOS: ~/Library - backed up by iCloud/Time Machine but hidden
      // from the user, per Apple's data storage guidelines.
      if (Platform.isIOS || Platform.isMacOS) {
        return getLibraryDirectory();
      }
      // Linux/Windows/Android: per-user, writable application data dir
      // (XDG_DATA_HOME / %APPDATA% / Android internal storage). Must NOT be
      // derived from the executable path - read-only on NixOS, packaged
      // installs, and most Linux distros.
      return getApplicationSupportDirectory();
    });
  }

  static Future<Directory> getTempDir({String? override}) {
    return _resolve(override, getTemporaryDirectory);
  }

  static Future<Directory> getDocumentsDir({String? override}) {
    return _resolve(override, getApplicationDocumentsDirectory);
  }

  static Future<Directory> getCacheDir({String? override}) {
    return _resolve(override, getApplicationCacheDirectory);
  }

  // path_provider returns null on platforms without a downloads concept
  // (e.g. Android). Override is honoured unconditionally.
  static Future<Directory?> getDownloadsDir({String? override}) async {
    if (override != null) {
      final dir = Directory(override);
      await dir.create(recursive: true);
      return dir;
    }
    return getDownloadsDirectory();
  }
}
