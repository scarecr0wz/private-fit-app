// Muscle group definitions for the body heatmap feature.
//
// These IDs match the `primaryMuscles` / `secondaryMuscles` values
// already stored in the ExerciseDictionary (from exercises.json).
// There are exactly 17 distinct muscle groups in the dataset.

enum MuscleGroup {
  chest('chest', 'Chest', {BodySide.front}),
  abdominals('abdominals', 'Abs', {BodySide.front}),
  quadriceps('quadriceps', 'Quads', {BodySide.front}),
  biceps('biceps', 'Biceps', {BodySide.front}),
  shoulders('shoulders', 'Shoulders', {BodySide.front, BodySide.back}),
  adductors('adductors', 'Adductors', {BodySide.front}),
  abductors('abductors', 'Abductors', {BodySide.back}),
  forearms('forearms', 'Forearms', {BodySide.front, BodySide.back}),
  neck('neck', 'Neck', {BodySide.front, BodySide.back}),
  lats('lats', 'Lats', {BodySide.back}),
  middleBack('middle back', 'Mid Back', {BodySide.back}),
  lowerBack('lower back', 'Low Back', {BodySide.back}),
  traps('traps', 'Traps', {BodySide.back}),
  glutes('glutes', 'Glutes', {BodySide.back}),
  hamstrings('hamstrings', 'Hamstrings', {BodySide.back}),
  calves('calves', 'Calves', {BodySide.back}),
  triceps('triceps', 'Triceps', {BodySide.back});

  const MuscleGroup(this.id, this.displayName, this.sides);

  /// The raw string ID as it appears in exercises.json (e.g. "middle back").
  final String id;

  /// Short display name for UI chips/labels.
  final String displayName;

  /// Which side(s) of the body diagram this muscle appears on.
  final Set<BodySide> sides;

  /// Whether this muscle should render on the front view.
  bool get showOnFront => sides.contains(BodySide.front);

  /// Whether this muscle should render on the back view.
  bool get showOnBack => sides.contains(BodySide.back);

  /// Lookup a MuscleGroup by its raw string ID from exercises.json.
  /// Returns null if the string doesn't match any known group.
  static MuscleGroup? fromId(String id) {
    final normalized = id.trim().toLowerCase();
    for (final m in MuscleGroup.values) {
      if (m.id == normalized) return m;
    }
    return null;
  }
}

enum BodySide { front, back }

/// Intensity level for coloring muscles in the heatmap.
enum MuscleIntensity {
  /// Not worked at all — default gray.
  none,

  /// 1–3 sets (light work / secondary only).
  low,

  /// 4–8 sets (moderate).
  moderate,

  /// 9+ sets (heavy — fully "lit up" red).
  high,
}

/// The computed muscle activation data for a single session or time range.
class MuscleActivationData {
  /// Map from muscle group ID (e.g. "chest") to its activation info.
  final Map<String, MuscleActivation> muscles;

  const MuscleActivationData(this.muscles);

  /// Empty activation — everything is gray.
  const MuscleActivationData.empty() : muscles = const {};

  /// Get activation for a specific muscle group.
  MuscleActivation? getActivation(String muscleId) => muscles[muscleId];

  /// Get all muscle groups that were worked.
  Iterable<MapEntry<String, MuscleActivation>> get workedMuscles =>
      muscles.entries.where((e) => e.value.totalSets > 0);

  /// How many distinct muscles were hit.
  int get workedCount => workedMuscles.length;

  /// Whether any muscles were worked.
  bool get hasData => workedMuscles.isNotEmpty;
}

/// Activation details for a single muscle group.
class MuscleActivation {
  /// Total number of sets that targeted this muscle.
  final int totalSets;

  /// Whether this muscle was primarily or secondarily targeted.
  /// If both, we report "primary" (the stronger signal).
  final MuscleTargetType targetType;

  const MuscleActivation({
    required this.totalSets,
    required this.targetType,
  });

  /// Compute intensity level from total sets.
  MuscleIntensity get intensity {
    if (totalSets <= 0) return MuscleIntensity.none;
    if (totalSets <= 3) return MuscleIntensity.low;
    if (totalSets <= 8) return MuscleIntensity.moderate;
    return MuscleIntensity.high;
  }
}

enum MuscleTargetType { primary, secondary }
