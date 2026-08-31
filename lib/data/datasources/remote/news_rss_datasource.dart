import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:webfeed_revised/webfeed_revised.dart';

/// One parsed entry from a feed, normalised across RSS 2.0 and Atom so the
/// rest of the app never has to care which format a source speaks.
class FeedItem {
  const FeedItem({
    required this.title,
    required this.link,
    this.publishedAt,
    this.summary = '',
  });

  final String title;
  final String link;
  final DateTime? publishedAt;
  final String summary;
}

/// Fetches and parses RSS 2.0 / Atom feeds over HTTP (§7.17, "RSS fetch service").
///
/// Design notes:
/// * a single [http.Client] is reused for the session (TLS handshake paid once);
/// * a generous-but-bounded timeout keeps a slow/dead source from pinning the
///   refresh UI;
/// * malformed or unsupported payloads throw — the use-case swallows them and
///   keeps the previously cached articles, so a broken source is never a
///   user-visible error.
class NewsRssDataSource {
  NewsRssDataSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 15);

  /// Downloads [feedUrl] and parses it. Throws on network/HTTP/parse failure.
  Future<List<FeedItem>> fetch(String feedUrl) async {
    final uri = Uri.tryParse(feedUrl);
    if (uri == null) throw ArgumentError('Invalid feed URL: $feedUrl');

    final response = await _client
        .get(
          uri,
          headers: {'User-Agent': 'Yomu/1.0 (+news reader)'},
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Feed returned HTTP ${response.statusCode}');
    }
    return parse(_decodeBody(response));
  }

  /// Pure parse step, exposed for tests: accepts raw feed XML and returns the
  /// normalised entries. Tries RSS first, then falls back to Atom.
  List<FeedItem> parse(String xmlString) {
    final trimmed = xmlString.trim();
    if (trimmed.isEmpty) return const [];

    // RSS 2.0 (and RDF/RSS 1.0) — most Japanese/English news feeds use this.
    try {
      final rss = RssFeed.parse(trimmed);
      final items = rss.items;
      if (items != null && items.isNotEmpty) {
        return items
            .map(
              (i) => FeedItem(
                title: (i.title ?? '').trim(),
                link: (i.link ?? '').trim(),
                publishedAt: i.pubDate,
                summary: _stripHtml(i.description),
              ),
            )
            .where((e) => e.title.isNotEmpty && e.link.isNotEmpty)
            .toList();
      }
    } on Object {
      // Not RSS — fall through to Atom below.
    }

    // Atom (RFC 4287).
    final atom = AtomFeed.parse(trimmed);
    final entries = atom.items;
    if (entries == null || entries.isEmpty) return const [];
    return entries
        .map(
          (e) => FeedItem(
            title: (e.title ?? '').trim(),
            link: _atomLink(e.links),
            publishedAt: e.published != null
                ? DateTime.tryParse(e.published!)
                : e.updated,
            summary: _stripHtml(e.summary ?? e.content),
          ),
        )
        .where((x) => x.title.isNotEmpty && x.link.isNotEmpty)
        .toList();
  }

  /// Picks the article link from an Atom entry's link list: prefer
  /// `rel="alternate"`, then any non-`self` link, else the first.
  String _atomLink(List<AtomLink>? links) {
    if (links == null || links.isEmpty) return '';
    final alternate =
        links.where((l) => l.rel == 'alternate').firstOrNull?.href;
    if (alternate != null && alternate.isNotEmpty) return alternate.trim();
    final nonSelf = links
        .where((l) => l.rel == null || l.rel == 'self')
        .firstOrNull
        ?.href;
    return (nonSelf ?? links.first.href ?? '').trim();
  }

  /// Decodes the response body as UTF-8, lossily, so a stray byte never drops
  /// the whole feed. (Dart has no built-in Shift-JIS/EUC-JP codec, so feeds in
  /// those encodings are best-effort; UTF-8 — the overwhelming majority, incl.
  /// every default source — decode perfectly.)
  String _decodeBody(http.Response response) =>
      utf8.decode(response.bodyBytes, allowMalformed: true);

  /// Removes HTML tags and collapses whitespace from a feed summary, and caps
  /// it so very long descriptions don't blow up the list row height.
  static String _stripHtml(String? html) {
    if (html == null || html.isEmpty) return '';
    final noTags = html.replaceAll(RegExp(r'<[^>]*>'), ' ');
    final decoded = noTags
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
    final collapsed = decoded.replaceAll(RegExp(r'\s+'), ' ').trim();
    return collapsed.length > 280 ? '${collapsed.substring(0, 277)}…' : collapsed;
  }
}
