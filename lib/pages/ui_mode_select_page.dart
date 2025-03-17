import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_container.dart';
import '../services/settings_controller.dart';
import '../templates/default_page_template.dart';
import '../ui_constants.dart';

class UiModeSelectPage extends StatefulWidget {
  const UiModeSelectPage({super.key});

  @override
  State<UiModeSelectPage> createState() => _UiModeSelectPageState();
}

class _UiModeSelectPageState extends State<UiModeSelectPage> {
  @override
  Widget build(BuildContext context) {
    final AppContainer container = context.read<AppContainer>();
    final SettingsController settingsController = container.settingsController;

    return DefaultPageTemplate(
        appBarTitle: 'Settings',
        showAppBar: true,
        body: Container(
          padding: EdgeInsets.all(XLARGE_PADDING),
          width: double.infinity,
          child: Column(
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

                  return SwitchListTile(
                    title: Text('Dark mode'),
                    value: settings.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      settingsController.updateThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light);
                      settingsController.getSharedPref();
                    },
                  );
                },
              ),
            ],
          ),
        ));
  }
}
