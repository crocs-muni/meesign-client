import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_model.dart';

import '../pages/device_page.dart';
import '../pages/group_page.dart';
import '../util/chars.dart';
import 'device_name.dart';

class DeviceChip extends StatelessWidget {
  final Device device;

  final void Function()? onDeleted;

  const DeviceChip({super.key, required this.device, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    return InputChip(
      avatar: CircleAvatar(
        child: Text(
          device.name.initials,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
      label: DeviceName(
        device.name,
        kind: device.kind,
        iconSize: 20,
      ),
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

class GroupChip extends StatelessWidget {
  final Group group;

  const GroupChip({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return InputChip(
      avatar: CircleAvatar(
        child: Text(
          group.name.initials,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
      label: Text(group.name),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => GroupPage(group: group),
          ),
        );
      },
    );
  }
}
