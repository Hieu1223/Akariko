import 'package:drift/drift.dart';

/// Open browser tabs. The active tab is referenced by [BrowserViewModel].
@DataClassName('TabRow')
class TabsTable extends Table {
  TextColumn get id => text()();

  TextColumn get url => text().withDefault(const Constant('about:blank'))();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get faviconUrl => text().nullable()();
  TextColumn get screenshotPath => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastActiveAt =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
