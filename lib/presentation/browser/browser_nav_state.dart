import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Volatile, per-frame-ish UI indicators for the active tab (loading spinner,
/// load progress, back/forward availability, bookmark state).
///
/// Kept separate from [BrowserState] on purpose: these change dozens of times
/// per page load (progress 0→100, load start/stop), whereas the WebView tree
/// only cares about structural state (tabs / active id / cache). Splitting them
/// stops every progress tick from rebuilding [BrowserView] and its retained
/// WebViews.
class BrowserNavState {
  const BrowserNavState({
    this.isLoading = false,
    this.progress = 0,
    this.canGoBack = false,
    this.canGoForward = false,
    this.isBookmarked = false,
  });

  final bool isLoading;
  final int progress;
  final bool canGoBack;
  final bool canGoForward;
  final bool isBookmarked;

  BrowserNavState copyWith({
    bool? isLoading,
    int? progress,
    bool? canGoBack,
    bool? canGoForward,
    bool? isBookmarked,
  }) =>
      BrowserNavState(
        isLoading: isLoading ?? this.isLoading,
        progress: progress ?? this.progress,
        canGoBack: canGoBack ?? this.canGoBack,
        canGoForward: canGoForward ?? this.canGoForward,
        isBookmarked: isBookmarked ?? this.isBookmarked,
      );
}

final browserNavProvider =
    NotifierProvider<BrowserNavViewModel, BrowserNavState>(BrowserNavViewModel.new);

class BrowserNavViewModel extends Notifier<BrowserNavState> {
  @override
  BrowserNavState build() => const BrowserNavState();

  void setLoading(bool v) =>
      state = state.copyWith(isLoading: v, progress: v ? 0 : state.progress);

  void setProgress(int p) => state = state.copyWith(progress: p);

  void setNav({required bool back, required bool forward}) =>
      state = state.copyWith(canGoBack: back, canGoForward: forward);

  void setBookmarked(bool v) => state = state.copyWith(isBookmarked: v);

  void reset() => state = const BrowserNavState();
}
