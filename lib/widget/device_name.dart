import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/ui_constants.dart';
import 'package:meesign_core/meesign_model.dart';

class DeviceName extends StatelessWidget {
  const DeviceName(
    this.name, {
    super.key,
    this.kind = DeviceKind.user,
    this.iconSize,
    this.textStyle,
    this.isLocalDevice = false,
  });
  final String name;
  final DeviceKind kind;
  final double? iconSize;
  final TextStyle? textStyle;
  final bool isLocalDevice;

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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: textStyle,
                softWrap: false,
                overflow: TextOverflow.fade,
              ),
              if (isLocalDevice) ...[
                const SizedBox(width: SMALL_GAP),
                Text(
                  AppLocalizations.of(context).selfDevice,
                  style: textStyle?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ) ??
                      TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize:
                            Theme.of(context).textTheme.titleSmall?.fontSize,
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
