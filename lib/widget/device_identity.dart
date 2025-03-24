import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../util/qr_coder.dart';
import 'hex_table.dart';

class DeviceIdentity extends StatelessWidget {
  final Device device;

  const DeviceIdentity({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        QrImageView(
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: color,
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: color,
          ),
          data: QrCoder().encode(device),
        ),
        const SizedBox(height: 8),
        HexTable(hex: device.id.encode()),
      ],
    );
  }
}
