import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_model.dart';

import '../ui/device_page.dart';
import '../util/chars.dart';

class EntityChip extends StatelessWidget {
  final String name;

  final void Function()? onPressed;
  final void Function()? onDeleted;

  const EntityChip({
    super.key,
    required this.name,
    this.onPressed,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return InputChip(
      avatar: CircleAvatar(
        child: Text(
          name.initials,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
      label: Text(name),
      onPressed: onPressed,
      onDeleted: onDeleted,
    );
  }
}

class DeviceChip extends StatelessWidget {
  final Device device;

  final void Function()? onDeleted;

  const DeviceChip({super.key, required this.device, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return EntityChip(
      name: device.name,
      onDeleted: onDeleted,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => DevicePage(device: device),
          ),
        );
      },
    );
  }
}
