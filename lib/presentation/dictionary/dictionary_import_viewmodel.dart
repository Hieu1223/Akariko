import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modules/dictionary_module.dart';
import '../../modules/usecases/import_dictionary_usecase.dart';

/// Owns the one-time dictionary import (§9 phase 3).
///
/// Kept alive for the app session — like `DownloadListViewModel` — so leaving
/// the Dictionary screen mid-import does not cancel it (§8 ViewModel lifecycle).
final dictionaryImportProvider =
    NotifierProvider<DictionaryImportViewModel, DictionaryImportProgress>(
  DictionaryImportViewModel.new,
);

class DictionaryImportViewModel extends Notifier<DictionaryImportProgress> {
  StreamSubscription<DictionaryImportProgress>? _subscription;
  bool _disposed = false;

  @override
  DictionaryImportProgress build() {
    ref.keepAlive();
    ref.onDispose(() {
      _disposed = true;
      _subscription?.cancel();
    });
    return const DictionaryImportProgress(stage: DictionaryImportStage.idle);
  }

  /// Imports the bundled dataset if it is not in the database yet.
  ///
  /// Safe to call on every visit to the Dictionary screen: the use-case
  /// short-circuits when the current dataset version is already imported.
  void ensureImported() {
    if (state.isRunning) return;
    if (state.stage == DictionaryImportStage.done) return;
    _start(force: false);
  }

  /// Wipes and re-imports the dataset (Settings → dictionary pack management).
  void reimport() => _start(force: true);

  void _start({required bool force}) {
    _subscription?.cancel();
    _subscription = ref
        .read(importDictionaryUsecaseProvider)
        .run(force: force)
        .listen((progress) {
      if (!_disposed) state = progress;
    });
  }
}
