import '../../data/datasources/local/dictionary_import_datasource.dart';
import '../../data/repositories/dictionary_repository.dart';

/// Stage of the one-time dictionary import (§9 phase 3).
enum DictionaryImportStage {
  /// Nothing has been checked yet.
  idle,

  /// Clearing any previous dataset before writing the new one.
  preparing,

  /// Parsing the bundled dataset and writing rows.
  writing,

  /// Building the FTS5 search index over the imported rows.
  indexing,

  /// Dictionary is searchable.
  done,

  /// Import stopped on an error; [DictionaryImportProgress.error] explains it.
  failed,
}

/// Progress snapshot emitted by [ImportDictionaryUsecase.run].
class DictionaryImportProgress {
  const DictionaryImportProgress({
    required this.stage,
    this.imported = 0,
    this.total = 0,
    this.error,
  });

  final DictionaryImportStage stage;
  final int imported;
  final int total;
  final String? error;

  bool get isRunning =>
      stage == DictionaryImportStage.preparing ||
      stage == DictionaryImportStage.writing ||
      stage == DictionaryImportStage.indexing;

  /// 0..1 while writing rows, or `null` when the work is not measurable
  /// (index rebuild, unknown total).
  double? get fraction {
    if (stage != DictionaryImportStage.writing || total <= 0) return null;
    return (imported / total).clamp(0.0, 1.0);
  }
}

/// Imports the bundled dictionary dataset into `DictionaryEntriesTable`.
///
/// Pairs the asset parser ([DictionaryImportDatasource]) with the dictionary
/// repository: the datasource never touches the database, and the repository
/// never decides *when* an import is needed — that policy lives here.
class ImportDictionaryUsecase {
  ImportDictionaryUsecase(this._repository, this._datasource);

  final DictionaryRepository _repository;
  final DictionaryImportDatasource _datasource;

  /// Bump when the bundled dataset changes so installed apps re-import.
  static const int datasetVersion = 1;

  /// Rows written per transaction. Large enough to keep SQLite busy, small
  /// enough that a chunk never holds a noticeable amount of memory.
  static const int chunkSize = 2000;

  /// Whether the current dataset version has already been imported.
  Future<bool> isImported() async =>
      _repository.importedVersion() >= datasetVersion &&
      await _repository.entryCount() > 0;

  /// Runs the import, emitting progress as it goes.
  ///
  /// Skips the work when the dataset is already in place unless [force] is set
  /// (Settings → "dictionary pack management" re-import in a later phase).
  Stream<DictionaryImportProgress> run({bool force = false}) async* {
    try {
      if (!force && await isImported()) {
        final count = await _repository.entryCount();
        yield DictionaryImportProgress(
          stage: DictionaryImportStage.done,
          imported: count,
          total: count,
        );
        return;
      }

      yield const DictionaryImportProgress(
        stage: DictionaryImportStage.preparing,
      );
      await _repository.clearEntries();

      var imported = 0;
      var expected = 0;
      await for (final event in _datasource.read(chunkSize: chunkSize)) {
        switch (event) {
          case DictionaryTotalEvent(:final total):
            expected = total;
            yield DictionaryImportProgress(
              stage: DictionaryImportStage.writing,
              total: expected,
            );
          case DictionaryChunkEvent(:final entries):
            await _repository.insertEntries(entries);
            imported += entries.length;
            yield DictionaryImportProgress(
              stage: DictionaryImportStage.writing,
              imported: imported,
              total: expected,
            );
        }
      }

      if (imported == 0) {
        // Never record an empty dataset as imported, or the dictionary would
        // stay silently empty until the app is reinstalled.
        yield const DictionaryImportProgress(
          stage: DictionaryImportStage.failed,
          error: 'No entries could be read from the bundled dictionary.',
        );
        return;
      }

      yield DictionaryImportProgress(
        stage: DictionaryImportStage.indexing,
        imported: imported,
        total: expected,
      );
      await _repository.rebuildSearchIndex();
      await _repository.markImported(
        version: datasetVersion,
        entryCount: imported,
      );

      yield DictionaryImportProgress(
        stage: DictionaryImportStage.done,
        imported: imported,
        total: imported,
      );
    } catch (error) {
      yield DictionaryImportProgress(
        stage: DictionaryImportStage.failed,
        error: '$error',
      );
    }
  }
}
