import 'dart:convert';

import '../mpc_model.dart';

class QrCoder {
  static const String mime = 'application/meesign';

  late final _base64encoder = const Base64Encoder.urlSafe();
  late final _base64decoder = const Base64Decoder();

  String encode(Cosigner cosigner) {
    final base64Id = _base64encoder.convert(cosigner.id);
    return '$mime;${cosigner.name},$base64Id';
  }

  Cosigner decode(String? data) {
    if (data == null || !data.startsWith(mime)) {
      throw const FormatException('Incorrect QR data format');
    }

    final args = data.split(';')[1].split(',');
    final id = _base64decoder.convert(args[1]);

    return Cosigner(args[0], id, CosignerType.app);
  }
}
