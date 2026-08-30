import '../local/app_database.dart';

class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.url,
    required this.title,
    required this.visitedAt,
  });

  final String id;
  final String url;
  final String title;
  final DateTime visitedAt;

  String get displayTitle => title.isNotEmpty ? title : url;

  factory HistoryEntry.fromRow(HistoryRow row) => HistoryEntry(
        id: row.id,
        url: row.url,
        title: row.title,
        visitedAt: row.visitedAt,
      );
}
