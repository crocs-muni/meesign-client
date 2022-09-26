import 'dart:ffi';
import 'dart:io';

String dlPlatformName(String name) {
  if (Platform.isAndroid || Platform.isLinux) return 'lib$name.so';
  if (Platform.isWindows) return '$name.dll';
  if (Platform.isMacOS) return '$name.dylib';
  throw Exception('Platform unsupported');
}

DynamicLibrary dlOpen(String name) {
  return DynamicLibrary.open(dlPlatformName(name));
}
