import 'dart:io';

import 'package:arisu_browser/data/local/app_database.dart';
import 'package:arisu_browser/data/models/word_entry.dart';
import 'package:arisu_browser/data/repositories/dictionary_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// Exercises [DictionaryRepository.search] mode selection against a real,
/// in-memory Drift database (and the FTS5 index) so the three lookup strategies
/// are covered, not just the pure query builders.
void main() {
  late Directory tmp;
  late Box settings;
  late AppDatabase db;
  late DriftDictionaryRepository repo;

  setUpAll(() async {
    tmp = await Directory.systemTemp.createTemp('yomu_search_test_');
    Hive.init(tmp.path);
    settings = await Hive.openBox('settings');
  });

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = DriftDictionaryRepository(db, settings);
    await repo.clearEntries();
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seed(Iterable<WordEntry> entries) async {
    await repo.insertEntries(entries.toList());
    await repo.rebuildSearchIndex();
  }

  test('Japanese input resolves through the prefix (index range) mode', () async {
    await seed([
      WordEntry(id: '1', headword: '読書', reading: 'どくしょ', meanings: ['to read']),
    ]);
    final page = await repo.search('読');
    expect(page.mode, DictionarySearchMode.prefix);
    expect(page.entries.map((e) => e.id), contains('1'));
  });

  test('Latin input resolves through the fullText (FTS5) mode', () async {
    await seed([
      WordEntry(id: '2', headword: 'nam châm', reading: '', meanings: ['magnet']),
    ]);
    final page = await repo.search('nam');
    expect(page.mode, DictionarySearchMode.fullText);
    expect(page.entries.map((e) => e.id), contains('2'));
  });

  test('no hit falls back to the contains mode', () async {
    await seed([
      WordEntry(id: '3', headword: '食堂', reading: 'しょくどう', meanings: ['canteen']),
    ]);
    final page = await repo.search('zzzzz');
    expect(page.mode, DictionarySearchMode.contains);
    expect(page.entries, isEmpty);
  });

  test('empty query returns the empty page', () async {
    await seed([WordEntry(id: '4', headword: '本', meanings: ['book'])]);
    final page = await repo.search('   ');
    expect(page.entries, isEmpty);
    expect(page.hasMore, isFalse);
  });

  test('paging reuses the supplied mode', () async {
    await seed([WordEntry(id: '5', headword: '木', meanings: ['tree'])]);
    final page = await repo.search('木', mode: DictionarySearchMode.prefix);
    expect(page.mode, DictionarySearchMode.prefix);
    expect(page.entries.map((e) => e.id), contains('5'));
  });

  test('fullText is empty before the index is rebuilt', () async {
    await repo.insertEntries([WordEntry(id: '6', headword: 'bàn', meanings: ['table'])]);
    // Deliberately skip rebuildSearchIndex.
    final page = await repo.search('bàn');
    expect(page.mode, isNot(DictionarySearchMode.fullText));
  });
}
