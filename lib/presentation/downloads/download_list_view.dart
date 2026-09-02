import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/extensions.dart';
import '../../data/models/download_item.dart';
import 'download_list_viewmodel.dart';

/// Download manager screen (§7.16): progress, pause/resume/cancel/retry,
/// and "Clear completed".
class DownloadListView extends ConsumerWidget {
  const DownloadListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(downloadListViewModelProvider);
    final hasCompleted =
        vm.items.any((i) => i.status == DownloadStatus.done);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Downloads'),
        actions: [
          if (hasCompleted)
            TextButton(
              onPressed: () =>
                  ref.read(downloadListViewModelProvider.notifier).clearCompleted(),
              child: const Text('Clear completed'),
            ),
        ],
      ),
      body: vm.items.isEmpty
          ? const Center(child: Text('No downloads'))
          : const RepaintBoundary(
              child: _DownloadListView(),
            ),
    );
  }
}

class _DownloadListView extends ConsumerWidget {
  const _DownloadListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(downloadListViewModelProvider);
    return ListView.separated(
      itemCount: vm.items.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) => _DownloadTile(item: vm.items[i]),
    );
  }
}

class _DownloadTile extends ConsumerWidget {
  const _DownloadTile({required this.item});
  final DownloadItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(downloadListViewModelProvider.notifier);
    final pct = (item.progress * 100).round();

    return ListTile(
      leading: _statusIcon(item.status),
      title: Text(item.fileName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          if (item.status == DownloadStatus.downloading ||
              item.status == DownloadStatus.paused)
            LinearProgressIndicator(
              value: item.progress > 0 ? item.progress : null,
            ),
          const SizedBox(height: 4),
          Text(
            _statusLabel(item, pct),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      trailing: _actions(context, item, notifier),
    );
  }

  Widget _statusIcon(DownloadStatus status) {
    return switch (status) {
      DownloadStatus.downloading => const Icon(Icons.downloading),
      DownloadStatus.paused => const Icon(Icons.pause_circle_outline),
      DownloadStatus.done => const Icon(Icons.check_circle_outline),
      DownloadStatus.failed => const Icon(Icons.error_outline, color: Colors.red),
    };
  }

  Widget _actions(
    BuildContext context,
    DownloadItem item,
    DownloadListViewModel notifier,
  ) {
    switch (item.status) {
      case DownloadStatus.downloading:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.pause),
              onPressed: () => notifier.pause(item),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => notifier.cancel(item.id),
            ),
          ],
        );
      case DownloadStatus.paused:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () => notifier.resume(item),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => notifier.cancel(item.id),
            ),
          ],
        );
      case DownloadStatus.done:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: () async {
                final path = await notifier.filePathOf(item.id);
                if (context.mounted && path != null) {
                  context.showSnack('Saved to $path');
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => notifier.remove(item.id),
            ),
          ],
        );
      case DownloadStatus.failed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => notifier.retry(item),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => notifier.remove(item.id),
            ),
          ],
        );
    }
  }

  String _statusLabel(DownloadItem item, int pct) {
    return switch (item.status) {
      DownloadStatus.downloading => '$pct%',
      DownloadStatus.paused => 'Paused · $pct%',
      DownloadStatus.done => 'Completed',
      DownloadStatus.failed => 'Failed',
    };
  }
}
