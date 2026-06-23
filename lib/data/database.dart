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
  // Weather snapshot at activity start (nullable for backwards compat)
  RealColumn get weatherTemp => real().nullable()();
  RealColumn get weatherHumidity => real().nullable()();
  RealColumn get weatherWindKmh => real().nullable()();
  IntColumn get weatherCode => integer().nullable()();
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // v1 → v2: add weather snapshot columns to activity_logs
        await m.addColumn(activityLogs, activityLogs.weatherTemp);
        await m.addColumn(activityLogs, activityLogs.weatherHumidity);
        await m.addColumn(activityLogs, activityLogs.weatherWindKmh);
        await m.addColumn(activityLogs, activityLogs.weatherCode);
      }
    },
  );

  /// Menghapus seluruh isi tabel secara permanen (Truncate)
  /// Wajib dipanggil saat proses Logout untuk mencegah kebocoran data privasi.
  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(foodLogs).go();
      await delete(workoutSets).go(); // Delete children first
      await delete(workoutLogs).go();
      await delete(activityLogs).go();
      await delete(bodyWeights).go();
    });
  }
}

final db = AppDatabase();
