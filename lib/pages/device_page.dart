import 'package:flutter/material.dart';
import 'package:meesign_client/pages/register_page.dart';
import 'package:meesign_client/templates/default_page_template.dart';
import 'package:meesign_client/ui_constants.dart';
import 'package:meesign_client/util/chars.dart';
import 'package:meesign_client/util/confirm_device_change.dart';
import 'package:meesign_client/util/fade_black_page_transition.dart';
import 'package:meesign_client/widget/avatar_app_bar.dart';
import 'package:meesign_client/widget/change_device_section.dart';
import 'package:meesign_client/widget/danger_zone_section.dart';
import 'package:meesign_client/widget/device_identity.dart';
import 'package:meesign_client/widget/device_name.dart';
import 'package:meesign_core/meesign_data.dart';

class DevicePage extends StatefulWidget {
  const DevicePage({
    required this.device,
    super.key,
    this.showActionButtons = true,
  });
  final Device device;
  final bool showActionButtons;

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
              const SizedBox(height: XLARGE_GAP),
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
                      final res = await showChangeServerDialog(
                        context,
                        mounted: mounted,
                      );

                      if (res == null || !res) {
                        return;
                      }

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          Navigator.of(context, rootNavigator: true)
                              .pushAndRemoveUntil(
                            FadeBlackPageTransition.fadeBlack(
                              destination: const RegisterPage(),
                            ),
                            (route) => false,
                          );
                        }
                      });
                    },
                    centerContent: true,
                    showText: false,
                  ),
                ),
                const SizedBox(height: LARGE_GAP),
                const Center(
                  child: DangerZoneSection(
                    centerContent: true,
                    showText: false,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
