import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:meesign_client/mpc_model.dart';

class CardReaderPage extends StatefulWidget {
  const CardReaderPage({Key? key}) : super(key: key);

  @override
  _CardReaderPageState createState() => _CardReaderPageState();
}

class _CardReaderPageState extends State<CardReaderPage> {
  bool _working = false;

  // TODO: check for availability

  void _pollTag() async {
    try {
      final tag = await FlutterNfcKit.poll(
        androidCheckNDEF: false,
      );

      setState(() {
        _working = true;
      });

      Uint8List apdu = Uint8List.fromList([0x00, 0xa4, 0x04, 0x00, 3, 1, 2, 3]);
      final response = await FlutterNfcKit.transceive(apdu);

      await Future.delayed(const Duration(seconds: 1));

      await FlutterNfcKit.finish();
      setState(() {
        _working = false;
      });

      // TODO: this should be done in mpc_model.dart
      final cosigner = Cosigner.random('card', CosignerType.card);

      Navigator.pop(context, cosigner);
    } catch (e) {
      setState(() {
        _working = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to read card'),
        ),
      );
      _pollTag();
    }
  }

  @override
  void initState() {
    super.initState();
    _pollTag();
  }

  @override
  void dispose() {
    FlutterNfcKit.finish();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: const [
                    BackButton(),
                  ],
                ),
              ),
              // TODO: this can overflow
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    elevation: 2,
                    shape: const CircleBorder(),
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        SizedBox.square(
                          dimension: 140,
                          child: CircularProgressIndicator(
                            value: _working ? null : 0,
                          ),
                        ),
                        Icon(
                          Icons.contactless,
                          size: 100,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Hold the card\n near the back of the device',
                      style: Theme.of(context).textTheme.subtitle1,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
