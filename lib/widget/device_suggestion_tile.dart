import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';

import '../theme.dart';
import '../util/chars.dart';
import 'device_name.dart';

class DeviceSuggestionTile extends StatelessWidget {
  final Device device;
  final bool active;
  final bool selected;
  final void Function(bool?)? onChanged;

  const DeviceSuggestionTile({
    super.key,
    required this.device,
    this.active = false,
    this.selected = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: selected,
      onChanged: onChanged,
      secondary: Badge(
        backgroundColor: active
            ? Theme.of(context).extension<CustomColors>()!.success
            : Theme.of(context).colorScheme.error,
        smallSize: 8,
        child: CircleAvatar(
          child: Text(device.name.initials),
        ),
      ),
      title: DeviceName(
        device.name,
        kind: device.kind,
        iconSize: 20,
      ),
      subtitle: Text(
        device.id.encode().splitByLength(4).join(' '),
        softWrap: false,
        overflow: TextOverflow.fade,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .26),
          fontFamily: 'RobotoMono',
        ),
      ),
    );
  }
}
