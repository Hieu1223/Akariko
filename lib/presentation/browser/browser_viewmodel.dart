import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../app/theme/ui_prefs_notifier.dart';
import '../../core/utils/extensions.dart';
import '../../data/models/tab_model.dart';
import '../../modules/ai_launcher_module.dart';
import '../../modules/browser_module.dart';
import '../../modules/webview_bridge_module.dart';
import '../dictionary/popup_dictionary_viewmodel.dart';
import 'browser_nav_state.dart';
import 'webview_instance_manager.dart';

/// Phase-1 structural state for the browser shell.
///
/// Deliberately holds only structural data (tabs / active id / cache). The
/// frequently-changing load indicators (progress, loading, back/forward,
/// bookmark) live in [BrowserNavState] so they don't rebuild the WebView tree.
class BrowserState {
  const BrowserState({
    required this.tabs,
    required this.activeTabId,
    this.cachedTabIds = const [],
  });

  final List<TabModel> tabs;
  final String activeTabId;
  /// Ordered list (active-first) of tab ids whose WebView is kept alive so
  /// switching to them is instant. Only these tabs retain live page state; the
  /// rest keep only their URL + history stack.
  final List<String> cachedTabIds;

  TabModel? get activeTab =>
      tabs.where((t) => t.id == activeTabId).firstOrNull;

  BrowserState copyWith({
    List<TabModel>? tabs,
    String? activeTabId,
    List<String>? cachedTabIds,
  }) =>
      BrowserState(
        tabs: tabs ?? this.tabs,
        activeTabId: activeTabId ?? this.activeTabId,
        cachedTabIds: cachedTabIds ?? this.cachedTabIds,
      );
}

const String kHomeUrl = 'about:home';

/// Drives the Browser shell: tab list, per-tab history, and a pool of live
/// WebViews for the most recently used tabs.
///
/// Every tab owns its own navigation history stack (capped at [UiPrefs.maxTabHistory]).
/// The top [UiPrefs.cachedTabCount] tabs keep their `InAppWebView` mounted so
/// switching between them is instant and never reloads. Any other tab keeps only
/// its URL + history. A per-tab timer releases a tab's page data after it has
/// been backgrounded for [UiPrefs.tabPageTimeoutSec] seconds (URL + stack stay).
///
/// The live WebView pool itself is owned by [WebViewInstanceManager]; this
/// view-model wires it to [BrowserState] (so the UI rebuilds when the cache
/// changes) and to the per-tab navigation/scroll/selection events.
final browserViewModelProvider =
    NotifierProvider<BrowserViewModel, BrowserState>(BrowserViewModel.new);

class BrowserViewModel extends Notifier<BrowserState> {
  late final BrowserModule _module;
  late final WebViewInstanceManager manager;
  final TextEditingController addressController = TextEditingController();

  /// 0 = chrome fully visible, 1 = fully collapsed. Driven directly by scroll
  /// position so the bar tracks the finger instead of snapping.
  final chromeOffset = ValueNotifier<double>(0);

  int _lastScrollY = 0;
  DateTime _lastScrollProcess = DateTime.fromMicrosecondsSinceEpoch(0);
  static const Duration _scrollInterval = Duration(milliseconds: 1000 ~/ 24);

  @override
  BrowserState build() {
    _module = ref.read(browserModuleProvider);
    manager = WebViewInstanceManager(ref);
    ref.keepAlive();
    _init();
    ref.read(webviewBridgeServiceProvider).selectionStream.listen((sel) {
      ref.read(popupDictionaryViewModelProvider.notifier).onSelection(sel);
    }).let((sub) => ref.onDispose(sub.cancel));
    ref.onDispose(() {
      _sub?.cancel();
      manager.dispose();
      chromeOffset.dispose();
      addressController.dispose();
    });
    return const BrowserState(tabs: [], activeTabId: '');
  }

  // ── Prefs (read live so settings changes apply without a restart) ─────────
  InAppWebViewController? get controller => manager[state.activeTabId];
  bool get hasActiveController => manager.hasController(state.activeTabId);

