import 'package:drift/drift.dart';

import '../models/bookmark.dart';
import '../models/history_entry.dart';
import '../models/tab_model.dart';
import '../local/app_database.dart';

/// Interface: tabs, bookmarks and history — pure CRUD, no business rules.
abstract class BrowserRepository {
  Stream<List<TabModel>> watchTabs();
  Future<List<TabModel>> getTabs();
  Future<TabModel?> getTab(String id);
  Future<TabModel> createTab({String url = 'about:blank', String title = ''});
  Future<void> updateTab(String id, {String? url, String? title, String? faviconUrl, String? screenshotPath});
  Future<void> closeTab(String id);
  Future<void> closeAll();

  Stream<List<Bookmark>> watchBookmarks();
  Future<bool> isBookmarked(String url);
  Future<void> toggleBookmark(String url, {String title = ''});
  Future<void> addBookmark(String url, {String title = ''});
  Future<void> removeBookmark(String url);
  Future<List<Bookmark>> searchBookmarks(String query, {int limit = 5});

  Stream<List<HistoryEntry>> watchHistory();
  Future<void> recordVisit(String url, {String title = ''});
  Future<void> removeHistory(String id);
  Future<void> clearHistory();
  Future<List<HistoryEntry>> searchHistory(String query, {int limit = 5});
  Future<List<HistoryEntry>> recentHistory({int limit = 6});
}

class DriftBrowserRepository implements BrowserRepository {
  DriftBrowserRepository(this._db);
  final AppDatabase _db;

  @override
  Stream<List<TabModel>> watchTabs() =>
      _db.browserDao.watchTabs().map((rows) => rows.map(TabModel.fromRow).toList());

  @override
  Future<List<TabModel>> getTabs() async =>
      (await _db.browserDao.getAllTabs()).map(TabModel.fromRow).toList();

  @override
  Future<TabModel?> getTab(String id) async {
    final row = await _db.browserDao.getTab(id);
    return row == null ? null : TabModel.fromRow(row);
  }

  @override
  Future<TabModel> createTab({String url = 'about:blank', String title = ''}) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final row = TabsTableCompanion.insert(
      id: id,
      url: Value(url),
      title: Value(title),
    );
    await _db.browserDao.insertTab(row);
    return TabModel(id: id, url: url, title: title);
  }

  @override
  Future<void> updateTab(String id, {String? url, String? title, String? faviconUrl, String? screenshotPath}) async {
    await _db.browserDao.updateTab(
      id,
      TabsTableCompanion(
        url: url == null ? const Value.absent() : Value(url),
        title: title == null ? const Value.absent() : Value(title),
        faviconUrl:
            faviconUrl == null ? const Value.absent() : Value(faviconUrl),
        screenshotPath:
            screenshotPath == null ? const Value.absent() : Value(screenshotPath),
        lastActiveAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> closeTab(String id) => _db.browserDao.deleteTab(id);

  @override
  Future<void> closeAll() => _db.browserDao.clearAllTabs();

  @override
  Stream<List<Bookmark>> watchBookmarks() => _db.browserDao
      .watchBookmarks()
      .map((rows) => rows.map(Bookmark.fromRow).toList());

  @override
  Future<bool> isBookmarked(String url) => _db.browserDao.isBookmarked(url);

  @override
  Future<void> toggleBookmark(String url, {String title = ''}) async {
    if (await isBookmarked(url)) {
      await removeBookmark(url);
    } else {
      await addBookmark(url, title: title);
    }
  }

  @override
  Future<void> addBookmark(String url, {String title = ''}) async {
    await _db.browserDao.addBookmark(
      BookmarksTableCompanion.insert(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        url: url,
        title: Value(title),
      ),
    );
  }

  @override
  Future<void> removeBookmark(String url) =>
      _db.browserDao.removeBookmarkByUrl(url);

  @override
  Future<List<Bookmark>> searchBookmarks(String query, {int limit = 5}) async =>
      (await _db.browserDao.searchBookmarks(query, limit: limit))
          .map(Bookmark.fromRow)
          .toList();

  @override
  Stream<List<HistoryEntry>> watchHistory() => _db.browserDao
      .watchHistory()
      .map((rows) => rows.map(HistoryEntry.fromRow).toList());

  @override
  Future<void> recordVisit(String url, {String title = ''}) async {
    // De-duplicate consecutive visits to the same URL: a back-to-back reload or
    // the navigate + load-stop pair would otherwise write repeat rows. Instead
    // of inserting a new entry we refresh the most recent one's timestamp.
    final latest = await _db.browserDao.getLatestHistory();
    if (latest != null && latest.url == url) {
      await _db.browserDao.touchHistory(latest.id, title: title);
      return;
    }
    await _db.browserDao.addHistory(
      HistoryTableCompanion.insert(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        url: url,
        title: Value(title),
      ),
    );
  }

  @override
  Future<void> clearHistory() => _db.browserDao.clearHistory();

  @override
  Future<void> removeHistory(String id) =>
      _db.browserDao.removeHistory(id);

  @override
  Future<List<HistoryEntry>> searchHistory(String query, {int limit = 5}) async =>
      (await _db.browserDao.searchHistory(query, limit: limit))
          .map(HistoryEntry.fromRow)
          .toList();

  @override
  Future<List<HistoryEntry>> recentHistory({int limit = 6}) async =>
      (await _db.browserDao.recentHistory(limit: limit))
          .map(HistoryEntry.fromRow)
          .toList();
}
