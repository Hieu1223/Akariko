import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/services.dart';

import '../../models/word_entry.dart';

/// Asset key of the bundled dictionary dataset (declared in `pubspec.yaml`).
const String kDictionaryAssetKey = 'lib/asset/dictionary.json';

/// Events emitted while reading the bundled dataset.
sealed class DictionaryImportEvent {
  const DictionaryImportEvent();
}

/// Emitted once, before the first chunk, with the entry count found in the file.
class DictionaryTotalEvent extends DictionaryImportEvent {
  const DictionaryTotalEvent(this.total);
  final int total;
}

/// A batch of parsed entries, ready to be written to the database.
class DictionaryChunkEvent extends DictionaryImportEvent {
  const DictionaryChunkEvent(this.entries);
  final List<WordEntry> entries;
}

/// Reads the bundled dictionary dataset — file access + parsing only, no
/// database writes and no import policy (that lives in the import use-case).
abstract class DictionaryImportDatasource {
  /// Streams the dataset in batches of [chunkSize] entries.
  ///
  /// The consumer must keep up: the parser waits for each chunk to be handled
  /// before producing the next one, which keeps peak memory flat regardless of
  /// how slow the database is.
  Stream<DictionaryImportEvent> read({int chunkSize});
}

class AssetDictionaryImportDatasource implements DictionaryImportDatasource {
  AssetDictionaryImportDatasource({this.assetKey = kDictionaryAssetKey});

  final String assetKey;

  @override
  Stream<DictionaryImportEvent> read({int chunkSize = 2000}) {
    final token = RootIsolateToken.instance;
    // Without a root token (unit tests, background isolates) there is no way to
    // hand asset access to a helper isolate — parse in place instead.
    return token == null
        ? _readInCurrentIsolate(chunkSize)
        : _readInHelperIsolate(token, chunkSize);
  }

  /// Parses in a helper isolate so the 50 MB JSON scan never janks the UI.
  Stream<DictionaryImportEvent> _readInHelperIsolate(
    RootIsolateToken token,
    int chunkSize,
  ) async* {
    final incoming = ReceivePort();
    final isolate = await Isolate.spawn(
      _parseEntrypoint,
      _ParseRequest(
        responsePort: incoming.sendPort,
        token: token,
        assetKey: assetKey,
        chunkSize: chunkSize,
      ),
      debugName: 'yomu-dictionary-import',
    );

    SendPort? ackPort;
    var chunksEmitted = 0;
    var fellBack = false;
    try {
      // Labelled so a fallback/completion leaves the loop *and* the try block,
      // instead of returning straight out of the generator.
      listen:
      await for (final message in incoming) {
        switch (message) {
          case SendPort port:
            ackPort = port;
          case DictionaryTotalEvent event:
            yield event;
          case DictionaryChunkEvent event:
            chunksEmitted++;
            yield event;
            // Backpressure: the parser is blocked until this ack arrives.
            ackPort?.send(null);
          case _ParseFailure failure:
            // A failure before the first chunk means the helper isolate could
            // not reach the asset bundle at all (no platform channel, hot
            // restart, …). Retrying in place still beats no dictionary.
            if (chunksEmitted == 0) {
              log('Dictionary parse isolate failed, falling back to the '
                  'current isolate: ${failure.message}');
              fellBack = true;
              break listen;
            }
            throw DictionaryImportException(failure.message, failure.stackTrace);
          case _ParseComplete _:
            break listen;
        }
      }
    } finally {
      incoming.close();
      isolate.kill(priority: Isolate.immediate);
    }

    if (fellBack) yield* _readInCurrentIsolate(chunkSize);
  }

  Stream<DictionaryImportEvent> _readInCurrentIsolate(int chunkSize) async* {
    final bytes = await _loadAsset(assetKey);
    yield DictionaryTotalEvent(countDatasetEntries(bytes));
    var chunk = <WordEntry>[];
    for (final entry in parseDictionaryEntries(bytes)) {
      chunk.add(entry);
      if (chunk.length >= chunkSize) {
        yield DictionaryChunkEvent(chunk);
        chunk = <WordEntry>[];
      }
    }
    if (chunk.isNotEmpty) yield DictionaryChunkEvent(chunk);
  }
}

