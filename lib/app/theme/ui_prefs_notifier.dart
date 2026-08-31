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
    this.chatGptPrompt = _defaultChatGptPrompt,
    this.autoHideChrome = true,
    this.searchSuggestionsEnabled = true,
    this.maxTabHistory = 20,
    this.cachedTabCount = 2,
    this.tabPageTimeoutSec = 30,
    this.tabSwipeToClose = true,
    this.topBarHeight = 48,
    this.bottomBarHeight = 44,
    this.perfOverlayEnabled = false,
    this.perfRefreshMs = 1000,
  });

  final ThemeMode themeMode;
  final Color accentColor;
  final double fontScale;
  final AddressBarPosition addressBarPosition;
  final String? locale; // null => system
  final bool ocrEnabled;
  final String chatGptPrompt;
  final bool autoHideChrome;

  /// Send the address-bar text to Google's autocomplete endpoint while typing.
  /// When off, suggestions come only from local history and bookmarks.
  final bool searchSuggestionsEnabled;
  final int maxTabHistory;
  final int cachedTabCount;
  final int tabPageTimeoutSec;
  final bool tabSwipeToClose;
  final double topBarHeight;
  final double bottomBarHeight;
  final bool perfOverlayEnabled;
  final int perfRefreshMs;

  static const String _defaultChatGptPrompt =
      'Explain the following Japanese text in simple, beginner-friendly terms. '
      'Break down any grammar and list the key vocabulary:\n\n{text}';

  UiPrefs copyWith({
    ThemeMode? themeMode,
    Color? accentColor,
    double? fontScale,
    AddressBarPosition? addressBarPosition,
    String? locale,
    bool? clearLocale,
    bool? ocrEnabled,
    String? chatGptPrompt,
    bool? autoHideChrome,
    bool? searchSuggestionsEnabled,
    int? maxTabHistory,
    int? cachedTabCount,
    int? tabPageTimeoutSec,
    bool? tabSwipeToClose,
    double? topBarHeight,
    double? bottomBarHeight,
    bool? perfOverlayEnabled,
    int? perfRefreshMs,
  }) =>
      UiPrefs(
        themeMode: themeMode ?? this.themeMode,
        accentColor: accentColor ?? this.accentColor,
        fontScale: fontScale ?? this.fontScale,
        addressBarPosition: addressBarPosition ?? this.addressBarPosition,
        locale: clearLocale == true ? null : (locale ?? this.locale),
        ocrEnabled: ocrEnabled ?? this.ocrEnabled,
        chatGptPrompt: chatGptPrompt ?? this.chatGptPrompt,
        autoHideChrome: autoHideChrome ?? this.autoHideChrome,
        searchSuggestionsEnabled:
            searchSuggestionsEnabled ?? this.searchSuggestionsEnabled,
        maxTabHistory: maxTabHistory ?? this.maxTabHistory,
        cachedTabCount: cachedTabCount ?? this.cachedTabCount,
        tabPageTimeoutSec: tabPageTimeoutSec ?? this.tabPageTimeoutSec,
        tabSwipeToClose: tabSwipeToClose ?? this.tabSwipeToClose,
        topBarHeight: topBarHeight ?? this.topBarHeight,
        bottomBarHeight: bottomBarHeight ?? this.bottomBarHeight,
        perfOverlayEnabled: perfOverlayEnabled ?? this.perfOverlayEnabled,
        perfRefreshMs: perfRefreshMs ?? this.perfRefreshMs,
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
    final prompt = _box.get(PrefKeys.chatGptPrompt,
        defaultValue: UiPrefs._defaultChatGptPrompt) as String;
    final autoHide = _box.get(PrefKeys.autoHideChrome, defaultValue: true);
    final suggestions =
        _box.get(PrefKeys.searchSuggestionsEnabled, defaultValue: true);
    final maxHistory = _box.get(PrefKeys.maxTabHistory, defaultValue: 20);
    final cachedCount = _box.get(PrefKeys.cachedTabCount, defaultValue: 2);
    final pageTimeout =
        _box.get(PrefKeys.tabPageTimeoutSec, defaultValue: 30);
    final swipeToClose =
        _box.get(PrefKeys.tabSwipeToClose, defaultValue: true);
    final topBarHeight =
        _box.get(PrefKeys.topBarHeight, defaultValue: 48.0);
    final bottomBarHeight =
        _box.get(PrefKeys.bottomBarHeight, defaultValue: 44.0);
    final perfOverlay =
        _box.get(PrefKeys.perfOverlayEnabled, defaultValue: false);
    final refreshMs = _box.get(PrefKeys.perfRefreshMs, defaultValue: 1000);
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
      chatGptPrompt: prompt,
      autoHideChrome: autoHide as bool,
      searchSuggestionsEnabled: suggestions as bool,
      maxTabHistory: (maxHistory as num).toInt(),
      cachedTabCount: (cachedCount as num).toInt(),
      tabPageTimeoutSec: (pageTimeout as num).toInt(),
      tabSwipeToClose: swipeToClose as bool,
      topBarHeight: (topBarHeight as num).toDouble(),
      bottomBarHeight: (bottomBarHeight as num).toDouble(),
      perfOverlayEnabled: perfOverlay as bool,
      perfRefreshMs: (refreshMs as num).toInt(),
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

  Future<void> setChatGptPrompt(String prompt) async {
    await _box.put(PrefKeys.chatGptPrompt, prompt);
    state = state.copyWith(chatGptPrompt: prompt);
  }

  Future<void> setAutoHideChrome(bool enabled) async {
    await _box.put(PrefKeys.autoHideChrome, enabled);
    state = state.copyWith(autoHideChrome: enabled);
  }

  Future<void> setSearchSuggestionsEnabled(bool enabled) async {
    await _box.put(PrefKeys.searchSuggestionsEnabled, enabled);
    state = state.copyWith(searchSuggestionsEnabled: enabled);
  }

  Future<void> setMaxTabHistory(int value) async {
    final v = value.clamp(1, 999);
    await _box.put(PrefKeys.maxTabHistory, v);
    state = state.copyWith(maxTabHistory: v);
  }

  Future<void> setCachedTabCount(int value) async {
    final v = value.clamp(1, 10);
    await _box.put(PrefKeys.cachedTabCount, v);
    state = state.copyWith(cachedTabCount: v);
  }

  Future<void> setTabPageTimeoutSec(int value) async {
    final v = value.clamp(0, 9999);
    await _box.put(PrefKeys.tabPageTimeoutSec, v);
    state = state.copyWith(tabPageTimeoutSec: v);
  }

  Future<void> setTabSwipeToClose(bool enabled) async {
    await _box.put(PrefKeys.tabSwipeToClose, enabled);
    state = state.copyWith(tabSwipeToClose: enabled);
  }

  Future<void> setTopBarHeight(double value) async {
    final v = value.clamp(28.0, 120.0);
    await _box.put(PrefKeys.topBarHeight, v);
    state = state.copyWith(topBarHeight: v);
  }

  Future<void> setBottomBarHeight(double value) async {
    final v = value.clamp(36.0, 120.0);
    await _box.put(PrefKeys.bottomBarHeight, v);
    state = state.copyWith(bottomBarHeight: v);
  }

  Future<void> setPerfOverlayEnabled(bool enabled) async {
    await _box.put(PrefKeys.perfOverlayEnabled, enabled);
    state = state.copyWith(perfOverlayEnabled: enabled);
  }

  Future<void> setPerfRefreshMs(int ms) async {
    final v = ms.clamp(250, 5000);
    await _box.put(PrefKeys.perfRefreshMs, v);
    state = state.copyWith(perfRefreshMs: v);
  }
}
