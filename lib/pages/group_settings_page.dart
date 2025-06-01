import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/model/settings.dart';
import '../app_container.dart';
import '../services/settings_controller.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';

class GroupSettingsPage extends StatelessWidget {
  const GroupSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppContainer container = context.read<AppContainer>();
    final SettingsController settingsController = container.settingsController;

    return DefaultPageTemplate(
      appBarTitle: 'Group settings',
      showAppBar: true,
      wrapInScroll: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          StreamBuilder(
            stream: settingsController.settingsStream,
            builder: (context, settingsSnapshot) {
              if (settingsSnapshot.hasError || !settingsSnapshot.hasData) {
                return CircularProgressIndicator();
              }

              final settings = settingsSnapshot.data!;

              return Column(
                children: [
                  _buildAutomationSection(
                      settingsController, settings, context),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAutomationSection(
      SettingsController controller, Settings settings, BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Group automation settings",
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: SMALL_GAP),
        Text(
            "By default all group invitations you receive must be manually accepted. You can change this behaviour in the section bellow to automatically accept each invitation.",
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.outline)),
        SizedBox(height: SMALL_GAP),
        SwitchListTile(
          title: Text('Automatically accept group invitations',
              style: theme.textTheme.bodyMedium),
          value: settings.autoJoinGroups,
          onChanged: (value) {
            controller.updateAutoJoinGroups(value);
          },
        ),
        /*
          SwitchListTile(
            title: Text('Auto-reject group invitations',
                style: theme.textTheme.bodyMedium),
            value: settings.autoRejectGroups,
            onChanged: (value) {
              controller.updateAutoRejectGroups(value);
            },
          ),
        */
      ],
    );
  }
}
