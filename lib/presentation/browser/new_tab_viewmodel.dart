import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/bookmark.dart';
import '../../data/models/news_article.dart';
import '../../data/models/news_source.dart';
import '../../modules/browser_module.dart';
import '../../modules/news_module.dart';
import '../../modules/usecases/manage_news_usecase.dart';
import 'browser_viewmodel.dart';

/// Phase-1 home screen state: quick-access bookmarks + the news feed (§7.3).
class NewTabState {
  const NewTabState({
    this.bookmarks = const [],
    this.articles = const [],
    this.sources = const [],
    this.isLoading = false,
    this.isRefreshing = false,
  });
  final List<Bookmark> bookmarks;
  final List<NewsArticle> articles;
  final List<NewsSource> sources;
  final bool isLoading;
  final bool isRefreshing;

  NewTabState copyWith({
    List<Bookmark>? bookmarks,
    List<NewsArticle>? articles,
    List<NewsSource>? sources,
    bool? isLoading,
    bool? isRefreshing,
  }) =>
      NewTabState(
        bookmarks: bookmarks ?? this.bookmarks,
        articles: articles ?? this.articles,
        sources: sources ?? this.sources,
        isLoading: isLoading ?? this.isLoading,
        isRefreshing: isRefreshing ?? this.isRefreshing,
      );
}

final newTabViewModelProvider =
    NotifierProvider<NewTabViewModel, NewTabState>(NewTabViewModel.new);

class NewTabViewModel extends Notifier<NewTabState> {
  late final BrowserModule _module;
  late final ManageNewsUsecase _news;
  StreamSubscription<List<Bookmark>>? _bookmarkSub;
  StreamSubscription<List<NewsArticle>>? _articleSub;
  StreamSubscription<List<NewsSource>>? _sourceSub;
  bool _initialFetchDone = false;

  @override
  NewTabState build() {
    _module = ref.read(browserModuleProvider);
    _news = ref.read(manageNewsUsecaseProvider);

    _bookmarkSub = _module.watchBookmarks().listen((b) {
      state = state.copyWith(bookmarks: b);
    });
    _articleSub = _news.watchArticles().listen((a) {
      state = state.copyWith(articles: a);
    });
    _sourceSub = _news.watchSources().listen((s) {
      state = state.copyWith(sources: s);
    });
    ref.onDispose(() {
      _bookmarkSub?.cancel();
      _articleSub?.cancel();
      _sourceSub?.cancel();
    });

    // First cold open: the seeded sources have no articles yet. Kick a silent
    // refresh so the feed isn't empty on the very first launch. We must NOT read
    // `state` here (it isn't initialised until `build` returns), so we track
    // this with a plain flag instead.
    if (!_initialFetchDone) {
      _initialFetchDone = true;
      refreshNews(silent: true);
    }
    return const NewTabState();
  }

  /// Maps a source id to its display name for rendering article rows.
  String sourceNameOf(String sourceId) =>
      state.sources.where((s) => s.id == sourceId).firstOrNull?.name ?? '';

  /// Submits a search/URL from the home screen; navigates the active tab.
  void submit(String query) {
    ref.read(browserViewModelProvider.notifier).navigateTo(query);
  }

  /// Opens an article in the current tab (§7.3).
  void openArticle(String link) {
    ref.read(browserViewModelProvider.notifier).navigateTo(link);
  }

  /// Pull-to-refresh handler (§7.3); [silent] suppresses the spinner on the
  /// automatic first-load fetch.
  Future<void> refreshNews({bool silent = false}) async {
    if (!silent) state = state.copyWith(isRefreshing: true);
    try {
      await _news.refreshAll();
    } on Object {
      // A failed refresh is non-fatal — the previous articles (if any) remain.
    } finally {
      if (!silent) state = state.copyWith(isRefreshing: false);
    }
  }
}
