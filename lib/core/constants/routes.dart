/// Named route paths used across the app.
class Routes {
  const Routes._();

  static const String splash = '/';
  static const String browser = '/browser';
  static const String newTab = 'new-tab';
  static const String tabSwitcher = 'tab-switcher';
  static const String history = 'history';
  static const String bookmarks = 'bookmarks';
  static const String downloads = 'downloads';
  static const String passwords = 'passwords';
  static const String flashcards = 'flashcards';
  static const String newsSources = 'news-sources';
  static const String settings = 'settings';
  static const String permissions = 'permissions';

  /// Dictionary browse/search screen (§7.6), nested under [browser].
  static const String dictionary = 'dictionary';

  /// Full entry screen (§7.7). Pushed from [dictionary] with the entry id.
  static const String wordDetail = 'word-detail';
  static const String wordDetailPath = 'word/:id';
}
