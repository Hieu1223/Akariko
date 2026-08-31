import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/bookmark.dart';
import '../data/models/history_entry.dart';
import '../data/models/tab_model.dart';
import '../data/repositories/browser_repository.dart';
import '../data/local/app_database.dart';

/// Bridges presentation → data for tab/bookmark/history use-cases.
///
/// Kept deliberately thin for phase 1; later phases add richer orchestration
/// (e.g. capturing a screenshot on tab switch) here rather than in the DAO.
class BrowserModule {
  BrowserModule(this.repository);
  final BrowserRepository repository;

  Stream<List<TabModel>> watchTabs() => repository.watchTabs();
  Future<List<TabModel>> getTabs() => repository.getTabs();
  Future<TabModel?> getTab(String id) => repository.getTab(id);
  Future<TabModel> createTab({String url = 'about:blank', String title = ''}) =>
      repository.createTab(url: url, title: title);
  Future<void> updateTab(String id, {String? url, String? title, String? faviconUrl, String? screenshotPath}) =>
      repository.updateTab(id, url: url, title: title, faviconUrl: faviconUrl, screenshotPath: screenshotPath);
  Future<void> closeTab(String id) => repository.closeTab(id);
  Future<void> closeAll() => repository.closeAll();

  Stream<List<Bookmark>> watchBookmarks() => repository.watchBookmarks();
  Future<bool> isBookmarked(String url) => repository.isBookmarked(url);
  Future<void> toggleBookmark(String url, {String title = ''}) =>
      repository.toggleBookmark(url, title: title);
  Future<void> addBookmark(String url, {String title = ''}) =>
      repository.addBookmark(url, title: title);
  Future<void> removeBookmark(String url) => repository.removeBookmark(url);
  Future<List<Bookmark>> searchBookmarks(String query, {int limit = 5}) =>
      repository.searchBookmarks(query, limit: limit);

  Stream<List<HistoryEntry>> watchHistory() => repository.watchHistory();
  Future<void> recordVisit(String url, {String title = ''}) =>
      repository.recordVisit(url, title: title);
  Future<void> removeHistory(String id) => repository.removeHistory(id);
  Future<void> clearHistory() => repository.clearHistory();
  Future<List<HistoryEntry>> searchHistory(String query, {int limit = 5}) =>
      repository.searchHistory(query, limit: limit);
  Future<List<HistoryEntry>> recentHistory({int limit = 6}) =>
      repository.recentHistory(limit: limit);
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden in main() with the initialised DB',
  );
});

final browserRepositoryProvider = Provider<BrowserRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftBrowserRepository(db);
});

final browserModuleProvider = Provider<BrowserModule>((ref) {
  final repo = ref.watch(browserRepositoryProvider);
  return BrowserModule(repo);
});
