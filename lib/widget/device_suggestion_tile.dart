import 'package:flutter/material.dart';
import 'package:meesign_client/theme.dart';
import 'package:meesign_client/util/chars.dart';
import 'package:meesign_client/widget/device_name.dart';
import 'package:meesign_core/meesign_core.dart';

class DeviceSuggestionTile extends StatelessWidget {
  const DeviceSuggestionTile({
    required this.device,
    super.key,
    this.active = false,
    this.selected = false,
    this.onChanged,
  });
  final Device device;
  final bool active;
  final bool selected;
  // Checkbox callback signature requires positional bool parameter.
  // ignore: avoid_positional_boolean_parameters
  final void Function(bool?)? onChanged;

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
        isLocalDevice: device.isLocal,
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
