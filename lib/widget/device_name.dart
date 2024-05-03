import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_core/meesign_model.dart';

class DeviceName extends StatelessWidget {
  final String name;
  final DeviceKind kind;

  final double? iconSize;
  final TextStyle? textStyle;

  const DeviceName(
    this.name, {
    super.key,
    this.kind = DeviceKind.user,
    this.iconSize,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (kind == DeviceKind.bot) ...[
          Icon(
            Symbols.smart_toy,
            size: iconSize,
            opticalSize: iconSize,
          ),
          SizedBox(width: (iconSize ?? 24) / 5),
        ],
        Flexible(
          child: Text(
            name,
            style: textStyle,
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
        ),
      ],
    );
  }
}
