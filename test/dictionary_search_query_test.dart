import 'package:arisu_browser/data/local/daos/dictionary_dao.dart';
import 'package:flutter_test/flutter_test.dart';

/// Query builders behind dictionary search (phase 3). They decide which of the
/// three lookup strategies runs, so a mistake here silently degrades search.
void main() {
  group('prefixUpperBound', () {
    test('increments the last code point for the range scan', () {
      expect(prefixUpperBound('\u8aad'), '\u8aae'); // 読 → 謮
      expect(prefixUpperBound('ab'), 'ac');
    });

    test('bounds a range that contains the prefix itself', () {
      const prefix = '食べ';
      final bound = prefixUpperBound(prefix);

      expect(prefix.compareTo(bound) < 0, isTrue);
      expect('食べる'.compareTo(bound) < 0, isTrue);
      expect('食べる'.compareTo(prefix) > 0, isTrue);
      // A word outside the prefix must fall outside the range.
      expect('飲む'.compareTo(bound) > 0, isTrue);
    });

    test('handles surrogate pairs without producing a lone surrogate', () {
      final bound = prefixUpperBound('\u{20000}'); // CJK ext. B ideograph
      expect(bound.runes, hasLength(1));
      expect(bound.runes.single, 0x20001);
    });

    test('returns empty for an empty prefix', () {
      expect(prefixUpperBound(''), '');
    });
  });

  group('escapeLikePattern', () {
    test('escapes wildcards so user input matches literally', () {
      expect(escapeLikePattern('100%_off'), r'100\%\_off');
      expect(escapeLikePattern(r'back\slash'), r'back\\slash');
      expect(escapeLikePattern('読む'), '読む');
    });
  });

  group('buildFtsMatchQuery', () {
    test('requires every token, matched as a prefix', () {
      expect(buildFtsMatchQuery('nam cham'), '"nam"* AND "cham"*');
    });

    test('strips punctuation that FTS5 would read as an operator', () {
      expect(buildFtsMatchQuery('to read (a book)'),
          '"to"* AND "read"* AND "a"* AND "book"*');
      expect(buildFtsMatchQuery('cord-blood'), '"cord"* AND "blood"*');
      expect(buildFtsMatchQuery('"quoted"'), '"quoted"*');
    });

    test('returns null when there is nothing to match', () {
      expect(buildFtsMatchQuery('   '), isNull);
      expect(buildFtsMatchQuery('!!!'), isNull);
    });
  });

  group('containsJapanese', () {
    test('detects kana, kanji and half-width katakana', () {
      expect(containsJapanese('よむ'), isTrue);
      expect(containsJapanese('読書'), isTrue);
      expect(containsJapanese('ソフト'), isTrue);
      expect(containsJapanese('ｿﾌﾄ'), isTrue);
      expect(containsJapanese('日本のnews'), isTrue);
    });

    test('treats latin/Vietnamese input as non-Japanese', () {
      expect(containsJapanese('nam cham'), isFalse);
      expect(containsJapanese('dè dặt'), isFalse);
      expect(containsJapanese('123'), isFalse);
    });
  });
}
