import 'package:meesign_core/meesign_data.dart';

import 'dart:convert';

class QrCoder {
  static const String mime = 'application/meesign';

  late final _base64encoder = const Base64Encoder.urlSafe();
  late final _base64decoder = const Base64Decoder();

  String encode(Device device) {
    final base64Id = _base64encoder.convert(device.id.bytes);
    return '$mime;$base64Id,${device.name},${device.kind.name}';
  }

  Device decode(String? data) {
    if (data == null || !data.startsWith(mime)) {
      throw const FormatException('Incorrect QR data format');
    }

    final args = data.split(';')[1].split(',');
    if (args.length != 3) throw const FormatException('Malformed QR data');

    final id = _base64decoder.convert(args[0]);
    final name = args[1];
    final kind = DeviceKind.values.firstWhere((kind) => kind.name == args[2]);

    return Device(name, Uuid(id), kind, DateTime.now());
  }
}
