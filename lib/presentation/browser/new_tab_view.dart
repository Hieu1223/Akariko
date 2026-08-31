import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/ui_prefs_notifier.dart';
import '../../core/constants/routes.dart';
import '../../data/models/bookmark.dart';
import '../common_widgets/safari_address_bar.dart';
import 'browser_viewmodel.dart';
import 'new_tab_viewmodel.dart';

/// Home / New Tab screen: search bar + quick-access bookmarks.
///
/// Rendered inside the Browser shell when the active tab url is `about:home`.
/// Provides its own top bar (address bar + tabs/menu) so the home screen is
/// consistent with the rest of the browser chrome.
class NewTabView extends ConsumerStatefulWidget {
  const NewTabView({super.key});

  @override
  ConsumerState<NewTabView> createState() => _NewTabViewState();
}

class _NewTabViewState extends ConsumerState<NewTabView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(newTabViewModelProvider);
    final prefs = ref.watch(uiPrefsProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: SafariAddressBar(
          controller: _controller,
          onSubmitted: (q) {
            if (q.trim().isNotEmpty) {
              ref.read(newTabViewModelProvider.notifier).submit(q);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.layers_outlined),
            tooltip: 'Tabs',
            onPressed: () => context.pushNamed(Routes.tabSwitcher),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'bookmarks':
                  context.pushNamed(Routes.bookmarks);
                case 'history':
                  context.pushNamed(Routes.history);
                case 'dictionary':
                  context.pushNamed(Routes.dictionary);
                case 'downloads':
                  context.pushNamed(Routes.downloads);
                case 'settings':
                  context.pushNamed(Routes.settings);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'bookmarks', child: Text('Bookmarks')),
              PopupMenuItem(value: 'history', child: Text('History')),
              PopupMenuItem(value: 'dictionary', child: Text('Dictionary')),
              PopupMenuItem(value: 'downloads', child: Text('Downloads')),
              PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            const SizedBox(height: 8),
            Icon(Icons.menu_book_rounded,
                size: 56, color: prefs.accentColor),
            const SizedBox(height: 16),
            Text(
              'Yomu',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (vm.bookmarks.isNotEmpty) ...[
              Text('Quick access',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: vm.bookmarks
                    .take(8)
                    .map((b) => _QuickAccessTile(bookmark: b))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickAccessTile extends ConsumerWidget {
  const _QuickAccessTile({required this.bookmark});
  final Bookmark bookmark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () =>
          ref.read(browserViewModelProvider.notifier).navigateTo(bookmark.url),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 72,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            const Icon(Icons.language, size: 22),
            const SizedBox(height: 6),
            Text(
              bookmark.displayTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
