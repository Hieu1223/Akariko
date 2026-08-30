import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Thin wrapper around the platform download engine.
///
/// The default implementation ([HttpDownloadEngineService]) fetches over
/// `dart:io` so progress survives app restarts and works without any native
/// bridge. The contract is abstract so a `flutter_downloader` / OS-level
/// manager could be dropped in later without touching the use-case or UI.
abstract class DownloadEngineService {
  /// Downloads [url] to [savePath], invoking callbacks as bytes arrive.
  ///
  /// [resumeFrom] supports continue-on-failure via HTTP Range requests.
  /// Call [cancel] with the same [id] to abort; the engine then invokes
  /// [onCancel] instead of [onError].
  Future<void> start({
    required String id,
    required String url,
    required String savePath,
    required void Function(int receivedBytes, int? totalBytes, double progress)
        onProgress,
    required void Function() onDone,
    required void Function(Object error) onError,
    void Function()? onCancel,
    int resumeFrom = 0,
  });

  /// Aborts an in-flight download started with [start].
  void cancel(String id);
}

class HttpDownloadEngineService implements DownloadEngineService {
  final Map<String, bool> _cancelled = {};
  final Map<String, HttpClientRequest> _requests = {};

  @override
  Future<void> start({
    required String id,
    required String url,
    required String savePath,
    required void Function(int receivedBytes, int? totalBytes, double progress)
        onProgress,
    required void Function() onDone,
    required void Function(Object error) onError,
    void Function()? onCancel,
    int resumeFrom = 0,
  }) async {
    _cancelled[id] = false;
    final client = HttpClient();
    IOSink? sink;
    try {
      final uri = Uri.parse(url);
      final request = await client.getUrl(uri);
      if (resumeFrom > 0) {
        request.headers.set(HttpHeaders.rangeHeader, 'bytes=$resumeFrom-');
      }
      _requests[id] = request;

      final response = await request.close();
      // For a range request the content length is the remaining bytes.
      final remaining = response.contentLength;
      final total = remaining > 0 ? remaining + resumeFrom : null;

      final file = File(savePath);
      sink = file.openWrite(
        mode: resumeFrom > 0 ? FileMode.append : FileMode.write,
      );
      var received = resumeFrom;
      await for (final chunk in response) {
        if (_cancelled[id] == true) return;
        sink.add(chunk);
        received += chunk.length;
        final progress = total != null && total > 0
            ? (received / total).clamp(0.0, 1.0)
            : 0.0;
        onProgress(received, total, progress);
      }

      if (_cancelled[id] == true) {
        onCancel?.call();
        return;
      }
      onDone();
    } catch (e) {
      if (_cancelled[id] == true) {
        onCancel?.call();
        return;
      }
      onError(e);
    } finally {
      await sink?.close();
      _cancelled.remove(id);
      _requests.remove(id);
      client.close(force: true);
    }
  }

  @override
  void cancel(String id) {
    _cancelled[id] = true;
    _requests[id]?.abort();
  }
}

/// Resolves the on-device directory used to persist downloaded files.
Future<Directory> getDownloadsDirectory() async {
  final base = await getApplicationDocumentsDirectory();
  final dir = Directory('${base.path}/yomu_downloads');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return dir;
}
