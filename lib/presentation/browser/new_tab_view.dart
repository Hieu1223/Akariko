import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/ui_prefs_notifier.dart';
import '../../data/models/bookmark.dart';
import 'browser_viewmodel.dart';
import 'new_tab_viewmodel.dart';

/// Home / New Tab screen: quick-access bookmarks.
///
/// Rendered inside the Browser shell (filling the content area) when the active
/// tab url is `about:home`. The address bar is the shared top-bar chrome from
/// `BrowserView`, so the home search bar is identical in size and behaviour to
/// the normal URL bar.
class NewTabView extends ConsumerStatefulWidget {
  const NewTabView({super.key});

  @override
  ConsumerState<NewTabView> createState() => _NewTabViewState();
}

class _NewTabViewState extends ConsumerState<NewTabView> {
  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(newTabViewModelProvider);
    final prefs = ref.watch(uiPrefsProvider);

    return Scaffold(
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
