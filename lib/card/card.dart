import 'dart:io';

import 'package:meesign_core/meesign_card.dart';

import 'nfc_card.dart';
import 'pcsc_card.dart';

abstract class CardManager {
  Future<void> connect();
  Future<void> disconnect();

  Future<List<Card>> poll();

  Future<List<String>> get readers;

  static bool get platformSupported =>
      Platform.isAndroid ||
      Platform.isIOS ||
      Platform.isLinux ||
      Platform.isWindows;

  factory CardManager() {
    if (Platform.isAndroid || Platform.isIOS) {
      return NfcCardManager();
    }
    if (Platform.isLinux || Platform.isWindows) {
      return PcscCardManager();
    }
    throw UnsupportedError('Platform not supported');
  }
}
