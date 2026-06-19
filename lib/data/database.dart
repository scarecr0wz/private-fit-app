import 'package:drift/drift.dart';
import 'connection/connection.dart' as connection;

part 'database.g.dart';

class FoodLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get foodName => text()();
  RealColumn get grams => real()(); 
  RealColumn get calories => real()();
  RealColumn get protein => real()();
  RealColumn get carbs => real()();
  RealColumn get fat => real()();
}

class WorkoutLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get templateName => text()();
  IntColumn get durationMinutes => integer()();
  RealColumn get totalVolumeKg => real()();
  RealColumn get caloriesBurned => real().withDefault(const Constant(0.0))();
}

class WorkoutSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutLogId => integer()();
  TextColumn get exerciseName => text()();
  IntColumn get reps => integer()();
  RealColumn get weightKg => real()();
}

class ActivityLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get type => text()();
  IntColumn get durationSeconds => integer()();
  RealColumn get distanceMeters => real()();
  RealColumn get caloriesBurned => real()();
  TextColumn get routePoints => text()();
}

class BodyWeights extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  RealColumn get weightKg => real()();
}

@DriftDatabase(tables: [
  FoodLogs,
  WorkoutLogs,
  WorkoutSets,
  ActivityLogs,
  BodyWeights,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connection.connect());

  @override
  int get schemaVersion => 1;
}

final db = AppDatabase();
