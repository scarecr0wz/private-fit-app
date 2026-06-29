import 'package:drift/drift.dart' as drift;
import 'database.dart';
import 'muscle_data.dart';

/// Service that computes muscle activation data by cross-referencing
/// workout sets against the local ExerciseDictionary.
///
/// No backend API changes needed — the exercise→muscle mapping
/// already exists in the local SQLite DB via exercises.json seeder.
class MuscleActivationService {
  MuscleActivationService._();
  static final MuscleActivationService instance = MuscleActivationService._();

  /// Cache: exercise name → (primaryMuscles, secondaryMuscles)
  /// Built lazily on first query, cleared if exercises are re-seeded.
  Map<String, _ExerciseMuscleMapping>? _cache;

  /// Build or return the cached exercise→muscle lookup.
  Future<Map<String, _ExerciseMuscleMapping>> _getCache() async {
    if (_cache != null) return _cache!;

    final allExercises = await db.select(db.exerciseDictionary).get();
    _cache = {};
    for (final ex in allExercises) {
      // exerciseDictionary stores muscles as comma-separated strings
      // e.g. "chest,shoulders" and "triceps"
      final primary = ex.primaryMuscles
          .split(',')
          .map((s) => s.trim().toLowerCase())
          .where((s) => s.isNotEmpty)
          .toList();
      final secondary = ex.secondaryMuscles
          .split(',')
          .map((s) => s.trim().toLowerCase())
          .where((s) => s.isNotEmpty)
          .toList();

      // Index by both the exercise name (case-insensitive) for fuzzy matching
      _cache![ex.name.toLowerCase()] = _ExerciseMuscleMapping(primary, secondary);
    }
    return _cache!;
  }

  /// Invalidate cache (call if exercises are re-seeded).
  void invalidateCache() => _cache = null;

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Compute muscle activation for a single workout session.
  ///
  /// Takes the list of [WorkoutSet] for a given workout and returns
  /// which muscles were hit, how many sets, and at what intensity.
  Future<MuscleActivationData> computeForSession(List<WorkoutSet> sets) async {
    final cache = await _getCache();
    final Map<String, _MuscleAccumulator> accumulator = {};

    for (final set in sets) {
      final mapping = cache[set.exerciseName.toLowerCase()];
      if (mapping == null) continue; // Exercise not in dictionary — skip

      // Count 1 set for each primary muscle
      for (final muscle in mapping.primaryMuscles) {
        accumulator.putIfAbsent(muscle, () => _MuscleAccumulator());
        accumulator[muscle]!.primarySets++;
      }

      // Count 1 set for each secondary muscle
      for (final muscle in mapping.secondaryMuscles) {
        accumulator.putIfAbsent(muscle, () => _MuscleAccumulator());
        accumulator[muscle]!.secondarySets++;
      }
    }

    // Convert accumulators to MuscleActivation
    final Map<String, MuscleActivation> result = {};
    for (final entry in accumulator.entries) {
      final acc = entry.value;
      result[entry.key] = MuscleActivation(
        totalSets: acc.primarySets + acc.secondarySets,
        targetType: acc.primarySets > 0
            ? MuscleTargetType.primary
            : MuscleTargetType.secondary,
      );
    }

    return MuscleActivationData(result);
  }

  /// Compute muscle activation for a date range (e.g. last 7 days).
  ///
  /// Aggregates all workout sessions in the range into a single heatmap.
  Future<MuscleActivationData> computeForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    // Fetch all workout logs in the date range
    final logs = await (db.select(db.workoutLogs)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerOrEqualValue(end)))
        .get();

    if (logs.isEmpty) return const MuscleActivationData.empty();

    // Fetch all sets for those workouts
    final logIds = logs.map((l) => l.id).toList();
    final allSets = await (db.select(db.workoutSets)
          ..where((t) => t.workoutLogId.isIn(logIds)))
        .get();

    return computeForSession(allSets);
  }

  /// Compute weekly muscle activation (last 7 days from now).
  Future<MuscleActivationData> computeWeekly() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return computeForDateRange(weekAgo, now);
  }

  /// Compute muscle activation for a specific workout log by ID.
  Future<MuscleActivationData> computeForWorkout(int workoutLogId) async {
    final sets = await (db.select(db.workoutSets)
          ..where((t) => t.workoutLogId.equals(workoutLogId)))
        .get();
    return computeForSession(sets);
  }
}

/// Internal: tracks set counts during accumulation.
class _MuscleAccumulator {
  int primarySets = 0;
  int secondarySets = 0;
}

/// Internal: cached muscle mapping for a single exercise.
class _ExerciseMuscleMapping {
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;

  const _ExerciseMuscleMapping(this.primaryMuscles, this.secondaryMuscles);
}
