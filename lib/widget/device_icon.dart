import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_container.dart';
import '../pages/device_page.dart';
import '../theme.dart';
import '../ui_constants.dart';
import '../util/chars.dart';
import '../view_model/app_view_model.dart';

class DeviceIcon extends StatelessWidget {
  const DeviceIcon({super.key, this.showFullName = true});

  final bool showFullName;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(
      builder: (context, model, child) {
        final name = model.device?.name ?? '';
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showFullName) ...[
              Text(name, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(width: SMALL_GAP / 2),
            Container(
                padding: const EdgeInsets.only(right: SMALL_PADDING),
                child: IconButton(
                  onPressed: () {
                    final device = model.device;
                    if (device == null) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            DevicePage(device: device),
                      ),
                    );
                  },
                  icon: _buildIndicatorIcon(context, name),
                )),
          ],
        );
      },
    );
  }

  Widget _buildIndicatorIcon(BuildContext context, String name) {
    if (context.read<AppContainer>().session == null) {
      return _buildBadge(context, name);
    }

    var session = context.read<AppContainer>().session;

    return AnimatedBuilder(
      animation:
          session != null ? session.sync.subscribed : ValueNotifier(false),
      builder: (context, child) {
        return _buildBadge(context, name,
            isOnline: session != null && session.sync.subscribed.value);
      },
    );
  }

  Widget _buildBadge(BuildContext context, String name,
      {bool isOnline = false}) {
    return Badge(
      backgroundColor: isOnline
          ? Theme.of(context).extension<CustomColors>()!.success
          : Theme.of(context).colorScheme.error,
      smallSize: 8,
      child: CircleAvatar(
        child: Text(name.initials),
      ),
    );
  }
}
