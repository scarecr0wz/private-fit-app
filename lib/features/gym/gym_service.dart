import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/database.dart';
import '../../data/sync_service.dart';

enum GymWorkoutState { idle, countdown, active, paused }

class GymExercise {
  final String name;
  final String bodyPart;
  final List<GymSet> sets;

  GymExercise({required this.name, required this.bodyPart, List<GymSet>? sets})
      : sets = sets ?? [GymSet()];

  /// Deep copy for summary snapshot
  GymExercise copyDeep() => GymExercise(
        name: name,
        bodyPart: bodyPart,
        sets: sets.map((s) => GymSet(weight: s.weight, reps: s.reps, completed: s.completed)).toList(),
      );
}

class GymSet {
  double weight;
  int reps;
  bool completed;

  GymSet({this.weight = 0, this.reps = 0, this.completed = false});
}

class WorkoutSummaryData {
  final Duration duration;
  final double totalVolume;
  final int exerciseCount;
  final int totalSets;
  final double caloriesBurned;
  final List<GymExercise> exercises;
  final DateTime date;

  WorkoutSummaryData({
    required this.duration,
    required this.totalVolume,
    required this.exerciseCount,
    required this.totalSets,
    required this.caloriesBurned,
    required this.exercises,
    required this.date,
  });
}

/// Singleton service that manages gym workout state globally.
/// State persists across tab switches (same as ActivityService pattern).
class GymService extends ChangeNotifier {
  GymService._();
  static final GymService instance = GymService._();

  // ─── State ────────────────────────────────────────────────────────────────
  GymWorkoutState state = GymWorkoutState.idle;

  // Countdown
  int countdownValue = 5;
  Timer? _countdownTimer;
  final FlutterTts _flutterTts = FlutterTts();

  // Elapsed time tracking (same pattern as ActivityService)
  Duration _accumulatedDuration = Duration.zero;
  DateTime? _lastStartTime;
  Timer? _timer;

  Duration get duration {
    if (state == GymWorkoutState.active && _lastStartTime != null) {
      return _accumulatedDuration + DateTime.now().difference(_lastStartTime!);
    }
    return _accumulatedDuration;
  }

  // Active workout exercises
  List<GymExercise> exercises = [];

  // Rest timer
  int restSecondsRemaining = 0;
  int defaultRestTime = 90;
  Timer? _restTimer;
  bool get isRestActive => restSecondsRemaining > 0;

