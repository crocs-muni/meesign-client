import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_data.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../util/chars.dart';
import '../util/qr_coder.dart';
import '../widget/avatar_app_bar.dart';

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
        const SizedBox(height: 8),
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
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 192,
            pinned: true,
            flexibleSpace: FlexibleAvatarAppBar(name: device.name),
          ),
          SliverList.list(
            children: [
              Center(
                child: SizedBox(
                  width: 256,
                  child: DeviceIdentityWidget(device: device),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }
}
