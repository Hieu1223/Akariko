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
import 'new_tab_view.dart';

/// Main browser shell: address bar + (WebView | New Tab) + bottom toolbar.
class BrowserView extends ConsumerWidget {
  const BrowserView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(browserViewModelProvider);
    final vmNotifier = ref.read(browserViewModelProvider.notifier);
    final prefs = ref.watch(uiPrefsProvider);
    final active = vm.activeTab;
    final showHome = active == null || active.url == 'about:home';

    final addressBar = SafariAddressBar(
      controller: vmNotifier.addressController,
      isLoading: vm.isLoading,
      progress: vm.progress.toDouble(),
      onSubmitted: (q) => vmNotifier.navigateTo(q),
      trailing: IconButton(
        icon: Icon(
          (!showHome && vmNotifier.isActiveBookmarked)
              ? Icons.bookmark
              : Icons.bookmark_border,
          size: 20,
        ),
        onPressed: () {
          if (active != null && !showHome) {
            vmNotifier.onToggleBookmark();
          }
        },
      ),
    );

    final content = Stack(
      children: [
        if (showHome)
          const NewTabView()
        else
          Positioned.fill(
            child: _WebViewArea(
              key: ValueKey(active.id),
              vm: vmNotifier,
              onDownload: (url) {
                ref.read(manageDownloadsUsecaseProvider).enqueue(url);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Downloading $url')),
                );
              },
            ),
          ),
        if (!showHome) const PopupDictionaryOverlay(),
      ],
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            if (prefs.addressBarPosition == AddressBarPosition.top)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: addressBar,
              ),
            Expanded(child: content),
            if (prefs.addressBarPosition == AddressBarPosition.bottom)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: addressBar,
              ),
            BottomToolbar(
              tabCount: vm.tabs.length,
              canGoBack: vm.canGoBack,
              canGoForward: vm.canGoForward,
              onBack: vmNotifier.controller != null
                  ? () => vmNotifier.goBack()
                  : () {},
              onForward: vmNotifier.controller != null
                  ? () => vmNotifier.goForward()
                  : () {},
              onShare: () {
                final url = active?.url;
                if (url != null && url != 'about:home') {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Share: $url')));
                }
              },
              onTabs: () => context.pushNamed(Routes.tabSwitcher),
              onMenu: () => _openMenu(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _openMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('New Tab'),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(browserViewModelProvider.notifier).openNewTab();
              },
            ),
            ListTile(
              leading: const Icon(Icons.square_outlined),
              title: const Text('Tab Switcher'),
              onTap: () {
                Navigator.pop(ctx);
                context.pushNamed(Routes.tabSwitcher);
              },
            ),
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
          ],
        ),
      ),
    );
  }
}

class _WebViewArea extends StatelessWidget {
  const _WebViewArea({
    super.key,
    required this.vm,
    required this.onDownload,
  });
  final BrowserViewModel vm;
  final void Function(String) onDownload;

  @override
  Widget build(BuildContext context) {
    final active = vm.activeTab!;

    // Long-press selection → native "Ask AI" item (§7.5). The item action
    // receives no arguments in this flutter_inappwebview version, so we read
    // the live selection via JS when the item is tapped.
    final askAiItem = ContextMenuItem(id: 1, title: 'Ask AI');
    final contextMenu = ContextMenu(
      menuItems: [askAiItem],
      onContextMenuActionItemClicked: (item) async {
        if (item.id != 1 || vm.controller == null) return;
        final text = await vm.controller!.evaluateJavascript(
          source: "window.getSelection().toString()",
        );
        final selected = (text?.toString() ?? '').trim();
        if (selected.isNotEmpty) vm.askAi(selected);
      },
    );

    return InAppWebView(
      key: key,
      initialUrlRequest: URLRequest(url: WebUri(active.url)),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
        useOnDownloadStart: true,
      ),
      contextMenu: contextMenu,
      onWebViewCreated: (c) => vm.onWebViewCreated(c),
      onLoadStart: (c, url) => vm.onLoadStart(url),
      onLoadStop: (c, url) => vm.onLoadStop(url),
      onProgressChanged: (c, p) => vm.onProgressChanged(p),
      onTitleChanged: (c, title) => vm.onTitleChanged(title),
      onUpdateVisitedHistory: (c, url, reload) =>
          vm.onUpdateVisitedHistory(url, reload),
      onDownloadStartRequest: (c, request) =>
          onDownload(request.url.toString()),
    );
  }
}
