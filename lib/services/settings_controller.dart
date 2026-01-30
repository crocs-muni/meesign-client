import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:meesign_client/app/model/settings.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController {
  SettingsController() {
    setup();
  }
  static const autoJoinGroupKey = 'autoJoinGroups';
  static const autoRejectGroupKey = 'autoRejectGroups';
  static const showArchivedItemsKey = 'showArchivedItems';
  static const currentUserIdKey = 'currentUserId';
  static const themeModeKey = 'themeMode';
  static const ThemeMode defaultThemeMode = ThemeMode.system;
  static const minGroupMembersKey = 'minGroupMembers';
  static const currentLanguageKey = 'currentLanguage';
  static const defaultLanguage = 'en';
  static const closeWithoutConfirmationKey = 'close_without_confirmation';
  static const authenticateProtectedActionsKey =
      'authenticate_protected_actions';

  // Seed settings controller stream with default settings
  final _settingsController = BehaviorSubject<Settings>.seeded(
    Settings(
      themeMode: ThemeMode.system,
    ),
  );

  Stream<Settings> get settingsStream => _settingsController.stream;
  Settings get currentSettings => _settingsController.value;

  Future<void> setup() async {
    _initThemeSettings();
    _initShowArchivedItemsSettings();
    _initGroupAutomation();
    _initCurrentUserIdSettings();
    _initMinGroupMembers();
    _initLanguageSettings();
    _initCloseWithoutConfirmation();
    _initAuthenticateProtectedActions();
  }

  void updateAutoJoinGroups({required bool autoJoin}) {
    _updateSettingsStream(autoJoinGroups: autoJoin);
    if (autoJoin) {
      updateAutoRejectGroups(autoReject: false);
    }
  }

  void updateAutoRejectGroups({required bool autoReject}) {
    _updateSettingsStream(autoRejectGroups: autoReject);
    if (autoReject) {
      updateAutoJoinGroups(autoJoin: false);
    }
  }

  void updateThemeMode(ThemeMode themeMode) =>
      _updateSettingsStream(themeMode: themeMode);
  void updateShowArchivedItems({required bool showArchivedItems}) =>
      _updateSettingsStream(showArchivedItems: showArchivedItems);
  void updateCurrentUserId(String currentUserId) =>
      _updateSettingsStream(currentUserId: currentUserId);
  void updateMinGroupMembers(int minGroupMembers) {
    _updateSettingsStream(minGroupMembers: minGroupMembers);
  }

  void updateCurrentLanguage(String currentLanguage) =>
      _updateSettingsStream(currentLanguage: currentLanguage);

  void updateCloseWithoutConfirmation({
    required bool closeWithoutConfirmation,
  }) =>
      _updateSettingsStream(closeWithoutConfirmation: closeWithoutConfirmation);

  void updateAuthenticateProtectedActions({
    required bool authenticateProtectedActions,
  }) =>
      _updateSettingsStream(
        authenticateProtectedActions: authenticateProtectedActions,
      );

  void _updateSettingsStream({
    ThemeMode? themeMode,
    bool? showArchivedItems,
    String? currentUserId,
    bool? autoJoinGroups,
    bool? autoRejectGroups,
    int? minGroupMembers,
    String? currentLanguage,
    bool? closeWithoutConfirmation,
    bool? authenticateProtectedActions,
  }) {
    final currentSettings = _settingsController.value;
    final updatedSettings = currentSettings.copyWith(
      themeMode: themeMode ?? currentSettings.themeMode,
      showArchivedItems: showArchivedItems ?? currentSettings.showArchivedItems,
      currentUserId: currentUserId ?? currentSettings.currentUserId,
      autoJoinGroups: autoJoinGroups ?? currentSettings.autoJoinGroups,
      autoRejectGroups: autoRejectGroups ?? currentSettings.autoRejectGroups,
      minGroupMembers: minGroupMembers ?? currentSettings.minGroupMembers,
      currentLanguage: currentLanguage ?? currentSettings.currentLanguage,
      closeWithoutConfirmation:
          closeWithoutConfirmation ?? currentSettings.closeWithoutConfirmation,
      authenticateProtectedActions: authenticateProtectedActions ??
          currentSettings.authenticateProtectedActions,
    );
    _settingsController.add(updatedSettings);

    SharedPreferences.getInstance().then((sharedPreferences) {
      sharedPreferences
        ..setString(
          themeModeKey,
          getThemeIdentifier(updatedSettings.themeMode),
        )
        ..setBool(
          showArchivedItemsKey,
          updatedSettings.showArchivedItems,
        )
        ..setString(
          currentUserIdKey,
          updatedSettings.currentUserId,
        )
        ..setBool(
          autoJoinGroupKey,
          updatedSettings.autoJoinGroups,
        )
        ..setBool(
          autoRejectGroupKey,
          updatedSettings.autoRejectGroups,
        )
        ..setInt(
          minGroupMembersKey,
          updatedSettings.minGroupMembers,
        )
        ..setString(
          currentLanguageKey,
          updatedSettings.currentLanguage,
        )
        ..setBool(
          closeWithoutConfirmationKey,
          updatedSettings.closeWithoutConfirmation,
        )
        ..setBool(
          authenticateProtectedActionsKey,
          updatedSettings.authenticateProtectedActions,
        );
    });
  }

  Future<void> _initThemeSettings() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final themeModeIdentifier =
        sharedPreferences.getString(themeModeKey) ?? 'system';

    updateThemeMode(getThemeModeFromIdentifier(themeModeIdentifier));
    sharedPreferences.setString(themeModeKey, themeModeIdentifier);
  }

  Future<void> _initShowArchivedItemsSettings() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final showArchivedItems =
        sharedPreferences.getBool(showArchivedItemsKey) ?? false;

    updateShowArchivedItems(showArchivedItems: showArchivedItems);
    sharedPreferences.setBool(showArchivedItemsKey, showArchivedItems);
  }

  Future<void> _initCurrentUserIdSettings() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final currentUserId = sharedPreferences.getString(currentUserIdKey) ?? '';

    updateCurrentUserId(currentUserId);
    sharedPreferences.setString(currentUserIdKey, currentUserId);
  }

  Future<void> _initGroupAutomation() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final autoJoinGroups = sharedPreferences.getBool(autoJoinGroupKey) ?? false;
    final autoRejectGroups =
        sharedPreferences.getBool(autoRejectGroupKey) ?? false;

    updateAutoJoinGroups(autoJoin: autoJoinGroups);
    updateAutoRejectGroups(autoReject: autoRejectGroups);
    sharedPreferences
      ..setBool(autoJoinGroupKey, autoJoinGroups)
      ..setBool(autoRejectGroupKey, autoRejectGroups);
  }

  Future<void> _initMinGroupMembers() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final minGroupMembers = sharedPreferences.getInt(minGroupMembersKey) ?? 2;
    updateMinGroupMembers(minGroupMembers);
    sharedPreferences.setInt(minGroupMembersKey, minGroupMembers);
  }

  Future<void> _initLanguageSettings() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final savedLanguage = sharedPreferences.getString(currentLanguageKey);

    String currentLanguage;
    if (savedLanguage != null) {
      // Use saved language if it exists
      currentLanguage = savedLanguage;
    } else {
      // For devel branch use English by default
      currentLanguage = defaultLanguage;
    }

    updateCurrentLanguage(currentLanguage);
    sharedPreferences.setString(currentLanguageKey, currentLanguage);
  }

  Future<void> _initCloseWithoutConfirmation() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final closeWithoutConfirmation =
        sharedPreferences.getBool(closeWithoutConfirmationKey) ?? false;

    updateCloseWithoutConfirmation(
      closeWithoutConfirmation: closeWithoutConfirmation,
    );
    sharedPreferences.setBool(
      closeWithoutConfirmationKey,
      closeWithoutConfirmation,
    );
  }

  Future<void> _initAuthenticateProtectedActions() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final authenticateProtectedActions =
        sharedPreferences.getBool(authenticateProtectedActionsKey) ?? true;

    updateAuthenticateProtectedActions(
      authenticateProtectedActions: authenticateProtectedActions,
    );
    sharedPreferences.setBool(
      authenticateProtectedActionsKey,
      authenticateProtectedActions,
    );
  }

  Future<void> saveUserIdentifier(
    String deviceName,
    String host,
    String id,
  ) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('$deviceName/$host', id);
  }

  // Used to check if provided name on provided server is already registered
  Future<String?> getSavedUserId(String deviceName, String host) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('$deviceName/$host');
  }

  Future<void> saveHostData(String deviceName, String host) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences
      ..setString('host', host)
      ..setString('name', deviceName);
  }

  Future<void> deleteHostData() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final host = sharedPreferences.getString('host');
    final name = sharedPreferences.getString('name');
    sharedPreferences.remove('${name!}/${host!}');
  }

  Future<void> saveNameById(String name, String id) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(id, name);
  }

  Future<String?> getNameById(String id) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(id);
  }

  Future<void> saveLastHostname(String hostname) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('hostname', hostname);
  }

  Future<String?> getLastHostname() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('hostname');
  }

  ThemeMode getSystemBrightness() {
    final brightness =
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

  // Returns a list of available language codes
  List<String> getAvailableLanguages() {
    return ['en', 'cs'];
  }

  // Returns the display name for a language code
  String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'cs':
        return 'Čeština';
      default:
        return languageCode.toUpperCase();
    }
  }

  // Validates if a language code is supported
  bool isLanguageSupported(String languageCode) {
    return getAvailableLanguages().contains(languageCode);
  }

  // Gets the current language locale
  Locale getCurrentLanguageLocale() {
    return Locale(currentSettings.currentLanguage);
  }
}
