// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_dao.dart';

// ignore_for_file: type=lint
mixin _$BrowserDaoMixin on DatabaseAccessor<AppDatabase> {
  $TabsTableTable get tabsTable => attachedDatabase.tabsTable;
  $BookmarksTableTable get bookmarksTable => attachedDatabase.bookmarksTable;
  $HistoryTableTable get historyTable => attachedDatabase.historyTable;
  BrowserDaoManager get managers => BrowserDaoManager(this);
}

class BrowserDaoManager {
  final _$BrowserDaoMixin _db;
  BrowserDaoManager(this._db);
  $$TabsTableTableTableManager get tabsTable =>
      $$TabsTableTableTableManager(_db.attachedDatabase, _db.tabsTable);
  $$BookmarksTableTableTableManager get bookmarksTable =>
      $$BookmarksTableTableTableManager(
        _db.attachedDatabase,
        _db.bookmarksTable,
      );
  $$HistoryTableTableTableManager get historyTable =>
      $$HistoryTableTableTableManager(_db.attachedDatabase, _db.historyTable);
}
