import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_data.dart';

import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/chars.dart';
import '../widget/avatar_app_bar.dart';
import '../widget/device_identity.dart';
import '../widget/device_name.dart';

class DevicePage extends StatelessWidget {
  final Device device;

  const DevicePage({
    super.key,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultPageTemplate(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleAvatarAppBar(
              avatar: Text(device.name.initials),
              title: DeviceName(device.name, kind: device.kind),
            ),
          ),
          SliverList.list(
            children: [
              SizedBox(height: XLARGE_GAP),
              Center(
                child: SizedBox(
                  width: 256,
                  child: DeviceIdentity(device: device),
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
