import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrReaderPage extends StatefulWidget {
  const QrReaderPage({Key? key}) : super(key: key);

  @override
  _QrReaderPageState createState() => _QrReaderPageState();
}

class _QrReaderPageState extends State<QrReaderPage> {
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;

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
    print(data.code);
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
                controller.scannedDataStream.listen(_onData);
              },
            ),
          ),
          const Expanded(
            flex: 1,
            child: Center(
              child: Text('Scan the code of the peer'),
            ),
          )
        ],
      ),
    );
  }
}
