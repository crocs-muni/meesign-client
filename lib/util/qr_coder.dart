import 'dart:convert';

import '../model/device.dart';
import 'uuid.dart';

class QrCoder {
  static const String mime = 'application/meesign';

  late final _base64encoder = const Base64Encoder.urlSafe();
  late final _base64decoder = const Base64Decoder();

  String encode(Device device) {
    final base64Id = _base64encoder.convert(device.id.bytes);
    return '$mime;$base64Id,${device.name}';
  }

  Device decode(String? data) {
    if (data == null || !data.startsWith(mime)) {
      throw const FormatException('Incorrect QR data format');
    }

    final args = data.split(';')[1];
    int i = args.indexOf(',');
    if (i == -1) throw const FormatException('Malformed QR data');

    final id = _base64decoder.convert(args.substring(0, i));
    final name = args.substring(i + 1);

    return Device(name, Uuid(id), DeviceType.app, DateTime.now());
  }
}
