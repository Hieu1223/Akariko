import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/history_entry.dart';
import '../../modules/browser_module.dart';
import '../browser/browser_viewmodel.dart';

/// History list state (§7.19), grouped by day with an optional text filter.
class HistoryState {
  const HistoryState({this.entries = const [], this.query = ''});
  final List<HistoryEntry> entries;
  final String query;

  /// [entries] narrowed by [query] (title or URL substring, case-insensitive).
  List<HistoryEntry> get filtered {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return entries;
    return entries
        .where((e) =>
            e.url.toLowerCase().contains(q) ||
            e.displayTitle.toLowerCase().contains(q))
        .toList();
  }

  HistoryState copyWith({List<HistoryEntry>? entries, String? query}) =>
      HistoryState(
        entries: entries ?? this.entries,
        query: query ?? this.query,
      );
}

final historyViewModelProvider =
    NotifierProvider<HistoryViewModel, HistoryState>(HistoryViewModel.new);

class HistoryViewModel extends Notifier<HistoryState> {
  late final BrowserModule _module;
  StreamSubscription<List<HistoryEntry>>? _sub;

  @override
  HistoryState build() {
    _module = ref.read(browserModuleProvider);
    _sub = _module.watchHistory().listen((list) {
      state = state.copyWith(entries: list);
    });
    ref.onDispose(() => _sub?.cancel());
    return const HistoryState();
  }

  void setQuery(String q) => state = state.copyWith(query: q);

  /// Opens a history entry in the current tab and returns to the browser.
  void open(String url) {
    ref.read(browserViewModelProvider.notifier).navigateTo(url);
  }

  Future<void> remove(String id) => _module.removeHistory(id);
  Future<void> clearAll() => _module.clearHistory();
}
