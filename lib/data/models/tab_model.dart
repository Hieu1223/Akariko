import '../local/app_database.dart';

/// Domain model for an open browser tab (maps from [TabRow]).
class TabModel {
  const TabModel({
    required this.id,
    required this.url,
    required this.title,
    this.faviconUrl,
    this.screenshotPath,
    this.isPinned = false,
  });

  final String id;
  final String url;
  final String title;
  final String? faviconUrl;
  final String? screenshotPath;
  final bool isPinned;

  String get displayTitle => title.isNotEmpty ? title : url;

  TabModel copyWith({
    String? id,
    String? url,
    String? title,
    String? faviconUrl,
    String? screenshotPath,
    bool? isPinned,
  }) =>
      TabModel(
        id: id ?? this.id,
        url: url ?? this.url,
        title: title ?? this.title,
        faviconUrl: faviconUrl ?? this.faviconUrl,
        screenshotPath: screenshotPath ?? this.screenshotPath,
        isPinned: isPinned ?? this.isPinned,
      );

  factory TabModel.fromRow(TabRow row) => TabModel(
        id: row.id,
        url: row.url,
        title: row.title,
        faviconUrl: row.faviconUrl,
        screenshotPath: row.screenshotPath,
        isPinned: row.isPinned,
      );
}
