import 'package:drift/drift.dart';

import '../local/app_database.dart';
import '../models/download_item.dart';

/// Interface: download manager items — pure CRUD over [DownloadItemsTable],
/// no business rules (pause/resume orchestration lives in the use-case).
abstract class DownloadRepository {
  Stream<List<DownloadItem>> watchItems();
  Future<DownloadItem?> get(String id);
  Future<void> insert(DownloadItem item);
  Future<void> updateProgress(String id,
      {double? progress, int? totalBytes, String? status});
  Future<void> updateStatus(String id, String status);
  Future<void> delete(String id);
  Future<void> clearCompleted();
}

class DriftDownloadRepository implements DownloadRepository {
  DriftDownloadRepository(this._db);
  final AppDatabase _db;

  @override
  Stream<List<DownloadItem>> watchItems() =>
      (_db.select(_db.downloadItemsTable)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch()
          .map((rows) => rows.map(DownloadItem.fromRow).toList());

  @override
  Future<DownloadItem?> get(String id) async {
    final row = await (_db.select(_db.downloadItemsTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : DownloadItem.fromRow(row);
  }

  @override
  Future<void> insert(DownloadItem item) => _db.into(_db.downloadItemsTable).insert(
        DownloadItemsTableCompanion.insert(
          id: item.id,
          url: item.url,
          filePath: Value(item.filePath),
          status: Value(DownloadItem.statusToString(item.status)),
          progress: Value(item.progress),
          totalBytes: Value(item.totalBytes),
        ),
      );

  @override
  Future<void> updateProgress(
    String id, {
    double? progress,
    int? totalBytes,
    String? status,
  }) async {
    await (_db.update(_db.downloadItemsTable)
          ..where((t) => t.id.equals(id)))
        .write(
      DownloadItemsTableCompanion(
        progress: progress == null ? const Value.absent() : Value(progress),
        totalBytes:
            totalBytes == null ? const Value.absent() : Value(totalBytes),
        status: status == null ? const Value.absent() : Value(status),
      ),
    );
  }

  @override
  Future<void> updateStatus(String id, String status) async {
    await (_db.update(_db.downloadItemsTable)
          ..where((t) => t.id.equals(id)))
        .write(DownloadItemsTableCompanion(status: Value(status)));
  }

  @override
  Future<void> delete(String id) =>
      (_db.delete(_db.downloadItemsTable)..where((t) => t.id.equals(id))).go();

  @override
  Future<void> clearCompleted() =>
      (_db.delete(_db.downloadItemsTable)..where((t) => t.status.equals('done')))
          .go();
}
