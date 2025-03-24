import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/model/settings.dart';

class SettingsController {
  // Seed settings controller stream with default settings
  final _settingsController = BehaviorSubject<Settings>.seeded(
    Settings(
      themeMode: ThemeMode.system,
    ),
  );

  Stream<Settings> get settingsStream => _settingsController.stream;

  SettingsController() {
    setup();
  }

  void setup() async {
    _initThemeSettings();
    _initShowArchivedItemsSettings();
  }

  void updateThemeMode(ThemeMode themeMode) =>
      _updateSettingsStream(themeMode: themeMode);
  void updateShowArchivedItems(bool showArchivedItems) =>
      _updateSettingsStream(showArchivedItems: showArchivedItems);

  void _updateSettingsStream({ThemeMode? themeMode, bool? showArchivedItems}) {
    final currentSettings = _settingsController.value;
    final updatedSettings = currentSettings.copyWith(
      themeMode: themeMode ?? currentSettings.themeMode,
      showArchivedItems: showArchivedItems ?? currentSettings.showArchivedItems,
    );
    _settingsController.add(updatedSettings);

    SharedPreferences.getInstance().then((sharedPreferences) {
      sharedPreferences.setString(
          'themeMode', getThemeIdentifier(updatedSettings.themeMode));
      sharedPreferences.setBool(
          'showArchivedItems', updatedSettings.showArchivedItems);
    });
  }

  void _initThemeSettings() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? themeModeIdentifier =
        sharedPreferences.getString('themeMode') ?? 'system';

    updateThemeMode(getThemeModeFromIdentifier(themeModeIdentifier));
    sharedPreferences.setString('themeMode', themeModeIdentifier);
  }

  void _initShowArchivedItemsSettings() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool? showArchivedItems =
        sharedPreferences.getBool('showArchivedItems') ?? false;

    updateShowArchivedItems(showArchivedItems);
    sharedPreferences.setBool('showArchivedItems', showArchivedItems);
  }

  ThemeMode getSystemBrightness() {
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
  }

  String getThemeIdentifier(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode getThemeModeFromIdentifier(String identifier) {
    switch (identifier) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }
}
