import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'database.dart';

final syncServiceInstance = SyncService(dioInstance);
final syncServiceProvider = Provider((ref) => syncServiceInstance);

class SyncService {
  final Dio _dio;

  SyncService(this._dio);

  /// 🍅 Sync Food
  Future<void> syncFood(FoodLog food) async {
    try {
      await _dio.post('/api/food-logs', data: {
        'date': food.date.toIso8601String(),
        'foodName': food.foodName,
        'grams': food.grams,
        'calories': food.calories,
        'protein': food.protein,
        'carbs': food.carbs,
        'fat': food.fat,
      });
      print('✅ [Sync] Food Log tersinkronisasi: ${food.foodName}');
    } catch (e) {
      print('❌ [Sync Error] Gagal kirim Food Log: $e');
    }
  }

  /// 💪 Sync Gym (Workout + Sets)
  Future<void> syncWorkout(WorkoutLog workout, List<WorkoutSet> sets) async {
    try {
      // 1. Bikin Session Gym dulu
      final res = await _dio.post('/api/workout-logs', data: {
        'date': workout.date.toIso8601String(),
        'templateName': workout.templateName,
        'durationMinutes': workout.durationMinutes,
        'totalVolumeKg': workout.totalVolumeKg,
        'caloriesBurned': workout.caloriesBurned,
      });
      
      // Ambil ID dari VPS (karena ID VPS beda dengan ID SQLite)
      final serverWorkoutId = res.data['id'];

      // 2. Kirim Sets-nya ke ID tersebut
      for (final s in sets) {
        await _dio.post('/api/workout-logs/$serverWorkoutId/sets', data: {
          'exerciseName': s.exerciseName,
          'reps': s.reps,
          'weightKg': s.weightKg,
        });
      }
      print('✅ [Sync] Workout & ${sets.length} Sets tersinkronisasi: ${workout.templateName}');
    } catch (e) {
      print('❌ [Sync Error] Gagal kirim Workout Log: $e');
    }
  }

  /// 🏃‍♂️ Sync Activity (Running/Cycling + GPS & Weather)
  Future<void> syncActivity(ActivityLog activity) async {
    try {
      await _dio.post('/api/activities', data: {
        'date': activity.date.toIso8601String(),
        'type': activity.type,
        'durationSeconds': activity.durationSeconds,
        'distanceMeters': activity.distanceMeters,
        'caloriesBurned': activity.caloriesBurned,
        'routePoints': activity.routePoints, // Array route GPS dalam bentuk string
        'weatherTemp': activity.weatherTemp,
        'weatherHumidity': activity.weatherHumidity,
        'weatherWindKmh': activity.weatherWindKmh,
        'weatherCode': activity.weatherCode,
      });
      print('✅ [Sync] Activity tersinkronisasi: ${activity.type}');
    } catch (e) {
      print('❌ [Sync Error] Gagal kirim Activity Log: $e');
    }
  }

  /// 🗑 Delete Food
  Future<void> deleteFood(int id) async {
    try {
      await _dio.delete('/api/food-logs/$id');
      print('✅ [Sync] Food Log dihapus: $id');
    } catch (e) {
      print('❌ [Sync Error] Gagal hapus Food Log: $e');
    }
  }

  /// 🗑 Delete Activity
  Future<void> deleteActivity(int id) async {
    try {
      await _dio.delete('/api/activities/$id');
      print('✅ [Sync] Activity dihapus: $id');
    } catch (e) {
      print('❌ [Sync Error] Gagal hapus Activity Log: $e');
    }
  }

  /// 🗑 Delete Workout
  Future<void> deleteWorkout(int id) async {
    try {
      await _dio.delete('/api/workout-logs/$id');
      print('✅ [Sync] Workout dihapus: $id');
    } catch (e) {
      print('❌ [Sync Error] Gagal hapus Workout Log: $e');
    }
  }

  /// 🔄 Restore dari VPS (Hanya jika SQLite lokal kosong)
  Future<void> restoreFromVpsIfEmpty() async {
    try {
      final foodCount = await db.foodLogs.count().getSingle();
      final activityCount = await db.activityLogs.count().getSingle();
      final workoutCount = await db.workoutLogs.count().getSingle();

      if (foodCount == 0 && activityCount == 0 && workoutCount == 0) {
        print('⏳ [Sync] SQLite kosong. Mendownload riwayat dari VPS...');

        // 1. Restore Food
        final foodRes = await _dio.get('/api/food-logs');
        for (final f in foodRes.data) {
          await db.into(db.foodLogs).insert(FoodLogsCompanion.insert(
            id: drift.Value(f['id']),
            date: DateTime.parse(f['date']),
            foodName: f['foodName'],
            grams: (f['grams'] as num).toDouble(),
            calories: (f['calories'] as num).toDouble(),
            protein: (f['protein'] as num).toDouble(),
            carbs: (f['carbs'] as num).toDouble(),
            fat: (f['fat'] as num).toDouble(),
          ));
        }

        // 2. Restore Activities
        final actRes = await _dio.get('/api/activities');
        for (final a in actRes.data) {
          await db.into(db.activityLogs).insert(ActivityLogsCompanion.insert(
            id: drift.Value(a['id']),
            date: DateTime.parse(a['date']),
            type: a['type'],
            durationSeconds: a['durationSeconds'],
            distanceMeters: (a['distanceMeters'] as num).toDouble(),
            caloriesBurned: (a['caloriesBurned'] as num).toDouble(),
            routePoints: a['routePoints'] ?? '[]',
            weatherTemp: drift.Value(a['weatherTemp'] != null ? (a['weatherTemp'] as num).toDouble() : null),
            weatherHumidity: drift.Value(a['weatherHumidity'] != null ? (a['weatherHumidity'] as num).toDouble() : null),
            weatherWindKmh: drift.Value(a['weatherWindKmh'] != null ? (a['weatherWindKmh'] as num).toDouble() : null),
            weatherCode: drift.Value(a['weatherCode']),
          ));
        }

        // 3. Restore Workouts
        final workRes = await _dio.get('/api/workout-logs');
        for (final w in workRes.data) {
          await db.into(db.workoutLogs).insert(WorkoutLogsCompanion.insert(
            id: drift.Value(w['id']),
            date: DateTime.parse(w['date']),
            templateName: w['templateName'],
            durationMinutes: w['durationMinutes'],
            totalVolumeKg: (w['totalVolumeKg'] as num).toDouble(),
            caloriesBurned: drift.Value((w['caloriesBurned'] as num).toDouble()),
          ));

          // Restore sets (jika ada)
          if (w['sets'] != null) {
            for (final s in w['sets']) {
              await db.into(db.workoutSets).insert(WorkoutSetsCompanion.insert(
                id: drift.Value(s['id']),
                workoutLogId: w['id'],
                exerciseName: s['exerciseName'],
                reps: s['reps'],
                weightKg: (s['weightKg'] as num).toDouble(),
              ));
            }
          }
        }
        print('✅ [Sync] Selesai merestore semua data dari VPS ke SQLite lokal.');
      } else {
        print('ℹ️ [Sync] SQLite sudah ada datanya, lewati proses Restore.');
      }
    } catch (e) {
      print('❌ [Sync Error] Gagal merestore dari VPS: $e');
    }
  }
}
