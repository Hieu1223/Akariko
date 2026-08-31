/// Hive box names + typed accessors for settings/preferences.
class HiveBoxes {
  const HiveBoxes._();

  static const String settings = 'settings';
  static const String prefs = 'ui_prefs';
  static const String lastTab = 'last_open_tab';
}

/// Strongly-typed keys inside the [HiveBoxes.prefs] box.
class PrefKeys {
  const PrefKeys._();

  static const String themeMode = 'theme_mode'; // 'system' | 'light' | 'dark'
  static const String accentColor = 'accent_color'; // int (ARGB)
  static const String fontScale = 'font_scale'; // double
  static const String addressBarPosition = 'address_bar_position'; // 'top'|'bottom'
  static const String locale = 'locale'; // 'system' | 'en' | 'ja' | 'vi'
  static const String ocrEnabled = 'ocr_enabled'; // bool
  static const String chatGptPrompt =
      'chatgpt_prompt'; // String template, {text} placeholder
  static const String autoHideChrome =
      'auto_hide_chrome'; // bool — collapse bars on scroll
  static const String searchSuggestionsEnabled =
      'search_suggestions_enabled'; // bool — query Google's suggest endpoint
  static const String maxTabHistory =
      'max_tab_history'; // int — per-tab history stack size
  static const String cachedTabCount =
      'cached_tab_count'; // int — tabs retaining live page state
  static const String tabPageTimeoutSec =
      'tab_page_timeout_sec'; // int — release page data after idle
  static const String tabSwipeToClose =
      'tab_swipe_to_close'; // bool — swipe to delete in tab switcher
  static const String topBarHeight =
      'top_bar_height'; // double — height of the address/top bar
  static const String bottomBarHeight =
      'bottom_bar_height'; // double — height of the bottom toolbar
  static const String perfOverlayEnabled =
      'perf_overlay_enabled'; // bool — show the RAM/CPU bubble
  static const String perfRefreshMs =
      'perf_refresh_ms'; // int — monitor sampling interval
}

/// Strongly-typed keys inside the [HiveBoxes.settings] box.
class SettingsKeys {
  const SettingsKeys._();

  /// Most-recently-opened dictionary entry ids, newest first (`List<String>`).
  static const String dictionaryRecentIds = 'dictionary_recent_ids';
}
