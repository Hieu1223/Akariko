import 'package:arisu_browser/data/datasources/local/dictionary_import_datasource.dart';
import 'package:arisu_browser/data/models/word_entry.dart';
import 'package:arisu_browser/data/repositories/dictionary_repository.dart';
import 'package:arisu_browser/modules/usecases/import_dictionary_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory [DictionaryRepository] that records what the import pipeline does
/// without touching SQLite or Hive.
class FakeDictionaryRepository implements DictionaryRepository {
  final List<WordEntry> written = [];
  int rebuildSearchIndexCalls = 0;
  bool clearEntriesCalled = false;
  int importedVersionValue = 0;
  int entryCountValue = 0;

  @override
  Future<int> entryCount() async => entryCountValue;

  @override
  Future<DictionarySearchPage> search(
    String query, {
    int limit = 40,
    int offset = 0,
    DictionarySearchMode? mode,
  }) async =>
      const DictionarySearchPage.empty();

  @override
  Future<WordEntry?> getById(String id) async => null;

  @override
  Future<List<WordEntry>> getByIds(List<String> ids) async => const [];

  @override
  Future<void> insertEntries(List<WordEntry> entries) async {
    written.addAll(entries);
  }

  @override
  Future<void> clearEntries() async {
    written.clear();
    entryCountValue = 0;
    clearEntriesCalled = true;
  }

  @override
  Future<void> rebuildSearchIndex() async => rebuildSearchIndexCalls++;

  @override
  int importedVersion() => importedVersionValue;

  @override
  Future<void> markImported({
    required int version,
    required int entryCount,
  }) async {
    importedVersionValue = version;
    entryCountValue = entryCount;
  }

  @override
  List<String> recentLookupIds() => const [];

  @override
  Future<void> addRecentLookup(String id) async {}

  @override
  Future<void> clearRecentLookups() async {}
}

/// Emits a finite, chunked stream of entries for the import pipeline.
class FakeDatasource implements DictionaryImportDatasource {
  FakeDatasource(this.entries);
  final List<WordEntry> entries;

  @override
  Stream<DictionaryImportEvent> read({int chunkSize = 2000}) async* {
    yield DictionaryTotalEvent(entries.length);
    for (var i = 0; i < entries.length; i += chunkSize) {
      final end = (i + chunkSize < entries.length) ? i + chunkSize : entries.length;
      yield DictionaryChunkEvent(entries.sublist(i, end));
    }
  }
}

WordEntry entry(String id, String headword) =>
    WordEntry(id: id, headword: headword, meanings: ['gloss-$id']);

void main() {
  group('ImportDictionaryUsecase.run', () {
    test('writes entries, rebuilds the index and marks imported', () async {
      final repo = FakeDictionaryRepository();
      final data = [entry('1', 'a'), entry('2', 'b'), entry('3', 'c')];
      final usecase = ImportDictionaryUsecase(repo, FakeDatasource(data));

      final stages = <DictionaryImportStage>[];
      await for (final p in usecase.run()) {
        stages.add(p.stage);
      }

      expect(stages.first, DictionaryImportStage.preparing);
      expect(stages.last, DictionaryImportStage.done);
      expect(stages, contains(DictionaryImportStage.indexing));
      expect(stages.where((s) => s == DictionaryImportStage.writing), isNotEmpty);
      // preparing → …writing… → indexing → done, no stage out of order.
      expect(
        stages.indexOf(DictionaryImportStage.indexing),
        greaterThan(stages.indexOf(DictionaryImportStage.writing)),
      );
      expect(repo.written, hasLength(3));
      expect(repo.rebuildSearchIndexCalls, 1);
      expect(repo.importedVersionValue, ImportDictionaryUsecase.datasetVersion);
      expect(repo.entryCountValue, 3);
    });

    test('streams the dataset in chunks (back-pressure contract)', () async {
      final repo = FakeDictionaryRepository();
      final data = List.generate(5, (i) => entry('$i', 'w$i'));
      final usecase = ImportDictionaryUsecase(repo, FakeDatasource(data));

      final sizes = <int>[];
      await for (final p in usecase.run()) {
        if (p.stage == DictionaryImportStage.writing) sizes.add(p.imported);
      }

      // Chunk size is 2000, so all five arrive in one chunk → 5 total.
      expect(sizes.last, 5);
      expect(repo.written, hasLength(5));
    });

    test('skips the work when already imported', () async {
      final repo = FakeDictionaryRepository();
      final data = [entry('1', 'a')];
      final seed = ImportDictionaryUsecase(repo, FakeDatasource(data));
      await for (final _ in seed.run()) {}

      // Second run should short-circuit before writing/indexing.
      final stages = <DictionaryImportStage>[];
      await for (final p in seed.run()) {
        stages.add(p.stage);
      }
      expect(stages, [DictionaryImportStage.done]);
      expect(repo.rebuildSearchIndexCalls, 1); // only the first run
    });

    test('fails (not imports) on an empty dataset', () async {
      final repo = FakeDictionaryRepository();
      final usecase = ImportDictionaryUsecase(repo, FakeDatasource(const []));

      final stages = <DictionaryImportStage>[];
      DictionaryImportProgress? last;
      await for (final p in usecase.run()) {
        stages.add(p.stage);
        last = p;
      }
      expect(stages.first, DictionaryImportStage.preparing);
      expect(stages.last, DictionaryImportStage.failed);
      expect(last?.error, isNotNull);
      expect(repo.rebuildSearchIndexCalls, 0);
      expect(repo.importedVersionValue, 0);
    });
  });
}
