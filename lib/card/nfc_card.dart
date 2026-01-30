import 'dart:typed_data';

import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:meesign_client/card/card.dart';
import 'package:meesign_core/meesign_card.dart';

class NfcCard extends Card {
  NfcCard(this._tag);
  // Ignore linter
  // ignore: unused_field
  final NFCTag _tag;

  @override
  Future<Uint8List> transceive(Uint8List data) =>
      FlutterNfcKit.transceive(data, timeout: const Duration(seconds: 8));

  @override
  Future<void> disconnect() => FlutterNfcKit.finish();
}

class NfcCardManager implements CardManager {
  @override
  Future<List<Card>> poll() async {
    final tag = await FlutterNfcKit.poll(
      androidCheckNDEF: false,
    );
    return [NfcCard(tag)];
  }

  // TODO(dev): we might want to throw here if the feature
  // is not supported at all
  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() => FlutterNfcKit.finish();

  @override
  Future<List<String>> get readers async {
    final avail = await FlutterNfcKit.nfcAvailability;
    if (avail == NFCAvailability.available) return ['default'];
    return [];
  }
}
