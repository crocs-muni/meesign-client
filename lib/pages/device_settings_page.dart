import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_container.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../util/fade_black_page_transition.dart';
import '../view_model/app_view_model.dart';
import '../widget/change_device_section.dart';
import '../widget/confirmation_dialog.dart';
import 'register_page.dart';

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
      appBarTitle: 'Device settings',
      showAppBar: true,
      wrapInScroll: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildDeviceNameSection(),
          SizedBox(height: XLARGE_GAP),
          _buildChangeServerSection(),
          SizedBox(height: XLARGE_GAP * 2),
          _buildDangerZone()
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    return showConfirmationDialog(
      context,
      'Confirm deletion',
      'Are you sure you want to delete this device?',
      'Delete',
      () async {
        confirmDeviceChange(deleteData: true);
      },
    );
  }

  void _showChangeServerDialog() {
    return showConfirmationDialog(
      context,
      'Confirm profile change',
      'Are you sure you want to change server or device?',
      'Confirm',
      () {
        confirmDeviceChange(deleteData: false);
      },
    );
  }

  void confirmDeviceChange({bool deleteData = false}) {
    final appContainer = context.read<AppContainer>();

    appContainer.recreate(deleteData: deleteData);

    if (deleteData) {
      appContainer.settingsController.deleteHostData();
    }

    // This is to ensure that the app is recreated before navigating
    Future.delayed(const Duration(milliseconds: 0), () {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          FadeBlackPageTransition.fadeBlack(destination: RegisterPage()),
          (route) => false,
        );
      }
    });
  }

  Widget _buildDeviceNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Device name",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: SMALL_GAP),
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
                    _nameController.text == "" || !_nameControllerFocus.hasFocus
                        ? null
                        : IconButton(
                            // Icon to
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _nameController.clear();
                              });
                            },
                          ),
                filled: true,
                hintText: 'Name to identify yourself',
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary, width: 0),
                ),
                errorText: null,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildChangeServerSection() {
    return ChangeDeviceSection(onChangeServer: () {
      _showChangeServerDialog();
    });
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Danger zone",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        SizedBox(height: SMALL_GAP),
        Text(
          "This action will effectively delete your device and all associated data. After deletion, you will need to re-register your device to continue using the app.",
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
        SizedBox(height: MEDIUM_GAP),
        FilledButton.icon(
          onPressed: () {
            _showDeleteDialog();
          },
          label: Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text('Delete device',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer)),
          ),
          icon: Icon(Icons.delete,
              color: Theme.of(context).colorScheme.onErrorContainer),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(
                Theme.of(context).colorScheme.errorContainer),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
