import 'package:drift/drift.dart';

import '../local/app_database.dart';

/// A user-managed RSS/Atom news source (§7.17). Seeded with a default list on
/// first launch; every row is editable/removable afterward like any other.
class NewsSource {
  const NewsSource({
    required this.id,
    required this.name,
    required this.feedUrl,
    required this.addedAt,
  });

  final String id;
  final String name;
  final String feedUrl;
  final DateTime addedAt;

  factory NewsSource.fromRow(NewsSourcesTableData row) => NewsSource(
        id: row.id,
        name: row.name,
        feedUrl: row.feedUrl,
        addedAt: row.addedAt,
      );

  NewsSource copyWith({
    String? id,
    String? name,
    String? feedUrl,
    DateTime? addedAt,
  }) =>
      NewsSource(
        id: id ?? this.id,
        name: name ?? this.name,
        feedUrl: feedUrl ?? this.feedUrl,
        addedAt: addedAt ?? this.addedAt,
      );

  /// Companion used both for insert (new user source) and for the idempotent
  /// seed migration (which must not clobber a source the user kept/edited).
  NewsSourcesTableCompanion toInsertCompanion() =>
      NewsSourcesTableCompanion.insert(
        id: id,
        name: name,
        feedUrl: feedUrl,
        addedAt: Value(addedAt),
      );
}
