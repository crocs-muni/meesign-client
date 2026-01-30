import 'dart:io';

import 'package:meesign_client/card/nfc_card.dart';
import 'package:meesign_client/card/pcsc_card.dart';
import 'package:meesign_core/meesign_card.dart';

abstract class CardManager {
  factory CardManager() {
    if (Platform.isAndroid || Platform.isIOS) {
      return NfcCardManager();
    }
    if (Platform.isLinux || Platform.isWindows) {
      return PcscCardManager();
    }
    throw UnsupportedError('Platform not supported');
  }
  Future<void> connect();
  Future<void> disconnect();

  Future<List<Card>> poll();

  Future<List<String>> get readers;

  static bool get platformSupported =>
      Platform.isAndroid ||
      Platform.isIOS ||
      Platform.isLinux ||
      Platform.isWindows;
}
