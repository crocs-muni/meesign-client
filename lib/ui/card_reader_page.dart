import 'package:flutter/material.dart' hide Card;
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_core/meesign_card.dart';

import '../card/card.dart';
import '../util/platform.dart';

class CardReaderPage extends StatefulWidget {
  final Future<void> Function(Card) onCard;

  const CardReaderPage({required this.onCard, super.key});

  @override
  State<CardReaderPage> createState() => _CardReaderPageState();
}

sealed class ReaderStatus {
  final String message;
  const ReaderStatus._(this.message);
}

class ReaderOkStatus extends ReaderStatus {
  const ReaderOkStatus._(super.message) : super._();

  static final waiting = ReaderOkStatus._(
    PlatformGroup.isMobile
        ? 'Hold a card near the device'
        : 'Insert a card into the reader',
  );
  static const working = ReaderOkStatus._('Do not remove the card');
}

class ReaderErrStatus extends ReaderStatus {
  const ReaderErrStatus._(super.message) : super._();
  static const noReader = ReaderErrStatus._('No reader available');
  static const initError = ReaderErrStatus._('Cannot connect to card manager');
}

class _CardReaderPageState extends State<CardReaderPage> {
  final _manager = CardManager();
  ReaderStatus _status = ReaderOkStatus.waiting;

  bool get _hasError => _status is ReaderErrStatus;

  void setStatus(ReaderStatus status) => setState(() {
        _status = status;
      });

  @override
  void initState() {
    super.initState();
    _initManager();
  }

  @override
  void dispose() {
    _manager.disconnect();
    super.dispose();
  }

  Future<void> _initManager() async {
    try {
      await _manager.connect();
    } on Exception {
      setStatus(ReaderErrStatus.initError);
    }

    _poll();
  }

  void _poll() async {
    // TODO: wait for reader instead
    try {
      if ((await _manager.readers).isEmpty) throw Exception();
    } on Exception {
      setStatus(ReaderErrStatus.noReader);
      return;
    }

    try {
      final cards = await _manager.poll();
      // TODO: let the user pick one?
      final card = cards[0];
      setStatus(ReaderOkStatus.working);

      try {
        await widget.onCard(card);
        Navigator.pop(context);
      } finally {
        await card.disconnect();
        setStatus(ReaderOkStatus.waiting);
      }
    } catch (e) {
      /* FIXME: make sure not to end up in a busy loop */
      if (!mounted) return;
      _showError();
      _poll();
    }
  }

  void _showError({String message = 'Failed to read card'}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          Material(
            shape: const CircleBorder(),
            color: _hasError
                ? colorScheme.errorContainer
                : colorScheme.primaryContainer,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                SizedBox.square(
                  dimension: 140,
                  child: CircularProgressIndicator(
                    value: _status == ReaderOkStatus.working ? null : 0,
                  ),
                ),
                Icon(
                  Symbols.contactless,
                  size: 64,
                  color: _hasError ? colorScheme.error : colorScheme.primary,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _status.message,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
