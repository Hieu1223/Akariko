import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'news_source_manage_viewmodel.dart';

/// News Source Management screen (§7.17).
class NewsSourceManageView extends ConsumerStatefulWidget {
  const NewsSourceManageView({super.key});

  @override
  ConsumerState<NewsSourceManageView> createState() =>
      _NewsSourceManageViewState();
}

class _NewsSourceManageViewState extends ConsumerState<NewsSourceManageView> {
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(newsSourceManageViewModelProvider);
    final isRefreshing = vm.isRefreshing;

    // Surface a transient error (bad add/refresh) without blocking the list.
    ref.listen(newsSourceManageViewModelProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('News Sources'),
        actions: [
          IconButton(
            icon: isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Refresh all',
            onPressed: isRefreshing
                ? null
                : () => ref
                    .read(newsSourceManageViewModelProvider.notifier)
                    .refreshAll(),
          ),
        ],
      ),
      body: vm.sources.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.rss_feed, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    'No sources yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  const Text('Tap + to add an RSS/Atom feed.'),
                ],
              ),
            )
          : ListView.separated(
              itemCount: vm.sources.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final source = vm.sources[i];
                return Dismissible(
                  key: Key(source.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Remove source?'),
                        content: Text(
                          'Delete "${source.name}" and its articles?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    return ok ?? false;
                  },
                  onDismissed: (_) => ref
                      .read(newsSourceManageViewModelProvider.notifier)
                      .deleteSource(source.id),
                  child: ListTile(
                    leading: const Icon(Icons.rss_feed),
                    title: Text(source.name),
                    subtitle: Text(
                      source.feedUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add source',
        child: const Icon(Icons.add),
        onPressed: () => _showAddDialog(context),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    _nameController.clear();
    _urlController.clear();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add news source'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. NHK News',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Feed URL',
                  hintText: 'https://example.com/feed',
                ),
                keyboardType: TextInputType.url,
                validator: (v) {
                  final url = (v ?? '').trim();
                  if (url.isEmpty) return 'Enter a feed URL';
                  final uri = Uri.tryParse(url);
                  if (uri == null ||
                      (uri.scheme != 'http' && uri.scheme != 'https')) {
                    return 'Enter a valid http(s) URL';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                Navigator.pop(ctx, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != true) return;
    final name = _nameController.text;
    final url = _urlController.text.trim();
    // The view-model surfaces validation/network failures via `state.error`,
    // which the `ref.listen` above renders as a snackbar — so this method
    // never touches `context` across the await.
    await ref
        .read(newsSourceManageViewModelProvider.notifier)
        .addSource(name, url);
  }
}
