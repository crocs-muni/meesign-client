import 'package:flutter/material.dart';

class Settings {
  final ThemeMode themeMode;
  final bool showArchivedItems;

  Settings({
    this.themeMode = ThemeMode.light,
    this.showArchivedItems = false,
  });

  Settings copyWith({ThemeMode? themeMode, bool? showArchivedItems}) {
    return Settings(
      themeMode: themeMode ?? this.themeMode,
      showArchivedItems: showArchivedItems ?? this.showArchivedItems,
    );
  }
}
