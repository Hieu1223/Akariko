import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/ui_prefs_notifier.dart';
import '../../core/constants/routes.dart';
import '../../data/models/tab_model.dart';
import '../../modules/download_module.dart';
import '../common_widgets/bottom_toolbar.dart';
import '../common_widgets/popup_dictionary_card.dart';
import '../common_widgets/safari_address_bar.dart';
import 'address_suggestions_overlay.dart';
import 'browser_viewmodel.dart';
import 'browser_nav_state.dart';
import 'perf_overlay.dart';

/// Main browser shell: address bar + (WebView | Home) + bottom toolbar.
class BrowserView extends ConsumerWidget {
  const BrowserView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only the fields the shell actually depends on — not the whole
    // [BrowserState]. Title/url churn on a background tab must NOT rebuild this
    // widget (and the retained WebViews), only [BrowserNavState] ticks do.
    final vmNotifier = ref.read(browserViewModelProvider.notifier);
    final prefs = ref.watch(uiPrefsProvider);
    final activeTabId =
        ref.watch(browserViewModelProvider.select((s) => s.activeTabId));
    final tabCount =
        ref.watch(browserViewModelProvider.select((s) => s.tabs.length));
    final showPerfOverlay = ref.watch(
      uiPrefsProvider.select((s) => s.perfOverlayEnabled),
    );

    // The address bar depends on the volatile nav state (loading / progress /
    // bookmark), so it is a Consumer: a progress tick rebuilds only this widget,
    // not the WebView tree above.
    final addressBar = Consumer(
      builder: (ctx, ref, _) {
        final nav = ref.watch(browserNavProvider);
        return SafariAddressBar(
          controller: vmNotifier.addressController,
          focusNode: vmNotifier.addressFocusNode,
          isLoading: nav.isLoading,
          progress: nav.progress.toDouble(),
          onChanged: vmNotifier.onAddressChanged,
          onClear: vmNotifier.clearAddress,
          onSubmitted: (q) => vmNotifier.navigateTo(q),
          trailing: IconButton(
            icon: Icon(
              (!nav.isBookmarked) ? Icons.bookmark : Icons.bookmark_border,
              size: 18,
            ),
            onPressed: () {
              if (activeTabId.isNotEmpty) {
                vmNotifier.onToggleBookmark();
              }
            },
          ),
        );
      },
    );

