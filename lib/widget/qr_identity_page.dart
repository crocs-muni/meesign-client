import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrIdentityPage extends StatelessWidget {
  const QrIdentityPage({Key? key}) : super(key: key);

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
              Expanded(
                child: Center(
                  child: QrImage(
                    padding: const EdgeInsets.all(24),
                    data: 'application/mpc;1234',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
