import '../../data/datasources/remote/news_rss_datasource.dart';
import '../../data/models/news_article.dart';
import '../../data/models/news_source.dart';
import '../../data/repositories/news_repository.dart';

/// Orchestrates feed polling/refresh over [NewsRssDataSource] + [NewsRepository]
/// (§7.3, §7.17). The repository is the source of truth — fetched articles are
/// upserted (stable id per `sourceId|link`), so refreshes never duplicate and a
/// read-state survives.
class ManageNewsUsecase {
  ManageNewsUsecase(this._repository, this._rss);
  final NewsRepository _repository;
  final NewsRssDataSource _rss;

  Stream<List<NewsSource>> watchSources() => _repository.watchSources();
  Stream<List<NewsArticle>> watchArticles() => _repository.watchArticles();

  /// Refreshes every source. Individual source failures are swallowed so one
  /// dead feed doesn't abort the others (or surface as an error to the user).
  Future<void> refreshAll() async {
    final sources = await _repository.getSources();
    for (final source in sources) {
      await refreshSource(source);
    }
  }

  /// Fetches a single source's feed and upserts its articles.
  Future<void> refreshSource(NewsSource source) async {
    final items = await _rss.fetch(source.feedUrl);
    final articles = items
        .map(
          (i) => NewsArticle(
            id: _articleId(source.id, i.link),
            sourceId: source.id,
            title: i.title,
            link: i.link,
            publishedAt: i.publishedAt,
            summary: i.summary,
          ),
        )
        .toList();
    await _repository.upsertArticles(articles);
  }

  /// Validates [feedUrl] by fetching it (throws on invalid/unreachable), then
  /// inserts the source and seeds its articles from the first fetch.
  Future<NewsSource> addSource({
    required String name,
    required String feedUrl,
  }) async {
    final items = await _rss.fetch(feedUrl); // throws if the feed is bad
    final id = _sourceId(feedUrl);
    final source = NewsSource(
      id: id,
      name: name.trim().isEmpty ? feedUrl : name.trim(),
      feedUrl: feedUrl.trim(),
      addedAt: DateTime.now(),
    );
    await _repository.insertSource(source);
    final articles = items
        .map(
          (i) => NewsArticle(
            id: _articleId(id, i.link),
            sourceId: id,
            title: i.title,
            link: i.link,
            publishedAt: i.publishedAt,
            summary: i.summary,
          ),
        )
        .toList();
    await _repository.upsertArticles(articles);
    return source;
  }

  Future<void> deleteSource(String id) => _repository.deleteSource(id);

  Future<void> markRead(String id) => _repository.markRead(id);

  /// Stable article id: hash of `sourceId|link`, namespaced by source so two
  /// sources linking to the same URL stay distinct.
  static String _articleId(String sourceId, String link) =>
      '$sourceId-${(sourceId + link).hashCode.abs().toRadixString(16)}';

  /// Stable source id derived from its feed URL.
  static String _sourceId(String feedUrl) =>
      'src-${feedUrl.trim().hashCode.abs().toRadixString(16)}';
}
