import 'dart:async';
import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/constants/db_constants.dart';
import 'daos/browser_dao.dart';
import 'daos/dictionary_dao.dart';
import 'tables/decks_table.dart';
import 'tables/download_items_table.dart';
import 'tables/dictionary_entries_table.dart';
import 'tables/flashcards_table.dart';
import 'tables/history_table.dart';
import 'tables/bookmarks_table.dart';
import 'tables/news_articles_table.dart';
import 'tables/news_sources_table.dart';
import 'tables/password_entries_table.dart';
import 'tables/review_logs_table.dart';
import 'tables/tabs_table.dart';

part 'app_database.g.dart';

/// Root Drift database. Owns the full Yomu schema from phase 1 so later
/// phases only add rows/queries, never new tables (per the roadmap §9).
@DriftDatabase(
  tables: [
    TabsTable,
    HistoryTable,
    BookmarksTable,
    DictionaryEntriesTable,
    DecksTable,
    FlashcardsTable,
    ReviewLogsTable,
    DownloadItemsTable,
    NewsSourcesTable,
    NewsArticlesTable,
    PasswordEntriesTable,
  ],
  daos: [BrowserDao, DictionaryDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'yomu'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedNewsSources(m);
          await _createDictionaryFts();
        },
        onUpgrade: (m, from, to) async {
          // v2 (phase 3): FTS5 index backing dictionary search.
          if (from < 2) {
            await _createDictionaryFts();
            // Users who imported under v1 already have rows; rebuild the index
            // so latin/meaning search isn't silently served by contains-fallback.
            if (await dictionaryDao.countEntries() > 0) {
              await dictionaryDao.rebuildFtsIndex();
            }
          }
        },
      );

  /// Creates the FTS5 index over [DictionaryEntriesTable].
  ///
  /// Declared as an *external content* table (`content=`), so the index holds
  /// no second copy of the ~190k rows — it reads them from the base table by
  /// rowid. `remove_diacritics 2` makes latin/Vietnamese lookups accent
  /// insensitive ("de dat" → "dè dặt"); Japanese input is served by the
  /// headword/reading indexes instead (see `DictionaryDao`).
  Future<void> _createDictionaryFts() async {
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS ${DbConstants.dictionaryFts}
      USING fts5(
        ${DbConstants.headword},
        ${DbConstants.reading},
        ${DbConstants.meaningsJson},
        content='${DbConstants.dictionaryEntries}',
        tokenize='unicode61 remove_diacritics 2'
      )
    ''');
  }

  Future<void> _seedNewsSources(Migrator m) async {
    // Default seed list (§7.17). Inserted once on first launch; every row is
    // user-editable/removable afterward like any other source.
    const seeds = [
      ('japan-times', 'Japan Times — latest articles',
          'https://www.japantimes.co.jp/feed/topstories/'),
      ('japan-today', 'Japan Today', 'https://japantoday.com/feed'),
      ('news-on-japan', 'News On Japan',
          'http://www.newsonjapan.com/rss/top.xml'),
      ('kyodo', 'Kyodo News+ (All)',
          'https://english.kyodonews.net/rss/all.xml'),
      ('bridge', 'BRIDGE（ブリッジ）', 'http://feeds.feedburner.com/SdJapan'),
      ('nyt-japan', 'NYT > Japan',
          'https://www.nytimes.com/svc/collections/v1/publish/http://www.nytimes.com/topic/destination/japan/rss.xml'),
      ('livedoor', 'ライブドアニュース', 'https://news.livedoor.com/topics/rss/top.xml'),
      ('asahi', '朝日新聞デジタル', 'http://rss.asahi.com/rss/asahi/newsheadlines.rdf'),
    ];

    for (final (id, name, feedUrl) in seeds) {
      await into(newsSourcesTable).insert(
        NewsSourcesTableCompanion.insert(
          id: id,
          name: name,
          feedUrl: feedUrl,
        ),
      );
    }
    log('Seeded ${seeds.length} default news sources');
  }
}
