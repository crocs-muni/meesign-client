import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

void downloadFileOnWeb(Uint8List bytes, String filename) {
  final blob = web.Blob(
    [bytes.toJS].toJS,
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = filename
    ..style.display = 'none';
  web.document.body!.appendChild(anchor);
  anchor
    ..click()
    ..remove();
  web.URL.revokeObjectURL(url);
}
