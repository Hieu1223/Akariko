import 'package:drift/drift.dart';

/// Download manager items. Status stored as a text enum
/// (downloading | paused | done | failed).
class DownloadItemsTable extends Table {
  TextColumn get id => text()();
  TextColumn get url => text()();
  TextColumn get filePath => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('downloading'))();
  RealColumn get progress => real().withDefault(const Constant(0.0))();
  IntColumn get totalBytes => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
