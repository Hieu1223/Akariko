/// Pure-Dart dictionary engine: a flat, array-backed prefix trie plus an
/// in-memory entry store, with a compact binary (gzip) serialization.
///
/// No Flutter / Drift imports so this file is shared by:
///  * the build-time asset generator (`tool/build_dictionary.dart`), and
///  * the runtime loader, which decodes the prebuilt asset directly.
library;

import 'dart:convert';
import 'dart:typed_data';

import '../../models/word_entry.dart';
import '../../repositories/dictionary_search.dart';

/// Magic + version header for the serialized dictionary asset.
const List<int> _kMagic = [0x59, 0x4F, 0x4D, 0x44]; // "YOMD"
const int _kVersion = 1;

/// Array-backed prefix trie over dictionary headwords / readings.
///
/// Children of a node are stored sorted by character code, so a prefix lookup is
/// a binary search per rune and a prefix scan is a bounded DFS that naturally
/// yields entries shortest-first (depth == rune length).
class FlatTrie {
  const FlatTrie({
    required this.childStart,
    required this.childChar,
    required this.childNext,
    required this.entryStart,
    required this.entryIds,
  });

  final Int32List childStart; // length nodeCount + 1
  final Int32List childChar; // length == total edges
  final Int32List childNext; // length == total edges
  final Int32List entryStart; // length nodeCount + 1
  final Int32List entryIds; // length == total entry refs

  /// Collects entry indices under [query] (prefix), shortest-first, up to
  /// [limit]. Returns `[]` when the prefix does not exist.
  List<int> collect(String query, int limit) {
    var node = 0;
    for (final r in query.runes) {
      node = _child(node, r);
      if (node < 0) return const [];
    }
    final out = <int>[];
    _dfs(node, out, limit);
    return out;
  }

  int _child(int node, int ch) {
    var a = childStart[node];
    var b = childStart[node + 1];
    while (a < b) {
      final m = (a + b) >> 1;
      final c = childChar[m];
      if (c == ch) return childNext[m];
      if (c < ch) {
        a = m + 1;
      } else {
        b = m;
      }
    }
    return -1;
  }

  void _dfs(int node, List<int> out, int limit) {
    for (var i = entryStart[node];
        i < entryStart[node + 1] && out.length < limit;
        i++) {
      out.add(entryIds[i]);
    }
    if (out.length >= limit) return;
    for (var i = childStart[node];
        i < childStart[node + 1] && out.length < limit;
        i++) {
      _dfs(childNext[i], out, limit);
    }
  }
}

/// In-memory dictionary: entries + two prefix tries (headword, reading).
class InMemoryDictionary {
  InMemoryDictionary({
    required this.words,
    required this.kanas,
    required this.meanings,
    required this.head,
    required this.reading,
  }) : _meaningText = [
          for (final m in meanings) m.join(' ').toLowerCase(),
        ];

  final List<String> words;
  final List<String> kanas;
  final List<List<String>> meanings;
  final FlatTrie head;
  final FlatTrie reading;

  /// Lowercased, space-joined meanings — used for meaning (latin) search.
  final List<String> _meaningText;

  int get entryCount => words.length;

  WordEntry _toEntry(int i) => WordEntry(
        id: i.toString(),
        headword: words[i],
        reading: kanas[i],
        meanings: meanings[i],
      );

  WordEntry? getById(String id) {
    final i = int.tryParse(id);
    if (i == null || i < 0 || i >= words.length) return null;
    return _toEntry(i);
  }

  List<WordEntry> getByIds(List<String> ids) {
    final out = <WordEntry>[];
    for (final id in ids) {
      final e = getById(id);
      if (e != null) out.add(e);
    }
    return out;
  }

  DictionarySearchPage search(
    String query, {
    int limit = 40,
    int offset = 0,
    DictionarySearchMode? mode,
  }) {
    final q = query.trim();
    if (q.isEmpty) return const DictionarySearchPage.empty();
    if (mode == DictionarySearchMode.meaning) {
      return _page(_searchMeaning(q, limit, offset), DictionarySearchMode.meaning);
    }
    if (mode == DictionarySearchMode.prefix) {
      return _page(
        _searchJapanese(q, limit, offset),
        DictionarySearchMode.prefix,
      );
    }
    if (containsJapanese(q)) {
      return _page(
        _searchJapanese(q, limit, offset),
        DictionarySearchMode.prefix,
      );
    }
    return _page(_searchMeaning(q, limit, offset), DictionarySearchMode.meaning);
  }

