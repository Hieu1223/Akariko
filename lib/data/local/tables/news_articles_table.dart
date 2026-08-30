import 'package:drift/drift.dart';

class NewsArticlesTable extends Table {
  TextColumn get id => text()();
  TextColumn get sourceId => text()();
  TextColumn get title => text()();
  TextColumn get link => text()();
  DateTimeColumn get publishedAt => dateTime().nullable()();
  TextColumn get summary => text().withDefault(const Constant(''))();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
