import 'dart:io';

class PlatformGroup {
  static final bool isMobile = Platform.isAndroid || Platform.isIOS;
  static final bool isDesktop =
      Platform.isLinux || Platform.isMacOS || Platform.isWindows;
}
