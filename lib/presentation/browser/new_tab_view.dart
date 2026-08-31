import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/theme/ui_prefs_notifier.dart';
import '../../core/constants/routes.dart';
import '../../data/models/bookmark.dart';
import '../../data/models/news_article.dart';
import '../browser/browser_viewmodel.dart';
import 'new_tab_viewmodel.dart';

/// Home / New Tab screen: quick-access bookmarks + the news feed (§7.3).
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
        child: RefreshIndicator(
          onRefresh: () => ref.read(newTabViewModelProvider.notifier).refreshNews(),
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
                const SizedBox(height: 28),
              ],
              _NewsFeedSection(
                articles: vm.articles,
                isRefreshing: vm.isRefreshing,
                sourceNameOf: (id) =>
                    ref.read(newTabViewModelProvider.notifier).sourceNameOf(id),
                onOpen: (link) =>
                    ref.read(newTabViewModelProvider.notifier).openArticle(link),
              ),
            ],
          ),
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

class _NewsFeedSection extends StatelessWidget {
  const _NewsFeedSection({
    required this.articles,
    required this.isRefreshing,
    required this.sourceNameOf,
    required this.onOpen,
  });

  final List<NewsArticle> articles;
  final bool isRefreshing;
  final String Function(String) sourceNameOf;
  final void Function(String) onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('News',
                style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            if (isRefreshing)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            TextButton(
              onPressed: () => context.pushNamed(Routes.newsSources),
              child: const Text('Manage sources'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (articles.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: Text('No articles yet')),
          )
        else
          ...articles.take(30).map((a) => _NewsRow(
                article: a,
                sourceName: sourceNameOf(a.sourceId),
                onOpen: () => onOpen(a.link),
              )),
      ],
    );
  }
}

class _NewsRow extends StatelessWidget {
  const _NewsRow({
    required this.article,
    required this.sourceName,
    required this.onOpen,
  });

  final NewsArticle article;
  final String sourceName;
  final VoidCallback onOpen;

  static final DateFormat _day = DateFormat('MMM d');
  static final DateFormat _dayTime = DateFormat('MMM d HH:mm');

  @override
  Widget build(BuildContext context) {
    final published = article.publishedAt;
    final when = published == null
        ? ''
        : (published.day == DateTime.now().day
            ? _dayTime.format(published)
            : _day.format(published));

    return InkWell(
      onTap: onOpen,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: article.isRead
                        ? FontWeight.normal
                        : FontWeight.w600,
                  ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (article.summary.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                article.summary,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey.shade600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    sourceName,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (when.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    when,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: Colors.grey.shade500),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
