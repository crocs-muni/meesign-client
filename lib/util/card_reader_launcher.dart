import 'package:flutter/material.dart' hide Card;
import 'package:meesign_core/meesign_card.dart';
import '../pages/card_reader_page.dart';

void launchCardReader(
  BuildContext context,
  Future<void> Function(Card) onCard,
) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CardReaderPage(
        onCard: onCard,
      ),
    ),
  );
}
