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

    // Static address bar — no scroll-based collapse. Full-width, like a normal
    // browser URL bar, with a configurable height.
    final chrome = SizedBox(
      height: prefs.topBarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Center(child: addressBar),
      ),
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
      child: Stack(
        children: [
          ...webViews,
          if (showHome)
            const Positioned.fill(child: NewTabView())
          else
            const Positioned.fill(child: PopupDictionaryOverlay()),
        ],
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
                    tabCount: vm.tabs.length,
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
      onDownloadStartRequest: (c, request) =>
          widget.onDownload(request.url.toString()),
    );
  }
}
