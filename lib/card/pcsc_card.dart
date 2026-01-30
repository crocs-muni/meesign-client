import 'dart:typed_data';

import 'package:dart_pcsc/dart_pcsc.dart' as pcsc;
import 'package:meesign_client/card/card.dart';
import 'package:meesign_core/meesign_card.dart';

class PcscCardDelegate extends Card {
  PcscCardDelegate(this._card);
  final pcsc.Card _card;

  @override
  Future<void> disconnect() => _card.disconnect(pcsc.Disposition.leaveCard);

  @override
  Future<Uint8List> transceive(Uint8List data) => _card.transmit(data);
}

class PcscCardManager implements CardManager {
  final pcsc.Context _context = pcsc.Context(pcsc.Scope.user);

  @override
  Future<void> connect() => _context.establish();

  @override
  Future<void> disconnect() => _context.release();

  @override
  Future<List<String>> get readers => _context.listReaders();

  @override
  Future<List<Card>> poll() async {
    final rs = await readers;
    if (rs.isEmpty) throw Exception('No reader');

    final withCard = await _context.waitForCard(rs).value;

    final card = await _context.connect(
      withCard.first,
      pcsc.ShareMode.shared,
      pcsc.Protocol.any,
    );

    return [PcscCardDelegate(card)];
  }
}
