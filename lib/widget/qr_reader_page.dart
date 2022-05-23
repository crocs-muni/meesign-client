import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../util/qr_coder.dart';

class QrReaderPage extends StatefulWidget {
  const QrReaderPage({Key? key}) : super(key: key);

  @override
  _QrReaderPageState createState() => _QrReaderPageState();
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

  void _onDetect(Barcode data, MobileScannerArguments? _) {
    _errorTimer?.cancel();

    try {
      final cosigner = _coder.decode(data.rawValue);
      controller.dispose();
      Navigator.pop(context, cosigner);
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
              allowDuplicates: false,
              onDetect: _onDetect,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: _recentError
                  ? Text(
                      'This code does not belong to any peer',
                      style: TextStyle(
                        color: Theme.of(context).errorColor,
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
