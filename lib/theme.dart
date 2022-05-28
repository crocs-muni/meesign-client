import 'package:flutter/material.dart';

class AppTheme {
  static final light = ThemeData.from(
    colorScheme: const ColorScheme.light().copyWith(
      primary: Colors.indigo,
      primaryContainer: Colors.indigo[700],
      secondary: Colors.amberAccent[200],
      secondaryContainer: Colors.amberAccent[700],
    ),
  ).copyWith(
    // necessary for avatar color, seems like a bug
    primaryColorDark: Colors.indigo[700],
  );

  static final dark = ThemeData.from(
    colorScheme: const ColorScheme.dark().copyWith(
      primary: Colors.indigo[200],
      primaryContainer: Colors.indigo[700],
      secondary: Colors.amberAccent[200],
      secondaryContainer: Colors.amberAccent[200],
    ),
  );
}
