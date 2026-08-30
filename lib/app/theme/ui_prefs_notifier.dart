import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/local/hive_boxes.dart';

enum AddressBarPosition { top, bottom }

/// User-facing appearance + layout preferences (§7.18).
class UiPrefs {
  const UiPrefs({
    this.themeMode = ThemeMode.system,
    this.accentColor = const Color(0xFF1A73E8),
    this.fontScale = 1.0,
    this.addressBarPosition = AddressBarPosition.top,
    this.locale,
    this.ocrEnabled = false,
  });

  final ThemeMode themeMode;
  final Color accentColor;
  final double fontScale;
  final AddressBarPosition addressBarPosition;
  final String? locale; // null => system
  final bool ocrEnabled;

  UiPrefs copyWith({
    ThemeMode? themeMode,
    Color? accentColor,
    double? fontScale,
    AddressBarPosition? addressBarPosition,
    String? locale,
    bool? clearLocale,
    bool? ocrEnabled,
  }) =>
      UiPrefs(
        themeMode: themeMode ?? this.themeMode,
        accentColor: accentColor ?? this.accentColor,
        fontScale: fontScale ?? this.fontScale,
        addressBarPosition: addressBarPosition ?? this.addressBarPosition,
        locale: clearLocale == true ? null : (locale ?? this.locale),
        ocrEnabled: ocrEnabled ?? this.ocrEnabled,
      );
}

final uiPrefsBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError('uiPrefsBoxProvider must be overridden in main()');
});

final uiPrefsProvider =
    NotifierProvider<UiPrefsNotifier, UiPrefs>(UiPrefsNotifier.new);

class UiPrefsNotifier extends Notifier<UiPrefs> {
  Box get _box => ref.read(uiPrefsBoxProvider);

  @override
  UiPrefs build() => _read();

  UiPrefs _read() {
    final themeName = _box.get(PrefKeys.themeMode, defaultValue: 'system');
    final accent = _box.get(PrefKeys.accentColor,
        defaultValue: const Color(0xFF1A73E8).toARGB32());
    final fontScale = _box.get(PrefKeys.fontScale, defaultValue: 1.0);
    final barPos = _box.get(PrefKeys.addressBarPosition, defaultValue: 'top');
    final locale = _box.get(PrefKeys.locale) as String?;
    final ocr = _box.get(PrefKeys.ocrEnabled, defaultValue: false);
    return UiPrefs(
      themeMode: switch (themeName) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      accentColor: Color(accent as int),
      fontScale: (fontScale as num).toDouble(),
      addressBarPosition: barPos == 'bottom'
          ? AddressBarPosition.bottom
          : AddressBarPosition.top,
      locale: locale,
      ocrEnabled: ocr as bool,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _box.put(PrefKeys.themeMode,
        switch (mode) { ThemeMode.light => 'light', ThemeMode.dark => 'dark', _ => 'system' });
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setAccentColor(Color color) async {
    await _box.put(PrefKeys.accentColor, color.toARGB32());
    state = state.copyWith(accentColor: color);
  }

  Future<void> setFontScale(double scale) async {
    await _box.put(PrefKeys.fontScale, scale);
    state = state.copyWith(fontScale: scale);
  }

  Future<void> setAddressBarPosition(AddressBarPosition pos) async {
    await _box.put(PrefKeys.addressBarPosition,
        pos == AddressBarPosition.bottom ? 'bottom' : 'top');
    state = state.copyWith(addressBarPosition: pos);
  }

  Future<void> setLocale(String? locale) async {
    if (locale == null) {
      await _box.delete(PrefKeys.locale);
      state = state.copyWith(clearLocale: true);
    } else {
      await _box.put(PrefKeys.locale, locale);
      state = state.copyWith(locale: locale);
    }
  }

  Future<void> setOcrEnabled(bool enabled) async {
    await _box.put(PrefKeys.ocrEnabled, enabled);
    state = state.copyWith(ocrEnabled: enabled);
  }
}
