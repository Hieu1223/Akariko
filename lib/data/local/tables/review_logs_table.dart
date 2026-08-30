import 'package:drift/drift.dart';

class ReviewLogsTable extends Table {
  TextColumn get id => text()();
  TextColumn get cardId => text()();
  TextColumn get rating => text()();
  DateTimeColumn get reviewedAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get prevStateJson => text().withDefault(const Constant('{}'))();
  TextColumn get newStateJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
