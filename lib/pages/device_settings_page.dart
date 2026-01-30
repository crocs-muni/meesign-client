import 'package:flutter/material.dart';
import 'package:meesign_client/l10n/arb/app_localizations.dart';
import 'package:meesign_client/pages/register_page.dart';
import 'package:meesign_client/templates/default_page_template.dart';
import 'package:meesign_client/ui_constants.dart';
import 'package:meesign_client/util/confirm_device_change.dart';
import 'package:meesign_client/util/fade_black_page_transition.dart';
import 'package:meesign_client/view_model/app_view_model.dart';
import 'package:meesign_client/widget/change_device_section.dart';
import 'package:meesign_client/widget/danger_zone_section.dart';
import 'package:provider/provider.dart';

class DeviceSettingsPage extends StatefulWidget {
  const DeviceSettingsPage({super.key});

  @override
  State<DeviceSettingsPage> createState() => _DeviceSettingsPageState();
}

class _DeviceSettingsPageState extends State<DeviceSettingsPage> {
  final _nameController = TextEditingController();
  final FocusNode _nameControllerFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameControllerFocus.addListener(checkFocus);

    // Delay execution until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appViewModel = context.read<AppViewModel>();
      setState(() {
        _nameController.text = appViewModel.device?.name ?? '';
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameControllerFocus.removeListener(checkFocus);
    super.dispose();
  }

  void checkFocus() {
    // Hide clear input button when not focused
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultPageTemplate(
      appBarTitle: AppLocalizations.of(context).deviceSettingsTitle,
      showAppBar: true,
      wrapInScroll: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDeviceNameSection(),
          const SizedBox(height: XLARGE_GAP),
          _buildChangeServerSection(),
          const SizedBox(height: XLARGE_GAP * 2),
          _buildDangerZone(),
        ],
      ),
    );
  }

  Widget _buildDeviceNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).deviceName,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: SMALL_GAP),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              enabled: false,
              readOnly: true,
              controller: _nameController,
              focusNode: _nameControllerFocus,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                suffixIcon:
                    _nameController.text == '' || !_nameControllerFocus.hasFocus
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(_nameController.clear);
                            },
                          ),
                filled: true,
                hintText:
                    AppLocalizations.of(context).nameToIdentifyYourselfHint,
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChangeServerSection() {
    return ChangeDeviceSection(
      onChangeServer: () async {
        final res = await showChangeServerDialog(context, mounted: mounted);

        if (res == null || !res) {
          return;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              FadeBlackPageTransition.fadeBlack(
                destination: const RegisterPage(),
              ),
              (route) => false,
            );
          }
        });
      },
    );
  }

  Widget _buildDangerZone() {
    return const DangerZoneSection();
  }
}
