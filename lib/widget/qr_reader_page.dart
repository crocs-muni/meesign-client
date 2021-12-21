import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mpc_demo/mpc_model.dart';
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

    final code = data.code;
    if (code == null || !code.startsWith('application/mpc;')) {
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

    // application/mpc;name,id
    final qrData = code.split(';')[1].split(',');
    final cosigner =
        Cosigner.fromBase64(qrData[0], CosignerType.app, qrData[1]);
    // TODO: is the stream always recreated after a pop?
    _dataStream?.cancel();
    Navigator.pop(context, cosigner);
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
