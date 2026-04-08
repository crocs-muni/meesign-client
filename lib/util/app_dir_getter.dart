export 'app_dir_getter_stub.dart'
    if (dart.library.io) 'app_dir_getter_native.dart'
    if (dart.library.js_interop) 'app_dir_getter_web.dart';
