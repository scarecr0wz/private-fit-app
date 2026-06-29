import 'package:flutter/material.dart';
import 'package:flutter_body_part_selector/flutter_body_part_selector.dart';
import '../../data/muscle_data.dart';

/// Maps our exercises.json muscle group IDs to the package's [Muscle] enum.
///
/// exercises.json uses generic names like "chest", "biceps", "triceps" etc.
/// The package has 25 muscles split across front/back SVG views.
/// Front: traps, delts, chest, abs, triceps, biceps, forearms, quads, calves.
/// Back: latsBack, lowerLatsBack, glutes, hamstrings.
const Map<String, List<Muscle>> _muscleGroupToPackageMuscles = {
  // ─── Front view muscles ────────────────────────────────────────────────
  'chest': [Muscle.chestLeft, Muscle.chestRight],
  'abdominals': [Muscle.abs],
  'quadriceps': [Muscle.quadsLeft, Muscle.quadsRight],
  'biceps': [Muscle.bicepsLeft, Muscle.bicepsRight],
  'shoulders': [Muscle.deltsLeft, Muscle.deltsRight],
  'forearms': [Muscle.forearmsLeft, Muscle.forearmsRight],
  'triceps': [Muscle.tricepsLeft, Muscle.tricepsRight],
  'traps': [Muscle.trapsLeft, Muscle.trapsRight],
  'calves': [Muscle.calvesLeft, Muscle.calvesRight],

  // ─── Back view muscles ─────────────────────────────────────────────────
  'lats': [Muscle.latsBackLeft, Muscle.latsBackRight],
  'lower back': [Muscle.lowerLatsBackLeft, Muscle.lowerLatsBackRight],
  'middle back': [Muscle.latsBackLeft, Muscle.latsBackRight],
  'glutes': [Muscle.glutesLeft, Muscle.glutesRight],
  'hamstrings': [Muscle.hamstringsLeft, Muscle.hamstringsRight],

  // ─── Mapped to closest visual match ────────────────────────────────────
  'adductors': [Muscle.quadsLeft, Muscle.quadsRight],
  'abductors': [Muscle.glutesLeft, Muscle.glutesRight],
  'neck': [], // no neck path in the package SVG
};

/// A reusable widget that displays a muscle heatmap using [MuscleActivationData].
///
/// Shows front and back body views with muscles colored by activation intensity.
/// Uses the `flutter_body_part_selector` package for the SVG body diagram.
class MuscleHeatmapWidget extends StatefulWidget {
  /// The computed muscle activation data to visualize.
  final MuscleActivationData activationData;

  /// Optional height constraint. Defaults to 280.
  final double height;

  /// Whether to show the "Muscles Worked" title. Default true.
  final bool showTitle;

  /// Whether to show the legend. Default true.
  final bool showLegend;

  const MuscleHeatmapWidget({
    super.key,
    required this.activationData,
    this.height = 280,
    this.showTitle = true,
    this.showLegend = true,
  });

  @override
  State<MuscleHeatmapWidget> createState() => _MuscleHeatmapWidgetState();
}

class _MuscleHeatmapWidgetState extends State<MuscleHeatmapWidget> {
  bool _showFront = true;

  /// Convert our activation data to the set of [Muscle] enums the package expects.
  Set<Muscle> _getHighlightedMuscles() {
    final Set<Muscle> result = {};

    for (final entry in widget.activationData.workedMuscles) {
      final muscleId = entry.key;
      final packageMuscles = _muscleGroupToPackageMuscles[muscleId];
      if (packageMuscles != null) {
        result.addAll(packageMuscles);
      }
    }

    return result;
  }

  /// Get the highlight color based on the highest intensity in the data.
  Color _getHighlightColor() {
    if (!widget.activationData.hasData) return Colors.grey;

    // Find the dominant intensity
    int maxSets = 0;
    for (final entry in widget.activationData.workedMuscles) {
      if (entry.value.totalSets > maxSets) {
        maxSets = entry.value.totalSets;
      }
    }

    if (maxSets >= 9) return const Color(0xFFFF3B30).withValues(alpha: 0.8); // High - Red
    if (maxSets >= 4) return const Color(0xFFFF5722).withValues(alpha: 0.7); // Moderate - Deep Orange
    return const Color(0xFFFF9500).withValues(alpha: 0.6); // Low - Orange
  }

  @override
  Widget build(BuildContext context) {
    final highlightedMuscles = _getHighlightedMuscles();
    final workedCount = widget.activationData.workedCount;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── Header ─────────────────────────────────────────────────────
          if (widget.showTitle)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  const Icon(Icons.accessibility_new, color: Color(0xFFFF5722), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Muscles Worked',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (workedCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5722).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$workedCount groups',
                        style: const TextStyle(
                          color: Color(0xFFFF5722),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // ─── Body Map ────────────────────────────────────────────────────
          SizedBox(
            height: widget.height,
            child: Stack(
              children: [
                InteractiveBodySvg(
                  isFront: _showFront,
                  selectedMuscles: highlightedMuscles,
                  onMuscleTap: (_) {}, // Non-interactive in heatmap mode
                  enableSelection: false,
                  highlightColor: _getHighlightColor(),
                  selectedStrokeWidth: 2.0,
                  unselectedStrokeWidth: 0.5,
                  fit: BoxFit.contain,
                ),
                // Flip button overlay
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: GestureDetector(
                    onTap: () => setState(() => _showFront = !_showFront),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flip,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _showFront ? 'Back' : 'Front',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Legend ──────────────────────────────────────────────────────
          if (widget.showLegend && widget.activationData.hasData)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _buildMuscleChips(),
            ),
        ],
      ),
    );
  }

  /// Build small chips showing which muscle groups were worked.
  Widget _buildMuscleChips() {
    final worked = widget.activationData.workedMuscles.toList();
    // Sort by total sets descending (most worked first)
    worked.sort((a, b) => b.value.totalSets.compareTo(a.value.totalSets));

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: worked.map((entry) {
        final muscleGroup = MuscleGroup.fromId(entry.key);
        final activation = entry.value;
        final isPrimary = activation.targetType == MuscleTargetType.primary;
        final color = isPrimary ? const Color(0xFFFF3B30) : const Color(0xFFFF9500);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                muscleGroup?.displayName ?? entry.key,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${activation.totalSets}s',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
