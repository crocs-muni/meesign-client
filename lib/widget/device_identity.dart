import 'package:flutter/material.dart';
import 'package:meesign_client/util/qr_coder.dart';
import 'package:meesign_client/widget/hex_table.dart';
import 'package:meesign_core/meesign_core.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DeviceIdentity extends StatelessWidget {
  const DeviceIdentity({required this.device, super.key});
  final Device device;

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
