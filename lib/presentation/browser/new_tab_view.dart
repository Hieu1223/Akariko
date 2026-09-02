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
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  int _currentPage = 1;
  static const int _pageSize = 30;
  
  // Filter state
  String? _selectedSourceFilter;
  bool _showUnreadOnly = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(newTabViewModelProvider);
    final prefs = ref.watch(uiPrefsProvider);
    
    // Apply filters
    var filteredArticles = vm.articles;
    if (_selectedSourceFilter != null) {
      filteredArticles = filteredArticles
          .where((a) => a.sourceId == _selectedSourceFilter)
          .toList();
    }
    if (_showUnreadOnly) {
      filteredArticles = filteredArticles
          .where((a) => !a.isRead)
          .toList();
    }

    return Scaffold(
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (!_isLoadingMore && 
                notification is ScrollEndNotification &&
                notification.metrics.pixels >= 
                    notification.metrics.maxScrollExtent - 200) {
              // Load more articles (endless scroll)
              _loadMoreArticles();
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: () => ref.read(newTabViewModelProvider.notifier).refreshNews(),
            child: ListView(
              controller: _scrollController,
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
                // Filter controls
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedSourceFilter,
                        hint: const Text('All sources'),
                        isExpanded: true,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All sources')),
                          ...vm.sources.map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.name),
                          )),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedSourceFilter = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(_showUnreadOnly ? Icons.visibility : Icons.visibility_off),
                      tooltip: _showUnreadOnly ? 'Show all' : 'Show unread only',
                      onPressed: () {
                        setState(() => _showUnreadOnly = !_showUnreadOnly);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                  articles: filteredArticles.take(_currentPage * _pageSize).toList(),
                  isRefreshing: vm.isRefreshing,
                  isLoadingMore: _isLoadingMore,
                  sourceNameOf: (id) =>
                      ref.read(newTabViewModelProvider.notifier).sourceNameOf(id),
                  onOpen: (link) =>
                      ref.read(newTabViewModelProvider.notifier).openArticle(link),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _loadMoreArticles() {
    setState(() => _isLoadingMore = true);
    // Simulate loading delay, in real app this would fetch more from API
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _currentPage++;
          _isLoadingMore = false;
        });
      }
    });
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
    this.isLoadingMore = false,
    required this.sourceNameOf,
    required this.onOpen,
  });

  final List<NewsArticle> articles;
  final bool isRefreshing;
  final bool isLoadingMore;
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
        else ...[
          ...articles.map((a) => _NewsRow(
                article: a,
                sourceName: sourceNameOf(a.sourceId),
                onOpen: () => onOpen(a.link),
              )),
          if (isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
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
