import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/ui_prefs_notifier.dart';
import '../../core/utils/debouncer.dart';
import '../../data/models/search_suggestion.dart';
import '../../modules/search_suggestions_module.dart';

/// State of the address-bar suggestion overlay.
///
/// Deliberately separate from `BrowserState`/`BrowserNavState`: every keystroke
/// updates this object, and nothing that watches it also builds the retained
/// WebViews, so typing never touches the platform view.
class AddressSuggestionsState {
  const AddressSuggestionsState({
    this.visible = false,
    this.query = '',
    this.suggestions = const [],
    this.loading = false,
  });

  /// True while the user is editing the address bar (overlay is mounted).
  final bool visible;
  final String query;
  final List<SearchSuggestion> suggestions;

  /// A lookup is in flight. Old rows stay on screen meanwhile, so the list
  /// doesn't flash empty between keystrokes.
  final bool loading;

  AddressSuggestionsState copyWith({
    bool? visible,
    String? query,
    List<SearchSuggestion>? suggestions,
    bool? loading,
  }) =>
      AddressSuggestionsState(
        visible: visible ?? this.visible,
        query: query ?? this.query,
        suggestions: suggestions ?? this.suggestions,
        loading: loading ?? this.loading,
      );
}

final addressSuggestionsProvider = NotifierProvider<AddressSuggestionsViewModel,
    AddressSuggestionsState>(AddressSuggestionsViewModel.new);

/// Drives the suggestion list while the address bar is being edited.
///
/// Performance rules encoded here:
///
/// * **Debounce** — a lookup runs [_debounceDelay] after the last keystroke, so
///   typing "flutter" costs one request, not seven.
/// * **Generation guard** — every lookup carries a sequence number; responses
///   that arrive after a newer keystroke (or after the overlay closed) are
///   dropped instead of overwriting the list out of order.
/// * **Identity check** — an unchanged result list is not re-emitted, so cache
///   hits (e.g. backspacing) rebuild nothing.
/// * **No state while hidden** — closing clears the rows so the hidden overlay
///   holds no widgets and no strings.
class AddressSuggestionsViewModel extends Notifier<AddressSuggestionsState> {
  static const Duration _debounceDelay = Duration(milliseconds: 160);
  static const int _maxRows = 8;

  final Debouncer _debouncer = Debouncer(duration: _debounceDelay);

  /// Incremented for every lookup and every close; a response is only applied
  /// when it still matches.
  int _generation = 0;
  bool _disposed = false;

  @override
  AddressSuggestionsState build() {
    ref.onDispose(() {
      _disposed = true;
      _debouncer.cancel();
    });
    return const AddressSuggestionsState();
  }

  /// Opens the overlay for the text currently in the address bar.
  ///
  /// With an empty [query] this shows recently visited pages without hitting the
  /// network.
  void open(String query) {
    if (state.visible && state.query == query) return;
    state = state.copyWith(visible: true, query: query, loading: true);
    _debouncer.cancel();
    _load(query);
  }

  /// Called from the text field's `onChanged` — debounced.
  void onQueryChanged(String query) {
    if (!state.visible) {
      open(query);
      return;
    }
    if (query == state.query) return;
    // Only swap in the new text; don't flip `loading` here. Setting `loading`
    // on every keystroke would animate the progress line (and rebuild the panel)
    // for the whole burst of a delete-spam, even though no new lookup has fired
    // yet — `_load` flips it when a request actually starts.
    state = state.copyWith(query: query);
    _debouncer.call(() => _load(query));
  }

  /// Hides the overlay and abandons any pending/in-flight lookup.
  void close() {
    _debouncer.cancel();
    _generation++;
    if (!state.visible &&
        state.suggestions.isEmpty &&
        state.query.isEmpty &&
        !state.loading) {
      return;
    }
    state = const AddressSuggestionsState();
  }

  Future<void> _load(String query) async {
    final generation = ++_generation;
    final prefs = ref.read(uiPrefsProvider);
    // Mark an in-flight lookup so the progress line shows only for real work,
    // not for the whole keystroke burst before the debounce fires.
    if (!state.loading) state = state.copyWith(loading: true);
    final results = await ref.read(searchSuggestionsModuleProvider).suggest(
          query,
          remoteEnabled: prefs.searchSuggestionsEnabled,
          hl: prefs.locale,
          limit: _maxRows,
        );

    // A newer keystroke won the race, or the overlay was dismissed while the
    // request was in flight.
    if (_disposed || generation != _generation || !state.visible) return;
    if (listEquals(results, state.suggestions)) {
      if (state.loading) state = state.copyWith(loading: false);
      return;
    }
    state = state.copyWith(suggestions: results, loading: false);
  }
}
