import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_data.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../util/chars.dart';
import '../util/qr_coder.dart';

class HexTable extends StatelessWidget {
  final String hex;
  final int charsPerCell;
  final int width;
  final TableColumnWidth columnWidth;

  const HexTable({
    super.key,
    required this.hex,
    this.charsPerCell = 4,
    this.width = 4,
    this.columnWidth = const FlexColumnWidth(),
  });

  @override
  Widget build(BuildContext context) {
    final chunks = hex.splitByLength(charsPerCell).toList();
    assert(width > 1);
    final height = (chunks.length + 1) ~/ width;

    return Table(
      defaultColumnWidth: columnWidth,
      children: [
        for (int y = 0; y < height; ++y)
          TableRow(children: [
            for (int x = 0; x < width; ++x)
              Center(
                child: Text(
                  chunks[y * width + x],
                  style: const TextStyle(fontFamily: 'RobotoMono'),
                ),
              )
          ])
      ],
    );
  }
}

class DeviceAvatar extends StatelessWidget {
  final Device device;
  final double? avatarSize;

  const DeviceAvatar({
    super.key,
    required this.device,
    this.avatarSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: avatarSize,
          child: FittedBox(
            child: CircleAvatar(
              child: Text(device.name.initials),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          device.name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }
}

class DeviceIdentityWidget extends StatelessWidget {
  final Device device;

  const DeviceIdentityWidget({super.key, required this.device});

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
        const SizedBox(height: 16),
        HexTable(hex: device.id.encode()),
      ],
    );
  }
}

class DevicePage extends StatelessWidget {
  final Device device;

  const DevicePage({
    super.key,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          Center(
            child: DeviceAvatar(
              device: device,
              avatarSize: 112,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 256,
              child: DeviceIdentityWidget(device: device),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
