/// Pure-Dart parser for the bundled dictionary dataset, used by the build-time
/// asset generator. No Flutter / Drift imports.
library;

import 'dart:convert';
import 'dart:typed_data';

/// One entry trimmed to exactly what the runtime needs: word, reading, meanings.
class ParsedEntry {
  const ParsedEntry({
    required this.id,
    required this.word,
    required this.kana,
    required this.meanings,
  });

  final String id;
  final String word;
  final String kana;
  final List<String> meanings;
}

const int _openBrace = 0x7b; // {
const int _closeBrace = 0x7d; // }
const int _openBracket = 0x5b; // [
const int _closeBracket = 0x5d; // ]
const int _quote = 0x22; // "
const int _backslash = 0x5c; // \

/// Walks `{"api_entries":[ {...}, {...} ]}` one object at a time.
///
/// The dataset is large (~50 MB), so it is scanned as UTF-8 bytes and decoded
/// per entry: a single `jsonDecode` of the whole file would allocate the entire
/// object graph at once and risk an out-of-memory kill on a phone.
Iterable<ParsedEntry> parseDictionaryEntries(Uint8List bytes) sync* {
  final length = bytes.length;
  var cursor = bytes.indexOf(_openBracket);
  if (cursor < 0) return;

  while (cursor < length) {
    while (cursor < length &&
        bytes[cursor] != _openBrace &&
        bytes[cursor] != _closeBracket) {
      cursor++;
    }
    if (cursor >= length || bytes[cursor] == _closeBracket) return;

    final start = cursor;
    var depth = 0;
    var inString = false;
    var escaped = false;
    for (; cursor < length; cursor++) {
      final byte = bytes[cursor];
      if (inString) {
        if (escaped) {
          escaped = false;
        } else if (byte == _backslash) {
          escaped = true;
        } else if (byte == _quote) {
          inString = false;
        }
        continue;
      }
      if (byte == _quote) {
        inString = true;
      } else if (byte == _openBrace) {
        depth++;
      } else if (byte == _closeBrace) {
        depth--;
        if (depth == 0) {
          cursor++;
          break;
        }
      }
    }
    if (depth != 0) return; // truncated file — stop instead of throwing

    final raw = utf8.decode(Uint8List.sublistView(bytes, start, cursor));
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      final entry = wordEntryFromDataset(decoded);
      if (entry != null) yield entry;
    }
  }
}

/// Counts dataset entries by looking for the `"slug"` field each one carries.
///
/// Used only to drive the progress bar, so an approximate answer is fine; a
/// second full parse just to count would double the import time.
int countDatasetEntries(Uint8List bytes) {
  final needle = utf8.encode('"slug"');
  final first = needle[0];
  var count = 0;
  final limit = bytes.length - needle.length;
  for (var i = 0; i <= limit; i++) {
    if (bytes[i] != first) continue;
    var matches = true;
    for (var j = 1; j < needle.length; j++) {
      if (bytes[i + j] != needle[j]) {
        matches = false;
        break;
      }
    }
    if (matches) {
      count++;
      i += needle.length - 1;
    }
  }
  return count;
}

/// Maps one dataset object onto a [ParsedEntry], or `null` if it has no headword.
///
/// Dataset shape: `{id, slug, word, kana, suggest_mean, type: {name, tag}}`.
ParsedEntry? wordEntryFromDataset(Map<String, dynamic> json) {
  final headword = (json['word'] as String?)?.trim() ?? '';
  if (headword.isEmpty) return null;

  final id = json['id']?.toString() ?? json['slug']?.toString();
  if (id == null || id.isEmpty) return null;

  return ParsedEntry(
    id: id,
    word: headword,
    kana: (json['kana'] as String?)?.trim() ?? '',
    meanings: parseMeanings(json['suggest_mean'] as String?),
  );
}

/// Splits a dataset `suggest_mean` value into individual senses.
///
/// Entries use `;` between senses when present ("dè dặt; làm khách;"), and `,`
/// otherwise ("ahoy, hullo, hello"). Commas inside parentheses are kept, so
/// "nhựa (de: harz)" and "tóc ngắn (nữ)" survive intact.
List<String> parseMeanings(String? raw) {
  final text = raw?.trim() ?? '';
  if (text.isEmpty) return const [];

  final separator = text.contains(';') ? ';' : ',';
  final parts = <String>[];
  final buffer = StringBuffer();
  var depth = 0;

  for (final rune in text.runes) {
    final char = String.fromCharCode(rune);
    if (char == '(' || char == '（') {
      depth++;
    } else if (char == ')' || char == '）') {
      if (depth > 0) depth--;
    } else if (char == separator && depth == 0) {
      parts.add(buffer.toString());
      buffer.clear();
      continue;
    }
    buffer.write(char);
  }
  parts.add(buffer.toString());

  final seen = <String>{};
  final meanings = <String>[];
  for (final part in parts) {
    final cleaned = part.trim();
    if (cleaned.isEmpty) continue;
    if (seen.add(cleaned)) meanings.add(cleaned);
  }
  return meanings;
}
