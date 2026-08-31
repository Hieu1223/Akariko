import 'dart:async';
import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/constants/db_constants.dart';
import 'daos/browser_dao.dart';
import 'tables/decks_table.dart';
import 'tables/download_items_table.dart';
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
///
/// The dictionary is intentionally NOT here: it is a prebuilt, compressed trie
/// asset held entirely in memory (see `InMemoryDictionary`), so there is no
/// dictionary table, FTS index, or import flow in the database.
@DriftDatabase(
  tables: [
    TabsTable,
    HistoryTable,
    BookmarksTable,
    DecksTable,
    FlashcardsTable,
    ReviewLogsTable,
    DownloadItemsTable,
    NewsSourcesTable,
    NewsArticlesTable,
    PasswordEntriesTable,
  ],
  daos: [BrowserDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'yomu'));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedNewsSources(m);
        },
        onUpgrade: (m, from, to) async {
          // v2 (phase 3) added an FTS5 index over the (now removed) dictionary
          // table; nothing to keep.
          if (from < 2) {
            await customStatement('DROP TABLE IF EXISTS dictionary_fts');
          }
          // v4: the dictionary table is gone (moved to the in-memory asset) and we
          // add indexes that back the tabs/history ordering + history de-dup.
          if (from < 4) {
            await customStatement(
              'DROP TABLE IF EXISTS dictionary_entries_table',
            );
            await customStatement(
              'DROP TABLE IF EXISTS dictionary_fts',
            );
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_tabs_last_active_at '
              'ON ${DbConstants.tabs} (last_active_at)',
            );
            await customStatement(
              'CREATE INDEX IF NOT EXISTS idx_history_visited_at '
              'ON ${DbConstants.history} (visited_at)',
            );
          }
        },
      );

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
