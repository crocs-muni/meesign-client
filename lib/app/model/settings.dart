import 'package:flutter/material.dart';

class Settings {
  final ThemeMode themeMode;
  final bool showArchivedItems;
  final String currentUserId;
  final bool autoJoinGroups;
  final bool autoRejectGroups;

  Settings(
      {this.themeMode = ThemeMode.light,
      this.showArchivedItems = false,
      this.currentUserId = '',
      this.autoJoinGroups = true,
      this.autoRejectGroups = false});

  Settings copyWith(
      {ThemeMode? themeMode,
      bool? showArchivedItems,
      String? currentUserId,
      bool? autoJoinGroups,
      bool? autoRejectGroups}) {
    return Settings(
        themeMode: themeMode ?? this.themeMode,
        showArchivedItems: showArchivedItems ?? this.showArchivedItems,
        currentUserId: currentUserId ?? this.currentUserId,
        autoJoinGroups: autoJoinGroups ?? this.autoRejectGroups,
        autoRejectGroups: autoRejectGroups ?? this.autoRejectGroups);
  }
}
