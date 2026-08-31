import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../data/datasources/local/dictionary_binary.dart';
import '../data/repositories/dictionary_repository.dart';
import 'usecases/lookup_word_usecase.dart';

/// Binding for the dictionary (§7.6/§7.7): prebuilt trie asset → repository →
/// use-cases. The dictionary is held entirely in memory; the asset is decoded
/// once at startup and injected via [inMemoryDictionaryProvider].

/// Hive `settings` box, opened in `main()`.
final settingsBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError(
    'settingsBoxProvider must be overridden in main() with the opened box',
  );
});

/// The decoded in-memory dictionary, loaded from the bundled trie asset.
///
/// Must be overridden in `main()` with the instance produced by
/// [decodeDictionary] (after gunzipping the asset bytes).
final inMemoryDictionaryProvider = Provider<InMemoryDictionary>((ref) {
  throw UnimplementedError(
    'inMemoryDictionaryProvider must be overridden in main() with the decoded '
    'dictionary asset',
  );
});

final dictionaryRepositoryProvider = Provider<DictionaryRepository>((ref) {
  return InMemoryDictionaryRepository(
    ref.watch(inMemoryDictionaryProvider),
    ref.watch(settingsBoxProvider),
  );
});

final lookupWordUsecaseProvider = Provider<LookupWordUsecase>((ref) {
  return LookupWordUsecase(ref.watch(dictionaryRepositoryProvider));
});
