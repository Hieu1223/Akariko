import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../core/utils/extensions.dart';
import '../../core/webview_bridge.dart';
import '../../data/models/tab_model.dart';
import '../../modules/ai_launcher_module.dart';
import '../../modules/browser_module.dart';
import '../../modules/webview_bridge_module.dart';
import '../dictionary/popup_dictionary_viewmodel.dart';

/// Phase-1 state for the browser shell.
class BrowserState {
  const BrowserState({
    required this.tabs,
    required this.activeTabId,
    this.canGoBack = false,
    this.canGoForward = false,
    this.isLoading = false,
    this.progress = 0,
  });

  final List<TabModel> tabs;
  final String activeTabId;
  final bool canGoBack;
  final bool canGoForward;
  final bool isLoading;
  final int progress;

  TabModel? get activeTab =>
      tabs.where((t) => t.id == activeTabId).firstOrNull;

  BrowserState copyWith({
    List<TabModel>? tabs,
    String? activeTabId,
    bool? canGoBack,
    bool? canGoForward,
    bool? isLoading,
    int? progress,
  }) =>
      BrowserState(
        tabs: tabs ?? this.tabs,
        activeTabId: activeTabId ?? this.activeTabId,
        canGoBack: canGoBack ?? this.canGoBack,
        canGoForward: canGoForward ?? this.canGoForward,
        isLoading: isLoading ?? this.isLoading,
        progress: progress ?? this.progress,
      );
}

const String kHomeUrl = 'about:home';

/// Drives the Browser shell: tab list, active tab, navigation events.
///
/// One [InAppWebViewController] is kept for the visible web tab; the home tab
/// ('about:home') renders the New Tab UI instead of a WebView. Kept alive for
/// the whole session (tabs must survive navigation away).
final browserViewModelProvider =
    NotifierProvider<BrowserViewModel, BrowserState>(BrowserViewModel.new);

class BrowserViewModel extends Notifier<BrowserState> {
  late final BrowserModule _module;
  InAppWebViewController? controller;
  StreamSubscription<List<TabModel>>? _sub;
  StreamSubscription<WebSelection>? _selSub;
  final TextEditingController addressController = TextEditingController();

  @override
  BrowserState build() {
    _module = ref.read(browserModuleProvider);
    ref.keepAlive();
    _init();
    // Forward in-page text selections to the popup dictionary overlay.
    _selSub = ref
        .read(webviewBridgeServiceProvider)
        .selectionStream
        .listen((sel) {
      ref.read(popupDictionaryViewModelProvider.notifier).onSelection(sel);
    });
    ref.onDispose(() {
      _sub?.cancel();
      _selSub?.cancel();
      addressController.dispose();
    });
    return const BrowserState(tabs: [], activeTabId: '');
  }

  Future<void> _init() async {
    final existing = await _module.getTabs();
    if (existing.isEmpty) {
      await _module.createTab(url: kHomeUrl, title: 'New Tab');
    }
    _sub = _module.watchTabs().listen((tabs) {
      if (tabs.isEmpty) return;
      final activeStillExists = tabs.any((t) => t.id == state.activeTabId);
      state = state.copyWith(
        tabs: tabs,
        activeTabId: activeStillExists ? state.activeTabId : tabs.first.id,
      );
      _syncAddressBar();
    });
  }

  void _syncAddressBar() {
    final active = state.activeTab;
    if (active != null && active.url != kHomeUrl) {
      addressController.text = active.url;
    }
  }

  TabModel? get activeTab => state.activeTab;

  Future<void> openNewTab() async {
    final tab = await _module.createTab(url: kHomeUrl, title: 'New Tab');
    state = state.copyWith(activeTabId: tab.id);
    _syncAddressBar();
  }

  Future<void> switchTo(String id) async {
    state = state.copyWith(activeTabId: id);
    _syncAddressBar();
    await _refreshBookmarkState();
    final tab = state.activeTab;
    if (tab != null && tab.url != kHomeUrl) {
      controller?.loadUrl(urlRequest: URLRequest(url: WebUri(tab.url)));
    }
  }