/// Raised when the dataset cannot be read or parsed.
class DictionaryImportException implements Exception {
  const DictionaryImportException(this.message, [this.stackTrace]);
  final String message;
  final String? stackTrace;

  @override
  String toString() => 'DictionaryImportException: $message';
}

// ── Helper-isolate plumbing ─────────────────────────────────────────────────

class _ParseRequest {
  const _ParseRequest({
    required this.responsePort,
    required this.token,
    required this.assetKey,
    required this.chunkSize,
  });

  final SendPort responsePort;
  final RootIsolateToken token;
  final String assetKey;
  final int chunkSize;
}

class _ParseComplete {
  const _ParseComplete();
}

class _ParseFailure {
  const _ParseFailure(this.message, this.stackTrace);
  final String message;
  final String stackTrace;
}

Future<void> _parseEntrypoint(_ParseRequest request) async {
  final acks = ReceivePort();
  final ackQueue = StreamIterator<dynamic>(acks);
  request.responsePort.send(acks.sendPort);

  try {
    // Gives this isolate access to the asset bundle over the platform channel.
    BackgroundIsolateBinaryMessenger.ensureInitialized(request.token);
    final bytes = await _loadAsset(request.assetKey);
    request.responsePort.send(DictionaryTotalEvent(countDatasetEntries(bytes)));

    var chunk = <WordEntry>[];
    for (final entry in parseDictionaryEntries(bytes)) {
      chunk.add(entry);
      if (chunk.length >= request.chunkSize) {
        request.responsePort.send(DictionaryChunkEvent(chunk));
        chunk = <WordEntry>[];
        if (!await ackQueue.moveNext()) return;
      }
    }
    if (chunk.isNotEmpty) {
      request.responsePort.send(DictionaryChunkEvent(chunk));
      await ackQueue.moveNext();
    }
    request.responsePort.send(const _ParseComplete());
  } catch (error, stackTrace) {
    request.responsePort.send(_ParseFailure('$error', '$stackTrace'));
  } finally {
    await ackQueue.cancel();
    acks.close();
  }
}

Future<Uint8List> _loadAsset(String assetKey) async {
  final data = await rootBundle.load(assetKey);
  return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
}

// ── Dataset parsing (pure, unit-tested) ─────────────────────────────────────

const int _openBrace = 0x7b; // {
const int _closeBrace = 0x7d; // }
const int _openBracket = 0x5b; // [
const int _closeBracket = 0x5d; // ]
const int _quote = 0x22; // "
const int _backslash = 0x5c; // \

/// Walks `{"api_entries":[ {...}, {...} ]}` one object at a time.
///
/// The dataset is ~50 MB, so it is scanned as UTF-8 bytes and decoded per
/// entry: a single `jsonDecode` of the whole file would allocate the entire
/// object graph at once and risk an out-of-memory kill on a phone.
Iterable<WordEntry> parseDictionaryEntries(Uint8List bytes) sync* {
  final length = bytes.length;
  var cursor = bytes.indexOf(_openBracket);
  if (cursor < 0) return;

  while (cursor < length) {
    // Advance to the next object, stopping at the end of the array.
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

/// Maps one dataset object onto a [WordEntry], or `null` if it has no headword.
///
/// Dataset shape: `{id, slug, word, kana, suggest_mean, type: {name, tag}}`.
WordEntry? wordEntryFromDataset(Map<String, dynamic> json) {
  final headword = (json['word'] as String?)?.trim() ?? '';
  if (headword.isEmpty) return null;

  final id = json['id']?.toString() ?? json['slug']?.toString();
  if (id == null || id.isEmpty) return null;

  return WordEntry(
    id: id,
    headword: headword,
    reading: (json['kana'] as String?)?.trim() ?? '',
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
