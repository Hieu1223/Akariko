import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../data/datasources/local/dictionary_import_datasource.dart';
import '../data/repositories/dictionary_repository.dart';
import 'browser_module.dart';
import 'usecases/import_dictionary_usecase.dart';
import 'usecases/lookup_word_usecase.dart';

/// Binding for the dictionary (§7.6/§7.7): asset importer + repository → use-cases.

/// Hive `settings` box, opened in `main()`.
///
/// Holds the dictionary import bookkeeping and the recent-lookup list; further
/// phases (flashcard prefs, news polling state) share the same box.
final settingsBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError(
    'settingsBoxProvider must be overridden in main() with the opened box',
  );
});

final dictionaryRepositoryProvider = Provider<DictionaryRepository>((ref) {
  return DriftDictionaryRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(settingsBoxProvider),
  );
});

final dictionaryImportDatasourceProvider =
    Provider<DictionaryImportDatasource>((ref) {
  return AssetDictionaryImportDatasource();
});

final importDictionaryUsecaseProvider = Provider<ImportDictionaryUsecase>((ref) {
  return ImportDictionaryUsecase(
    ref.watch(dictionaryRepositoryProvider),
    ref.watch(dictionaryImportDatasourceProvider),
  );
});

final lookupWordUsecaseProvider = Provider<LookupWordUsecase>((ref) {
  return LookupWordUsecase(ref.watch(dictionaryRepositoryProvider));
});
