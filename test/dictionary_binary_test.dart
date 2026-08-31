import 'package:arisu_browser/data/datasources/local/dictionary_binary.dart';
import 'package:arisu_browser/data/repositories/dictionary_search.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a tiny in-memory dictionary entirely in-process so the trie + search
/// logic can be unit-tested without the 50 MB asset.
InMemoryDictionary _build() {
  final words = ['本', '本屋', '日本語', '読む', '読書'];
  final kanas = ['ほん', 'ほんや', 'にほんご', 'よむ', 'どくしょ'];
  final meanings = [
    ['book'],
    ['bookstore'],
    ['Japanese'],
    ['to read'],
    ['to read', 'reading'],
  ];
  final head = buildTrie(words, [0, 1, 2, 3, 4]);
  final reading = buildTrie(kanas, [0, 1, 2, 3, 4]);
  return InMemoryDictionary(
    words: words,
    kanas: kanas,
    meanings: meanings,
    head: head,
    reading: reading,
  );
}

void main() {
  test('prefix trie matches headword prefixes only', () {
    final d = _build();
    // The trie itself is strict: only headwords beginning with 本.
    final prefixIds = d.head.collect('本', 100);
    final prefixWords =
        prefixIds.map((i) => d.words[i]).toList();
    expect(prefixWords, containsAll(['本', '本屋']));
    expect(prefixWords, isNot(contains('日本語'))); // starts with 日, not 本
  });

  test('search() is prefix-only over headword + reading', () {
    final d = _build();
    final page = d.search('本');
    expect(page.mode, DictionarySearchMode.prefix);
    final hits = page.entries.map((e) => e.headword).toList();
    expect(hits, containsAll(['本', '本屋']));
    expect(hits, isNot(contains('日本語'))); // starts with 日, not 本
  });

  test('prefix search matches readings (kana)', () {
    final d = _build();
    final page = d.search('よ');
    expect(page.entries.map((e) => e.headword), contains('読む'));
  });

  test('meaning (latin) search scans meanings', () {
    final d = _build();
    final page = d.search('book');
    expect(page.mode, DictionarySearchMode.meaning);
    expect(
      page.entries.map((e) => e.headword),
      containsAll(['本', '本屋']),
    );
  });

  test('getById resolves the index id, null when out of range', () {
    final d = _build();
    expect(d.getById('0')?.headword, '本');
    expect(d.getById('99'), isNull);
    expect(d.getById('abc'), isNull);
  });

  test('encode -> decode round-trips and stays searchable', () {
    final d = _build();
    final decoded = decodeDictionary(encodeDictionary(d));
    expect(decoded.entryCount, d.entryCount);
    expect(
      decoded.search('本').entries.map((e) => e.headword),
      contains('本'),
    );
  });

  test('empty query yields the empty page', () {
    final d = _build();
    final page = d.search('   ');
    expect(page.entries, isEmpty);
    expect(page.hasMore, isFalse);
  });
}
