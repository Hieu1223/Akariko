import 'dart:convert';

import 'package:arisu_browser/data/datasources/remote/google_suggest_datasource.dart';
import 'package:arisu_browser/data/models/bookmark.dart';
import 'package:arisu_browser/data/models/history_entry.dart';
import 'package:arisu_browser/data/models/search_suggestion.dart';
import 'package:arisu_browser/data/repositories/browser_repository.dart';
import 'package:arisu_browser/data/repositories/search_suggestion_repository.dart';
import 'package:arisu_browser/modules/search_suggestions_module.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Serves history/bookmark rows from memory. Unused repository members are
/// forwarded to [noSuchMethod] so the fake stays focused on the suggestion path.
class FakeBrowserRepository implements BrowserRepository {
  FakeBrowserRepository({this.history = const [], this.bookmarks = const []});

  List<HistoryEntry> history;
  List<Bookmark> bookmarks;
  bool throwOnLookup = false;
  final List<String> historyQueries = [];

  @override
  Future<List<HistoryEntry>> searchHistory(String query, {int limit = 5}) async {
    historyQueries.add(query);
    if (throwOnLookup) throw StateError('db down');
    return history
        .where((h) => _matches(query, h.url, h.title))
        .take(limit)
        .toList();
  }

  @override
  Future<List<HistoryEntry>> recentHistory({int limit = 6}) async =>
      history.take(limit).toList();

  @override
  Future<List<Bookmark>> searchBookmarks(String query, {int limit = 5}) async =>
      bookmarks
          .where((b) => _matches(query, b.url, b.title))
          .take(limit)
          .toList();

  static bool _matches(String query, String url, String title) {
    final q = query.toLowerCase();
    return url.toLowerCase().contains(q) || title.toLowerCase().contains(q);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName} unused in this test');
}

/// Returns canned completions (or fails) without touching the network.
class FakeSuggestRepository implements SearchSuggestionRepository {
  FakeSuggestRepository({this.result = const [], this.fail = false});

  List<String> result;
  bool fail;
  int calls = 0;

  @override
  Future<List<String>> completions(String query, {String? hl}) async {
    calls++;
    if (fail) return const [];
    return result;
  }

  @override
  void clearCache() {}

  @override
  void dispose() {}
}

HistoryEntry _history(String url, String title) => HistoryEntry(
      id: url,
      url: url,
      title: title,
      visitedAt: DateTime(2026),
    );

Bookmark _bookmark(String url, String title) =>
    Bookmark(id: url, url: url, title: title);

