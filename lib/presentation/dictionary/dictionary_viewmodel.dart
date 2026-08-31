import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/debouncer.dart';
import '../../data/models/word_entry.dart';
import '../../data/repositories/dictionary_repository.dart';
import '../../modules/dictionary_module.dart';
import '../../modules/usecases/lookup_word_usecase.dart';

/// State of the Dictionary browse/search screen (§7.6).
class DictionaryState {
  const DictionaryState({
    this.query = '',
    this.results = const [],
    this.recents = const [],
    this.mode,
    this.isSearching = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.entryCount = 0,
  });

  final String query;
  final List<WordEntry> results;
  final List<WordEntry> recents;

  /// Query mode of the current result set, reused when paging.
  final DictionarySearchMode? mode;
  final bool isSearching;
  final bool isLoadingMore;
  final bool hasMore;

  /// Entries available on device, shown as the empty-state subtitle.
  final int entryCount;

  bool get hasQuery => query.trim().isNotEmpty;
  bool get isEmptyResult => hasQuery && !isSearching && results.isEmpty;

  DictionaryState copyWith({
    String? query,
    List<WordEntry>? results,
    List<WordEntry>? recents,
    DictionarySearchMode? mode,
    bool clearMode = false,
    bool? isSearching,
    bool? isLoadingMore,
    bool? hasMore,
    int? entryCount,
  }) =>
      DictionaryState(
        query: query ?? this.query,
        results: results ?? this.results,
        recents: recents ?? this.recents,
        mode: clearMode ? null : (mode ?? this.mode),
        isSearching: isSearching ?? this.isSearching,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        entryCount: entryCount ?? this.entryCount,
      );
}

final dictionaryViewModelProvider =
    NotifierProvider.autoDispose<DictionaryViewModel, DictionaryState>(
  DictionaryViewModel.new,
);

/// Drives dictionary search: debounced queries, paging, recent lookups.
class DictionaryViewModel extends AutoDisposeNotifier<DictionaryState> {
  late final LookupWordUsecase _lookup;
  final Debouncer _debouncer =
      Debouncer(duration: const Duration(milliseconds: 250));

  /// Guards against a slow earlier query overwriting a newer result set.
  int _requestId = 0;
  bool _disposed = false;

  @override
  DictionaryState build() {
    _lookup = ref.read(lookupWordUsecaseProvider);

    ref.onDispose(() {
      _disposed = true;
      _debouncer.cancel();
    });

    // The dictionary is decoded and ready before the app starts, so just load
    // the entry count + recent lookups.
    Future.microtask(() {
      if (_disposed) return;
      refresh();
    });

    return const DictionaryState();
  }

  /// Reloads the entry count, the recent-lookup list and the active query.
  Future<void> refresh() async {
    final count = await _lookup.entryCount();
    final recents = await _lookup.recentLookups();
    if (_disposed) return;
    state = state.copyWith(entryCount: count, recents: recents);
    if (state.hasQuery) await _search(state.query);
  }

  /// Reloads just the recent-lookup list (after returning from Word Detail).
  Future<void> refreshRecents() async {
    final recents = await _lookup.recentLookups();
    if (_disposed) return;
    state = state.copyWith(recents: recents);
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);

    if (query.trim().isEmpty) {
      _debouncer.cancel();
      _requestId++;
      state = state.copyWith(
        results: const [],
        clearMode: true,
        isSearching: false,
        isLoadingMore: false,
        hasMore: false,
      );
      return;
    }

    state = state.copyWith(isSearching: true);
    _debouncer.call(() => _search(query));
  }

  void clearQuery() => setQuery('');

  Future<void> _search(String query) async {
    final requestId = ++_requestId;
    final page = await _lookup.search(query);
    if (_disposed || requestId != _requestId) return;
    state = state.copyWith(
      results: page.entries,
      mode: page.mode,
      hasMore: page.hasMore,
      isSearching: false,
    );
  }

  /// Appends the next page of results (infinite scroll).
  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isSearching || !state.hasMore) return;
    final mode = state.mode;
    if (mode == null) return;

    final requestId = _requestId;
    state = state.copyWith(isLoadingMore: true);
    final page = await _lookup.search(
      state.query,
      offset: state.results.length,
      mode: mode,
    );
    if (_disposed || requestId != _requestId) return;
    state = state.copyWith(
      results: [...state.results, ...page.entries],
      hasMore: page.hasMore,
      isLoadingMore: false,
    );
  }

  Future<void> clearRecents() async {
    await _lookup.clearRecents();
    if (_disposed) return;
    state = state.copyWith(recents: const []);
  }
}
