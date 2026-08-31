import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/bookmarks_table.dart';
import '../tables/history_table.dart';
import '../tables/tabs_table.dart';

part 'browser_dao.g.dart';

/// CRUD for open tabs, bookmarks and history. Pure data access — no rules.
@DriftAccessor(tables: [TabsTable, BookmarksTable, HistoryTable])
class BrowserDao extends DatabaseAccessor<AppDatabase>
    with _$BrowserDaoMixin {
  BrowserDao(super.db);

  // ── Tabs ─────────────────────────────────────────────────────────────
  Stream<List<TabRow>> watchTabs() =>
      (select(db.tabsTable)..orderBy([(t) => OrderingTerm.desc(t.lastActiveAt)]))
          .watch();

  Future<List<TabRow>> getAllTabs() =>
      (select(db.tabsTable)..orderBy([(t) => OrderingTerm.desc(t.lastActiveAt)]))
          .get();

  Future<TabRow?> getTab(String id) =>
      (select(db.tabsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> insertTab(TabsTableCompanion row) =>
      into(db.tabsTable).insertOnConflictUpdate(row);

  Future<void> updateTab(String id, TabsTableCompanion row) =>
      (update(db.tabsTable)..where((t) => t.id.equals(id))).write(row);

  Future<void> deleteTab(String id) =>
      (delete(db.tabsTable)..where((t) => t.id.equals(id))).go();

  Future<void> clearAllTabs() => delete(db.tabsTable).go();

  // ── Bookmarks ────────────────────────────────────────────────────────
  Stream<List<BookmarkRow>> watchBookmarks() =>
      (select(db.bookmarksTable)
            ..orderBy([(b) => OrderingTerm.desc(b.createdAt)]))
          .watch();

  Future<bool> isBookmarked(String url) async =>
      await (select(db.bookmarksTable)..where((b) => b.url.equals(url)))
          .getSingleOrNull() !=
      null;

  Future<void> addBookmark(BookmarksTableCompanion row) =>
      into(db.bookmarksTable).insert(row);

  Future<void> removeBookmarkByUrl(String url) =>
      (delete(db.bookmarksTable)..where((b) => b.url.equals(url))).go();

  /// Bookmarks whose url or title matches [query], newest first, capped at
  /// [limit].
  ///
  /// Used by the address-bar suggestion list: a bounded `LIKE` + `LIMIT` query
  /// keeps the hot typing path off the full-table `watchBookmarks` stream.
  Future<List<BookmarkRow>> searchBookmarks(String query, {int limit = 5}) {
    final pattern = _likePattern(query);
    return (select(db.bookmarksTable)
          ..where((b) => b.url.like(pattern) | b.title.like(pattern))
          ..orderBy([(b) => OrderingTerm.desc(b.createdAt)])
          ..limit(limit))
        .get();
  }

  // ── History ─────────────────────────────────────────────────────────
  Stream<List<HistoryRow>> watchHistory() =>
      (select(db.historyTable)
            ..orderBy([(h) => OrderingTerm.desc(h.visitedAt)]))
          .watch();

  Future<void> addHistory(HistoryTableCompanion row) =>
      into(db.historyTable).insert(row);

  Future<void> clearHistory() => delete(db.historyTable).go();

  Future<void> removeHistory(String id) =>
      (delete(db.historyTable)..where((h) => h.id.equals(id))).go();

  /// The most recently visited row, or `null` when history is empty.
  ///
  /// Used to de-duplicate consecutive visits to the same URL (see
  /// [DriftBrowserRepository.recordVisit]).
  Future<HistoryRow?> getLatestHistory() =>
      (select(db.historyTable)
            ..orderBy([(h) => OrderingTerm.desc(h.visitedAt)])
            ..limit(1))
          .getSingleOrNull();

  /// Refreshes a row's visit timestamp (and optionally its title) without
  /// creating a duplicate history entry.
  Future<void> touchHistory(String id, {String? title}) =>
      (update(db.historyTable)..where((h) => h.id.equals(id))).write(
        HistoryTableCompanion(
          visitedAt: Value(DateTime.now()),
          title: title == null ? const Value.absent() : Value(title),
        ),
      );

  /// The [limit] most recently visited rows, newest first.
  ///
  /// Cheaper than [watchHistory] for one-shot reads (address-bar suggestions):
  /// no stream is kept open and SQLite stops after `limit` rows.
  Future<List<HistoryRow>> recentHistory({int limit = 6}) =>
      (select(db.historyTable)
            ..orderBy([(h) => OrderingTerm.desc(h.visitedAt)])
            ..limit(limit))
          .get();

  /// History rows whose url or title matches [query], newest first, capped at
  /// [limit]. Filtering happens in SQLite instead of in memory.
  Future<List<HistoryRow>> searchHistory(String query, {int limit = 5}) {
    final pattern = _likePattern(query);
    return (select(db.historyTable)
          ..where((h) => h.url.like(pattern) | h.title.like(pattern))
          ..orderBy([(h) => OrderingTerm.desc(h.visitedAt)])
          ..limit(limit))
        .get();
  }

  /// Builds a `%…%` pattern for a `LIKE` filter.
  ///
  /// The value is always passed as a bound parameter (no SQL injection), but
  /// `%`/`_` inside the query would act as wildcards, so they are dropped —
  /// a suggestion list should match literally what the user typed.
  static String _likePattern(String query) =>
      '%${query.trim().replaceAll(RegExp(r'[%_\\]'), '')}%';
}
