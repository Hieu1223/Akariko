import '../../data/models/word_entry.dart';
import '../../data/repositories/dictionary_repository.dart';

/// Dictionary lookups for the presentation layer (§7.6, §7.7).
///
/// Phase 3 is manual search only: a query goes straight to the dictionary
/// repository. Phase 4 adds the Kuromoji bridge, at which point [lookupText]
/// gains a tokenizer pass so a whole sentence can be resolved word by word —
/// callers keep the same entry point.
class LookupWordUsecase {
  LookupWordUsecase(this._repository);

  final DictionaryRepository _repository;

  /// Results per page; the Dictionary screen appends pages as the user scrolls.
  static const int pageSize = 40;

  Future<DictionarySearchPage> search(
    String query, {
    int offset = 0,
    DictionarySearchMode? mode,
  }) =>
      _repository.search(
        query,
        limit: pageSize,
        offset: offset,
        mode: mode,
      );

  Future<WordEntry?> byId(String id) => _repository.getById(id);

  /// Entries behind the "recent lookups" list, newest first.
  Future<List<WordEntry>> recentLookups() =>
      _repository.getByIds(_repository.recentLookupIds());

  /// Records that the user opened [id]'s full entry.
  Future<void> remember(String id) => _repository.addRecentLookup(id);

  Future<void> clearRecents() => _repository.clearRecentLookups();

  Future<int> entryCount() => _repository.entryCount();
}
