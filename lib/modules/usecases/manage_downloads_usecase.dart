import 'dart:io';

import '../../data/native/download_engine_service.dart';
import '../../data/repositories/download_repository.dart';
import '../../data/models/download_item.dart';

/// Orchestrates the download engine with the Drift-backed repository (§7.16).
///
/// The repository is the source of truth — its rows drive the UI, while the
/// engine only streams progress that this use-case funnels back into storage.
class ManageDownloadsUsecase {
  ManageDownloadsUsecase(this._repository, this._engine);
  final DownloadRepository _repository;
  final DownloadEngineService _engine;

  Stream<List<DownloadItem>> watch() => _repository.watchItems();

  /// Adds a URL to the download manager and begins fetching it immediately.
  Future<void> enqueue(String url) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final dir = await getDownloadsDirectory();
    final savePath = '${dir.path}/$id-${_safeName(url)}';
    await _repository.insert(
      DownloadItem(
        id: id,
        url: url,
        filePath: savePath,
        status: DownloadStatus.downloading,
        createdAt: DateTime.now(),
      ),
    );
    _run(id, url, savePath, resumeFrom: 0);
  }

  void _run(String id, String url, String savePath, {int resumeFrom = 0}) {
    _engine.start(
      id: id,
      url: url,
      savePath: savePath,
      resumeFrom: resumeFrom,
      onProgress: (received, total, progress) {
        _repository.updateProgress(
          id,
          progress: progress,
          totalBytes: total ?? 0,
          status: 'downloading',
        );
      },
      onDone: () {
        _repository.updateProgress(id, progress: 1.0, status: 'done');
      },
      onError: (_) {
        _repository.updateStatus(id, 'failed');
      },
      onCancel: () {
        // Status is already moved to "paused" by [pause] when aborted.
      },
    );
  }

  /// Pauses an in-flight download (resumable later if the server allows Range).
  void pause(String id, String url, String savePath) {
    _engine.cancel(id);
    _repository.updateStatus(id, 'paused');
  }

  /// Resumes a paused download from the bytes already written.
  Future<void> resume(DownloadItem item) async {
    if (item.filePath == null) return;
    final resumeFrom = item.totalBytes > 0
        ? (item.progress * item.totalBytes).round()
        : 0;
    _repository.updateStatus(item.id, 'downloading');
    _run(item.id, item.url, item.filePath!, resumeFrom: resumeFrom);
  }

  /// Cancels and removes a download (deletes any partially written file).
  void cancel(String id) {
    _engine.cancel(id);
    _repository.delete(id);
  }

  /// Removes a finished or failed download from the list.
  Future<void> remove(String id) async {
    _engine.cancel(id);
    final item = await _repository.get(id);
    if (item?.filePath != null) {
      final file = File(item!.filePath!);
      if (await file.exists()) await file.delete();
    }
    _repository.delete(id);
  }

  /// Restarts a failed download from scratch.
  void retry(DownloadItem item) {
    if (item.filePath == null) return;
    _repository.updateStatus(item.id, 'downloading');
    _run(item.id, item.url, item.filePath!, resumeFrom: 0);
  }

  /// Deletes every completed download row (§7.16 "Clear completed").
  Future<void> clearCompleted() => _repository.clearCompleted();

  /// Path of the finished file, used to open it with a viewer intent.
  Future<String?> filePathOf(String id) async =>
      (await _repository.get(id))?.filePath;

  /// Derives a safe on-disk file name from the URL.
  ///
  /// The last URL path segment is used verbatim by default, but it is stripped
  /// of path separators and characters that are illegal in file names on every
  /// supported platform (and trimmed of directory-traversal segments such as
  /// `..`). When nothing usable remains, a stable hash of the URL is used so
  /// every download still lands somewhere predictable inside [savePath].
  String _safeName(String url) {
    final segment = Uri.tryParse(url)
            ?.pathSegments
            .where((s) => s.isNotEmpty)
            .lastOrNull ??
        '';
    final name = _sanitizeSegment(segment);
    if (name.isNotEmpty) return name;
    return _urlHash(url);
  }

  /// Removes directory-traversal and illegal filename characters from [segment].
  static String _sanitizeSegment(String segment) {
    // Drop any directory components that survived in the segment.
    final file = segment.split('/').last.split('\\').last;
    // Strip characters illegal on Windows/Unix filesystems plus control chars.
    final cleaned = file.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), '_');
    if (cleaned == '.' || cleaned == '..') return '';
    final trimmed = cleaned.trim();
    if (trimmed.isEmpty) return '';
    // Keep the name bounded so it can't blow past filesystem limits.
    return trimmed.length > 120 ? trimmed.substring(0, 120) : trimmed;
  }

  /// Stable, filesystem-safe fallback name derived from the URL itself.
  static String _urlHash(String url) =>
      'download-${url.hashCode.abs().toRadixString(16)}';
}
