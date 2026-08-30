import 'dart:io';

import 'package:arisu_browser/data/models/download_item.dart';
import 'package:arisu_browser/data/native/download_engine_service.dart';
import 'package:arisu_browser/data/repositories/download_repository.dart';
import 'package:arisu_browser/modules/usecases/manage_downloads_usecase.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records download rows in memory and lets the test inspect the latest state.
class FakeDownloadRepository implements DownloadRepository {
  final Map<String, DownloadItem> byId = {};

  @override
  Stream<List<DownloadItem>> watchItems() =>
      Stream.value(byId.values.toList());

  @override
  Future<DownloadItem?> get(String id) async => byId[id];

  @override
  Future<void> insert(DownloadItem item) async => byId[item.id] = item;

  @override
  Future<void> updateProgress(
    String id, {
    double? progress,
    int? totalBytes,
    String? status,
  }) async {
    final current = byId[id];
    if (current == null) return;
    byId[id] = current.copyWith(
      progress: progress ?? current.progress,
      totalBytes: totalBytes ?? current.totalBytes,
      status: status != null
          ? parseStatus(status)
          : current.status,
    );
  }

  @override
  Future<void> updateStatus(String id, String status) async {
    final current = byId[id];
    if (current == null) return;
    byId[id] = current.copyWith(status: parseStatus(status));
  }

  @override
  Future<void> delete(String id) async => byId.remove(id);

  @override
  Future<void> clearCompleted() async {
    byId.removeWhere((_, item) => item.status == DownloadStatus.done);
  }
}

class FakeStartArgs {
  FakeStartArgs(
    this.savePath,
    this.onProgress,
    this.onDone,
    this.onError,
    this.onCancel,
  );
  final String savePath;
  final void Function(int, int?, double) onProgress;
  final void Function() onDone;
  final void Function(Object) onError;
  final void Function()? onCancel;
}

/// Captures [start] invocations and lets the test drive the callbacks.
class FakeEngine implements DownloadEngineService {
  final Map<String, FakeStartArgs> starts = {};
  final List<String> cancelled = [];

  @override
  Future<void> start({
    required String id,
    required String url,
    required String savePath,
    required void Function(int, int?, double) onProgress,
    required void Function() onDone,
    required void Function(Object) onError,
    void Function()? onCancel,
    int resumeFrom = 0,
  }) async {
    starts[id] = FakeStartArgs(savePath, onProgress, onDone, onError, onCancel);
  }

  @override
  void cancel(String id) => cancelled.add(id);

  String? savePathOf(String id) => starts[id]?.savePath;
  void complete(String id) => starts[id]?.onDone();
  void fail(String id) => starts[id]?.onError(Exception('boom'));
  void abort(String id) => starts[id]?.onCancel?.call();
}

Matcher get hasNoIllegalFilenameChar =>
    predicate((String s) => !s.contains(RegExp(r'[\\/:*?"<>|]')),
        'contains no illegal filename character');

DownloadStatus parseStatus(String s) => switch (s) {
      'paused' => DownloadStatus.paused,
      'done' => DownloadStatus.done,
      'failed' => DownloadStatus.failed,
      _ => DownloadStatus.downloading,
    };

void main() {
  // path_provider has no host implementation under `flutter test`, so fake the
  // channel that [getDownloadsDirectory] talks to.
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  binding.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        final dir = await Directory.systemTemp.createTemp('yomu_dl_');
        return dir.path;
      }
      return null;
    },
  );

  late FakeDownloadRepository repo;
  late FakeEngine engine;
  late ManageDownloadsUsecase usecase;

  setUp(() {
    repo = FakeDownloadRepository();
    engine = FakeEngine();
    usecase = ManageDownloadsUsecase(repo, engine);
  });

  group('download filename sanitization', () {
    test('keeps a plain file name', () async {
      await usecase.enqueue('https://example.com/report.pdf');
      final item = repo.byId.values.single;
      expect(item.filePath, endsWith('report.pdf'));
    });

    test('strips illegal characters and path separators', () async {
      await usecase.enqueue(
        'https://example.com/a/../b/file:na*me?.txt',
      );
      final name = repo.byId.values.single.filePath!.split('/').last;
      // Note: '?' is a URL query delimiter, so the path segment is
      // 'file:na*me' → sanitized to 'file_na_me'.
      final safeName = name.substring(name.indexOf('-') + 1);
      expect(safeName, 'file_na_me');
      expect(safeName, hasNoIllegalFilenameChar);
    });

    test('neutralizes a traversal-only segment with a hashed fallback', () async {
      await usecase.enqueue('https://example.com/..');
      final name = repo.byId.values.single.filePath!.split('/').last;
      final safeName = name.substring(name.indexOf('-') + 1);
      expect(safeName, startsWith('download-'));
      expect(safeName, isNot(contains('..')));
    });

    test('passes the sanitized path to the engine', () async {
      await usecase.enqueue('https://example.com/f:oo*bar');
      final id = repo.byId.values.single.id;
      expect(engine.savePathOf(id), endsWith('f_oo_bar'));
    });
  });

  group('download lifecycle orchestration', () {
    test('enqueue starts the engine and marks done on completion', () async {
      await usecase.enqueue('https://example.com/a.pdf');
      final id = repo.byId.values.single.id;
      expect(engine.starts, contains(id));

      engine.complete(id);
      expect(repo.byId[id]?.status, DownloadStatus.done);
    });

    test('pause cancels the engine and flips status to paused', () async {
      await usecase.enqueue('https://example.com/a.pdf');
      final item = repo.byId.values.single;
      usecase.pause(item.id, item.url, item.filePath!);
      expect(engine.cancelled, contains(item.id));
      expect(repo.byId[item.id]?.status, DownloadStatus.paused);
    });

    test('resume restarts the engine with the same id', () async {
      await usecase.enqueue('https://example.com/a.pdf');
      final item = repo.byId.values.single;
      usecase.pause(item.id, item.url, item.filePath!);
      engine.starts.clear();

      await usecase.resume(item);
      expect(engine.starts, contains(item.id));
      expect(repo.byId[item.id]?.status, DownloadStatus.downloading);
    });

    test('cancel aborts and deletes the row', () async {
      await usecase.enqueue('https://example.com/a.pdf');
      final id = repo.byId.values.single.id;
      usecase.cancel(id);
      expect(engine.cancelled, contains(id));
      expect(repo.byId, isNot(contains(id)));
    });

    test('remove aborts, deletes the row and skips a missing file', () async {
      await usecase.enqueue('https://example.com/a.pdf');
      final id = repo.byId.values.single.id;
      await usecase.remove(id);
      expect(engine.cancelled, contains(id));
      expect(repo.byId, isNot(contains(id)));
    });

    test('clearCompleted drops only finished rows', () async {
      await usecase.enqueue('https://example.com/a.pdf');
      final id = repo.byId.values.single.id;
      engine.complete(id);
      await usecase.enqueue('https://example.com/b.pdf');
      usecase.clearCompleted();
      expect(repo.byId, isNot(contains(id)));
      expect(repo.byId, hasLength(1));
    });
  });
}