void main() {
  group('parseSuggestResponse', () {
    test('reads the completion array of a client=firefox payload', () {
      final body = utf8.encode(jsonEncode([
        'flut',
        ['flutter', 'flutter web', 'flutter riverpod'],
        <dynamic>[],
        {'google:suggestsubtypes': <dynamic>[]},
      ]));
      expect(parseSuggestResponse(body),
          ['flutter', 'flutter web', 'flutter riverpod']);
    });

    test('keeps non-ASCII completions intact', () {
      final body = utf8.encode(jsonEncode(['日本', ['日本語', '日本地図']]));
      expect(parseSuggestResponse(body), ['日本語', '日本地図']);
    });

    test('skips blank and non-string entries', () {
      final body = utf8.encode(jsonEncode(['a', ['ab', '', 7, null, 'ac']]));
      expect(parseSuggestResponse(body), ['ab', 'ac']);
    });

    test('returns empty for a shape it does not understand', () {
      expect(parseSuggestResponse(utf8.encode('{"not":"an array"}')), isEmpty);
      expect(parseSuggestResponse(utf8.encode('["only-query"]')), isEmpty);
    });
  });

  group('GoogleSuggestDataSource', () {
    List<int> payload(List<String> completions) =>
        utf8.encode(jsonEncode(['q', completions]));

    test('fetches, then serves repeats from the LRU cache', () async {
      var requests = 0;
      final source = GoogleSuggestDataSource(
        client: MockClient((_) async {
          requests++;
          return http.Response.bytes(payload(['flutter', 'flutter web']), 200);
        }),
      );
      addTearDown(source.close);

      expect(await source.fetch('flut'), ['flutter', 'flutter web']);
      expect(await source.fetch('flut'), ['flutter', 'flutter web']);
      // Case-insensitive: the same prefix in another case is the same key.
      expect(await source.fetch('FLUT'), ['flutter', 'flutter web']);
      expect(requests, 1);
    });

    test('evicts the oldest entry beyond the cache cap', () async {
      var requests = 0;
      final source = GoogleSuggestDataSource(
        maxCacheEntries: 2,
        client: MockClient((request) async {
          requests++;
          return http.Response.bytes(
            payload([request.url.queryParameters['q'] ?? '']),
            200,
          );
        }),
      );
      addTearDown(source.close);

      await source.fetch('a');
      await source.fetch('b');
      await source.fetch('c'); // evicts 'a'
      expect(requests, 3);
      await source.fetch('a'); // re-fetched
      expect(requests, 4);
      await source.fetch('c'); // still cached
      expect(requests, 4);
    });

    test('never throws and never caches a failure', () async {
      var requests = 0;
      final source = GoogleSuggestDataSource(
        client: MockClient((_) async {
          requests++;
          throw http.ClientException('offline');
        }),
      );
      addTearDown(source.close);

      expect(await source.fetch('x'), isEmpty);
      expect(await source.fetch('x'), isEmpty);
      expect(requests, 2);
    });

    test('treats a non-200 answer as "no suggestions"', () async {
      final source = GoogleSuggestDataSource(
        client: MockClient((_) async => http.Response('nope', 429)),
      );
      addTearDown(source.close);
      expect(await source.fetch('x'), isEmpty);
    });

    test('skips the request entirely for a blank query', () async {
      var requests = 0;
      final source = GoogleSuggestDataSource(
        client: MockClient((_) async {
          requests++;
          return http.Response.bytes(payload(const []), 200);
        }),
      );
      addTearDown(source.close);

      expect(await source.fetch('   '), isEmpty);
      expect(requests, 0);
    });
  });

  group('SearchSuggestionsModule.suggest', () {
    test('puts the typed query first, then bookmarks, history, completions',
        () async {
      final module = SearchSuggestionsModule(
        browser: FakeBrowserRepository(
          history: [_history('https://news.example.com', 'Example News')],
          bookmarks: [_bookmark('https://example.org', 'Example Org')],
        ),
        remote: FakeSuggestRepository(result: ['example domain', 'examples']),
      );

      final rows = await module.suggest('example');

      expect(rows.first.kind, SuggestionKind.query);
      expect(rows.first.text, 'example');
      expect(
        rows.map((r) => r.kind).toList(),
        [
          SuggestionKind.query,
          SuggestionKind.bookmark,
          SuggestionKind.history,
          SuggestionKind.search,
          SuggestionKind.search,
        ],
      );
    });

    test('offers a URL row when the input looks like an address', () async {
      final module = SearchSuggestionsModule(
        browser: FakeBrowserRepository(),
        remote: FakeSuggestRepository(),
      );

      final rows = await module.suggest('example.com/path');
      expect(rows.first.kind, SuggestionKind.url);
      expect(rows.first.target, 'https://example.com/path');
    });

    test('drops duplicates across sources and honours the limit', () async {
      final module = SearchSuggestionsModule(
        browser: FakeBrowserRepository(
          history: [_history('https://example.org', 'Dup')],
          bookmarks: [_bookmark('https://example.org', 'Dup')],
        ),
        remote: FakeSuggestRepository(
          result: ['example', 'example 2', 'example 3', 'example 4'],
        ),
      );

      final rows = await module.suggest('example', limit: 4);
      expect(rows, hasLength(4));
      expect(rows.map((r) => r.dedupeKey).toSet(), hasLength(4));
      // 'example' from the engine is already the typed-query row.
      expect(
        rows.where((r) => r.dedupeKey == 'example'),
        hasLength(1),
      );
      expect(
        rows.where((r) => r.url == 'https://example.org'),
        hasLength(1),
      );
    });

    test('an empty query lists recent pages without asking the engine',
        () async {
      final remote = FakeSuggestRepository(result: ['should not be used']);
      final module = SearchSuggestionsModule(
        browser: FakeBrowserRepository(
          history: [
            _history('https://a.example', 'A'),
            _history('https://b.example', 'B'),
          ],
        ),
        remote: remote,
      );

      final rows = await module.suggest('   ');
      expect(rows.map((r) => r.url), ['https://a.example', 'https://b.example']);
      expect(rows.every((r) => r.kind == SuggestionKind.history), isTrue);
      expect(remote.calls, 0);
    });

    test('remoteEnabled: false keeps the query on the device', () async {
      final remote = FakeSuggestRepository(result: ['leak']);
      final module = SearchSuggestionsModule(
        browser: FakeBrowserRepository(
          history: [_history('https://kept.example', 'Kept')],
        ),
        remote: remote,
      );

      final rows = await module.suggest('kept', remoteEnabled: false);
      expect(remote.calls, 0);
      expect(rows.map((r) => r.kind),
          [SuggestionKind.query, SuggestionKind.history]);
    });

    test('a failing local lookup still yields the typed query + completions',
        () async {
      final browser = FakeBrowserRepository()..throwOnLookup = true;
      final module = SearchSuggestionsModule(
        browser: browser,
        remote: FakeSuggestRepository(result: ['dart lang']),
      );

      final rows = await module.suggest('dart');
      expect(rows.map((r) => r.text), ['dart', 'dart lang']);
    });
  });
}
