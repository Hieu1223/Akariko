import '../datasources/remote/google_suggest_datasource.dart';

/// Query completions from a search engine's autocomplete endpoint.
abstract class SearchSuggestionRepository {
  /// Completions for [query] (never throws; empty when unavailable).
  Future<List<String>> completions(String query, {String? hl});

  /// Forgets cached completions.
  void clearCache();

  /// Releases the underlying HTTP connection pool.
  void dispose();
}

/// [SearchSuggestionRepository] backed by Google's suggest endpoint.
class GoogleSearchSuggestionRepository implements SearchSuggestionRepository {
  GoogleSearchSuggestionRepository(this._source);

  final GoogleSuggestDataSource _source;

  @override
  Future<List<String>> completions(String query, {String? hl}) =>
      _source.fetch(query, hl: hl);

  @override
  void clearCache() => _source.clearCache();

  @override
  void dispose() => _source.close();
}
