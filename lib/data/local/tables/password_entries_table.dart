import 'package:drift/drift.dart';

/// Password vault entries. `encryptedPassword` is AES-GCM ciphertext; the key
/// lives in flutter_secure_storage, never in the database.
class PasswordEntriesTable extends Table {
  TextColumn get id => text()();
  TextColumn get siteUrl => text().withDefault(const Constant(''))();
  TextColumn get username => text().withDefault(const Constant(''))();
  TextColumn get encryptedPassword => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
