import 'package:drift/drift.dart';

import '../local/app_database.dart';
import '../models/news_article.dart';
import '../models/news_source.dart';

/// Interface: news sources + articles — pure CRUD over the Drift tables, no
/// business rules (feed polling/refresh orchestration lives in the use-case).
abstract class NewsRepository {
  Stream<List<NewsSource>> watchSources();
  Stream<List<NewsArticle>> watchArticles();

  /// Snapshot of sources (used by the use-case before a refresh-all).
  Future<List<NewsSource>> getSources();

  Future<void> insertSource(NewsSource source);
  Future<void> deleteSource(String id);

  /// Inserts/updates each article, preserving an existing `isRead` flag.
  Future<void> upsertArticles(List<NewsArticle> articles);

  Future<void> markRead(String id);
}

class DriftNewsRepository implements NewsRepository {
  DriftNewsRepository(this._db);
  final AppDatabase _db;

  @override
  Stream<List<NewsSource>> watchSources() =>
      (_db.select(_db.newsSourcesTable)
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch()
          .map((rows) => rows.map(NewsSource.fromRow).toList());

  @override
  Stream<List<NewsArticle>> watchArticles() =>
      (_db.select(_db.newsArticlesTable)
            // Newest first; in SQLite a DESC sort places NULL publishedAt last,
            // which is the desired behaviour for undated items.
            ..orderBy([
              (t) => OrderingTerm(
                    expression: t.publishedAt,
                    mode: OrderingMode.desc,
                  ),
            ]))
          .watch()
          .map((rows) => rows.map(NewsArticle.fromRow).toList());

  @override
  Future<List<NewsSource>> getSources() async {
    final rows = await (_db.select(_db.newsSourcesTable)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
    return rows.map(NewsSource.fromRow).toList();
  }

  @override
  Future<void> insertSource(NewsSource source) =>
      _db.into(_db.newsSourcesTable).insert(source.toInsertCompanion());

  @override
  Future<void> deleteSource(String id) => _db.transaction(() async {
        await (_db.delete(_db.newsArticlesTable)
              ..where((t) => t.sourceId.equals(id)))
            .go();
        await (_db.delete(_db.newsSourcesTable)
              ..where((t) => t.id.equals(id)))
            .go();
      });

  @override
  Future<void> upsertArticles(List<NewsArticle> articles) async {
    if (articles.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.newsArticlesTable,
        articles.map((a) => a.toUpsertCompanion()).toList(),
      );
    });
  }

  @override
  Future<void> markRead(String id) =>
      (_db.update(_db.newsArticlesTable)..where((t) => t.id.equals(id)))
          .write(NewsArticlesTableCompanion(isRead: const Value(true)));
}
