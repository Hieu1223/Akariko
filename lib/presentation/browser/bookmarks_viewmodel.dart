import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/bookmark.dart';
import '../../modules/browser_module.dart';
import '../browser/browser_viewmodel.dart';

/// Bookmarks list state (§7.19).
class BookmarksState {
  const BookmarksState({this.bookmarks = const [], this.isLoading = false});
  final List<Bookmark> bookmarks;
  final bool isLoading;

  BookmarksState copyWith({List<Bookmark>? bookmarks, bool? isLoading}) =>
      BookmarksState(
        bookmarks: bookmarks ?? this.bookmarks,
        isLoading: isLoading ?? this.isLoading,
      );
}

final bookmarksViewModelProvider =
    NotifierProvider<BookmarksViewModel, BookmarksState>(BookmarksViewModel.new);

class BookmarksViewModel extends Notifier<BookmarksState> {
  late final BrowserModule _module;
  StreamSubscription<List<Bookmark>>? _sub;

  @override
  BookmarksState build() {
    _module = ref.read(browserModuleProvider);
    _sub = _module.watchBookmarks().listen((b) {
      state = state.copyWith(bookmarks: b);
    });
    ref.onDispose(() => _sub?.cancel());
    return const BookmarksState();
  }

  /// Opens a bookmark in the current tab and returns to the browser.
  void open(String url) {
    ref.read(browserViewModelProvider.notifier).navigateTo(url);
  }

  Future<void> remove(String url) => _module.removeBookmark(url);
}
