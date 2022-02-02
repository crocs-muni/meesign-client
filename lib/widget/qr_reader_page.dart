import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meesign_client/util/qr_coder.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrReaderPage extends StatefulWidget {
  const QrReaderPage({Key? key}) : super(key: key);

  @override
  _QrReaderPageState createState() => _QrReaderPageState();
}

class _QrReaderPageState extends State<QrReaderPage> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
  StreamSubscription? _dataStream;

  bool _recentError = false;
  Timer? _errorTimer;

  final QrCoder _coder = QrCoder();

  @override
  void reassemble() {
    super.reassemble();

    // necessary for hot reload
    if (Platform.isAndroid) {
      _controller!.pauseCamera();
    } else if (Platform.isIOS) {
      _controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onData(Barcode data) {
    _errorTimer?.cancel();

    try {
      final cosigner = _coder.decode(data.code);
      _dataStream?.cancel();
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
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: _qrKey,
              overlay: QrScannerOverlayShape(
                borderRadius: 16,
                borderColor: Colors.amber,
              ),
              onQRViewCreated: (controller) {
                _controller = controller;
                _dataStream = controller.scannedDataStream.listen(_onData);
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: _recentError
                  ? const Text(
                      'This code does not belong to any peer',
                      style: TextStyle(
                        color: Colors.red,
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
