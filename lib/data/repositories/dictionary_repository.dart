import 'package:hive/hive.dart';

import '../datasources/local/dictionary_binary.dart';
import '../local/hive_boxes.dart';
import '../models/word_entry.dart';
import 'dictionary_search.dart';

export 'dictionary_search.dart';

/// Interface: dictionary reads + the recent-lookup list — no rules.
abstract class DictionaryRepository {
  Future<int> entryCount();

  Future<DictionarySearchPage> search(
    String query, {
    int limit,
    int offset,
    DictionarySearchMode? mode,
  });

  Future<WordEntry?> getById(String id);
  Future<List<WordEntry>> getByIds(List<String> ids);

  // ── Recent lookups (§7.6) ─────────────────────────────────────────────
  List<String> recentLookupIds();
  Future<void> addRecentLookup(String id);
  Future<void> clearRecentLookups();
}

/// In-memory dictionary backed by the prebuilt trie asset (§7.6).
///
/// The dataset is trimmed to (word, kana, meaning) and pre-indexed at build time
/// into a compressed trie; at runtime we only decode the blob and serve prefix
/// (headword/reading) and meaning searches directly from memory. No SQLite table,
/// no on-device JSON parse.
class InMemoryDictionaryRepository implements DictionaryRepository {
  InMemoryDictionaryRepository(this._dict, this._settings);

  final InMemoryDictionary _dict;
  final Box _settings;

  /// Keeps the "recent lookups" list short enough to render without paging.
  static const int maxRecentLookups = 20;

  @override
  Future<int> entryCount() async => _dict.entryCount;

  @override
  Future<DictionarySearchPage> search(
    String query, {
    int limit = 40,
    int offset = 0,
    DictionarySearchMode? mode,
  }) async =>
      _dict.search(query, limit: limit, offset: offset, mode: mode);

  @override
  Future<WordEntry?> getById(String id) async => _dict.getById(id);

  @override
  Future<List<WordEntry>> getByIds(List<String> ids) async =>
      _dict.getByIds(ids);

  @override
  List<String> recentLookupIds() {
    final stored = _settings.get(SettingsKeys.dictionaryRecentIds);
    if (stored is! List) return const [];
    return stored.map((e) => e.toString()).toList(growable: false);
  }

  @override
  Future<void> addRecentLookup(String id) async {
    final ids =
        recentLookupIds().where((e) => e != id).toList()..insert(0, id);
    await _settings.put(
      SettingsKeys.dictionaryRecentIds,
      ids.take(maxRecentLookups).toList(growable: false),
    );
  }

  @override
  Future<void> clearRecentLookups() =>
      _settings.delete(SettingsKeys.dictionaryRecentIds);
}
