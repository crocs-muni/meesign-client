import 'dart:typed_data';

import 'package:meesign_core/src/card/apdu.dart';

abstract class Card {
  Future<Uint8List> transceive(Uint8List data);
  Future<ResponseApdu> send(CommandApdu command) async {
    final data = await transceive(command.takeBytes());
    return ResponseApdu(data);
  }

  Future<void> disconnect();
}

class SelectException implements Exception {}
