import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/bookmark.dart';
import '../../modules/browser_module.dart';
import 'browser_viewmodel.dart';

/// Phase-1 home screen state: quick-access bookmarks + news feed (later).
class NewTabState {
  const NewTabState({this.bookmarks = const [], this.isLoading = false});
  final List<Bookmark> bookmarks;
  final bool isLoading;

  NewTabState copyWith({List<Bookmark>? bookmarks, bool? isLoading}) =>
      NewTabState(
        bookmarks: bookmarks ?? this.bookmarks,
        isLoading: isLoading ?? this.isLoading,
      );
}

final newTabViewModelProvider =
    NotifierProvider<NewTabViewModel, NewTabState>(NewTabViewModel.new);

class NewTabViewModel extends Notifier<NewTabState> {
  late final BrowserModule _module;
  StreamSubscription<List<Bookmark>>? _sub;

  @override
  NewTabState build() {
    _module = ref.read(browserModuleProvider);
    _sub = _module.watchBookmarks().listen((b) {
      state = state.copyWith(bookmarks: b);
    });
    ref.onDispose(() => _sub?.cancel());
    return const NewTabState();
  }

  /// Submits a search/URL from the home screen; navigates the active tab.
  void submit(String query) {
    ref.read(browserViewModelProvider.notifier).navigateTo(query);
  }
}
