import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/native/download_engine_service.dart';
import '../data/repositories/download_repository.dart';
import 'usecases/manage_downloads_usecase.dart';
import 'browser_module.dart';

/// Binding for the download manager (§7.16): engine → repository → use-case.
final downloadRepositoryProvider = Provider<DownloadRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftDownloadRepository(db);
});

final downloadEngineServiceProvider = Provider<DownloadEngineService>(
  (ref) => HttpDownloadEngineService(),
);

final manageDownloadsUsecaseProvider = Provider<ManageDownloadsUsecase>((ref) {
  return ManageDownloadsUsecase(
    ref.watch(downloadRepositoryProvider),
    ref.watch(downloadEngineServiceProvider),
  );
});
