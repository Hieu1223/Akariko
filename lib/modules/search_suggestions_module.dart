import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/extensions.dart';
import '../data/datasources/remote/google_suggest_datasource.dart';
import '../data/models/search_suggestion.dart';
import '../data/repositories/browser_repository.dart';
import '../data/repositories/search_suggestion_repository.dart';
import 'browser_module.dart';

/// Builds the address-bar suggestion list: local matches (history, bookmarks)
/// merged with remote query completions.
///
/// Local and remote lookups run concurrently, so a slow network never delays the
/// history rows — the list is only as slow as the DB when Google is unreachable
/// (the remote call degrades to an empty list).
class SearchSuggestionsModule {
  SearchSuggestionsModule({required this.browser, required this.remote});

  /// Local history / bookmark lookups.
  final BrowserRepository browser;

  /// Remote query completions.
  final SearchSuggestionRepository remote;

  /// Rows for [rawQuery], best first, at most [limit] entries.
  ///
  /// With an empty query this returns recently visited pages (what the user sees
  /// the moment the address bar is focused, with no network traffic at all).
  /// [remoteEnabled] mirrors the user's privacy preference: when false, nothing
  /// is sent to the search engine.
  Future<List<SearchSuggestion>> suggest(
    String rawQuery, {
    bool remoteEnabled = true,
    String? hl,
    int limit = 8,
  }) async {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      final recent = await _safe(browser.recentHistory(limit: limit));
      return _dedupe([
        for (final h in recent)
          SearchSuggestion(
            text: h.url,
            kind: SuggestionKind.history,
            subtitle: h.title,
            url: h.url,
          ),
      ], limit);
    }

    // Start all three lookups before awaiting any of them so the DB and the
    // network run in parallel.
    final historyFuture = _safe(browser.searchHistory(query, limit: 4));
    final bookmarksFuture = _safe(browser.searchBookmarks(query, limit: 3));
    final completionsFuture = remoteEnabled
        ? _safe(remote.completions(query, hl: hl))
        : Future<List<String>>.value(const []);

    final history = await historyFuture;
    final bookmarks = await bookmarksFuture;
    final completions = await completionsFuture;

    return _dedupe([
      _primaryRow(query),
      for (final b in bookmarks)
        SearchSuggestion(
          text: b.url,
          kind: SuggestionKind.bookmark,
          subtitle: b.title,
          url: b.url,
        ),
      for (final h in history)
        SearchSuggestion(
          text: h.url,
          kind: SuggestionKind.history,
          subtitle: h.title,
          url: h.url,
        ),
      for (final c in completions)
        SearchSuggestion(text: c, kind: SuggestionKind.search),
    ], limit);
  }

  /// Suggestions must never break typing: a failed lookup contributes no rows.
  Future<List<T>> _safe<T>(Future<List<T>> future) async {
    try {
      return await future;
    } on Object {
      return <T>[];
    }
  }

  /// The always-present first row: open what was typed as a URL, or search it.
  SearchSuggestion _primaryRow(String query) => query.looksLikeUrl
      ? SearchSuggestion(
          text: query,
          kind: SuggestionKind.url,
          url: query.toLoadableUrl(),
        )
      : SearchSuggestion(text: query, kind: SuggestionKind.query);

  /// Keeps the first occurrence of each target and truncates to [limit].
  List<SearchSuggestion> _dedupe(List<SearchSuggestion> items, int limit) {
    final seen = <String>{};
    final out = <SearchSuggestion>[];
    for (final s in items) {
      if (out.length >= limit) break;
      if (!seen.add(s.dedupeKey)) continue;
      out.add(s);
    }
    return out;
  }
}

/// Single, app-wide suggest data source: one keep-alive HTTP client plus its LRU
/// cache, closed when the provider container is disposed.
final googleSuggestDataSourceProvider =
    Provider<GoogleSuggestDataSource>((ref) {
  final source = GoogleSuggestDataSource();
  ref.onDispose(source.close);
  return source;
});

final searchSuggestionRepositoryProvider =
    Provider<SearchSuggestionRepository>((ref) {
  return GoogleSearchSuggestionRepository(
    ref.watch(googleSuggestDataSourceProvider),
  );
});

final searchSuggestionsModuleProvider =
    Provider<SearchSuggestionsModule>((ref) {
  return SearchSuggestionsModule(
    browser: ref.watch(browserRepositoryProvider),
    remote: ref.watch(searchSuggestionRepositoryProvider),
  );
});
