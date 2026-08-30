import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/bookmark.dart';
import 'bookmarks_viewmodel.dart';

/// Bookmarks browser screen (§7.19).
class BookmarksView extends ConsumerWidget {
  const BookmarksView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(bookmarksViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Bookmarks'),
      ),
      body: vm.bookmarks.isEmpty
          ? const Center(child: Text('No bookmarks yet'))
          : ListView.separated(
              itemCount: vm.bookmarks.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final b = vm.bookmarks[i];
                return _BookmarkTile(bookmark: b);
              },
            ),
    );
  }
}

class _BookmarkTile extends ConsumerWidget {
  const _BookmarkTile({required this.bookmark});
  final Bookmark bookmark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(bookmark.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) =>
          ref.read(bookmarksViewModelProvider.notifier).remove(bookmark.url),
      child: ListTile(
        leading: const Icon(Icons.bookmark_outline),
        title: Text(bookmark.displayTitle),
        subtitle: Text(
          bookmark.url,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          ref.read(bookmarksViewModelProvider.notifier).open(bookmark.url);
          if (context.mounted) context.pop();
        },
      ),
    );
  }
}
