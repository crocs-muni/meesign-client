export 'file_store_stub.dart'
    if (dart.library.io) 'file_store_native.dart'
    if (dart.library.js_interop) 'file_store_web.dart';
