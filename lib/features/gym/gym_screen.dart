import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/database.dart';
import '../../theme.dart';
import 'gym_dummy.dart' as dummy;
import '../../widgets/profile_avatar.dart';

class GymScreen extends StatefulWidget {
  const GymScreen({super.key});

  @override
  State<GymScreen> createState() => _GymScreenState();
}

class _GymScreenState extends State<GymScreen> {
  bool _isWorkoutActive = false;
  DateTime? _startTime;
  List<dummy.Exercise> _activeExercises = [];

  @override
  void initState() {
    super.initState();
    _resetWorkout();
  }

  void _resetWorkout() {
    _isWorkoutActive = false;
    _startTime = null;
    _activeExercises = dummy.dummyActiveWorkout.map((e) => dummy.Exercise(
      id: e.id,
      name: e.name,
      sets: [],
    )).toList();
  }

  void _startWorkout() {
    setState(() {
      _isWorkoutActive = true;
      _startTime = DateTime.now();
    });
  }

  void _openAddSetSheet(int exerciseIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddSetSheet3D(
        onAddSet: (weight, reps) {
          setState(() {
            final ex = _activeExercises[exerciseIndex];
            final newSet = dummy.WorkoutSet(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              weight: weight,
              reps: reps,
              completed: true,
            );
            _activeExercises[exerciseIndex] = dummy.Exercise(
              id: ex.id,
              name: ex.name,
              sets: [...ex.sets, newSet],
            );
          });
        },
      ),
    );
  }

  Future<void> _finishWorkout() async {
    if (_startTime == null) return;
    
    int durationMinutes = DateTime.now().difference(_startTime!).inMinutes;
    double totalVolume = 0;
    List<WorkoutSetsCompanion> setsToInsert = [];
    
    for (var ex in _activeExercises) {
      for (var s in ex.sets) {
        totalVolume += (s.weight * s.reps);
        setsToInsert.add(WorkoutSetsCompanion.insert(
          workoutLogId: 0, // placeholder
          exerciseName: ex.name,
          reps: s.reps,
          weightKg: s.weight,
        ));
      }
    }
    
    await db.transaction(() async {
      final logId = await db.into(db.workoutLogs).insert(WorkoutLogsCompanion.insert(
        date: DateTime.now(),
        templateName: 'Push Day',
        durationMinutes: durationMinutes,
        totalVolumeKg: totalVolume,
        caloriesBurned: drift.Value(durationMinutes * 5.0),
      ));
      
      for (var s in setsToInsert) {
        await db.into(db.workoutSets).insert(s.copyWith(workoutLogId: drift.Value(logId)));
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout saved successfully!')),
      );
      setState(() {
        _resetWorkout();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: !_isWorkoutActive ? _Fab3D(onTap: _startWorkout) : null,
      body: Stack(
        children: [
          // Radial background gradient
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.9),
                  radius: 1.0,
                  colors: [Color(0xFF1E1E3E), AppColors.background],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context),
                const SizedBox(height: 16),
                _buildDailyRoutines(context),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      ..._activeExercises.asMap().entries.map((e) => _ExerciseCard(
                            exercise: e.value,
                            onAddSet: () => _openAddSetSheet(e.key),
                          )),
                      const SizedBox(height: 16),
                      if (!_isWorkoutActive) const _MotivationalBento(),
                      if (_isWorkoutActive)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: _FinishButton3D(onTap: _finishWorkout),
                        ),
                      const SizedBox(height: 100), // padding for FAB
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const ProfileAvatar(),
              const SizedBox(width: 10),
              Text(
                'Gym',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      shadows: const [
                        Shadow(color: Color(0x80C4C0FF), blurRadius: 20),
                      ],
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRoutines(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: dummy.dummyTemplates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final template = dummy.dummyTemplates[index];
          final isActive = template.name == 'Push Day';
          if (isActive) {
            return _ActiveChip3D(label: template.name);
          }
          return _Chip3D(label: template.name);
        },
      ),
    );
  }
}

class _ActiveChip3D extends StatelessWidget {
  final String label;
  const _ActiveChip3D({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.inversePrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x33FFFFFF),
            blurRadius: 4,
            offset: Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _Chip3D extends StatelessWidget {
  final String label;
  const _Chip3D({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xB3292839), Color(0xE61E1E2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 32,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final dummy.Exercise exercise;
  final VoidCallback onAddSet;

  const _ExerciseCard({
    required this.exercise,
    required this.onAddSet,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.onSurface,
                  ),
            ),
            const SizedBox(height: 16),
            ...exercise.sets.asMap().entries.map((e) {
              final index = e.key + 1;
              final set = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Set $index',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${set.weight.round()}kg × ${set.reps}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.onSurface,
                              ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.check_circle,
                          color: set.completed
                              ? AppColors.secondary
                              : AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                          size: 24,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onAddSet,
              child: CustomPaint(
                painter: _DashedRectPainter(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  child: Text(
                    'Add Set',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double dashWidth = 6.0;
    const double dashSpace = 4.0;
    final paint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw top
    double startX = 12.0; // Avoid corners
    while (startX < size.width - 12) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
    // Draw bottom
    startX = 12.0;
    while (startX < size.width - 12) {
      canvas.drawLine(
          Offset(startX, size.height), Offset(startX + dashWidth, size.height), paint);
      startX += dashWidth + dashSpace;
    }
    // Draw left
    double startY = 12.0;
    while (startY < size.height - 12) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
    // Draw right
    startY = 12.0;
    while (startY < size.height - 12) {
      canvas.drawLine(
          Offset(size.width, startY), Offset(size.width, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
    
    // Simple corners
    canvas.drawArc(
        const Rect.fromLTWH(0, 0, 12, 12), 3.14, 1.57, false, paint);
    canvas.drawArc(
        Rect.fromLTWH(size.width - 12, 0, 12, 12), -1.57, 1.57, false, paint);
    canvas.drawArc(
        Rect.fromLTWH(size.width - 12, size.height - 12, 12, 12), 0, 1.57, false, paint);
    canvas.drawArc(
        Rect.fromLTWH(0, size.height - 12, 12, 12), 1.57, 1.57, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MotivationalBento extends StatelessWidget {
  const _MotivationalBento();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_fire_department, color: AppColors.secondary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Keep Pushing!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.onSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'You are 2 workouts away from your weekly goal.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Fab3D extends StatefulWidget {
  final VoidCallback onTap;
  const _Fab3D({required this.onTap});

  @override
  State<_Fab3D> createState() => _Fab3DState();
}

class _Fab3DState extends State<_Fab3D> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD4D1FF), AppColors.primary, Color(0xFFB3AFF2)],
            stops: [0.0, 0.5, 1.0],
          ),
          boxShadow: _pressed
              ? [
                  const BoxShadow(
                    color: Color(0xFF7E79DF),
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Color(0xFF7E79DF),
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: AppColors.onPrimary,
          size: 32,
        ),
      ),
    );
  }
}

class _AddSetSheet3D extends StatefulWidget {
  final void Function(double weight, int reps) onAddSet;
  const _AddSetSheet3D({required this.onAddSet});

  @override
  State<_AddSetSheet3D> createState() => _AddSetSheet3DState();
}

class _AddSetSheet3DState extends State<_AddSetSheet3D> {
  double _weight = 60;
  int _reps = 10;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 40,
            offset: Offset(0, -10),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grabber
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Set',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.onSurface,
                    ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSlider(
            context: context,
            label: 'Weight (kg)',
            value: _weight,
            min: 0,
            max: 200,
            onChanged: (v) => setState(() => _weight = v),
          ),
          const SizedBox(height: 24),
          _buildSlider(
            context: context,
            label: 'Reps',
            value: _reps.toDouble(),
            min: 1,
            max: 30,
            isReps: true,
            onChanged: (v) => setState(() => _reps = v.toInt()),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.onSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () {
                widget.onAddSet(_weight, _reps);
                Navigator.pop(context);
              },
              child: const Text(
                'Add Set',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required BuildContext context,
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    bool isReps = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            Text(
              isReps ? '${value.toInt()}' : '${value.round()} kg',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            activeTrackColor: AppColors.secondary,
            inactiveTrackColor: AppColors.surfaceContainerLowest,
            thumbColor: AppColors.secondary,
            overlayColor: AppColors.secondary.withValues(alpha: 0.12),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: isReps ? (max - min).toInt() : null,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _FinishButton3D extends StatefulWidget {
  final VoidCallback onTap;
  const _FinishButton3D({required this.onTap});

  @override
  State<_FinishButton3D> createState() => _FinishButton3DState();
}

class _FinishButton3DState extends State<_FinishButton3D> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB4AB), AppColors.error, Color(0xFF93000A)],
            stops: [0.0, 0.5, 1.0],
          ),
          boxShadow: _pressed
              ? [
                  const BoxShadow(
                    color: Color(0xFF93000A),
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Color(0xFF93000A),
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 8),
                  ),
                ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: const Center(
          child: Text(
            'Selesaikan Latihan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
