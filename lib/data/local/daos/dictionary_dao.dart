import 'package:drift/drift.dart';

import '../../../core/constants/db_constants.dart';
import '../app_database.dart';
import '../tables/dictionary_entries_table.dart';

part 'dictionary_dao.g.dart';

/// Data access for the imported dictionary dataset — pure queries, no rules.
///
/// Three complementary lookups back the Dictionary screen (§7.6):
///
/// * [searchByPrefix]   — index range scan, used for Japanese input (`読` →
///   `読む`, `読書`…). Fast because it never touches a wildcard prefix.
/// * [searchByFullText] — FTS5 `MATCH` over the `dictionary_fts` index, used
///   for latin input so "de dat" finds "dè dặt" (the index is built with
///   `remove_diacritics 2`).
/// * [searchByContains] — `LIKE '%q%'` fallback for everything the two indexed
///   paths miss (mid-word Japanese, meanings without an FTS hit).
@DriftAccessor(tables: [DictionaryEntriesTable])
class DictionaryDao extends DatabaseAccessor<AppDatabase>
    with _$DictionaryDaoMixin {
  DictionaryDao(super.db);

  static const String _entries = DbConstants.dictionaryEntries;
  static const String _fts = DbConstants.dictionaryFts;

  // ── Reads ────────────────────────────────────────────────────────────
  Future<int> countEntries() async {
    final row =
        await customSelect('SELECT COUNT(*) AS c FROM $_entries').getSingle();
    return row.read<int>('c');
  }

  Future<DictionaryEntryRow?> getById(String id) =>
      (select(db.dictionaryEntriesTable)..where((e) => e.id.equals(id)))
          .getSingleOrNull();

  /// Entries for [ids], returned in the order the ids were given (used by the
  /// "recent lookups" section, which is ordered most-recent-first).
  Future<List<DictionaryEntryRow>> getByIds(List<String> ids) async {
    if (ids.isEmpty) return const [];
    final rows = await (select(db.dictionaryEntriesTable)
          ..where((e) => e.id.isIn(ids)))
        .get();
    final byId = {for (final row in rows) row.id: row};
    return [
      for (final id in ids) ?byId[id],
    ];
  }

  /// Exact + prefix matches on headword/reading, best match first.
  Future<List<DictionaryEntryRow>> searchByPrefix(
    String query, {
    int limit = 40,
    int offset = 0,
  }) async {
    final hi = prefixUpperBound(query);
    if (hi.isEmpty) return const [];
    final rows = await customSelect(
      '''
      SELECT d.* FROM $_entries d
      WHERE (d.${DbConstants.headword} >= ? AND d.${DbConstants.headword} < ?)
         OR (d.${DbConstants.reading} >= ? AND d.${DbConstants.reading} < ?)
      ORDER BY
        CASE
          WHEN d.${DbConstants.headword} = ? THEN 0
          WHEN d.${DbConstants.reading} = ? THEN 1
          WHEN d.${DbConstants.headword} >= ? AND d.${DbConstants.headword} < ? THEN 2
          ELSE 3
        END,
        length(d.${DbConstants.headword}), d.${DbConstants.headword}
      LIMIT ? OFFSET ?
      ''',
      variables: [
        Variable(query),
        Variable(hi),
        Variable(query),
        Variable(hi),
        Variable(query),
        Variable(query),
        Variable(query),
        Variable(hi),
        Variable(limit),
        Variable(offset),
      ],
      readsFrom: {db.dictionaryEntriesTable},
    ).get();
    return _mapRows(rows);
  }

  /// Substring matches, optionally also searching the meanings column.
  Future<List<DictionaryEntryRow>> searchByContains(
    String query, {
    bool includeMeanings = true,
    int limit = 40,
    int offset = 0,
  }) async {
    final escaped = escapeLikePattern(query);
    final contains = '%$escaped%';
    final startsWith = '$escaped%';
    final meaningsClause = includeMeanings
        ? "OR d.${DbConstants.meaningsJson} LIKE ? ESCAPE '\\'"
        : '';

    final rows = await customSelect(
      '''
      SELECT d.* FROM $_entries d
      WHERE d.${DbConstants.headword} LIKE ? ESCAPE '\\'
         OR d.${DbConstants.reading} LIKE ? ESCAPE '\\'
         $meaningsClause
      ORDER BY
        CASE
          WHEN d.${DbConstants.headword} = ? THEN 0
          WHEN d.${DbConstants.reading} = ? THEN 1
          WHEN d.${DbConstants.headword} LIKE ? ESCAPE '\\' THEN 2
          WHEN d.${DbConstants.reading} LIKE ? ESCAPE '\\' THEN 3
          ELSE 4
        END,
        length(d.${DbConstants.headword}), d.${DbConstants.headword}
      LIMIT ? OFFSET ?
      ''',
      variables: [
        Variable(contains),
        Variable(contains),
        if (includeMeanings) Variable(contains),
        Variable(query),
        Variable(query),
        Variable(startsWith),
        Variable(startsWith),
        Variable(limit),
        Variable(offset),
      ],
      readsFrom: {db.dictionaryEntriesTable},
    ).get();
    return _mapRows(rows);
  }

  /// FTS5 search over headword / reading / meanings, ranked by bm25.
  ///
  /// Returns an empty list when the query has no searchable token or the FTS
  /// index has not been built yet (the caller then falls back to [searchByContains]).
  Future<List<DictionaryEntryRow>> searchByFullText(
    String query, {
    int limit = 40,
    int offset = 0,
  }) async {
    final match = buildFtsMatchQuery(query);
    if (match == null) return const [];
    if (!await hasFtsIndex()) return const [];

    final rows = await customSelect(
      '''
      SELECT d.* FROM $_fts
      JOIN $_entries d ON d.rowid = $_fts.rowid
      WHERE $_fts MATCH ?
      ORDER BY bm25($_fts, 4.0, 2.0, 1.0), length(d.${DbConstants.headword})
      LIMIT ? OFFSET ?
      ''',
      variables: [Variable(match), Variable(limit), Variable(offset)],
      readsFrom: {db.dictionaryEntriesTable},
    ).get();
    return _mapRows(rows);
  }

  // ── Writes (import path) ─────────────────────────────────────────────
  Future<void> insertEntries(List<DictionaryEntriesTableCompanion> rows) async {
    if (rows.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(db.dictionaryEntriesTable, rows);
    });
  }

  Future<void> clearEntries() => delete(db.dictionaryEntriesTable).go();

  /// Whether the FTS5 virtual table exists (created by the schema migration).
  Future<bool> hasFtsIndex() async {
    final row = await customSelect(
      "SELECT 1 AS present FROM sqlite_master WHERE type = 'table' AND name = ?",
      variables: [const Variable(_fts)],
    ).getSingleOrNull();
    return row != null;
  }

  /// Rebuilds the external-content FTS index from the base table.
  ///
  /// Cheaper and simpler than keeping it in sync row-by-row: the dictionary is
  /// static between imports, so one rebuild after an import is enough.
  Future<void> rebuildFtsIndex() async {
    if (!await hasFtsIndex()) return;
    await customStatement("INSERT INTO $_fts($_fts) VALUES('rebuild')");
  }

  List<DictionaryEntryRow> _mapRows(List<QueryRow> rows) => rows
      .map((row) => db.dictionaryEntriesTable.map(row.data))
      .toList(growable: false);
}

