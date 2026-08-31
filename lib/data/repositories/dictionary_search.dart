/// Search result page + mode for the dictionary (§7.6).
///
/// Kept dependency-free (only [WordEntry]) so both the in-memory dictionary
/// engine and the repository can import it without a cycle.
library;

import '../models/word_entry.dart';

/// How a result set was produced, so paging keeps using the same query path.
///
/// Mixing modes mid-scroll would duplicate rows: `meaning` is a superset of
/// `prefix` for some inputs, so the stored mode anchors the next page.
enum DictionarySearchMode { prefix, meaning, contains }

/// One page of dictionary results plus the mode that produced it.
class DictionarySearchPage {
  const DictionarySearchPage({
    required this.entries,
    required this.mode,
    required this.hasMore,
  });

  const DictionarySearchPage.empty()
      : entries = const [],
        mode = DictionarySearchMode.prefix,
        hasMore = false;

  final List<WordEntry> entries;
  final DictionarySearchMode mode;
  final bool hasMore;
}
