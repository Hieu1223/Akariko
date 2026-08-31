import 'package:drift/drift.dart';

import '../local/app_database.dart';

/// A single article pulled from a [NewsSource] feed (§7.3 / §7.17).
///
/// `id` is a stable hash of `sourceId|link` (see [ManageNewsUsecase]) so the
/// same article upserts rather than duplicates across refreshes, while `isRead`
/// survives refreshes because the repository writes it as an absent column.
class NewsArticle {
  const NewsArticle({
    required this.id,
    required this.sourceId,
    required this.title,
    required this.link,
    this.publishedAt,
    this.summary = '',
    this.isRead = false,
  });

  final String id;
  final String sourceId;
  final String title;
  final String link;
  final DateTime? publishedAt;
  final String summary;
  final bool isRead;

  factory NewsArticle.fromRow(NewsArticlesTableData row) => NewsArticle(
        id: row.id,
        sourceId: row.sourceId,
        title: row.title,
        link: row.link,
        publishedAt: row.publishedAt,
        summary: row.summary,
        isRead: row.isRead,
      );

  NewsArticle copyWith({
    String? id,
    String? sourceId,
    String? title,
    String? link,
    DateTime? publishedAt,
    String? summary,
    bool? isRead,
  }) =>
      NewsArticle(
        id: id ?? this.id,
        sourceId: sourceId ?? this.sourceId,
        title: title ?? this.title,
        link: link ?? this.link,
        publishedAt: publishedAt ?? this.publishedAt,
        summary: summary ?? this.summary,
        isRead: isRead ?? this.isRead,
      );

  /// Companion for `insertOnConflictUpdate`: feeds only the columns that come
  /// from the source. `isRead` is left absent so an existing read-state is
  /// preserved on refresh instead of being reset to its column default.
  NewsArticlesTableCompanion toUpsertCompanion() =>
      NewsArticlesTableCompanion.insert(
        id: id,
        sourceId: sourceId,
        title: title,
        link: link,
        publishedAt: Value(publishedAt),
        summary: Value(summary),
      );
}
