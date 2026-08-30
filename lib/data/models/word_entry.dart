import 'dart:convert';

import '../local/app_database.dart';

/// A single dictionary entry (maps from [DictionaryEntryRow]).
///
/// [meanings] is the decoded form of the row's `meanings_json` column: one
/// entry per sense, in dataset order.
class WordEntry {
  const WordEntry({
    required this.id,
    required this.headword,
    this.reading = '',
    this.pos = '',
    this.meanings = const [],
    this.sourcePack = 'default',
  });

  final String id;
  final String headword;
  final String reading;
  final String pos;
  final List<String> meanings;
  final String sourcePack;

  bool get hasReading => reading.isNotEmpty && reading != headword;

  /// Comma-separated POS tags, rendered as chips on the Word Detail screen.
  List<String> get posTags => pos.isEmpty
      ? const []
      : pos
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList(growable: false);

  /// Short gloss for list rows (§7.6): the first few senses, joined.
  String get shortGloss => meanings.take(3).join('; ');

  String get meaningsJson => jsonEncode(meanings);

  factory WordEntry.fromRow(DictionaryEntryRow row) => WordEntry(
        id: row.id,
        headword: row.headword,
        reading: row.reading,
        pos: row.pos,
        meanings: decodeMeanings(row.meaningsJson),
        sourcePack: row.sourcePack,
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
