import 'dart:convert';
import 'dart:typed_data';

import 'package:arisu_browser/data/datasources/local/dictionary_import_datasource.dart';
import 'package:arisu_browser/data/models/word_entry.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dataset parsing (phase 3): the importer walks the bundled JSON one entry at
/// a time instead of decoding all ~190k objects at once, so these tests pin the
/// scanner and the `suggest_mean` splitting rules.
void main() {
  group('parseMeanings', () {
    test('splits on semicolons when present', () {
      expect(
        parseMeanings('dè dặt; làm khách; ngượng ngùng;'),
        ['dè dặt', 'làm khách', 'ngượng ngùng'],
      );
    });

    test('splits on commas when there is no semicolon', () {
      expect(parseMeanings('ahoy, hullo, hello'), ['ahoy', 'hullo', 'hello']);
    });

    test('keeps commas inside parentheses', () {
      expect(
        parseMeanings('tóc ngắn, kiểu tóc ngắn (nữ, trẻ);'),
        ['tóc ngắn, kiểu tóc ngắn (nữ, trẻ)'],
      );
    });

    test('keeps a comma-separated sense when semicolons group them', () {
      expect(
        parseMeanings('khả năng suy nghĩ, năng lực suy nghĩ;'),
        ['khả năng suy nghĩ, năng lực suy nghĩ'],
      );
    });

    test('drops duplicates and blank senses', () {
      expect(parseMeanings('nam châm;  nam châm; ;'), ['nam châm']);
    });

    test('returns empty for null or blank input', () {
      expect(parseMeanings(null), isEmpty);
      expect(parseMeanings('   '), isEmpty);
    });
  });

  group('parseDictionaryEntries', () {
    Uint8List bytes(String json) => Uint8List.fromList(utf8.encode(json));

    const sample = '''
{
  "api_entries": [
    {
      "id": 40652,
      "slug": "遠慮する-40652",
      "word": "遠慮する",
      "kana": "えんりょする",
      "suggest_mean": "dè dặt; làm khách;",
      "type": { "name": "Nhật Việt", "tag": "jp_vn" }
    },
    {
      "id": 210903,
      "slug": "おーい-210903",
      "word": "おーい",
      "kana": "",
      "suggest_mean": "ahoy, hullo",
      "type": { "name": "Nhật Việt", "tag": "jp_vn" }
    }
  ]
}
''';

    test('maps every entry in the array', () {
      final entries = parseDictionaryEntries(bytes(sample)).toList();

      expect(entries, hasLength(2));
      expect(entries.first.id, '40652');
      expect(entries.first.headword, '遠慮する');
      expect(entries.first.reading, 'えんりょする');
      expect(entries.first.meanings, ['dè dặt', 'làm khách']);
      expect(entries.first.sourcePack, 'jp_vn');
      expect(entries.last.headword, 'おーい');
      expect(entries.last.reading, isEmpty);
      expect(entries.last.meanings, ['ahoy', 'hullo']);
    });

    test('handles braces and escaped quotes inside string values', () {
      final entries = parseDictionaryEntries(bytes('''
{"api_entries":[
  {"id":1,"slug":"a-1","word":"括弧","kana":"かっこ",
   "suggest_mean":"a \\"{quoted}\\" gloss; dấu ngoặc",
   "type":{"name":"Nhật Việt","tag":"jp_vn"}}
]}
''')).toList();

      expect(entries, hasLength(1));
      expect(entries.single.meanings, ['a "{quoted}" gloss', 'dấu ngoặc']);
    });

    test('skips entries without a headword', () {
      final entries = parseDictionaryEntries(bytes(
        '{"api_entries":[{"id":1,"word":"","kana":"","suggest_mean":"x"}]}',
      )).toList();

      expect(entries, isEmpty);
    });

    test('stops cleanly on a truncated file instead of throwing', () {
      final entries = parseDictionaryEntries(bytes(
        '{"api_entries":[{"id":1,"word":"読む","kana":"よむ","suggest_mean":"to read"},{"id":2,"word":"書',
      )).toList();

      expect(entries, hasLength(1));
      expect(entries.single.headword, '読む');
    });

    test('countDatasetEntries counts one per entry', () {
      expect(countDatasetEntries(bytes(sample)), 2);
    });
  });

  group('wordEntryFromDataset', () {
    test('falls back to the slug when no numeric id is present', () {
      final entry = wordEntryFromDataset({
        'slug': 'よむ-1',
        'word': '読む',
        'kana': 'よむ',
        'suggest_mean': 'to read',
      });

      expect(entry, isNotNull);
      expect(entry!.id, 'よむ-1');
      expect(entry.sourcePack, 'default');
    });
  });

  group('WordEntry', () {
    test('round-trips meanings through the json column', () {
      const entry = WordEntry(
        id: '1',
        headword: '磁石',
        reading: 'じしゃく',
        meanings: ['đá nam châm', 'nam châm'],
      );

      expect(
        WordEntry.decodeMeanings(entry.meaningsJson),
        entry.meanings,
      );
    });

    test('treats a non-json column as a single sense', () {
      expect(WordEntry.decodeMeanings('to read'), ['to read']);
      expect(WordEntry.decodeMeanings(''), isEmpty);
    });

    test('hides a reading that only repeats the headword', () {
      const kana = WordEntry(id: '1', headword: 'おーい', reading: 'おーい');
      const kanji = WordEntry(id: '2', headword: '読む', reading: 'よむ');

      expect(kana.hasReading, isFalse);
      expect(kanji.hasReading, isTrue);
    });

    test('shortGloss joins the first three senses', () {
      const entry = WordEntry(
        id: '1',
        headword: '驚異',
        meanings: ['điều kỳ diệu', 'điều thần diệu', 'kỳ tích', 'thần kỳ'],
      );

      expect(entry.shortGloss, 'điều kỳ diệu; điều thần diệu; kỳ tích');
    });
  });
}
