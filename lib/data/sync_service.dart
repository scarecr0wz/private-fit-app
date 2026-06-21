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
}
