import 'package:flutter/material.dart';

class Settings {
  final ThemeMode themeMode;
  final bool showArchivedItems;
  final String currentUserId;

  Settings({
    this.themeMode = ThemeMode.light,
    this.showArchivedItems = false,
    this.currentUserId = '',
  });

  Settings copyWith({
    ThemeMode? themeMode,
    bool? showArchivedItems,
    String? currentUserId,
  }) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      showArchivedItems: showArchivedItems ?? this.showArchivedItems,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }
}
