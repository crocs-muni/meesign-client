import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../app_container.dart';
import '../model/device.dart';
import '../util/qr_coder.dart';

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
              const Expanded(
                child: Center(
                  child: DeviceQrCode(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeviceQrCode extends StatefulWidget {
  const DeviceQrCode({Key? key}) : super(key: key);

  @override
  State<DeviceQrCode> createState() => _DeviceQrCodeState();
}

class _DeviceQrCodeState extends State<DeviceQrCode> {
  late final Future<Device?> _device;

  @override
  void initState() {
    super.initState();
    _device = context.read<AppContainer>().prefRepository.getDevice();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Device?>(
      future: _device,
      builder: (_, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.hasError) {
          return Container();
        }

        return QrImage(
          padding: const EdgeInsets.all(24),
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          data: QrCoder().encode(snapshot.data!),
        );
      },
    );
  }
}
