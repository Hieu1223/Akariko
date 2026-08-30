import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/download_item.dart';
import '../../modules/download_module.dart';
import '../../modules/usecases/manage_downloads_usecase.dart';

/// Download manager state (§7.16).
class DownloadListState {
  const DownloadListState({this.items = const []});
  final List<DownloadItem> items;

  DownloadListState copyWith({List<DownloadItem>? items}) =>
      DownloadListState(items: items ?? this.items);
}

final downloadListViewModelProvider =
    NotifierProvider<DownloadListViewModel, DownloadListState>(
        DownloadListViewModel.new);

class DownloadListViewModel extends Notifier<DownloadListState> {
  late final ManageDownloadsUsecase _usecase;
  StreamSubscription<List<DownloadItem>>? _sub;

  @override
  DownloadListState build() {
    _usecase = ref.read(manageDownloadsUsecaseProvider);
    _sub = _usecase.watch().listen((items) {
      state = state.copyWith(items: items);
    });
    ref.onDispose(() => _sub?.cancel());
    return const DownloadListState();
  }

  void pause(DownloadItem item) =>
      _usecase.pause(item.id, item.url, item.filePath ?? '');
  Future<void> resume(DownloadItem item) => _usecase.resume(item);
  void cancel(String id) => _usecase.cancel(id);
  Future<void> remove(String id) => _usecase.remove(id);
  void retry(DownloadItem item) => _usecase.retry(item);
  Future<void> clearCompleted() => _usecase.clearCompleted();
  Future<String?> filePathOf(String id) => _usecase.filePathOf(id);
}