  Future<void> closeTab(String id) async {
    await _module.closeTab(id);
    if (state.tabs.length <= 1) {
      await _module.createTab(url: kHomeUrl, title: 'New Tab');
    }
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
    controller?.loadUrl(urlRequest: URLRequest(url: WebUri(target)));
    await _module.recordVisit(target);
    await _refreshBookmarkState();
  }

  Future<void> goBack() async => controller?.goBack();
  Future<void> goForward() async => controller?.goForward();
  Future<void> reload() async => controller?.reload();

  // ── WebView event callbacks ───────────────────────────────────────────
  void onWebViewCreated(InAppWebViewController c) {
    controller = c;
    final bridge = ref.read(webviewBridgeServiceProvider);
    bridge.registerHandler(c);
    bridge.injectListener(c);
  }

  Future<void> onLoadStart(WebUri? url) async {
    final tab = state.activeTab;
    final u = url?.toString() ?? '';
    state = state.copyWith(isLoading: true, progress: 0);
    ref.read(popupDictionaryViewModelProvider.notifier).hide();
    if (tab != null && u.isNotEmpty && u != kHomeUrl) {
      await _module.updateTab(tab.id, url: u);
      state = state.copyWith(
        tabs: state.tabs
            .map((t) => t.id == tab.id ? t.copyWith(url: u) : t)
            .toList(),
      );
      addressController.text = u;
    }
  }

  void onLoadStop(WebUri? url) {
    final u = url?.toString() ?? '';
    state = state.copyWith(isLoading: false, progress: 100);
    if (u.isNotEmpty && u != kHomeUrl) {
      _module.recordVisit(u);
    }
    if (controller != null) {
      ref.read(webviewBridgeServiceProvider).injectListener(controller!);
    }
    ref.read(popupDictionaryViewModelProvider.notifier).hide();
    _refreshBookmarkState();
    _refreshNavState();
  }

  Future<void> _refreshBookmarkState() async {
    final tab = state.activeTab;
    if (tab != null && tab.url != kHomeUrl) {
      _lastBookmarkState = await _module.isBookmarked(tab.url);
    } else {
      _lastBookmarkState = false;
    }
  }

  Future<void> _refreshNavState() async {
    final back = await controller?.canGoBack() ?? false;
    final fwd = await controller?.canGoForward() ?? false;
    state = state.copyWith(canGoBack: back, canGoForward: fwd);
  }

  Future<void> onToggleBookmark() async {
    final tab = state.activeTab;
    if (tab == null || tab.url == kHomeUrl) return;
    await _module.toggleBookmark(tab.url, title: tab.title);
    _lastBookmarkState = await _module.isBookmarked(tab.url);
  }

  bool _lastBookmarkState = false;
  bool get isActiveBookmarked => _lastBookmarkState;

  void onProgressChanged(int p) => state = state.copyWith(progress: p);

  /// Opens the selected text in ChatGPT via a new tab (§7.5 "Ask AI").
  ///
  /// The URL is built by [AiLauncherModule]; the new tab's WebView loads it
  /// through its `initialUrlRequest`, so no manual `loadUrl` is needed here.
  Future<void> askAi(String text) async {
    final url = ref.read(aiLauncherModuleProvider).explainUrl(text);
    final tab = await _module.createTab(url: url, title: 'ChatGPT');
    state = state.copyWith(activeTabId: tab.id);
    _syncAddressBar();
  }

  Future<void> onTitleChanged(String? title) async {
    final tab = state.activeTab;
    if (tab != null && title != null && title.isNotEmpty) {
      await _module.updateTab(tab.id, title: title);
      state = state.copyWith(
        tabs: state.tabs
            .map((t) => t.id == tab.id ? t.copyWith(title: title) : t)
            .toList(),
      );
    }
  }

  Future<void> onUpdateVisitedHistory(WebUri? url, bool? androidIsReload) async {
    final u = url?.toString();
    if (u != null && u.isNotEmpty && u != kHomeUrl) {
      addressController.text = u;
      await _module.updateTab(state.activeTabId, url: u);
    }
  }
}
