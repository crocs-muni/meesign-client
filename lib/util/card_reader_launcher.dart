import 'package:flutter/material.dart' hide Card;
import 'package:meesign_client/pages/card_reader_page.dart';
import 'package:meesign_core/meesign_card.dart';

void launchCardReader(
  BuildContext context,
  Future<void> Function(Card) onCard,
) {
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (context) => CardReaderPage(
        onCard: onCard,
      ),
    ),
  );
}
