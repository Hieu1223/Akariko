import 'package:drift/drift.dart';

/// Imported dictionary dataset (Hieu's custom pack). Indexed on headword /
/// reading for fast prefix search; free-text search over meanings goes through
/// the `dictionary_fts` FTS5 index created in [AppDatabase]'s migration.
@DataClassName('DictionaryEntryRow')
@TableIndex(name: 'idx_dict_headword', columns: {#headword})
@TableIndex(name: 'idx_dict_reading', columns: {#reading})
class DictionaryEntriesTable extends Table {
  TextColumn get id => text()();
  TextColumn get headword => text()();
  TextColumn get reading => text().withDefault(const Constant(''))();
  TextColumn get meaningsJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
