import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/routes.dart';
import '../../data/models/word_entry.dart';
import '../../modules/usecases/import_dictionary_usecase.dart';
import 'dictionary_import_viewmodel.dart';
import 'dictionary_viewmodel.dart';

/// Dictionary browse/search screen (§7.6).
///
/// Japanese input matches headwords and readings; latin input searches the
/// meanings through the FTS5 index. Tapping a row opens **Word Detail**.
class DictionaryView extends ConsumerStatefulWidget {
  const DictionaryView({super.key});

  @override
  ConsumerState<DictionaryView> createState() => _DictionaryViewState();
}

class _DictionaryViewState extends ConsumerState<DictionaryView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      ref.read(dictionaryViewModelProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(dictionaryViewModelProvider);
    final notifier = ref.read(dictionaryViewModelProvider.notifier);
    final importProgress = ref.watch(dictionaryImportProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Dictionary'),
        actions: [
          if (!vm.hasQuery && vm.recents.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear recent lookups',
              onPressed: notifier.clearRecents,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: TextField(
              controller: _controller,
              autofocus: false,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Word, reading or meaning',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: vm.query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _controller.clear();
                          notifier.clearQuery();
                        },
                      ),
              ),
              onChanged: notifier.setQuery,
            ),
          ),
          _ImportBanner(progress: importProgress),
          Expanded(child: _buildBody(context, vm)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, DictionaryState vm) {
    if (vm.hasQuery) {
      if (vm.isSearching && vm.results.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (vm.isEmptyResult) {
        return _EmptyMessage(
          icon: Icons.search_off,
          title: 'No matches for “${vm.query.trim()}”',
          subtitle: 'Try a shorter query, the reading in kana, '
              'or a word from the meaning.',
        );
      }
      return ListView.separated(
        controller: _scrollController,
        itemCount: vm.results.length + (vm.hasMore ? 1 : 0),
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index >= vm.results.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _WordEntryTile(entry: vm.results[index], onTap: _openEntry);
        },
      );
    }

    if (vm.recents.isEmpty) {
      return _EmptyMessage(
        icon: Icons.menu_book_outlined,
        title: 'Search the dictionary',
        subtitle: vm.entryCount > 0
            ? '${_formatCount(vm.entryCount)} entries available offline.'
            : 'The dictionary is being prepared…',
      );
    }

    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            'Recent lookups',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
          ),
        ),
        for (final entry in vm.recents) ...[
          _WordEntryTile(entry: entry, onTap: _openEntry),
          const Divider(height: 1),
        ],
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '${_formatCount(vm.entryCount)} entries available offline.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Future<void> _openEntry(WordEntry entry) async {
    await context.pushNamed(
      Routes.wordDetail,
      pathParameters: {'id': entry.id},
    );
    if (!mounted) return;
    // Opening an entry updates the recent-lookup list.
    await ref.read(dictionaryViewModelProvider.notifier).refreshRecents();
  }
}

String _formatCount(int count) {
  final digits = count.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// One search-result row: headword, reading, short gloss (§7.6).
class _WordEntryTile extends StatelessWidget {
  const _WordEntryTile({required this.entry, required this.onTap});

  final WordEntry entry;
  final void Function(WordEntry entry) onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Flexible(
            child: Text(
              entry.headword,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (entry.hasReading) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                entry.reading,
                style: textTheme.bodySmall?.copyWith(color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
      subtitle: entry.shortGloss.isEmpty
          ? null
          : Text(
              entry.shortGloss,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () => onTap(entry),
    );
  }
}

/// Progress strip for the one-time dataset import (~190k entries).
class _ImportBanner extends ConsumerWidget {
  const _ImportBanner({required this.progress});

  final DictionaryImportProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (progress.stage == DictionaryImportStage.idle ||
        progress.stage == DictionaryImportStage.done) {
      return const SizedBox.shrink();
    }

    if (progress.stage == DictionaryImportStage.failed) {
      return Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.errorContainer,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Dictionary import failed: ${progress.error ?? 'unknown error'}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
            TextButton(
              onPressed: ref.read(dictionaryImportProvider.notifier).reimport,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final label = switch (progress.stage) {
      DictionaryImportStage.preparing => 'Preparing dictionary…',
      DictionaryImportStage.indexing => 'Building search index…',
      _ => progress.total > 0
          ? 'Importing dictionary — '
              '${_formatCount(progress.imported)} / ${_formatCount(progress.total)}'
          : 'Importing dictionary…',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: progress.fraction),
        ],
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
