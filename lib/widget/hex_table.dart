import 'package:flutter/material.dart';

import '../util/chars.dart';

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
