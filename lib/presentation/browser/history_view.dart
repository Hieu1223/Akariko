import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/history_entry.dart';
import 'history_viewmodel.dart';

/// Browsing-history screen (§7.19), grouped by day with search + clear.
class HistoryView extends ConsumerWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(historyViewModelProvider);
    final groups = _groupByDay(vm.filtered);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('History'),
        actions: [
          if (vm.entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear all',
              onPressed: () async {
                final ok = await _confirm(context, 'Clear all history?');
                if (ok) {
                  await ref.read(historyViewModelProvider.notifier).clearAll();
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search history',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged:
                  ref.read(historyViewModelProvider.notifier).setQuery,
            ),
          ),
          Expanded(
            child: groups.isEmpty
                ? const Center(child: Text('No history'))
                : const RepaintBoundary(
                    child: _HistoryListView(),
                  ),
          ),
        ],
      ),
    );
  }

  static Future<bool> _confirm(BuildContext context, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static List<_DayGroup> _groupByDay(List<HistoryEntry> entries) {
    final map = <String, List<HistoryEntry>>{};
    for (final e in entries) {
      final key = _dayKey(e.visitedAt);
      map.putIfAbsent(key, () => []).add(e);
    }
    final sortedKeys = map.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    return sortedKeys
        .map((k) => _DayGroup(label: _dayLabel(k), entries: map[k]!))
        .toList();
  }

  static String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _dayLabel(String key) {
    final now = DateTime.now();
    final today = _dayKey(now);
    final yesterday = _dayKey(now.subtract(const Duration(days: 1)));
    if (key == today) return 'Today';
    if (key == yesterday) return 'Yesterday';
    return key;
  }
}

class _HistoryListView extends ConsumerWidget {
  const _HistoryListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(historyViewModelProvider);
    final groups = HistoryView._groupByDay(vm.filtered);
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, i) {
        final group = groups[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                group.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            ...group.entries.map(
              (e) => _HistoryTile(entry: e),
            ),
          ],
        );
      },
    );
  }
}

class _DayGroup {
  const _DayGroup({required this.label, required this.entries});
  final String label;
  final List<HistoryEntry> entries;
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({required this.entry});
  final HistoryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) =>
          ref.read(historyViewModelProvider.notifier).remove(entry.id),
      child: ListTile(
        leading: const Icon(Icons.history),
        title: Text(entry.displayTitle),
        subtitle: Text(
          entry.url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          ref.read(historyViewModelProvider.notifier).open(entry.url);
          if (context.mounted) context.pop();
        },
      ),
    );
  }
}
