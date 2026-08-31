import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/ui_prefs_notifier.dart';
import '../../core/constants/routes.dart';
import '../../modules/download_module.dart';
import '../common_widgets/bottom_toolbar.dart';
import '../common_widgets/popup_dictionary_card.dart';
import '../common_widgets/safari_address_bar.dart';
import 'browser_viewmodel.dart';
import 'browser_nav_state.dart';
import 'new_tab_view.dart';

/// Main browser shell: address bar + (WebView | Home) + bottom toolbar.
class BrowserView extends ConsumerWidget {
  const BrowserView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(browserViewModelProvider);
    final vmNotifier = ref.read(browserViewModelProvider.notifier);
    final prefs = ref.watch(uiPrefsProvider);
    final active = vm.activeTab;
    final showHome = active == null || active.url == 'about:home';

    // The address bar depends on the volatile nav state (loading / progress /
    // bookmark), so it is a Consumer: a progress tick rebuilds only this widget,
    // not the WebView tree above.
    final addressBar = Consumer(
      builder: (ctx, ref, _) {
        final nav = ref.watch(browserNavProvider);
        return SafariAddressBar(
          controller: vmNotifier.addressController,
          isLoading: nav.isLoading,
          progress: nav.progress.toDouble(),
          onSubmitted: (q) => vmNotifier.navigateTo(q),
          trailing: IconButton(
            icon: Icon(
              (!showHome && nav.isBookmarked)
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              size: 18,
            ),
            onPressed: () {
              if (active != null && !showHome) {
                vmNotifier.onToggleBookmark();
              }
            },
          ),
        );
      },
    );

    // Scroll-linked collapse. The bar slides/fades with the page scroll via
    // [BrowserViewModel.chromeOffset] (a ValueNotifier, so only the bar
    // rebuilds — not the whole WebView tree).
    final chrome = _ChromeBar(
      notifier: vmNotifier,
      addressBar: addressBar,
    );

    // One WebView per cached tab, kept mounted (but hidden) so switching is
    // instant. Only the active one is visible; the rest retain their page state
    // off-screen until they age out of the cache.
    final webViews = vm.cachedTabIds.map((id) {
      final tab = vm.tabs.where((t) => t.id == id).firstOrNull;
      if (tab == null) return const SizedBox.shrink();
      final isActive = id == vm.activeTabId;
      return Offstage(
        offstage: !isActive,
        child: _TabWebView(
          key: ValueKey(id),
          tabId: id,
          initialUrl: tab.url,
          vm: vmNotifier,
          onDownload: (url) {
            ref.read(manageDownloadsUsecaseProvider).enqueue(url);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Downloading $url')),
            );
          },
        ),
      );
    }).toList();

    final content = SizedBox.expand(
      child: GestureDetector(
        // Tapping the page area releases the keyboard / address-bar focus.
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            ...webViews,
            if (showHome)
              const Positioned.fill(child: NewTabView())
            else
              const Positioned.fill(child: PopupDictionaryOverlay()),
          ],
        ),
      ),
    );

    final scaffold = Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            if (!showHome && prefs.addressBarPosition == AddressBarPosition.top)
              chrome,
            Expanded(child: content),
            if (!showHome &&
                prefs.addressBarPosition == AddressBarPosition.bottom)
              chrome,
              // Back/forward availability is volatile nav state; keep it in a
              // Consumer so only the toolbar rebuilds on a history change.
              Consumer(
                builder: (ctx, ref, _) {
                  final nav = ref.watch(browserNavProvider);
                  return BottomToolbar(
                    tabCount: vm.tabs.length,
                    canGoBack: nav.canGoBack,
                    canGoForward: nav.canGoForward,
                    onBack: vmNotifier.hasActiveController
                        ? () => vmNotifier.goBack()
                        : () {},
                    onForward: vmNotifier.hasActiveController
                        ? () => vmNotifier.goForward()
                        : () {},
                    onNewTab: () => vmNotifier.openNewTab(),
                    onTabs: () {
                      context.pushNamed(Routes.tabSwitcher);
                    },
                    onMenu: () => _openMenu(context, ref),
                  );
                },
              ),
          ],
        ),
      ),
    );

    // Intercept the OS back gesture / button on phones so it navigates the
    // WebView back in history before exiting the app.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (vmNotifier.hasActiveController &&
            await vmNotifier.controller!.canGoBack()) {
          await vmNotifier.goBack();
        }
      },
      child: scaffold,
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
    required this.onDownload,
  });

  final String tabId;
  final String initialUrl;
  final BrowserViewModel vm;
  final void Function(String) onDownload;

  @override
  State<_TabWebView> createState() => _TabWebViewState();
}

class _TabWebViewState extends State<_TabWebView> {
  InAppWebViewController? _c;

  @override
  void dispose() {
    widget.vm.unregisterController(widget.tabId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final askAiItem = ContextMenuItem(id: 1, title: 'Ask AI');
    final contextMenu = ContextMenu(
      menuItems: [askAiItem],
      onContextMenuActionItemClicked: (item) async {
        if (item.id != 1 || _c == null) return;
        final text = await _c!.evaluateJavascript(
          source: "window.getSelection().toString()",
        );
        final selected = (text?.toString() ?? '').trim();
        if (selected.isNotEmpty) widget.vm.askAi(selected);
      },
    );

    return InAppWebView(
      key: widget.key,
      initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        mediaPlaybackRequiresUserGesture: false,
        useOnDownloadStart: true,
      ),
      contextMenu: contextMenu,
      onWebViewCreated: (c) {
        _c = c;
        widget.vm.onWebViewCreated(widget.tabId, c);
      },
      onLoadStart: (c, url) => widget.vm.onLoadStart(widget.tabId, url),
      onLoadStop: (c, url) => widget.vm.onLoadStop(widget.tabId, url),
      onProgressChanged: (c, p) => widget.vm.onProgressChanged(widget.tabId, p),
      onTitleChanged: (c, title) =>
          widget.vm.onTitleChanged(widget.tabId, title),
      onScrollChanged: (c, x, y) => widget.vm.onScrollChanged(widget.tabId, y),
      onUpdateVisitedHistory: (c, url, reload) =>
          widget.vm.onUpdateVisitedHistory(widget.tabId, url, reload),
      onDownloadStartRequest: (c, request) =>
          widget.onDownload(request.url.toString()),
    );
  }
}

/// Scroll-linked address bar. Listens to [BrowserViewModel.chromeOffset]
/// (0 = fully shown, 1 = fully collapsed) and slides/fades the bar so it tracks
/// the page scroll instead of snapping. Only this widget rebuilds on scroll.
/// The parent [Column] decides whether it sits at the top or bottom.
class _ChromeBar extends StatelessWidget {
  const _ChromeBar({
    required this.notifier,
    required this.addressBar,
  });

  final BrowserViewModel notifier;
  final Widget addressBar;

  /// Fixed bar height used for the collapse animation; the address bar fits
  /// comfortably within it, so clipping only trims during collapse.
  static const double _kBarHeight = 48;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: notifier.chromeOffset,
      builder: (ctx, t, _) {
        final visible = (1 - t).clamp(0.0, 1.0);
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            child: Opacity(
              opacity: visible,
              child: SizedBox(
                height: _kBarHeight * visible,
                child: Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: addressBar,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