  // ─── Countdown ────────────────────────────────────────────────────────────
  void beginCountdown() {
    state = GymWorkoutState.countdown;
    countdownValue = 5;
    notifyListeners();

    _flutterTts.setLanguage("en-US");
    _flutterTts.speak(countdownValue.toString());

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      countdownValue--;
      if (countdownValue > 0) {
        _flutterTts.speak(countdownValue.toString());
      }
      notifyListeners();
      if (countdownValue <= 0) {
        t.cancel();
        _countdownTimer = null;
        _startWorkout();
      }
    });
  }

  void cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    state = GymWorkoutState.idle;
    countdownValue = 5;
    notifyListeners();
  }

  // ─── Workout Lifecycle ────────────────────────────────────────────────────
  void _startWorkout() {
    _flutterTts.speak("Workout started");
    state = GymWorkoutState.active;
    _lastStartTime = DateTime.now();
    _accumulatedDuration = Duration.zero;
    exercises = [];
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners(); // Rebuild UI every second for timer
    });
  }

  void pauseWorkout() {
    if (state != GymWorkoutState.active) return;
    state = GymWorkoutState.paused;
    if (_lastStartTime != null) {
      _accumulatedDuration += DateTime.now().difference(_lastStartTime!);
      _lastStartTime = null;
    }
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void resumeWorkout() {
    if (state != GymWorkoutState.paused) return;
    state = GymWorkoutState.active;
    _lastStartTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
    notifyListeners();
  }

  // ─── Exercise Management ──────────────────────────────────────────────────
  void addExercise(String name, String bodyPart) {
    exercises.add(GymExercise(name: name, bodyPart: bodyPart));
    notifyListeners();
  }

  void removeExercise(int index) {
    if (index >= 0 && index < exercises.length) {
      exercises.removeAt(index);
      notifyListeners();
    }
  }

  void addSet(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= exercises.length) return;
    final ex = exercises[exerciseIndex];
    // Pre-fill with previous set's values for convenience
    double prevWeight = 0;
    int prevReps = 0;
    if (ex.sets.isNotEmpty) {
      prevWeight = ex.sets.last.weight;
      prevReps = ex.sets.last.reps;
    }
    ex.sets.add(GymSet(weight: prevWeight, reps: prevReps));
    notifyListeners();
  }

  void removeSet(int exerciseIndex, int setIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= exercises.length) return;
    final ex = exercises[exerciseIndex];
    if (setIndex >= 0 && setIndex < ex.sets.length) {
      ex.sets.removeAt(setIndex);
      notifyListeners();
    }
  }

  void updateSet(int exerciseIndex, int setIndex, {double? weight, int? reps}) {
    if (exerciseIndex < 0 || exerciseIndex >= exercises.length) return;
    final ex = exercises[exerciseIndex];
    if (setIndex < 0 || setIndex >= ex.sets.length) return;
    if (weight != null) ex.sets[setIndex].weight = weight;
    if (reps != null) ex.sets[setIndex].reps = reps;
    // Don't notifyListeners here — called from TextField onChanged, avoid rebuild loops
  }

  void completeSet(int exerciseIndex, int setIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= exercises.length) return;
    final ex = exercises[exerciseIndex];
    if (setIndex < 0 || setIndex >= ex.sets.length) return;
    final s = ex.sets[setIndex];
    s.completed = !s.completed;
    if (s.completed) {
      startRestTimer();
    }
    notifyListeners();
  }

  // ─── Rest Timer ───────────────────────────────────────────────────────────
  void startRestTimer() {
    _restTimer?.cancel();
    restSecondsRemaining = defaultRestTime;
    notifyListeners();

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      restSecondsRemaining--;
      if (restSecondsRemaining <= 0) {
        restSecondsRemaining = 0;
        timer.cancel();
        _restTimer = null;
        HapticFeedback.heavyImpact();
        _flutterTts.speak("Rest complete");
      }
      notifyListeners();
    });
  }

  void skipRest() {
    _restTimer?.cancel();
    _restTimer = null;
    restSecondsRemaining = 0;
    notifyListeners();
  }

  void adjustRestTime(int seconds) {
    restSecondsRemaining += seconds;
    if (restSecondsRemaining < 0) restSecondsRemaining = 0;
    notifyListeners();
  }

  void setDefaultRestTime(int seconds) {
    defaultRestTime = seconds;
    notifyListeners();
  }

  // ─── Finish Workout & Save ────────────────────────────────────────────────
  Future<WorkoutSummaryData?> finishWorkout() async {
    _timer?.cancel();
    _timer = null;
    _restTimer?.cancel();
    _restTimer = null;
    restSecondsRemaining = 0;

    // Capture final duration before resetting
    final finalDuration = duration;
    if (_lastStartTime != null) {
      _accumulatedDuration += DateTime.now().difference(_lastStartTime!);
      _lastStartTime = null;
    }

    // Calculate stats
    double totalVolume = 0;
    int totalSets = 0;
    int exerciseCount = 0;

    for (var ex in exercises) {
      final completedSets = ex.sets.where((s) => s.completed).toList();
      if (completedSets.isNotEmpty) {
        exerciseCount++;
        for (var s in completedSets) {
          totalVolume += s.weight * s.reps;
          totalSets++;
        }
      }
    }

    // Calculate calories (same formula as before)
    int durationMinutes = finalDuration.inMinutes;
    if (durationMinutes < 1) durationMinutes = 1;

    final latestWeightLog = await (db.select(db.bodyWeights)
          ..orderBy([(t) => drift.OrderingTerm(expression: t.date, mode: drift.OrderingMode.desc)])
          ..limit(1))
        .getSingleOrNull();

    final bodyWeightKg = latestWeightLog?.weightKg ?? 70.0;
    final durationHours = durationMinutes / 60.0;
    final baseCalories = 5.0 * bodyWeightKg * durationHours;
    final volumeBonusCalories = totalVolume * 0.005;
    final totalCaloriesBurned = baseCalories + volumeBonusCalories;

    // Save to database
    final now = DateTime.now();
    final List<WorkoutSetsCompanion> setsToInsert = [];

    for (var ex in exercises) {
      for (var s in ex.sets.where((s) => s.completed)) {
        setsToInsert.add(WorkoutSetsCompanion.insert(
          workoutLogId: 0, // placeholder, will be replaced in transaction
          exerciseName: ex.name,
          reps: s.reps,
          weightKg: s.weight,
        ));
      }
    }

    await db.transaction(() async {
      final logId = await db.into(db.workoutLogs).insert(WorkoutLogsCompanion.insert(
        date: now,
        templateName: 'Custom Workout',
        durationMinutes: durationMinutes,
        totalVolumeKg: totalVolume,
        caloriesBurned: drift.Value(totalCaloriesBurned),
      ));

      final savedSets = <WorkoutSet>[];
      for (var s in setsToInsert) {
        final setId = await db.into(db.workoutSets).insert(
          s.copyWith(workoutLogId: drift.Value(logId)),
        );
        savedSets.add(WorkoutSet(
          id: setId,
          workoutLogId: logId,
          exerciseName: s.exerciseName.value,
          reps: s.reps.value,
          weightKg: s.weightKg.value,
        ));
      }

      // Sync to VPS backend
      final workoutLog = WorkoutLog(
        id: logId,
        date: now,
        templateName: 'Custom Workout',
        durationMinutes: durationMinutes,
        totalVolumeKg: totalVolume,
        caloriesBurned: totalCaloriesBurned,
      );
      syncServiceInstance.syncWorkout(workoutLog, savedSets);
    });

    // Build summary snapshot
    final summary = WorkoutSummaryData(
      duration: finalDuration,
      totalVolume: totalVolume,
      exerciseCount: exerciseCount,
      totalSets: totalSets,
      caloriesBurned: totalCaloriesBurned,
      exercises: exercises.map((e) => e.copyDeep()).toList(),
      date: now,
    );

    _flutterTts.speak("Workout complete. Great job!");

    // Reset state
    state = GymWorkoutState.idle;
    exercises = [];
    _accumulatedDuration = Duration.zero;
    _lastStartTime = null;
    countdownValue = 5;
    notifyListeners();

    return summary;
  }

  // ─── History Queries ──────────────────────────────────────────────────────
  Stream<List<WorkoutLog>> watchHistory() {
    return (db.select(db.workoutLogs)
          ..orderBy([(t) => drift.OrderingTerm(expression: t.date, mode: drift.OrderingMode.desc)])
          ..limit(50))
        .watch();
  }

  Future<List<WorkoutSet>> getSetsForWorkout(int workoutLogId) {
    return (db.select(db.workoutSets)
          ..where((t) => t.workoutLogId.equals(workoutLogId)))
        .get();
  }
}
