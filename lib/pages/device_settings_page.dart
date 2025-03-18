import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../templates/default_page_template.dart';
import '../ui_constants.dart';
import '../view_model/app_view_model.dart';
import '../widget/confirmation_dialog.dart';

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Device name",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: SMALL_GAP),
          Consumer<AppViewModel>(builder: (context, model, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  focusNode: _nameControllerFocus,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    suffixIcon: _nameController.text == "" ||
                            !_nameControllerFocus.hasFocus
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
                    hint: Text(
                      'Name to identify yourself',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.outline),
                    ),
                    border: const OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 0),
                    ),
                    errorText: null,
                  ),
                ),
                SizedBox(height: MEDIUM_GAP),
                FilledButton.icon(
                  onPressed: _nameController.text.isEmpty ||
                          _nameController.text == model.device?.name
                      ? null
                      : () {
                          // TODO: Update device name
                        },
                  icon: Icon(Icons.save),
                  label: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text('Update name'),
                  ),
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: XLARGE_GAP),
          Text(
            "Change server",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: SMALL_GAP),
          Text(
            "This will take you back to the registration screen where you can change the server or register a new device.",
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
          SizedBox(height: MEDIUM_GAP),
          FilledButton.icon(
            onPressed: () {
              _showDeleteDialog();
            },
            label: Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Text('Change server'),
            ),
            icon: Icon(Icons.sync),
            style: ButtonStyle(
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(height: XLARGE_GAP * 2),
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
      ),
    );
  }

  void _showDeleteDialog() {
    return showConfirmationDialog(
      context,
      'Confirm deletion',
      'Are you sure you want to delete this device?',
      'Delete',
      () {},
    );
  }
}
