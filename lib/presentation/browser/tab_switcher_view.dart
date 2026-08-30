import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../common_widgets/tab_grid_card.dart';
import 'browser_viewmodel.dart';
import 'tab_switcher_viewmodel.dart';

/// Modal grid of open tabs, matching the Safari tab switcher.
class TabSwitcherView extends ConsumerWidget {
  const TabSwitcherView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(tabSwitcherViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await ref.read(tabSwitcherViewModelProvider.notifier).openNewTab();
              if (context.mounted) context.pop();
            },
          ),
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
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: vm.tabs.length,
        itemBuilder: (context, i) {
          final tab = vm.tabs[i];
          return TabGridCard(
            tab: tab,
            onTap: () async {
              await ref.read(browserViewModelProvider.notifier).switchTo(tab.id);
              if (context.mounted) context.pop();
            },
            onClose: () =>
                ref.read(tabSwitcherViewModelProvider.notifier).closeTab(tab.id),
          );
        },
      ),
    );
  }
}
