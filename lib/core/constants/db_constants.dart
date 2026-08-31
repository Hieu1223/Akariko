/// String constants for database table and column names.
///
/// Centralised so generated Drift code and raw SQL (e.g. FTS5 queries) never
/// drift apart from the Dart table definitions. The values mirror the table
/// names Drift derives from the classes in `data/local/tables/`.
class DbConstants {
  const DbConstants._();

  // Tables
  static const String tabs = 'tabs_table';
  static const String history = 'history_table';
  static const String bookmarks = 'bookmarks_table';
  static const String dictionaryEntries = 'dictionary_entries_table';
  static const String decks = 'decks_table';
  static const String flashcards = 'flashcards_table';
  static const String reviewLogs = 'review_logs_table';
  static const String downloadItems = 'download_items_table';
  static const String newsSources = 'news_sources_table';
  static const String newsArticles = 'news_articles_table';
  static const String passwordEntries = 'password_entries_table';

  /// FTS5 virtual table mirroring [dictionaryEntries] (phase 3).
  ///
  /// Declared with `content=` so the index stores no copy of the rows; it is
  /// rebuilt from the base table after every dictionary import.
  static const String dictionaryFts = 'dictionary_fts';

  // Shared columns
  static const String id = 'id';
  static const String url = 'url';
  static const String title = 'title';
  static const String createdAt = 'created_at';

  // Dictionary columns (also the FTS5 column names, which must match the
  // content table for an external-content index).
  static const String headword = 'headword';
  static const String reading = 'reading';
  static const String meaningsJson = 'meanings_json';
}
