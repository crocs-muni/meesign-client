import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:meesign_client/util/platform_io_stub.dart'
    if (dart.library.io) 'platform_io.dart';

class PlatformGroup {
  static const bool isWeb = kIsWeb;
  static final bool isMobile = !kIsWeb && platformIsMobile();
  static final bool isDesktop = !kIsWeb && platformIsDesktop();
  static final bool isAndroid = !kIsWeb && platformIsAndroid();
  static final bool isIOS = !kIsWeb && platformIsIOS();
  static final bool isLinux = !kIsWeb && platformIsLinux();
  static final bool isWindows = !kIsWeb && platformIsWindows();
  static final bool isMacOS = !kIsWeb && platformIsMacOS();
}
