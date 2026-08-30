import '../local/app_database.dart';

/// Lifecycle of a download managed by the download manager (§7.16).
enum DownloadStatus { downloading, paused, done, failed }

/// Domain model for a download manager item (maps from [DownloadItemsTableData]).
class DownloadItem {
  const DownloadItem({
    required this.id,
    required this.url,
    this.filePath,
    this.status = DownloadStatus.downloading,
    this.progress = 0.0,
    this.totalBytes = 0,
    required this.createdAt,
  });

  final String id;
  final String url;
  final String? filePath;
  final DownloadStatus status;
  final double progress;
  final int totalBytes;
  final DateTime createdAt;

  /// Best-effort display name derived from the saved path or the URL.
  String get fileName {
    final raw = filePath ?? url;
    final segments = raw.split(RegExp(r'[/\\]'));
    final last = segments.lastWhere((s) => s.isNotEmpty, orElse: () => raw);
    if (last.contains(RegExp(r'\.'))) return last;
    return last.isNotEmpty ? last : 'download';
  }

  DownloadItem copyWith({
    String? id,
    String? url,
    String? filePath,
    DownloadStatus? status,
    double? progress,
    int? totalBytes,
    DateTime? createdAt,
  }) =>
      DownloadItem(
        id: id ?? this.id,
        url: url ?? this.url,
        filePath: filePath ?? this.filePath,
        status: status ?? this.status,
        progress: progress ?? this.progress,
        totalBytes: totalBytes ?? this.totalBytes,
        createdAt: createdAt ?? this.createdAt,
      );

  factory DownloadItem.fromRow(DownloadItemsTableData row) => DownloadItem(
        id: row.id,
        url: row.url,
        filePath: row.filePath,
        status: _parse(row.status),
        progress: row.progress,
        totalBytes: row.totalBytes,
        createdAt: row.createdAt,
      );

  static DownloadStatus _parse(String s) => switch (s) {
        'paused' => DownloadStatus.paused,
        'done' => DownloadStatus.done,
        'failed' => DownloadStatus.failed,
        _ => DownloadStatus.downloading,
      };

  static String statusToString(DownloadStatus s) => s.name;
}
