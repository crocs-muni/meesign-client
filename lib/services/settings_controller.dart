import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/model/settings.dart';

class SettingsController {
  final _settingsController = BehaviorSubject<Settings>.seeded(Settings(
    themeMode:
        SchedulerBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
  ));
  Stream<Settings> get settingsStream => _settingsController.stream;

  SettingsController() {
    setup();
  }
  void setup() async {
    // Initialize the theme mode with the current platform brightness
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    bool? useDarkMode = sharedPreferences.getBool('useDarkMode');
    if (useDarkMode == null) {
      ThemeMode systemTheme = getSystemThemeMode();
      useDarkMode = systemTheme == ThemeMode.dark;
      sharedPreferences.setBool('useDarkMode', useDarkMode);
    }

    updateThemeMode(useDarkMode ? ThemeMode.dark : ThemeMode.light);
    sharedPreferences.setBool('useDarkMode', useDarkMode);
  }

  void updateThemeMode(ThemeMode themeMode) =>
      _updateSettings(themeMode: themeMode);

  void _updateSettings({ThemeMode? themeMode}) {
    final currentSettings = _settingsController.value;
    final updatedSettings = currentSettings.copyWith(themeMode: themeMode);
    _settingsController.add(updatedSettings);

    SharedPreferences.getInstance().then((sharedPreferences) {
      sharedPreferences.setBool('useDarkMode', themeMode == ThemeMode.dark);
    });
  }

  void getSharedPref() async {
    SharedPreferences.getInstance().then((sharedPreferences) {
      // print('Dark mode: ${sharedPreferences.getBool('useDarkMode')}');
    });
  }

  ThemeMode getSystemThemeMode() {
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
  }
}
