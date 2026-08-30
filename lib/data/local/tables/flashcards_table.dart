import 'package:drift/drift.dart';

/// Flashcards scheduled with FSRS. `state` / `type` are stored as text enum
/// values; schedule fields mirror the FSRS-4.5 card model.
class FlashcardsTable extends Table {
  TextColumn get id => text()();
  TextColumn get deckId => text()();
  TextColumn get type => text().withDefault(const Constant('word'))();
  TextColumn get content => text()();
  TextColumn get reading => text().withDefault(const Constant(''))();
  TextColumn get meaning => text().withDefault(const Constant(''))();
  TextColumn get extraJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get due => dateTime().withDefault(currentDateAndTime)();
  RealColumn get stability => real().withDefault(const Constant(0.0))();
  RealColumn get difficulty => real().withDefault(const Constant(0.0))();
  IntColumn get elapsedDays => integer().withDefault(const Constant(0))();
  IntColumn get scheduledDays => integer().withDefault(const Constant(0))();
  IntColumn get reps => integer().withDefault(const Constant(0))();
  IntColumn get lapses => integer().withDefault(const Constant(0))();
  TextColumn get state => text().withDefault(const Constant('New'))();
  DateTimeColumn get lastReview => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
