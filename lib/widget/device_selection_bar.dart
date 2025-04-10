import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_core.dart';

import '../ui_constants.dart';
import 'entity_chip.dart';

class DeviceSelectionBar extends StatefulWidget implements PreferredSizeWidget {
  final List<Device> devices;
  final void Function(Device) onDeleted;

  const DeviceSelectionBar({
    super.key,
    required this.devices,
    required this.onDeleted,
  });

  @override
  State<DeviceSelectionBar> createState() => _DeviceSelectionBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}

class _DeviceSelectionBarState extends State<DeviceSelectionBar> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: SMALL_PADDING),
      height: widget.preferredSize.height,
      child: Scrollbar(
        controller: _scrollController,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          itemCount: widget.devices.isEmpty ? 1 : widget.devices.length,
          itemBuilder: (context, index) {
            Device? device;
            if (widget.devices.isEmpty) {
              device = null;
            } else {
              device = widget.devices[index];
            }
            return _buildDeviceChip(device, widget.onDeleted);
          },
        ),
      ),
    );
  }

  Widget _buildDeviceChip(
    Device? device,
    void Function(Device) onDeleted,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Align(
        alignment: Alignment.topCenter,
        child: device == null
            ? InputChip(
                label: Text("No peer selected"),
              )
            : DeviceChip(
                device: device,
                onDeleted: () => onDeleted(device),
              ),
      ),
    );
  }
}