    // Static address bar — no scroll-based collapse. Full-width, like a normal
    // browser URL bar, with a configurable height.
    final chrome = SizedBox(
      height: prefs.topBarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Center(child: addressBar),
      ),
    );

    // The WebView stack rebuilds only when the *set* of cached tabs changes
    // (tab switch / open / close) — never on a title or background-URL update.
    final content = SizedBox.expand(
      child: Consumer(
        builder: (ctx, ref, _) {
          final cachedIds = ref.watch(
            browserViewModelProvider.select((s) => s.cachedTabIds),
          );
          // Read current tabs once; this closure only re-runs when cachedIds
          // changes, at which point the url for any new tab is already known.
          final tabs = ref.read(browserViewModelProvider).tabs;
          return Stack(
            children: [
              for (final id in cachedIds)
                _webViewTile(id, tabs, vmNotifier, activeTabId),
              const Positioned.fill(child: PopupDictionaryOverlay()),
              // Address-bar suggestions live in the shell (not a pushed route),
              // so the WebView underneath is never detached and the shell's
              // back handler can dismiss them.
              const Positioned.fill(child: AddressSuggestionsOverlay()),
              if (showPerfOverlay) const PerfOverlay(),
            ],
          );
        },
      ),
    );

    final scaffold = Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            if (prefs.addressBarPosition == AddressBarPosition.top) chrome,
            Expanded(child: content),
            if (prefs.addressBarPosition == AddressBarPosition.bottom) chrome,
            // Back/forward availability is volatile nav state; keep it in a
            // Consumer so only the toolbar rebuilds on a history change.
            Consumer(
              builder: (ctx, ref, _) {
                final nav = ref.watch(browserNavProvider);
                return BottomToolbar(
                  tabCount: tabCount,
                  canGoBack: nav.canGoBack,
                  height: prefs.bottomBarHeight,
                  onBack: vmNotifier.hasActiveController
                      ? () => vmNotifier.goBack()
                      : () {},
                  onReload: vmNotifier.hasActiveController
                      ? () => vmNotifier.reload()
                      : () {},
                  onNewTab: () => vmNotifier.openNewTab(),
                  onTabs: () {
                    // Leaving the shell ends address editing, so we never come
                    // back to a stale suggestion list / keyboard.
                    vmNotifier.cancelAddressEditing();
                    context.pushNamed(Routes.tabSwitcher);
                  },
                  onMenu: () {
                    vmNotifier.cancelAddressEditing();
                    _openMenu(context, ref);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );

    // Intercept the OS back gesture / button on phones. Priority:
    //   1. the address-bar suggestion overlay → close it, stay on the page;
    //   2. the page's own history → step back inside the WebView;
    //   3. a parent tab on the nav stack → return to it;
    //   4. nothing left → leave the app.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (vmNotifier.isEditingAddress) {
          vmNotifier.cancelAddressEditing();
          return;
        }
        // `canGoBack` is already tracked in nav state, so the common case needs
        // no round-trip to the platform WebView; only fall back to the async
        // check before we would otherwise close the app.
        if (ref.read(browserNavProvider).canGoBack) {
          await vmNotifier.goBack();
          return;
        }
        final controller = vmNotifier.controller;
        if (controller != null && await controller.canGoBack()) {
          await vmNotifier.goBack();
          return;
        }
        // No WebView history left — return to the parent tab if there is one.
        if (vmNotifier.popTabBackStack()) {
          return;
        }
        await SystemNavigator.pop();
      },
      child: scaffold,
    );
  }

  Widget _webViewTile(
    String id,
    List<TabModel> tabs,
    BrowserViewModel vm,
    String activeTabId,
  ) {
    // Use a Map for O(1) lookup instead of linear scan on every tile build
    final url = tabs.firstWhere((t) => t.id == id, orElse: () => TabModel(id: '', url: 'about:blank', title: '')).url;
    final isActive = id == activeTabId;
    return Offstage(
      offstage: !isActive,
      child: _TabWebView(
        key: ValueKey(id),
        tabId: id,
        initialUrl: url,
        vm: vm,
      ),
    );
  }

  void _openMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Bookmarks'),
              onTap: () {
                Navigator.pop(ctx);
                context.pushNamed(Routes.bookmarks);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () {
                Navigator.pop(ctx);
                context.pushNamed(Routes.history);
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Dictionary'),
              onTap: () {
                Navigator.pop(ctx);
                context.pushNamed(Routes.dictionary);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Downloads'),
              onTap: () {
                Navigator.pop(ctx);
                context.pushNamed(Routes.downloads);
              },
            ),
            ListTile(
              leading: const Icon(Icons.rss_feed),
              title: const Text('News Sources'),
              onTap: () {
                Navigator.pop(ctx);
                context.pushNamed(Routes.newsSources);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(ctx);
                context.pushNamed(Routes.settings);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// A single, retained WebView for one cached tab. Its controller is registered
/// with the [BrowserViewModel] so navigation/scroll/selection events can be
/// routed back to the correct tab.
class _TabWebView extends StatefulWidget {
  const _TabWebView({
    super.key,
    required this.tabId,
    required this.initialUrl,
    required this.vm,
  });

  final String tabId;
  final String initialUrl;
  final BrowserViewModel vm;

  @override
  State<_TabWebView> createState() => _TabWebViewState();
}

class _TabWebViewState extends State<_TabWebView> {
  @override
  void dispose() {
    widget.vm.unregisterController(widget.tabId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      key: widget.key,
      initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        mediaPlaybackRequiresUserGesture: false,
        useOnDownloadStart: true,
        // Disable the WebView's built-in (native) context/long-press menu so
        // only our custom Flutter selection menu is shown.
        disableContextMenu: true,
        disableLongPressContextMenuOnLinks: true,
      ),
      onWebViewCreated: (c) => widget.vm.onWebViewCreated(widget.tabId, c),
      onLoadStart: (c, url) => widget.vm.onLoadStart(widget.tabId, url),
      onLoadStop: (c, url) => widget.vm.onLoadStop(widget.tabId, url),
      onProgressChanged: (c, p) => widget.vm.onProgressChanged(widget.tabId, p),
      onTitleChanged: (c, title) =>
          widget.vm.onTitleChanged(widget.tabId, title),
      onScrollChanged: (c, x, y) => widget.vm.onScrollChanged(widget.tabId, y),
      onUpdateVisitedHistory: (c, url, reload) =>
          widget.vm.onUpdateVisitedHistory(widget.tabId, url, reload),
      onDownloadStartRequest: (c, request) {
        final url = request.url.toString();
        ProviderScope.containerOf(context)
            .read(manageDownloadsUsecaseProvider)
            .enqueue(url);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloading $url')),
        );
      },
    );
  }
}
