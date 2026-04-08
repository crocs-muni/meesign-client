import 'dart:io';

bool platformIsMobile() => Platform.isAndroid || Platform.isIOS;
bool platformIsDesktop() =>
    Platform.isLinux || Platform.isMacOS || Platform.isWindows;
bool platformIsAndroid() => Platform.isAndroid;
bool platformIsIOS() => Platform.isIOS;
bool platformIsLinux() => Platform.isLinux;
bool platformIsWindows() => Platform.isWindows;
bool platformIsMacOS() => Platform.isMacOS;
