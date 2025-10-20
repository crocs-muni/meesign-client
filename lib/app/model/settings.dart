import 'package:flutter/material.dart';

class Settings {
  final ThemeMode themeMode;
  final bool showArchivedItems;
  final String currentUserId;
  final bool autoJoinGroups;
  final bool autoRejectGroups;
  final int minGroupMembers;
  final String currentLanguage;
  final bool closeWithoutConfirmation;

  Settings(
      {this.themeMode = ThemeMode.light,
      this.showArchivedItems = false,
      this.currentUserId = '',
      this.autoJoinGroups = true,
      this.autoRejectGroups = false,
      this.minGroupMembers = 2,
      this.currentLanguage = 'en',
      this.closeWithoutConfirmation = false});

  Settings copyWith(
      {ThemeMode? themeMode,
      bool? showArchivedItems,
      String? currentUserId,
      bool? autoJoinGroups,
      bool? autoRejectGroups,
      int? minGroupMembers,
      String? currentLanguage,
      bool? closeWithoutConfirmation}) {
    return Settings(
        themeMode: themeMode ?? this.themeMode,
        showArchivedItems: showArchivedItems ?? this.showArchivedItems,
        currentUserId: currentUserId ?? this.currentUserId,
        autoJoinGroups: autoJoinGroups ?? this.autoJoinGroups,
        autoRejectGroups: autoRejectGroups ?? this.autoRejectGroups,
        minGroupMembers: minGroupMembers ?? this.minGroupMembers,
        currentLanguage: currentLanguage ?? this.currentLanguage,
        closeWithoutConfirmation:
            closeWithoutConfirmation ?? this.closeWithoutConfirmation);
  }
}
