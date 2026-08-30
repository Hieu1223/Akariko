import '../local/app_database.dart';

class Bookmark {
  const Bookmark({
    required this.id,
    required this.url,
    required this.title,
    this.folder = '',
  });

  final String id;
  final String url;
  final String title;
  final String folder;

  String get displayTitle => title.isNotEmpty ? title : url;

  factory Bookmark.fromRow(BookmarkRow row) => Bookmark(
        id: row.id,
        url: row.url,
        title: row.title,
        folder: row.folder,
      );
}
