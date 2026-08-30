import 'package:drift/drift.dart';

/// RSS/Atom news sources. Seeded with a default list on first launch
/// (see §7.17); user-editable thereafter.
class NewsSourcesTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get feedUrl => text()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