  DictionarySearchPage _page(List<WordEntry> entries, DictionarySearchMode mode) =>
      DictionarySearchPage(
        entries: entries,
        mode: mode,
        hasMore: entries.length >= 40,
      );

  /// Prefix search over headword + reading tries, shortest-first.
  List<WordEntry> _searchJapanese(String q, int limit, int offset) {
    final cap = offset + limit;
    final merged = _prefixIndices(q, cap);
    merged.sort(_byLengthThenWord);
    final end = (offset + limit).clamp(0, merged.length);
    final out = <WordEntry>[];
    for (var i = offset; i < end; i++) {
      out.add(_toEntry(merged[i]));
    }
    return out;
  }

  List<int> _prefixIndices(String q, int cap) {
    final seen = <int>{};
    final out = <int>[];
    void addAll(List<int> ids) {
      for (final i in ids) {
        if (seen.add(i)) out.add(i);
      }
    }

    addAll(head.collect(q, cap));
    addAll(reading.collect(q, cap));
    out.sort(_byLengthThenWord);
    return out;
  }

  int _byLengthThenWord(int a, int b) {
    final c = words[a].length.compareTo(words[b].length);
    return c != 0 ? c : words[a].compareTo(words[b]);
  }

  /// Linear scan over meanings (latin / Vietnamese / English) for all tokens.
  List<WordEntry> _searchMeaning(String q, int limit, int offset) {
    final tokens = q
        .toLowerCase()
        .split(RegExp(r'\W+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return const [];
    final cap = offset + limit;
    final hits = <int>[];
    for (var i = 0; i < _meaningText.length && hits.length < cap; i++) {
      final t = _meaningText[i];
      var ok = true;
      for (final tok in tokens) {
        if (!t.contains(tok)) {
          ok = false;
          break;
        }
      }
      if (ok) hits.add(i);
    }
    final end = (offset + limit).clamp(0, hits.length);
    final out = <WordEntry>[];
    for (var i = offset; i < end; i++) {
      out.add(_toEntry(hits[i]));
    }
    return out;
  }
}

/// True when [input] holds kana, kanji or Japanese punctuation — i.e. the query
/// should be resolved against headword/reading rather than the meanings.
bool containsJapanese(String input) => _japanesePattern.hasMatch(input);

final RegExp _japanesePattern = RegExp(
  r'[\u3000-\u303f\u3040-\u309f\u30a0-\u30ff\u3400-\u4dbf\u4e00-\u9fff'
  r'\uf900-\ufaff\uff66-\uff9f]',
);

// ── Build-time trie construction ───────────────────────────────────────────────


/// Builds a [FlatTrie] from [keys] (strings) mapped to [values] (entry indices).
///
/// Each key maps to exactly one value; multiple keys may share a prefix. Empty
/// keys are skipped. Children are kept sorted by character code via binary
/// insertion during construction, so no post-hoc sorting is needed.
FlatTrie buildTrie(List<String> keys, List<int> values) {
  // Parallel per-node arrays; children kept sorted by character code.
  final childKeys = <List<int>>[];
  final childNext = <List<int>>[];
  final entryIds = <List<int>>[];

  void newNode() {
    childKeys.add(<int>[]);
    childNext.add(<int>[]);
    entryIds.add(<int>[]);
  }

  newNode(); // root = 0

  for (var i = 0; i < keys.length; i++) {
    final k = keys[i];
    if (k.isEmpty) continue;
    var node = 0;
    for (final r in k.runes) {
      final keys0 = childKeys[node];
      // Binary search for rune `r` in the sorted child-keys list.
      var lo = 0;
      var hi = keys0.length;
      while (lo < hi) {
        final m = (lo + hi) >> 1;
        final c = keys0[m];
        if (c == r) {
          lo = m;
          break;
        } else if (c < r) {
          lo = m + 1;
        } else {
          hi = m;
        }
      }
      int child;
      if (lo < keys0.length && keys0[lo] == r) {
        child = childNext[node][lo];
      } else {
        final newChild = childKeys.length; // newNode() appends here
        newNode();
        keys0.insert(lo, r);
        childNext[node].insert(lo, newChild);
        child = newChild;
      }
      node = child;
    }
    entryIds[node].add(values[i]);
  }

  final nodeCount = childKeys.length;
  final cStart = Int32List(nodeCount + 1);
  final eStart = Int32List(nodeCount + 1);
  final cChar = <int>[];
  final cNext = <int>[];
  final eIds = <int>[];

  for (var n = 0; n < nodeCount; n++) {
    cStart[n] = cChar.length;
    cChar.addAll(childKeys[n]);
    cNext.addAll(childNext[n]);
    eStart[n] = eIds.length;
    eIds.addAll(entryIds[n]);
  }
  cStart[nodeCount] = cChar.length;
  eStart[nodeCount] = eIds.length;

  return FlatTrie(
    childStart: cStart,
    childChar: Int32List.fromList(cChar),
    childNext: Int32List.fromList(cNext),
    entryStart: eStart,
    entryIds: Int32List.fromList(eIds),
  );
}

// ── Serialization (encode in the tool, decode at runtime) ──────────────────────

Uint8List encodeDictionary(InMemoryDictionary d) {
  final bb = BytesBuilder();
  bb.add(_kMagic);
  bb.addByte(_kVersion);

  // Entries section.
  bb.addByte(0x01);
  _writeInt32(bb, d.words.length);
  for (var i = 0; i < d.words.length; i++) {
    _writeString(bb, d.words[i]);
    _writeString(bb, d.kanas[i]);
    final m = d.meanings[i];
    _writeInt32(bb, m.length);
    for (final s in m) {
      _writeString(bb, s);
    }
  }

  // Headword trie.
  bb.addByte(0x02);
  _writeTrie(bb, d.head);
  // Reading trie.
  bb.addByte(0x03);
  _writeTrie(bb, d.reading);

  return bb.toBytes();
}

void _writeTrie(BytesBuilder bb, FlatTrie t) {
  _writeInt32List(bb, t.childStart);
  _writeInt32List(bb, t.childChar);
  _writeInt32List(bb, t.childNext);
  _writeInt32List(bb, t.entryStart);
  _writeInt32List(bb, t.entryIds);
}

void _writeInt32List(BytesBuilder bb, Int32List list) {
  _writeInt32(bb, list.length);
  bb.add(Uint8List.view(list.buffer, list.offsetInBytes, list.lengthInBytes));
}

void _writeInt32(BytesBuilder bb, int v) {
  bb
    ..addByte(v & 0xff)
    ..addByte((v >> 8) & 0xff)
    ..addByte((v >> 16) & 0xff)
    ..addByte((v >> 24) & 0xff);
}

void _writeString(BytesBuilder bb, String s) {
  final b = utf8.encode(s);
  _writeInt32(bb, b.length);
  bb.add(b);
}

/// Decodes the bytes produced by [encodeDictionary] (already gunzipped).
InMemoryDictionary decodeDictionary(Uint8List bytes) {
  final bd = ByteData.sublistView(bytes);
  var pos = 0;

  int readInt32() {
    final v = bd.getInt32(pos, Endian.little);
    pos += 4;
    return v;
  }

  String readString() {
    final len = readInt32();
    final s = utf8.decode(bytes.sublist(pos, pos + len));
    pos += len;
    return s;
  }

  Int32List readInt32List() {
    final len = readInt32();
    final list = Int32List(len);
    for (var i = 0; i < len; i++) {
      list[i] = bd.getInt32(pos, Endian.little);
      pos += 4;
    }
    return list;
  }

  FlatTrie readTrie() => FlatTrie(
        childStart: readInt32List(),
        childChar: readInt32List(),
        childNext: readInt32List(),
        entryStart: readInt32List(),
        entryIds: readInt32List(),
      );

  pos = 5; // skip magic (4) + version (1)
  final words = <String>[];
  final kanas = <String>[];
  final meanings = <List<String>>[];
  FlatTrie? head;
  FlatTrie? reading;

  while (pos < bytes.length) {
    final tag = bytes[pos++];
    if (tag == 0x01) {
      final n = readInt32();
      for (var i = 0; i < n; i++) {
        final w = readString();
        final k = readString();
        final mc = readInt32();
        final ms = <String>[];
        for (var j = 0; j < mc; j++) {
          ms.add(readString());
        }
        words.add(w);
        kanas.add(k);
        meanings.add(ms);
      }
    } else if (tag == 0x02) {
      head = readTrie();
    } else if (tag == 0x03) {
      reading = readTrie();
    }
  }

  return InMemoryDictionary(
    words: words,
    kanas: kanas,
    meanings: meanings,
    head: head!,
    reading: reading!,
  );
}