  TabModel? get activeTab => state.activeTab;

  BrowserNavViewModel get _nav => ref.read(browserNavProvider.notifier);

  // ── Lifecycle ───────────────────────────────────────────────────────────
  Future<void> _init() async {
    final existing = await _module.getTabs();
    if (existing.isEmpty) {
      await _module.createTab(url: kHomeUrl, title: 'New Tab');
    }
    _sub = _module.watchTabs().listen(_onTabsChanged);
  }

  StreamSubscription<List<TabModel>>? _sub;

  void _onTabsChanged(List<TabModel> tabs) {
    if (tabs.isEmpty) return;
    final prev = state.activeTabId;
    final activeStillExists = tabs.any((t) => t.id == state.activeTabId);
    final newActive =
        activeStillExists ? state.activeTabId : (tabs.firstOrNull?.id ?? '');
    // `watchTabs` re-emits on every `updateTab` (which rewrites `lastActiveAt`
    // and reorders the list). Skip the rebuild when only ordering/visibility
    // changed — the WebView tree doesn't care about tab order.
    if (state.activeTabId == newActive && _tabsStructurallyEqual(state.tabs, tabs)) {
      return;
    }
    state = state.copyWith(tabs: tabs, activeTabId: newActive);
    // The (new) active tab must always have its WebView mounted, otherwise its
    // page would render blank after a close-switch.
    _ensureCached(newActive);
    _syncAddressBar();
    if (newActive.isNotEmpty) _refreshNavStateActive();
    if (newActive != prev) _resetAddressBar();
  }

  /// True when the two lists hold the same id→(url,title) mapping, ignoring the
  /// `lastActiveAt` ordering that `watchTabs` imposes.
  bool _tabsStructurallyEqual(List<TabModel> a, List<TabModel> b) {
    if (a.length != b.length) return false;
    final byId = {for (final t in b) t.id: t};
    for (final t in a) {
      final o = byId[t.id];
      if (o == null || o.url != t.url || o.title != t.title) return false;
    }
    return true;
  }

  // ── WebView pool (delegated to [WebViewInstanceManager]) ───────────────────
  void registerController(String tabId, InAppWebViewController c) =>
      manager.registerController(tabId, c);

  void unregisterController(String tabId) => manager.unregisterController(tabId);

  /// Adds [id] to the live-WebView pool (active-first) and trims to the cap,
  /// releasing the page data of tabs pushed out. Mirrors [WebViewInstanceManager]
  /// into [BrowserState.cachedTabIds] so the UI rebuilds.
  void _ensureCached(String id) {
    final tab = state.tabs.where((t) => t.id == id).firstOrNull;
    manager.activeTabId = state.activeTabId;
    manager.ensureCached(id, isHome: tab?.url == kHomeUrl);
    _syncCachedState();
  }

  void _syncCachedState() =>
      state = state.copyWith(cachedTabIds: manager.cachedTabIds);

  /// Starts the idle timer that releases [id]'s page data after the configured
  /// timeout. Cancelled whenever the tab becomes active again.
  void _scheduleRelease(String id) => manager.scheduleRelease(id);

  // ── Tab management ─────────────────────────────────────────────────────────
  Future<void> openNewTab() async {
    final tab = await _module.createTab(url: kHomeUrl, title: 'New Tab');
    state = state.copyWith(activeTabId: tab.id);
    manager.activeTabId = tab.id;
    _nav.setLoading(false);
    _resetAddressBar();
    _refreshNavStateActive();
  }

  Future<void> switchTo(String id) async {
    if (id == state.activeTabId) {
      _resetAddressBar();
      return;
    }
    // The tab we're leaving keeps its page data for a while, then releases it.
    manager.activeTabId = state.activeTabId;
    final leaving = state.activeTab;
    if (leaving != null && leaving.url != kHomeUrl) {
      _scheduleRelease(leaving.id);
    }

    state = state.copyWith(activeTabId: id);
    manager.activeTabId = id;
    _nav.setLoading(false);
    _ensureCached(id);
    // The newly active tab must never be on a release timer.
    manager.cancelRelease(id);

    _resetAddressBar();
    revealChrome();
    _lastScrollY = 0;
    await _refreshBookmarkState();
    _refreshNavStateActive();
  }

