import 'package:drift/drift.dart';
import 'package:hive/hive.dart';

import '../local/app_database.dart';
import '../local/daos/dictionary_dao.dart';
import '../local/hive_boxes.dart';
import '../models/word_entry.dart';

/// How a result set was produced, so paging keeps using the same query.
///
/// Mixing modes mid-scroll would duplicate rows: `contains` is a superset of
/// `prefix`, and `fullText` orders by bm25 rather than headword length.
enum DictionarySearchMode { prefix, fullText, contains }

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

/// Interface: dictionary reads/writes + the recent-lookup list — no rules.
abstract class DictionaryRepository {
  /// Rows currently stored in `DictionaryEntriesTable`.
  Future<int> entryCount();

  /// Searches the dictionary. Pass [mode] to keep paging the same query.
  Future<DictionarySearchPage> search(
    String query, {
    int limit,
    int offset,
    DictionarySearchMode? mode,
  });

  Future<WordEntry?> getById(String id);
  Future<List<WordEntry>> getByIds(List<String> ids);

  // ── Import path ────────────────────────────────────────────────────────
  Future<void> insertEntries(List<WordEntry> entries);
  Future<void> clearEntries();
  Future<void> rebuildSearchIndex();

  /// Dataset version already imported (0 when the dictionary is missing).
  int importedVersion();
  Future<void> markImported({required int version, required int entryCount});

  // ── Recent lookups (§7.6) ─────────────────────────────────────────────
  List<String> recentLookupIds();
  Future<void> addRecentLookup(String id);
  Future<void> clearRecentLookups();
}

/// Drift-backed entries + Hive-backed recents/import bookkeeping.
class DriftDictionaryRepository implements DictionaryRepository {
  DriftDictionaryRepository(this._db, this._settings);

  final AppDatabase _db;
  final Box _settings;

  /// Keeps the "recent lookups" list short enough to render without paging.
  static const int maxRecentLookups = 20;

  DictionaryDao get _dao => _db.dictionaryDao;

  @override
  Future<int> entryCount() => _dao.countEntries();

  @override
  Future<DictionarySearchPage> search(
    String query, {
    int limit = 40,
    int offset = 0,
    DictionarySearchMode? mode,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const DictionarySearchPage.empty();

    if (mode != null) {
      final rows = await _runMode(mode, trimmed, limit: limit, offset: offset);
      return _page(rows, mode, limit);
    }

    if (containsJapanese(trimmed)) {
      // Index range scan first — it answers most Japanese input instantly.
      final prefix = await _dao.searchByPrefix(trimmed, limit: limit);
      if (prefix.length >= limit) {
        return _page(prefix, DictionarySearchMode.prefix, limit);
      }
      // Not a full page: widen to substring matches, which include every
      // prefix hit in the same relative order (so nothing is duplicated).
      final contains = await _dao.searchByContains(
        trimmed,
        includeMeanings: false,
        limit: limit,
      );
      return contains.length > prefix.length
          ? _page(contains, DictionarySearchMode.contains, limit)
          : _page(prefix, DictionarySearchMode.prefix, limit);
    }

    final fullText = await _dao.searchByFullText(trimmed, limit: limit);
    if (fullText.isNotEmpty) {
      return _page(fullText, DictionarySearchMode.fullText, limit);
    }
    final contains = await _dao.searchByContains(trimmed, limit: limit);
    return _page(contains, DictionarySearchMode.contains, limit);
  }

  Future<List<DictionaryEntryRow>> _runMode(
    DictionarySearchMode mode,
    String query, {
    required int limit,
    required int offset,
  }) {
    return switch (mode) {
      DictionarySearchMode.prefix =>
        _dao.searchByPrefix(query, limit: limit, offset: offset),
      DictionarySearchMode.fullText =>
        _dao.searchByFullText(query, limit: limit, offset: offset),
      DictionarySearchMode.contains => _dao.searchByContains(
          query,
          includeMeanings: !containsJapanese(query),
          limit: limit,
          offset: offset,
        ),
    };
  }

  DictionarySearchPage _page(
    List<DictionaryEntryRow> rows,
    DictionarySearchMode mode,
    int limit,
  ) =>
      DictionarySearchPage(
        entries: rows.map(WordEntry.fromRow).toList(growable: false),
        mode: mode,
        hasMore: rows.length >= limit,
      );

  @override
  Future<WordEntry?> getById(String id) async {
    final row = await _dao.getById(id);
    return row == null ? null : WordEntry.fromRow(row);
  }

  @override
  Future<List<WordEntry>> getByIds(List<String> ids) async {
    final rows = await _dao.getByIds(ids);
    return rows.map(WordEntry.fromRow).toList(growable: false);
  }

  @override
  Future<void> insertEntries(List<WordEntry> entries) => _dao.insertEntries(
        entries
            .map(
              (e) => DictionaryEntriesTableCompanion.insert(
                id: e.id,
                headword: e.headword,
                reading: Value(e.reading),
                pos: Value(e.pos),
                meaningsJson: Value(e.meaningsJson),
                sourcePack: Value(e.sourcePack),
              ),
            )
            .toList(growable: false),
      );

  @override
  Future<void> clearEntries() => _dao.clearEntries();

  @override
  Future<void> rebuildSearchIndex() => _dao.rebuildFtsIndex();

  @override
  int importedVersion() =>
      _settings.get(SettingsKeys.dictionaryImportVersion, defaultValue: 0)
          as int;

  @override
  Future<void> markImported({
    required int version,
    required int entryCount,
  }) async {
    await _settings.put(SettingsKeys.dictionaryImportVersion, version);
    await _settings.put(SettingsKeys.dictionaryEntryCount, entryCount);
  }

  @override
  List<String> recentLookupIds() {
    final stored = _settings.get(SettingsKeys.dictionaryRecentIds);
    if (stored is! List) return const [];
    return stored.map((e) => e.toString()).toList(growable: false);
  }

  @override
  Future<void> addRecentLookup(String id) async {
    final ids = recentLookupIds().where((e) => e != id).toList()..insert(0, id);
    await _settings.put(
      SettingsKeys.dictionaryRecentIds,
      ids.take(maxRecentLookups).toList(growable: false),
    );
  }

  @override
  Future<void> clearRecentLookups() =>
      _settings.delete(SettingsKeys.dictionaryRecentIds);
}
