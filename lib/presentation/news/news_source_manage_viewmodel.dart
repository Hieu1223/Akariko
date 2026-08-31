import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/news_source.dart';
import '../../modules/news_module.dart';
import '../../modules/usecases/manage_news_usecase.dart';

/// News Source Management state (§7.17).
class NewsSourceManageState {
  const NewsSourceManageState({
    this.sources = const [],
    this.isRefreshing = false,
    this.error,
  });
  final List<NewsSource> sources;
  final bool isRefreshing;

  /// Non-null when the last add/refresh failed — surfaced as a snackbar.
  final String? error;

  NewsSourceManageState copyWith({
    List<NewsSource>? sources,
    bool? isRefreshing,
    String? error,
    bool clearError = false,
  }) =>
      NewsSourceManageState(
        sources: sources ?? this.sources,
        isRefreshing: isRefreshing ?? this.isRefreshing,
        error: clearError ? null : (error ?? this.error),
      );
}

final newsSourceManageViewModelProvider =
    NotifierProvider<NewsSourceManageViewModel, NewsSourceManageState>(
        NewsSourceManageViewModel.new);

class NewsSourceManageViewModel extends Notifier<NewsSourceManageState> {
  late final ManageNewsUsecase _usecase;
  StreamSubscription<List<NewsSource>>? _sub;

  @override
  NewsSourceManageState build() {
    _usecase = ref.read(manageNewsUsecaseProvider);
    _sub = _usecase.watchSources().listen((s) {
      state = state.copyWith(sources: s, clearError: true);
    });
    ref.onDispose(() => _sub?.cancel());
    return const NewsSourceManageState();
  }

  /// Refreshes every source. Errors are swallowed per-source in the use-case;
  /// a hard failure (e.g. repository) is recorded as [error].
  Future<void> refreshAll() async {
    state = state.copyWith(isRefreshing: true, clearError: true);
    try {
      await _usecase.refreshAll();
    } on Object catch (e) {
      state = state.copyWith(error: _message(e));
    } finally {
      state = state.copyWith(isRefreshing: false);
    }
  }

  /// Adds a source after validating its feed. Returns `false` (and records
  /// [NewsSourceManageState.error] for the view to surface) when the feed is
  /// invalid/unreachable; `true` on success.
  Future<bool> addSource(String name, String feedUrl) async {
    try {
      await _usecase.addSource(name: name, feedUrl: feedUrl);
      return true;
    } on Object catch (e) {
      state = state.copyWith(error: _message(e));
      return false;
    }
  }

  Future<void> deleteSource(String id) => _usecase.deleteSource(id);
}

String _message(Object e) {
  final s = e.toString();
  return s.startsWith('Exception:') ? s.substring('Exception:'.length).trim() : s;
}
