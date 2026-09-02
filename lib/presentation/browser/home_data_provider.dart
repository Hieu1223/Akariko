import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/ui_prefs_notifier.dart';
import '../../data/models/bookmark.dart';
import '../../data/models/news_article.dart';
import '../../data/models/news_source.dart';
import '../../modules/browser_module.dart';
import '../../modules/news_module.dart';

/// The special URL that loads the in-app home page (bookmarks + news feed).
const String kHomeUrl = 'yomu://home';

const String _kHomeHtmlAssetKey = 'lib/asset/home.html';

/// Loads the home HTML template once at startup so every home navigation is a
/// cheap string substitution (no asset bundle round-trip per tab switch).
final homeHtmlTemplateProvider = Provider<String>((ref) {
  throw UnimplementedError(
    'homeHtmlTemplateProvider must be overridden in main()',
  );
});

/// The fully-assembled home page HTML with the current feed data injected.
/// Rebuilds whenever bookmarks, articles, sources, or the accent color change.
final homeHtmlProvider = Provider<String>((ref) {
  final template = ref.watch(homeHtmlTemplateProvider);
  final bookmarks = ref.watch(_homeBookmarksProvider);
  final articles = ref.watch(_homeArticlesProvider);
  final sources = ref.watch(_homeSourcesProvider);
  final accent = ref.watch(uiPrefsProvider).accentColor;

  return _inject(template, bookmarks, articles, sources, accent);
});

final _homeBookmarksProvider = StreamProvider<List<Bookmark>>((ref) {
  final module = ref.watch(browserModuleProvider);
  return module.watchBookmarks();
});

final _homeArticlesProvider = StreamProvider<List<NewsArticle>>((ref) {
  final news = ref.watch(manageNewsUsecaseProvider);
  return news.watchArticles();
});

final _homeSourcesProvider = StreamProvider<List<NewsSource>>((ref) {
  final news = ref.watch(manageNewsUsecaseProvider);
  return news.watchSources();
});

/// Replaces `{{FEED_DATA}}` and `{{ACCENT_HEX}}` in [template] with the
/// serialised feed JSON and the accent colour hex string.
String _inject(
  String template,
  AsyncValue<List<Bookmark>> bookmarks,
  AsyncValue<List<NewsArticle>> articles,
  AsyncValue<List<NewsSource>> sources,
  Color accent,
) {
  final sourceById = {
    for (final s in sources.valueOrNull ?? <NewsSource>[]) s.id: s.name,
  };

  final feedMap = <String, dynamic>{
    'bookmarks': (bookmarks.valueOrNull ?? <Bookmark>[])
        .take(8)
        .map((b) => {
              'url': b.url,
              'displayTitle': b.displayTitle,
            })
        .toList(),
    'articles': (articles.valueOrNull ?? <NewsArticle>[])
        .take(30)
        .map((a) => {
              'title': a.title,
              'link': a.link,
              'summary': a.summary,
              'publishedAt': a.publishedAt?.toIso8601String(),
              'isRead': a.isRead,
              'sourceName': sourceById[a.sourceId] ?? '',
            })
        .toList(),
  };

  final html = template.replaceAll('{{FEED_DATA}}', jsonEncode(feedMap));
  final hex = accent.toARGB32().toRadixString(16).padLeft(8, '0').substring(2);
  return html.replaceAll('{{ACCENT_HEX}}', hex);
}

/// Loads the home HTML template from the asset bundle. Call once at startup
/// and override [homeHtmlTemplateProvider] with the result.
Future<String> loadHomeHtmlTemplate() async {
  return rootBundle.loadString(_kHomeHtmlAssetKey);
}
