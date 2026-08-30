import 'package:flutter/material.dart';

import 'ui_prefs_notifier.dart';

/// Builds a Safari-like [ThemeData] from the current [UiPrefs].
ThemeData buildAppTheme(UiPrefs prefs) {
  final accent = prefs.accentColor;
  final base = Brightness.light;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: base,
    primary: accent,
  ).copyWith(
    secondary: accent,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white.withValues(alpha: 0.9),
    ),
    textTheme: ThemeData.light().textTheme.apply(
          fontSizeFactor: prefs.fontScale,
        ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    ),
  );
}

ThemeData buildDarkTheme(UiPrefs prefs) {
  final accent = prefs.accentColor;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: Brightness.dark,
  ).copyWith(secondary: accent);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    textTheme: ThemeData.dark().textTheme.apply(fontSizeFactor: prefs.fontScale),
  );
}