  Future<void> closeTab(String id) async {
    manager.unregisterController(id);
    manager.cancelRelease(id);
    await _module.closeTab(id);
    if (state.tabs.length <= 1) {
      await _module.createTab(url: kHomeUrl, title: 'New Tab');
    }
    _syncCachedState();
  }

  /// Navigates the active tab to user input (URL or search query).
  Future<void> navigateTo(String input) async {
    final tab = state.activeTab;
    if (tab == null) return;
    final target = input.toLoadableUrl();
    await _module.updateTab(tab.id, url: target);
    state = state.copyWith(
      tabs: state.tabs
          .map((t) => t.id == tab.id ? t.copyWith(url: target, title: '') : t)
          .toList(),
    );
    addressController.text = target;
    if (manager.hasController(tab.id)) {
      await controller?.loadUrl(urlRequest: URLRequest(url: WebUri(target)));
    } else {
      // Home→web (or freshly created) tab: mount a WebView that loads [target].
      _ensureCached(tab.id);
    }
    _refreshNavStateActive();
    await _module.recordVisit(target);
    await _refreshBookmarkState();
  }

  // ── Per-tab history (delegated to the WebView's own back/forward stack) ────
  Future<void> goBack() async {
    final c = controller;
    if (c == null) return;
    if (await c.canGoBack()) await c.goBack();
  }

  Future<void> goForward() async {
    final c = controller;
    if (c == null) return;
    if (await c.canGoForward()) await c.goForward();
  }

  Future<void> reload() async {
    revealChrome();
    await controller?.reload();
  }

  Future<void> _refreshNavStateActive() async {
    final c = controller;
    if (c == null) {
      _nav.setNav(back: false, forward: false);
      return;
    }
    final back = await c.canGoBack();
    final fwd = await c.canGoForward();
    if (ref.read(browserNavProvider).canGoBack == back &&
        ref.read(browserNavProvider).canGoForward == fwd) {
      return;
    }
    _nav.setNav(back: back, forward: fwd);
  }

  // ── WebView event callbacks (per tab) ──────────────────────────────────────
  void onWebViewCreated(String tabId, InAppWebViewController c) =>
      registerController(tabId, c);

  void onLoadStart(String tabId, WebUri? url) {
    final u = url?.toString() ?? '';
    if (tabId == state.activeTabId) {
      _nav.setLoading(true);
      _lastScrollY = 0;
      revealChrome();
      ref.read(popupDictionaryViewModelProvider.notifier).hide();
    }
    if (u.isNotEmpty && u != kHomeUrl) _setTabUrlInState(tabId, u);
  }

  void onLoadStop(String tabId, WebUri? url) {
    final u = url?.toString() ?? '';
    if (tabId == state.activeTabId) {
      _nav.setLoading(false);
      _nav.setProgress(100);
    }
    if (u.isNotEmpty && u != kHomeUrl) {
      _module.updateTab(tabId, url: u);
    }
    final c = manager[tabId];
    if (c != null) ref.read(webviewBridgeServiceProvider).injectListener(c);
    ref.read(popupDictionaryViewModelProvider.notifier).hide();
    if (tabId == state.activeTabId) {
      _refreshBookmarkState();
      _refreshNavStateActive();
    }
  }

  void onProgressChanged(String tabId, int p) {
    if (tabId == state.activeTabId) _nav.setProgress(p);
  }

  void onTitleChanged(String tabId, String? title) {
    if (title == null || title.isEmpty) return;
    final existing = state.tabs.where((t) => t.id == tabId).firstOrNull;
    if (existing != null && existing.title == title) return;
    _module.updateTab(tabId, title: title).ignore();
    state = state.copyWith(
      tabs: state.tabs
          .map((t) => t.id == tabId ? t.copyWith(title: title) : t)
          .toList(),
    );
  }

