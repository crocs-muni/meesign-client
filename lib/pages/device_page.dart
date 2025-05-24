import 'package:flutter/material.dart';
import 'package:meesign_core/meesign_data.dart';

import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/chars.dart';
import '../util/confirm_device_change.dart';
import '../util/fade_black_page_transition.dart';
import '../widget/avatar_app_bar.dart';
import '../widget/change_device_section.dart';
import '../widget/danger_zone_section.dart';
import '../widget/device_identity.dart';
import '../widget/device_name.dart';
import 'register_page.dart';

class DevicePage extends StatefulWidget {
  final Device device;
  final bool showActionButtons;

  const DevicePage({
    super.key,
    required this.device,
    this.showActionButtons = true,
  });

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultPageTemplate(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleAvatarAppBar(
              avatar: Text(widget.device.name.initials),
              title: DeviceName(widget.device.name, kind: widget.device.kind),
            ),
          ),
          SliverList.list(
            children: [
              SizedBox(height: XLARGE_GAP),
              Center(
                child: SizedBox(
                  width: 256,
                  child: DeviceIdentity(device: widget.device),
                ),
              ),
              if (widget.showActionButtons) ...[
                const SizedBox(height: XLARGE_GAP),
                Center(
                    child: ChangeDeviceSection(
                  onChangeServer: () async {
                    var res = await showChangeServerDialog(context, mounted);

                    if (res == null || res == false) {
                      return;
                    }

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        Navigator.of(context, rootNavigator: true)
                            .pushAndRemoveUntil(
                          FadeBlackPageTransition.fadeBlack(
                              destination: RegisterPage()),
                          (route) => false,
                        );
                      }
                    });
                  },
                  centerContent: true,
                  showText: false,
                )),
                const SizedBox(height: LARGE_GAP),
                Center(
                  child: DangerZoneSection(
                    centerContent: true,
                    showText: false,
                  ),
                )
              ]
            ],
          ),
        ],
      ),
    );
  }
}
