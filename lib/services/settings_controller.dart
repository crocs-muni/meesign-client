import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/model/settings.dart';

class SettingsController {
  static const autoJoinGroupKey = 'autoJoinGroups';
  static const autoRejectGroupKey = 'autoRejectGroups';
  static const showArchivedItemsKey = 'showArchivedItems';
  static const currentUserIdKey = 'currentUserId';
  static const themeModeKey = 'themeMode';
  static const defaultThemeMode = ThemeMode.system;
  static const minGroupMembersKey = 'minGroupMembers';

  // Seed settings controller stream with default settings
  final _settingsController = BehaviorSubject<Settings>.seeded(
    Settings(
      themeMode: ThemeMode.system,
    ),
  );

  Stream<Settings> get settingsStream => _settingsController.stream;
  Settings get currentSettings => _settingsController.value;

  SettingsController() {
    setup();
  }

  void setup() async {
    _initThemeSettings();
    _initShowArchivedItemsSettings();
    _initGroupAutomation();
    _initCurrentUserIdSettings();
    _initMinGroupMembers();
  }

  void updateAutoJoinGroups(bool autoJoin) {
    _updateSettingsStream(autoJoinGroups: autoJoin);
    if (autoJoin) {
      updateAutoRejectGroups(false);
    }
  }

  void updateAutoRejectGroups(bool autoReject) {
    _updateSettingsStream(autoRejectGroups: autoReject);
    if (autoReject) {
      updateAutoJoinGroups(false);
    }
  }

  void updateThemeMode(ThemeMode themeMode) =>
      _updateSettingsStream(themeMode: themeMode);
  void updateShowArchivedItems(bool showArchivedItems) =>
      _updateSettingsStream(showArchivedItems: showArchivedItems);
  void updateCurrentUserId(String currentUserId) =>
      _updateSettingsStream(currentUserId: currentUserId);
  void updateMinGroupMembers(int minGroupMembers) {
    _updateSettingsStream(minGroupMembers: minGroupMembers);
  }

  void _updateSettingsStream(
      {ThemeMode? themeMode,
      bool? showArchivedItems,
      String? currentUserId,
      bool? autoJoinGroups,
      bool? autoRejectGroups,
      int? minGroupMembers}) {
    final currentSettings = _settingsController.value;
    final updatedSettings = currentSettings.copyWith(
        themeMode: themeMode ?? currentSettings.themeMode,
        showArchivedItems:
            showArchivedItems ?? currentSettings.showArchivedItems,
        currentUserId: currentUserId ?? currentSettings.currentUserId,
        autoJoinGroups: autoJoinGroups ?? currentSettings.autoJoinGroups,
        autoRejectGroups: autoRejectGroups ?? currentSettings.autoRejectGroups,
        minGroupMembers: minGroupMembers ?? currentSettings.minGroupMembers);
    _settingsController.add(updatedSettings);

    SharedPreferences.getInstance().then((sharedPreferences) {
      sharedPreferences.setString(
          themeModeKey, getThemeIdentifier(updatedSettings.themeMode));
      sharedPreferences.setBool(
          showArchivedItemsKey, updatedSettings.showArchivedItems);
      sharedPreferences.setString(
          currentUserIdKey, updatedSettings.currentUserId);
      sharedPreferences.setBool(
          autoJoinGroupKey, updatedSettings.autoJoinGroups);
      sharedPreferences.setBool(
          autoRejectGroupKey, updatedSettings.autoRejectGroups);
      sharedPreferences.setInt(
          minGroupMembersKey, updatedSettings.minGroupMembers);
    });
  }

  void _initThemeSettings() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? themeModeIdentifier =
        sharedPreferences.getString(themeModeKey) ?? 'system';

    updateThemeMode(getThemeModeFromIdentifier(themeModeIdentifier));
    sharedPreferences.setString(themeModeKey, themeModeIdentifier);
  }

  void _initShowArchivedItemsSettings() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool? showArchivedItems =
        sharedPreferences.getBool(showArchivedItemsKey) ?? false;

    updateShowArchivedItems(showArchivedItems);
    sharedPreferences.setBool(showArchivedItemsKey, showArchivedItems);
  }

  void _initCurrentUserIdSettings() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? currentUserId = sharedPreferences.getString(currentUserIdKey) ?? '';

    updateCurrentUserId(currentUserId);
    sharedPreferences.setString(currentUserIdKey, currentUserId);
  }

  void _initGroupAutomation() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool? autoJoinGroups = sharedPreferences.getBool(autoJoinGroupKey) ?? true;
    bool? autoRejectGroups =
        sharedPreferences.getBool(autoRejectGroupKey) ?? false;

    updateAutoJoinGroups(autoJoinGroups);
    updateAutoRejectGroups(autoRejectGroups);
    sharedPreferences.setBool(autoJoinGroupKey, autoJoinGroups);
    sharedPreferences.setBool(autoRejectGroupKey, autoRejectGroups);
  }

  void _initMinGroupMembers() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    int? minGroupMembers = sharedPreferences.getInt(minGroupMembersKey) ?? 2;
    updateMinGroupMembers(minGroupMembers);
    sharedPreferences.setInt(minGroupMembersKey, minGroupMembers);
  }

  void saveUserIdentifier(String deviceName, String host, String id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("$deviceName/$host", id);
  }

  // Used to check if provided name on provided server is already registered
  Future<String?> getSavedUserId(String deviceName, String host) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString("$deviceName/$host");
  }

  void saveHostData(String deviceName, String host) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("host", host);
    sharedPreferences.setString("name", deviceName);
  }

  Future<void> deleteHostData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? host = sharedPreferences.getString("host");
    String? name = sharedPreferences.getString("name");
    sharedPreferences.remove("${name!}/${host!}");
  }

  void saveNameById(String name, String id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(id, name);
  }

  Future<String?> getNameById(String id) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(id);
  }

  void saveLastHostname(String hostname) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('hostname', hostname);
  }

  Future<String?> getLastHostname() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('hostname');
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
