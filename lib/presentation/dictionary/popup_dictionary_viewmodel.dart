import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/webview_bridge.dart';
import '../../data/models/token.dart';
import '../../data/models/word_entry.dart';
import '../../data/repositories/dictionary_repository.dart';
import '../../modules/dictionary_module.dart';
import '../../modules/tokenizer_module.dart';
import '../../modules/usecases/lookup_word_usecase.dart';
import '../../modules/usecases/tokenize_text_usecase.dart';

/// State driving the text-selection overlay (§7.5).
///
/// A long-press / selection no longer opens the dictionary straight away.
/// Instead it shows a context menu (Copy / Paste / Select All / Web Search /
/// Lookup / Ask AI). Only "Lookup" runs a dictionary search and opens a popup
/// listing every entry whose headword/reading starts with the selection,
/// ordered shortest first.
///
/// When "Lookup" is pressed on a multi-token selection, the popup first shows
/// the tokenized breakdown — every morpheme produced by the tokenizer — so the
/// user can tap an individual token to look that one up.
class PopupDictionaryState {
  const PopupDictionaryState({
    this.selection,
    this.menuVisible = false,
    this.tokenizing = false,
    this.tokens = const [],
    this.loading = false,
    this.lookupResults = const [],
    this.error,
  });

  final WebSelection? selection;
  final bool menuVisible;

  /// True while the tokenizer is running on the selection text.
  final bool tokenizing;

  /// Morphemes produced from [selection] (shown before the lookup results).
  final List<Token> tokens;

  final bool loading;
  final List<WordEntry> lookupResults;
  final String? error;

  bool get visible => selection != null;

  /// The context menu is shown right after a selection.
  bool get showMenu => menuVisible && selection != null;

  /// The token list is shown while [tokens] is non-empty and no lookup has
  /// been started yet.
  bool get showTokens => tokens.isNotEmpty && lookupResults.isEmpty && !loading;

  /// The dictionary list popup is shown after a token or the selection is
  /// looked up.
  bool get showLookup => lookupResults.isNotEmpty;

  PopupDictionaryState copyWith({
    WebSelection? selection,
    bool? menuVisible,
    bool? tokenizing,
    List<Token>? tokens,
    bool? loading,
    List<WordEntry>? lookupResults,
    String? error,
    bool clearLookup = false,
  }) =>
      PopupDictionaryState(
        selection: selection ?? this.selection,
        menuVisible: menuVisible ?? this.menuVisible,
        tokenizing: tokenizing ?? this.tokenizing,
        tokens: tokens ?? this.tokens,
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
  late final TokenizeTextUsecase _tokenizer;

  /// Guards against a slower earlier lookup overwriting a newer selection.
  int _requestId = 0;

  @override
  PopupDictionaryState build() {
    _lookup = ref.read(lookupWordUsecaseProvider);
    _tokenizer = ref.read(tokenizeTextUsecaseProvider);
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
      tokenizing: false,
      tokens: const [],
      loading: false,
      clearLookup: true,
      error: null,
    );
  }

  /// "Lookup": tokenize the selection first, then show the token list.
  /// Tapping a token later calls [lookupToken].
  Future<void> tokenizeSelection() async {
    final sel = state.selection;
    if (sel == null) return;
    final requestId = ++_requestId;

    state = state.copyWith(
      menuVisible: false,
      tokenizing: true,
      loading: false,
      clearLookup: true,
      error: null,
    );

    final query = sel.text.trim();
    if (query.isEmpty) {
      state = state.copyWith(tokenizing: false);
      return;
    }

    final tokens = await _tokenizer(query);
    if (requestId != _requestId) return;

    if (tokens.isEmpty) {
      // Non-Japanese selection or the native bridge is unavailable — fall back
      // to searching the full text.
      await lookupSelection();
      return;
    }

    state = state.copyWith(tokenizing: false, tokens: tokens);
  }

  /// Looks up a single [token]'s surface form, opening the result list.
  Future<void> lookupToken(Token token) async {
    final request = ++_requestId;

    state = state.copyWith(
      tokens: const [],
      loading: true,
      clearLookup: true,
      error: null,
    );

    final page = await _lookup.search(
      token.surface,
      mode: DictionarySearchMode.prefix,
    );
    if (request != _requestId) return;

    // Shortest headword first (fewest characters → longest).
    final sorted = [...page.entries]
      ..sort((a, b) => a.headword.length.compareTo(b.headword.length));

    if (request != _requestId) return;
    state = state.copyWith(loading: false, lookupResults: sorted);
  }

  /// Full-selection lookup — falls back to searching the whole trimmed text
  /// when tokenization yields no tokens (e.g. non-Japanese selection on a
  /// device without the Kuromoji bridge).
  Future<void> lookupSelection() async {
    final sel = state.selection;
    if (sel == null) return;
    final request = ++_requestId;

    final query = sel.text.trim();
    if (query.isEmpty) return;

    state = state.copyWith(
      tokens: const [],
      loading: true,
      clearLookup: true,
      error: null,
    );

    final page = await _lookup.search(
      query,
      mode: DictionarySearchMode.prefix,
    );
    if (request != _requestId) return;

    final sorted = [...page.entries]
      ..sort((a, b) => a.headword.length.compareTo(b.headword.length));

    if (request != _requestId) return;
    state = state.copyWith(loading: false, lookupResults: sorted);
  }

  /// Returns to the token list from a lookup result.
  void backToTokens() {
    state = state.copyWith(
      loading: false,
      clearLookup: true,
    );
  }

  void hide() {
    _requestId++;
    state = const PopupDictionaryState();
  }
}
