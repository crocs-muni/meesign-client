import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_data.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../app_container.dart';
import '../util/qr_coder.dart';

class QrIdentityPage extends StatelessWidget {
  const QrIdentityPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Code'),
      ),
      body: const SafeArea(
        child: Center(
          child: DeviceQrCode(),
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

  Future<Device?> _getDevice() async {
    final di = context.read<AppContainer>();
    final did = await di.prefRepository.getDid();
    if (did == null) return null;
    return di.deviceRepository.getDevice(did);
  }

  @override
  void initState() {
    super.initState();
    _device = _getDevice();
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

        final color = Theme.of(context).colorScheme.onSurface;
        return QrImageView(
          padding: const EdgeInsets.all(24),
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: color,
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: color,
          ),
          data: QrCoder().encode(snapshot.data!),
        );
      },
    );
  }
}
