import 'package:flutter/material.dart' hide Card;

import '../card/card.dart';

class CardReaderPage extends StatefulWidget {
  const CardReaderPage({Key? key}) : super(key: key);

  @override
  State<CardReaderPage> createState() => _CardReaderPageState();
}

abstract class ReaderStatus {
  final String message;
  const ReaderStatus._(this.message);
}

class ReaderOkStatus extends ReaderStatus {
  const ReaderOkStatus._(String message) : super._(message);
  static const waiting = ReaderOkStatus._('Hold a card near the reader');
  static const working = ReaderOkStatus._('Do not remove the card');
}

class ReaderErrStatus extends ReaderStatus {
  const ReaderErrStatus._(String message) : super._(message);
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
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          Material(
            shape: const CircleBorder(),
            color: _hasError
                ? Theme.of(context).colorScheme.errorContainer
                : Theme.of(context).colorScheme.primaryContainer,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                SizedBox.square(
                  dimension: 140,
                  child: CircularProgressIndicator(
                    value: _status == ReaderOkStatus.working ? null : 0,
                  ),
                ),
                const Icon(
                  Icons.contactless,
                  size: 64,
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
