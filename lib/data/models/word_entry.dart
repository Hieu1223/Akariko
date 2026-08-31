import 'dart:convert';

import '../local/app_database.dart';

/// A single dictionary entry (maps from [DictionaryEntryRow]).
///
/// Trimmed to the three fields the UI needs: the headword (word), its reading
/// (kana) and the glosses (meaning). Entries live in the Drift store on disk —
/// never held in memory as a full list — and are paged in via search.
class WordEntry {
  const WordEntry({
    required this.id,
    required this.headword,
    this.reading = '',
    this.meanings = const [],
  });

  final String id;
  final String headword;
  final String reading;
  final List<String> meanings;

  bool get hasReading => reading.isNotEmpty && reading != headword;

  /// Short gloss for list rows (§7.6): the first few senses, joined.
  String get shortGloss => meanings.take(3).join('; ');

  String get meaningsJson => jsonEncode(meanings);

  factory WordEntry.fromRow(DictionaryEntryRow row) => WordEntry(
        id: row.id,
        headword: row.headword,
        reading: row.reading,
        meanings: decodeMeanings(row.meaningsJson),
      );

  /// Tolerant decoder for the `meanings_json` column.
  ///
  /// Falls back to treating the column as plain text so a malformed row can
  /// never break a search result list.
  static List<String> decodeMeanings(String raw) {
    if (raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .map((m) => m.toString().trim())
            .where((m) => m.isNotEmpty)
            .toList(growable: false);
      }
    } on FormatException {
      // Not JSON — fall through and treat it as a single sense.
    }
    final text = raw.trim();
    return text.isEmpty ? const [] : [text];
  }

  @override
  String toString() => 'WordEntry($id, $headword, $reading)';
}