/// Exclusive upper bound for a prefix range scan (`x >= q AND x < bound`).
///
/// Returns `''` for an empty prefix, which callers treat as "no range".
String prefixUpperBound(String prefix) {
  if (prefix.isEmpty) return '';
  final runes = prefix.runes.toList();
  var last = runes.removeLast();
  if (last >= 0x10FFFF) return prefix; // degenerate, caller skips the range
  last += 1;
  // Skip the surrogate block so the bound stays a valid scalar value.
  if (last >= 0xD800 && last <= 0xDFFF) last = 0xE000;
  runes.add(last);
  return String.fromCharCodes(runes);
}

/// Escapes the `LIKE` wildcards in user input (paired with `ESCAPE '\'`).
String escapeLikePattern(String input) => input
    .replaceAll('\\', '\\\\')
    .replaceAll('%', '\\%')
    .replaceAll('_', '\\_');

/// Builds an FTS5 `MATCH` expression: every token must appear, as a prefix.
///
/// Returns `null` when the input holds no letters/digits, since an empty MATCH
/// expression is a syntax error in SQLite.
String? buildFtsMatchQuery(String input) {
  final tokens = input
      .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
      .where((t) => t.isNotEmpty)
      .toList();
  if (tokens.isEmpty) return null;
  return tokens.map((t) => '"$t"*').join(' AND ');
}

/// True when [input] holds kana, kanji or Japanese punctuation, i.e. the query
/// should be resolved against headword/reading rather than the meanings.
bool containsJapanese(String input) => _japanesePattern.hasMatch(input);

final RegExp _japanesePattern = RegExp(
  r'[\u3000-\u303f\u3040-\u309f\u30a0-\u30ff\u3400-\u4dbf\u4e00-\u9fff'
  r'\uf900-\ufaff\uff66-\uff9f]',
);