  void onUpdateVisitedHistory(String tabId, WebUri? url, bool? androidIsReload) {
    final u = url?.toString();
    if (u == null || u.isEmpty || u == kHomeUrl) return;
    _setTabUrlInState(tabId, u);
    if (tabId == state.activeTabId) {
      addressController.text = u;
      _refreshNavStateActive();
    }
    _module.recordVisit(u).ignore();
  }

  void onScrollChanged(String tabId, int y) {
    manager.onScrollChanged(tabId, y);
    if (tabId != state.activeTabId) return;
    // Throttle the (relatively expensive) focus/chrome work to ~24 Hz so we
    // don't hit the focus tree and rebuild the chrome on every scroll frame.
    final now = DateTime.now();
    if (now.difference(_lastScrollProcess) < _scrollInterval) return;
    _lastScrollProcess = now;
    // Dismissing the keyboard when the page is manipulated satisfies "tapping
    // elsewhere releases the address-bar input".
    FocusManager.instance.primaryFocus?.unfocus();
    if (!ref.read(uiPrefsProvider).autoHideChrome) {
      if (chromeOffset.value != 0) chromeOffset.value = 0;
      _lastScrollY = y;
      return;
    }
    final dy = y - _lastScrollY;
    _lastScrollY = y;
    if (y <= 4) {
      if (chromeOffset.value != 0) chromeOffset.value = 0;
      return;
    }
    if (dy == 0) return;
    final next = (chromeOffset.value + dy / 220).clamp(0.0, 1.0);
    if (next != chromeOffset.value) chromeOffset.value = next;
  }

  void _setTabUrlInState(String id, String url) {
    final existing = state.tabs.where((t) => t.id == id).firstOrNull;
    if (existing != null && existing.url == url) return;
    state = state.copyWith(
      tabs: state.tabs
          .map((t) => t.id == id ? t.copyWith(url: url) : t)
          .toList(),
    );
  }

  /// Reveals the chrome (used after navigation / tab switches).
  void revealChrome() {
    if (chromeOffset.value != 0) chromeOffset.value = 0;
  }

  /// Resets the address bar to its idle state: shows the active URL but drops
  /// focus and any text selection so the keyboard is dismissed.
  void _resetAddressBar() {
    final active = state.activeTab;
    final text =
        (active != null && active.url != kHomeUrl) ? active.url : '';
    addressController.text = text;
    FocusManager.instance.primaryFocus?.unfocus();
    addressController.selection =
        TextSelection.collapsed(offset: text.length);
  }

  void _syncAddressBar() {
    final active = state.activeTab;
    if (active != null && active.url != kHomeUrl) {
      if (addressController.text != active.url) {
        addressController.text = active.url;
      }
    }
  }

  // ── Bookmarks ────────────────────────────────────────────────────────────
  Future<void> _refreshBookmarkState() async {
    final tab = state.activeTab;
    final bookmarked =
        (tab != null && tab.url != kHomeUrl) ? await _module.isBookmarked(tab.url) : false;
    _nav.setBookmarked(bookmarked);
  }

  Future<void> onToggleBookmark() async {
    final tab = state.activeTab;
    if (tab == null || tab.url == kHomeUrl) return;
    await _module.toggleBookmark(tab.url, title: tab.title);
    _nav.setBookmarked(await _module.isBookmarked(tab.url));
  }



  // ── Ask AI ────────────────────────────────────────────────────────────────
  Future<void> askAi(String text) async {
    final url = ref.read(aiLauncherModuleProvider).explainUrl(text);
    final tab = await _module.createTab(url: url, title: 'ChatGPT');
    state = state.copyWith(activeTabId: tab.id);
    manager.activeTabId = tab.id;
    _ensureCached(tab.id);
    manager.cancelRelease(tab.id);
    _resetAddressBar();
    _refreshNavStateActive();
  }
}

/// Tiny helper so we can `ref.onDispose(sub.cancel)` inline.
extension _LetExtension<T> on T {
  void let(void Function(T) block) => block(this);
}
