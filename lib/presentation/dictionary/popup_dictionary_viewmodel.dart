import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/webview_bridge.dart';
import '../../data/models/word_entry.dart';
import '../../data/repositories/dictionary_repository.dart';
import '../../modules/dictionary_module.dart';
import '../../modules/usecases/lookup_word_usecase.dart';

/// State driving the text-selection overlay (§7.5).
///
/// A long-press / selection no longer opens the dictionary straight away.
/// Instead it shows a context menu (Copy / Paste / Select All / Web Search /
/// Lookup / Ask AI). Only "Lookup" runs a dictionary search and opens a popup
/// listing every entry whose headword/reading starts with the selection,
/// ordered shortest first.
class PopupDictionaryState {
  const PopupDictionaryState({
    this.selection,
    this.menuVisible = false,
    this.loading = false,
    this.lookupResults = const [],
    this.error,
  });

  final WebSelection? selection;
  final bool menuVisible;
  final bool loading;
  final List<WordEntry> lookupResults;
  final String? error;

  bool get visible => selection != null;

  /// The context menu is shown right after a selection.
  bool get showMenu => menuVisible && selection != null;

  /// The dictionary list popup is shown after "Lookup" is chosen.
  bool get showLookup => lookupResults.isNotEmpty;

  PopupDictionaryState copyWith({
    WebSelection? selection,
    bool? menuVisible,
    bool? loading,
    List<WordEntry>? lookupResults,
    String? error,
    bool clearLookup = false,
  }) =>
      PopupDictionaryState(
        selection: selection ?? this.selection,
        menuVisible: menuVisible ?? this.menuVisible,
        loading: loading ?? this.loading,
        lookupResults: clearLookup ? const [] : (lookupResults ?? this.lookupResults),
        error: error ?? this.error,
      );
}

/// Drives the selection overlay (§7.5).
///
/// Kept alive for the session (non-autoDispose) so the active selection is not
/// lost across rebuilds; the overlay only renders when [state.visible].
final popupDictionaryViewModelProvider =
    NotifierProvider<PopupDictionaryViewModel, PopupDictionaryState>(
  PopupDictionaryViewModel.new,
);

class PopupDictionaryViewModel extends Notifier<PopupDictionaryState> {
  late final LookupWordUsecase _lookup;

  /// Guards against a slower earlier lookup overwriting a newer selection.
  int _requestId = 0;

  @override
  PopupDictionaryState build() {
    _lookup = ref.read(lookupWordUsecaseProvider);
    return const PopupDictionaryState();
  }

  /// Entry point called from the WebView selection stream: show the context
  /// menu instead of looking anything up.
  void onSelection(WebSelection sel) {
    if (sel.isEmpty) {
      hide();
      return;
    }
    state = state.copyWith(
      selection: sel,
      menuVisible: true,
      loading: false,
      clearLookup: true,
      error: null,
    );
  }

  /// "Lookup": prefix-search the dictionary for the selection and open the
  /// list popup, ordered from the shortest headword to the longest.
  Future<void> lookup() async {
    final sel = state.selection;
    if (sel == null) return;
    final requestId = ++_requestId;

    state = state.copyWith(
      menuVisible: false,
      loading: true,
      clearLookup: true,
      error: null,
    );

    final query = sel.text.trim();
    if (query.isEmpty) {
      state = state.copyWith(loading: false);
      return;
    }

    final page = await _lookup.search(
      query,
      mode: DictionarySearchMode.prefix,
    );
    if (requestId != _requestId) return;

    // Shortest headword first (fewest characters → longest).
    final sorted = [...page.entries]
      ..sort((a, b) => a.headword.length.compareTo(b.headword.length));

    if (requestId != _requestId) return;
    state = state.copyWith(loading: false, lookupResults: sorted);
  }

  void hide() {
    _requestId++;
    state = const PopupDictionaryState();
  }
}
