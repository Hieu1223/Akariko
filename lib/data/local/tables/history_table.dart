import 'package:drift/drift.dart';

@DataClassName('HistoryRow')
@TableIndex(name: 'idx_history_visited_at', columns: {#visitedAt})
class HistoryTable extends Table {
  TextColumn get id => text()();
  TextColumn get url => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  DateTimeColumn get visitedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
