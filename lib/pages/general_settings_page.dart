import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/model/settings.dart';
import '../app_container.dart';
import '../services/settings_controller.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';

class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppContainer container = context.read<AppContainer>();
    final SettingsController settingsController = container.settingsController;

    return DefaultPageTemplate(
      appBarTitle: 'General settings',
      showAppBar: true,
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
                  _buildThemeSettingsSection(
                      settingsController, settings, context),
                  SizedBox(height: XLARGE_GAP * 2),
                  _buildArchivedSettingsSection(
                      settingsController, settings, context),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSettingsSection(
      SettingsController controller, Settings settings, BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Theme settings",
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: SMALL_GAP),
        Text(
            "You can manually set your preferred theme, or use the system theme to automatically set color scheme based on your OS settings.",
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.outline)),
        SizedBox(height: SMALL_GAP),
        SwitchListTile(
          title: Text('Use system theme', style: theme.textTheme.bodyMedium),
          value: settings.themeMode == ThemeMode.system,
          onChanged: (value) {
            controller.updateThemeMode(
                value ? ThemeMode.system : controller.getSystemBrightness());
          },
        ),
        if (settings.themeMode != ThemeMode.system) ...[
          SwitchListTile(
            title: Text('Dark mode', style: theme.textTheme.bodyMedium),
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (value) {
              controller
                  .updateThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
        ]
      ],
    );
  }

  Widget _buildArchivedSettingsSection(
      SettingsController controller, Settings settings, BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Archivation settings",
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: SMALL_GAP),
        Text(
            "You can choose whether to display items that have been archived before Archived items will be shown in their corresponding pages.",
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.outline)),
        SizedBox(height: SMALL_GAP),
        SwitchListTile(
          title: Text('Show archived items', style: theme.textTheme.bodyMedium),
          value: settings.showArchivedItems,
          onChanged: (value) {
            controller.updateShowArchivedItems(value);
          },
        ),
      ],
    );
  }
}
