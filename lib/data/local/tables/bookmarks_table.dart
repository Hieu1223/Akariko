import 'package:drift/drift.dart';

@DataClassName('BookmarkRow')
class BookmarksTable extends Table {
  TextColumn get id => text()();
  TextColumn get url => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get folder => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
