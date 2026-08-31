/// Where a suggestion came from — drives the leading icon and the ordering
/// (local matches rank above remote query completions).
enum SuggestionKind {
  /// The raw text the user typed, offered as a search.
  query,

  /// The raw text the user typed, offered as a URL to open.
  url,

  /// A completion returned by the search engine's suggest endpoint.
  search,

  /// A previously visited page.
  history,

  /// A saved bookmark.
  bookmark,
}

/// One row of the address-bar suggestion list.
///
/// Immutable and cheap to compare so the view model can dedupe by [target] and
/// the list can skip rebuilds when the same suggestions come back (e.g. a cache
/// hit after deleting a character).
class SearchSuggestion {
  const SearchSuggestion({
    required this.text,
    required this.kind,
    this.subtitle = '',
    this.url = '',
  });

  /// Text shown as the row title, and what lands in the address bar when the
  /// user "fills" the row instead of opening it.
  final String text;

  final SuggestionKind kind;

  /// Secondary line (page title for history/bookmarks, empty for queries).
  final String subtitle;

  /// Explicit navigation target. Empty for query completions, where [text] is
  /// turned into a search URL by `String.toLoadableUrl()`.
  final String url;

  /// What [navigateTo] should load for this row.
  String get target => url.isNotEmpty ? url : text;

  /// Stable identity used for dedupe across sources: the same page reached from
  /// history and from a bookmark is one suggestion.
  String get dedupeKey => url.isNotEmpty ? url : text.trim().toLowerCase();

  @override
  bool operator ==(Object other) =>
      other is SearchSuggestion &&
      other.text == text &&
      other.kind == kind &&
      other.subtitle == subtitle &&
      other.url == url;

  @override
  int get hashCode => Object.hash(text, kind, subtitle, url);

  @override
  String toString() => 'SearchSuggestion($kind, $text)';
}
