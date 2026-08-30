import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/webview_bridge.dart';
import '../../data/models/token.dart';
import '../../data/models/word_entry.dart';
import '../../modules/dictionary_module.dart';
import '../../modules/tokenizer_module.dart';
import '../../modules/usecases/lookup_word_usecase.dart';

/// State driving the popup dictionary overlay (§7.5).
class PopupDictionaryState {
  const PopupDictionaryState({
    this.selection,
    this.loading = false,
    this.word,
    this.tokens = const [],
    this.error,
  });

  final WebSelection? selection;
  final bool loading;
  final WordEntry? word;
  final List<Token> tokens;
  final String? error;

  bool get visible => selection != null;
  bool get hasEntry => word != null || tokens.isNotEmpty;

  PopupDictionaryState copyWith({
    WebSelection? selection,
    bool? loading,
    WordEntry? word,
    List<Token>? tokens,
    String? error,
    bool clearWord = false,
    bool clearTokens = false,
  }) =>
      PopupDictionaryState(
        selection: selection ?? this.selection,
        loading: loading ?? this.loading,
        word: clearWord ? null : (word ?? this.word),
        tokens: clearTokens ? const [] : (tokens ?? this.tokens),
        error: error ?? this.error,
      );
}

/// Drives the popup dictionary: on a text selection it looks up the word (or
/// the token's base form) and tokenizes the selection so a sentence can be
/// explored morpheme by morpheme. Tapping a token re-runs the lookup for it.
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

  /// Entry point called from the WebView selection stream.
  void onSelection(WebSelection sel) {
    if (sel.isEmpty) {
      hide();
      return;
    }
    _resolve(sel);
  }

  Future<void> _resolve(WebSelection sel) async {
    final requestId = ++_requestId;
    state = state.copyWith(
      selection: sel,
      loading: true,
      clearWord: true,
      clearTokens: true,
      error: null,
    );

    final text = sel.text;
    final tokens = await _tokenize(text);
    if (requestId != _requestId) return;

    WordEntry? word = await _exactMatch(text);
    if (word == null && tokens.length == 1) {
      final base = tokens.first;
      if (base.hasBaseForm) word = await _exactMatch(base.baseForm);
    }
    if (requestId != _requestId) return;

    state = state.copyWith(loading: false, tokens: tokens, word: word);
  }

  /// Re-runs the lookup for a single tapped token (sentence breakdown → word).
  Future<void> focusToken(String surface) async {
    final requestId = _requestId;
    WordEntry? word = await _exactMatch(surface);
    if (word == null) {
      final tok = state.tokens.where((t) => t.surface == surface).firstOrNull;
      if (tok != null && tok.hasBaseForm) {
        word = await _exactMatch(tok.baseForm);
      }
    }
    if (requestId != _requestId) return;
    state = state.copyWith(word: word);
  }

  Future<WordEntry?> _exactMatch(String query) async {
    final page = await _lookup.search(query.trim());
    return page.entries.isNotEmpty ? page.entries.first : null;
  }

  Future<List<Token>> _tokenize(String text) async {
    if (text.trim().isEmpty) return const [];
    try {
      return await ref.read(tokenizeTextUsecaseProvider)(text);
    } on Object {
      // Tokenizer is best-effort enrichment; never block the dictionary card.
      return const [];
    }
  }

  void hide() {
    _requestId++;
    state = const PopupDictionaryState();
  }
}
