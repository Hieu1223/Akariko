import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/ui_prefs_notifier.dart';
import '../../data/models/tab_model.dart';
import '../common_widgets/favicon.dart';
import 'browser_viewmodel.dart';
import 'tab_switcher_viewmodel.dart';

/// Modal list of open tabs, matching the Safari tab switcher but laid out as
/// plain rows (no screenshot previews).
class TabSwitcherView extends ConsumerWidget {
  const TabSwitcherView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(tabSwitcherViewModelProvider);
    final activeTabId = ref.watch(browserViewModelProvider).activeTabId;
    final swipeToClose = ref.watch(uiPrefsProvider).tabSwipeToClose;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabs'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'close_all') {
                final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Close all tabs?'),
                        content: const Text(
                            'This closes every open tab except a new blank one.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Close all'),
                          ),
                        ],
                      ),
                    ) ??
                    false;
                if (ok) {
                  await ref
                      .read(tabSwitcherViewModelProvider.notifier)
                      .closeAll();
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'close_all', child: Text('Close All')),
            ],
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: vm.tabs.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final tab = vm.tabs[i];
          final isActive = tab.id == activeTabId;
          final row = _TabRow(
            tab: tab,
            isActive: isActive,
            onTap: () async {
              await ref.read(browserViewModelProvider.notifier).switchTo(tab.id);
              if (context.mounted) context.pop();
            },
            onClose: () =>
                ref.read(tabSwitcherViewModelProvider.notifier).closeTab(tab.id),
          );

          if (!swipeToClose) return row;

          return Dismissible(
            key: Key(tab.id),
            direction: DismissDirection.horizontal,
            onDismissed: (_) => ref
                .read(tabSwitcherViewModelProvider.notifier)
                .closeTab(tab.id),
            background: Container(
              color: Colors.red.shade400,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 24),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red.shade400,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: row,
          );
        },
      ),
    );
  }
}

/// A single tab row: favicon, title (active highlighted), url and a close button.
class _TabRow extends StatelessWidget {
  const _TabRow({
    required this.tab,
    required this.isActive,
    required this.onTap,
    required this.onClose,
  });

  final TabModel tab;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isActive ? colors.secondaryContainer.withValues(alpha: 0.4) : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Favicon(url: tab.faviconUrl, fallback: Icons.language),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tab.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tab.url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: colors.outline),
                  ),
                ],
              ),
            ),
            if (isActive)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.check_circle, size: 16),
              ),
            InkWell(
              onTap: onClose,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.close, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
