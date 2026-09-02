import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../app/theme/ui_prefs_notifier.dart';
import '../../modules/webview_bridge_module.dart';

/// Owns the pool of live [InAppWebViewController]s, the per-tab scroll
/// positions, and the idle timers that release a backgrounded tab's page data.
///
/// The active tab is always kept alive; the next [UiPrefs.cachedTabCount] - 1
/// most-recently-used tabs retain their WebView mounted (paused) so switching
/// is instant. Any other tab keeps only its URL + history.
class WebViewInstanceManager {
  WebViewInstanceManager(this.ref);

  final Ref ref;

  final Map<String, InAppWebViewController> _controllers = {};
  final Map<String, int> _scrollPositions = {};
  final Map<String, Timer> _releaseTimers = {};
  final Map<String, bool> _paused = {};
  final List<String> _cachedOrder = [];

  String _activeTabId = '';

  int get _cachedCount => ref.read(uiPrefsProvider).cachedTabCount;
  int get _pageTimeout => ref.read(uiPrefsProvider).tabPageTimeoutSec;

  List<String> get cachedTabIds => List<String>.from(_cachedOrder);

  set activeTabId(String id) {
    if (_activeTabId == id) return;
    _activeTabId = id;
    _applyPauseStates();
  }

  InAppWebViewController? operator [](String tabId) => _controllers[tabId];
  bool hasController(String tabId) => _controllers.containsKey(tabId);

  void onScrollChanged(String tabId, int y) => _scrollPositions[tabId] = y;
  int? scrollPositionOf(String tabId) => _scrollPositions[tabId];

  void registerController(String tabId, InAppWebViewController c) {
    _controllers[tabId] = c;
    final bridge = ref.read(webviewBridgeServiceProvider);
    bridge.registerHandler(c);
    bridge.injectListener(c);
    _setPaused(c, tabId, paused: tabId != _activeTabId);
  }

  void unregisterController(String tabId) {
    _controllers.remove(tabId);
    _paused.remove(tabId);
    _releaseTimers[tabId]?.cancel();
    _releaseTimers.remove(tabId);
    _cachedOrder.remove(tabId);
  }

  void ensureCached(String id) {
    _cachedOrder.remove(id);
    _cachedOrder.insert(0, id);
    while (_cachedOrder.length > _cachedCount) {
      _releaseTab(_cachedOrder.removeLast());
    }
    _applyPauseStates();
  }

  void _releaseTab(String id) {
    if (id == _activeTabId) return;
    _cachedOrder.remove(id);
    _controllers.remove(id);
    _paused.remove(id);
    _releaseTimers[id]?.cancel();
    _releaseTimers.remove(id);
  }

  void _setPaused(InAppWebViewController c, String tabId, {required bool paused}) {
    if (_paused[tabId] == paused) return;
    try {
      if (paused) {
        c.pause();
      } else {
        c.resume();
      }
      _paused[tabId] = paused;
    } on Object {
      // ignore
    }
  }

  void _applyPauseStates() {
    for (final entry in _controllers.entries) {
      _setPaused(entry.value, entry.key, paused: entry.key != _activeTabId);
    }
  }

  void scheduleRelease(String id) {
    _releaseTimers[id]?.cancel();
    _releaseTimers.remove(id);
    if (id == _activeTabId) return;
    final timeout = _pageTimeout;
    if (timeout <= 0) return;
    _releaseTimers[id] = Timer(Duration(seconds: timeout), () => _releaseTab(id));
  }

  void cancelRelease(String id) {
    _releaseTimers[id]?.cancel();
    _releaseTimers.remove(id);
  }

  void dispose() {
    for (final t in _releaseTimers.values) {
      t.cancel();
    }
    _releaseTimers.clear();
    _controllers.clear();
    _cachedOrder.clear();
    _scrollPositions.clear();
    _paused.clear();
  }
}
