import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../util/qr_coder.dart';

class QrReaderPage extends StatefulWidget {
  const QrReaderPage({super.key});

  @override
  State<QrReaderPage> createState() => _QrReaderPageState();
}

class _QrReaderPageState extends State<QrReaderPage> {
  final MobileScannerController controller = MobileScannerController();

  bool _recentError = false;
  Timer? _errorTimer;

  final QrCoder _coder = QrCoder();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    _errorTimer?.cancel();

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    try {
      final device = _coder.decode(barcodes.first.rawValue);
      controller.dispose();
      Navigator.pop(context, [device]);
    } catch (e) {
      setState(() {
        _recentError = true;
      });
      _errorTimer = Timer(const Duration(seconds: 1), () {
        setState(() {
          _recentError = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: MobileScanner(
              onDetect: _onDetect,
              controller: controller,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: _recentError
                  ? Text(
                      'This code does not belong to any peer',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  : const Text('Scan the code of the peer'),
            ),
          )
        ],
      ),
    );
  }
}
