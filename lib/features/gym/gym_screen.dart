import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/database.dart';
import '../../data/muscle_activation_service.dart';
import '../../theme.dart';
import '../../widgets/muscle_heatmap_widget.dart';
import '../../widgets/profile_avatar.dart';
import 'gym_service.dart';

class GymScreen extends StatefulWidget {
  const GymScreen({super.key});

  @override
  State<GymScreen> createState() => _GymScreenState();
}

class _GymScreenState extends State<GymScreen> with TickerProviderStateMixin {
  final _svc = GymService.instance;

  @override
  void initState() {
    super.initState();
    _svc.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _svc.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  String _formatRestTime(int seconds) {
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient
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

          // Main content based on state
          if (_svc.state == GymWorkoutState.idle)
            _buildIdleView()
          else if (_svc.state == GymWorkoutState.active || _svc.state == GymWorkoutState.paused)
            _buildActiveWorkoutView(),

          // Countdown overlay
          if (_svc.state == GymWorkoutState.countdown)
            _buildCountdownOverlay(),

          // Rest timer overlay
          if (_svc.isRestActive &&
              (_svc.state == GymWorkoutState.active || _svc.state == GymWorkoutState.paused))
            _buildRestTimerOverlay(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // IDLE VIEW — History List + Start Button
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildIdleView() {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppBar(),
          const SizedBox(height: 24),
          // Start Workout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _StartWorkoutButton(onTap: () => _svc.beginCountdown()),
          ),
          const SizedBox(height: 28),
          // Session History
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Workout History',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<List<WorkoutLog>>(
              stream: _svc.watchHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                final logs = snapshot.data ?? [];
                if (logs.isEmpty) {
                  return _buildEmptyHistory();
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: logs.length + 1, // +1 for bottom padding
                  itemBuilder: (context, index) {
                    if (index == logs.length) return const SizedBox(height: 32);
                    return _WorkoutHistoryCard(
                      log: logs[index],
                      onTap: () => _showSessionDetail(logs[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fitness_center, size: 64, color: AppColors.onSurfaceVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'No workouts yet',
            style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button above to start your first workout!',
            style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.3), fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTIVE WORKOUT VIEW
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildActiveWorkoutView() {
    final isPaused = _svc.state == GymWorkoutState.paused;
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // Timer bar at top
          _buildTimerBar(isPaused),
          // Exercise list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 8),
                // Exercise cards
                ..._svc.exercises.asMap().entries.map((entry) => _ActiveExerciseCard(
                      exerciseIndex: entry.key,
                      exercise: entry.value,
                      svc: _svc,
                    )),
                // Add Exercise button
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: GestureDetector(
                    onTap: _showAddExerciseSheet,
                    child: CustomPaint(
                      painter: _DashedRectPainter(color: AppColors.primary),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded, color: AppColors.primary, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'Add Exercise',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Finish button
                _FinishButton3D(onTap: _handleFinishWorkout),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBar(bool isPaused) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceContainerHigh.withValues(alpha: 0.9),
            AppColors.background.withValues(alpha: 0.5),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // Back / Cancel
          GestureDetector(
            onTap: () => _showCancelWorkoutDialog(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(Icons.close, color: AppColors.error, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          // Timer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _formatDuration(_svc.duration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                  ),
                ),
                if (isPaused)
                  Text(
                    'PAUSED',
                    style: TextStyle(
                      color: AppColors.secondary.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Pause/Resume button
          GestureDetector(
            onTap: isPaused ? _svc.resumeWorkout : _svc.pauseWorkout,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isPaused ? AppColors.secondary : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Icon(
                isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                color: isPaused ? AppColors.onSecondary : Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // COUNTDOWN OVERLAY
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildCountdownOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.85),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '🏋️',
                style: TextStyle(fontSize: 56),
              ),
              const SizedBox(height: 16),
              Text(
                'GET READY',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: Tween<double>(begin: 1.5, end: 1.0).animate(
                      CurvedAnimation(parent: animation, curve: Curves.elasticOut),
                    ),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Text(
                  '${_svc.countdownValue}',
                  key: ValueKey(_svc.countdownValue),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 120,
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(color: Color(0x80C4C0FF), blurRadius: 40),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Bersiap...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 48),
              TextButton(
                onPressed: _svc.cancelCountdown,
                child: Text(
                  'BATAL',
                  style: TextStyle(
                    color: AppColors.error.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REST TIMER OVERLAY
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildRestTimerOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xE61A1A2A),
                  AppColors.surfaceContainerHigh.withValues(alpha: 0.95),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border(
                top: BorderSide(color: AppColors.secondary.withValues(alpha: 0.3), width: 1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_outlined, color: AppColors.secondary, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'REST TIME',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatRestTime(_svc.restSecondsRemaining),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _RestAdjustButton(
                      label: '-30s',
                      onTap: () => _svc.adjustRestTime(-30),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: _svc.skipRest,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.secondary, Color(0xFF4ECDC4)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          'SKIP',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _RestAdjustButton(
                      label: '+30s',
                      onTap: () => _svc.adjustRestTime(30),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // APP BAR
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildAppBar() {
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
          // Rest time settings
          GestureDetector(
            onTap: _showRestTimeSettings,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: const Icon(Icons.settings_outlined, color: AppColors.onSurfaceVariant, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DIALOGS & SHEETS
  // ═══════════════════════════════════════════════════════════════════════════
  void _showAddExerciseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExerciseSearchSheet(
        onExerciseSelected: (exData) {
          _svc.addExercise(exData.name, exData.primaryMuscles);
        },
      ),
    );
  }

  String _getDefaultWorkoutName() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Morning Workout';
    } else if (hour >= 12 && hour < 17) {
      return 'Afternoon Workout';
    } else if (hour >= 17 && hour < 21) {
      return 'Evening Workout';
    } else {
      return 'Night Workout';
    }
  }

  Future<void> _handleFinishWorkout() async {
    final defaultName = _getDefaultWorkoutName();
    final nameController = TextEditingController(text: defaultName);

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        title: const Row(
          children: [
            Text('🏁 ', style: TextStyle(fontSize: 24)),
            Text(
              'Finish Workout',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Give your workout session a name:',
              style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Workout Name',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Finish', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final summary = await _svc.finishWorkout(workoutName: nameController.text);
      if (summary != null && mounted) {
        _showWorkoutSummary(summary);
      }
    }
  }

  void _showWorkoutSummary(WorkoutSummaryData summary) async {
    // Build synthetic WorkoutSets from the summary exercises to compute muscle activation
    final syntheticSets = <WorkoutSet>[];
    int fakeId = 0;
    for (final ex in summary.exercises) {
      for (final s in ex.sets.where((s) => s.completed)) {
        syntheticSets.add(WorkoutSet(
          id: fakeId++,
          workoutLogId: 0,
          exerciseName: ex.name,
          reps: s.reps,
          weightKg: s.weight,
        ));
      }
    }
    final muscleData = await MuscleActivationService.instance.computeForSession(syntheticSets);
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏋️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text(
              'Workout Summary',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('EEE, dd MMM yyyy • HH:mm').format(summary.date),
              style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 13),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Stats grid
              Row(
                children: [
                  Expanded(child: _SummaryStatTile(icon: Icons.timer_outlined, label: 'Duration', value: _formatDuration(summary.duration))),
                  const SizedBox(width: 8),
                  Expanded(child: _SummaryStatTile(icon: Icons.fitness_center, label: 'Volume', value: '${summary.totalVolume.toStringAsFixed(0)} kg')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _SummaryStatTile(icon: Icons.format_list_numbered, label: 'Exercises', value: '${summary.exerciseCount}')),
                  const SizedBox(width: 8),
                  Expanded(child: _SummaryStatTile(icon: Icons.repeat, label: 'Sets', value: '${summary.totalSets}')),
                ],
              ),
              const SizedBox(height: 8),
              _SummaryStatTile(
                icon: Icons.local_fire_department_outlined,
                label: 'Calories Burned',
                value: '${summary.caloriesBurned.toStringAsFixed(0)} kcal',
                wide: true,
              ),
              const SizedBox(height: 16),
              // Muscle heatmap
              if (muscleData.hasData)
                MuscleHeatmapWidget(
                  activationData: muscleData,
                  height: 200,
                  showTitle: true,
                ),
              if (muscleData.hasData) const SizedBox(height: 16),
              // Exercise breakdown
              if (summary.exercises.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Exercises',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                ...summary.exercises.where((e) => e.sets.any((s) => s.completed)).map(
                  (ex) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ex.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        ...ex.sets.where((s) => s.completed).toList().asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'Set ${entry.key + 1}: ${entry.value.weight.toStringAsFixed(1)} kg × ${entry.value.reps} reps',
                              style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSessionDetail(WorkoutLog log) async {
    final sets = await _svc.getSetsForWorkout(log.id);
    if (!mounted) return;

    // Compute muscle activation data for this session
    final muscleData = await MuscleActivationService.instance.computeForSession(sets);
    if (!mounted) return;

    // Group sets by exercise name
    final Map<String, List<WorkoutSet>> grouped = {};
    for (final s in sets) {
      grouped.putIfAbsent(s.exerciseName, () => []).add(s);
    }

    final endTime = log.date;
    final startTime = endTime.subtract(Duration(minutes: log.durationMinutes));
    final timeStr = '${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grabber
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            // Title
            const Text('🏋️', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 8),
            Text(
              log.templateName,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${DateFormat('EEE, dd MMM yyyy').format(log.date)} • $timeStr (${log.durationMinutes} min)',
              style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 13),
            ),
            const SizedBox(height: 16),
            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildDetailStat(Icons.timer_outlined, '${log.durationMinutes} min'),
                  _buildDetailStat(Icons.fitness_center, '${log.totalVolumeKg.toStringAsFixed(0)} kg'),
                  _buildDetailStat(Icons.local_fire_department_outlined, '${log.caloriesBurned.toStringAsFixed(0)} kcal'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Muscle heatmap
            if (muscleData.hasData)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MuscleHeatmapWidget(
                  activationData: muscleData,
                  height: 220,
                  showTitle: true,
                ),
              ),
            if (muscleData.hasData) const SizedBox(height: 16),
            // Exercise list
            if (grouped.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text('No exercises recorded', style: TextStyle(color: AppColors.onSurfaceVariant)),
              )
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shrinkWrap: true,
                  children: [
                    ...grouped.entries.map((entry) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                              const SizedBox(height: 8),
                              ...entry.value.asMap().entries.map((setEntry) => Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${setEntry.key + 1}',
                                            style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '${setEntry.value.weightKg.toStringAsFixed(1)} kg × ${setEntry.value.reps} reps',
                                          style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.8), fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailStat(IconData icon, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.secondary, size: 18),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _showCancelWorkoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        title: const Text('Cancel Workout?', style: TextStyle(color: Colors.white, fontSize: 18)),
        content: const Text(
          'Your current workout progress will be lost.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue', style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _svc.cancelCountdown(); // Reset to idle
              _svc.skipRest();
            },
            child: const Text('Cancel Workout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showRestTimeSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _RestTimeSettingsSheet(
        currentDefault: _svc.defaultRestTime,
        onChanged: (val) => _svc.setDefaultRestTime(val),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SUB-WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

// ── Start Workout Button ────────────────────────────────────────────────────
class _StartWorkoutButton extends StatefulWidget {
  final VoidCallback onTap;
  const _StartWorkoutButton({required this.onTap});

  @override
  State<_StartWorkoutButton> createState() => _StartWorkoutButtonState();
}

class _StartWorkoutButtonState extends State<_StartWorkoutButton> {
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
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD4D1FF), AppColors.primary, Color(0xFFB3AFF2)],
            stops: [0.0, 0.5, 1.0],
          ),
          boxShadow: _pressed
              ? [
                  const BoxShadow(color: Color(0xFF7E79DF), offset: Offset(0, 2), blurRadius: 0),
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4)),
                ]
              : [
                  const BoxShadow(color: Color(0xFF7E79DF), offset: Offset(0, 4), blurRadius: 0),
                  BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
                ],
          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, color: AppColors.onPrimary, size: 28),
            const SizedBox(width: 8),
            Text(
              'Start Workout',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Workout History Card ────────────────────────────────────────────────────
class _WorkoutHistoryCard extends StatelessWidget {
  final WorkoutLog log;
  final VoidCallback onTap;

  const _WorkoutHistoryCard({required this.log, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final endTime = log.date;
    final startTime = endTime.subtract(Duration(minutes: log.durationMinutes));
    final timeStr = '${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xB3292839), Color(0xE61E1E2E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
          boxShadow: const [
            BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.fitness_center, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.templateName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('EEE, dd MMM yyyy').format(log.date)} • $timeStr (${log.durationMinutes} min)',
                    style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 12),
                  ),
                ],
              ),
            ),
            // Stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${log.durationMinutes} min',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  '${log.caloriesBurned.toStringAsFixed(0)} kcal',
                  style: TextStyle(color: AppColors.secondary.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Active Exercise Card ────────────────────────────────────────────────────
class _ActiveExerciseCard extends StatelessWidget {
  final int exerciseIndex;
  final GymExercise exercise;
  final GymService svc;

  const _ActiveExerciseCard({
    required this.exerciseIndex,
    required this.exercise,
    required this.svc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xB3292839), Color(0xE61E1E2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x4D000000), blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.fitness_center, color: AppColors.secondary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      Text(
                        exercise.bodyPart,
                        style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => svc.removeExercise(exerciseIndex),
                  child: Icon(Icons.close, color: AppColors.onSurfaceVariant.withValues(alpha: 0.4), size: 20),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Column headers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text('SET', style: _headerStyle()),
                  ),
                  Expanded(child: Text('KG', style: _headerStyle(), textAlign: TextAlign.center)),
                  Expanded(child: Text('REPS', style: _headerStyle(), textAlign: TextAlign.center)),
                  SizedBox(width: 44, child: Text('', style: _headerStyle())),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Set rows
            ...exercise.sets.asMap().entries.map(
              (entry) => _SetRow(
                exerciseIndex: exerciseIndex,
                setIndex: entry.key,
                set: entry.value,
                svc: svc,
                onRemove: () => svc.removeSet(exerciseIndex, entry.key),
              ),
            ),
            const SizedBox(height: 8),
            // Add Set button
            GestureDetector(
              onTap: () => svc.addSet(exerciseIndex),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: AppColors.secondary.withValues(alpha: 0.8), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Add Set',
                      style: TextStyle(
                        color: AppColors.secondary.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _headerStyle() {
    return TextStyle(
      color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1,
    );
  }
}

// ── Set Row (inline editing) ────────────────────────────────────────────────
class _SetRow extends StatefulWidget {
  final int exerciseIndex;
  final int setIndex;
  final GymSet set;
  final GymService svc;
  final VoidCallback onRemove;

  const _SetRow({
    required this.exerciseIndex,
    required this.setIndex,
    required this.set,
    required this.svc,
    required this.onRemove,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late TextEditingController _weightCtrl;
  late TextEditingController _repsCtrl;

  @override
  void initState() {
    super.initState();
    _weightCtrl = TextEditingController(
      text: widget.set.weight > 0 ? widget.set.weight.toStringAsFixed(1) : '',
    );
    _repsCtrl = TextEditingController(
      text: widget.set.reps > 0 ? widget.set.reps.toString() : '',
    );
  }

  @override
  void didUpdateWidget(covariant _SetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controllers if the set data changed externally (e.g. new set added with pre-filled values)
    if (oldWidget.set != widget.set) {
      final newWeightText = widget.set.weight > 0 ? widget.set.weight.toStringAsFixed(1) : '';
      final newRepsText = widget.set.reps > 0 ? widget.set.reps.toString() : '';
      if (_weightCtrl.text != newWeightText && !_weightCtrl.text.isNotEmpty) {
        _weightCtrl.text = newWeightText;
      }
      if (_repsCtrl.text != newRepsText && !_repsCtrl.text.isNotEmpty) {
        _repsCtrl.text = newRepsText;
      }
    }
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.set.completed;
    return Dismissible(
      key: ValueKey('${widget.exerciseIndex}_${widget.setIndex}_${widget.set.hashCode}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onRemove(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.secondary.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Set number
            SizedBox(
              width: 36,
              child: Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.secondary.withValues(alpha: 0.2)
                      : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.setIndex + 1}',
                  style: TextStyle(
                    color: isCompleted ? AppColors.secondary : AppColors.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            // Weight input
            Expanded(
              child: _buildInputField(
                controller: _weightCtrl,
                hint: 'kg',
                enabled: !isCompleted,
                onChanged: (val) {
                  final w = double.tryParse(val) ?? 0;
                  widget.svc.updateSet(widget.exerciseIndex, widget.setIndex, weight: w);
                },
              ),
            ),
            const SizedBox(width: 8),
            // Reps input
            Expanded(
              child: _buildInputField(
                controller: _repsCtrl,
                hint: 'reps',
                enabled: !isCompleted,
                isInt: true,
                onChanged: (val) {
                  final r = int.tryParse(val) ?? 0;
                  widget.svc.updateSet(widget.exerciseIndex, widget.setIndex, reps: r);
                },
              ),
            ),
            const SizedBox(width: 4),
            // Complete button
            GestureDetector(
              onTap: () {
                // Sync current input values before completing
                final w = double.tryParse(_weightCtrl.text) ?? 0;
                final r = int.tryParse(_repsCtrl.text) ?? 0;
                widget.svc.updateSet(widget.exerciseIndex, widget.setIndex, weight: w, reps: r);
                widget.svc.completeSet(widget.exerciseIndex, widget.setIndex);
              },
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.secondary
                      : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.secondary
                        : AppColors.outlineVariant.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: isCompleted ? Colors.white : AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
    bool enabled = true,
    bool isInt = false,
  }) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: enabled ? AppColors.surfaceContainerHigh : AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.numberWithOptions(decimal: !isInt),
        style: TextStyle(
          color: enabled ? Colors.white : Colors.white.withValues(alpha: 0.5),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.3), fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          isDense: true,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

// ── Dashed Rect Painter ─────────────────────────────────────────────────────
class _DashedRectPainter extends CustomPainter {
  final Color color;
  _DashedRectPainter({this.color = AppColors.primary});

  @override
  void paint(Canvas canvas, Size size) {
    const double dashWidth = 6.0;
    const double dashSpace = 4.0;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    double startX = 12.0;
    while (startX < size.width - 12) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
    startX = 12.0;
    while (startX < size.width - 12) {
      canvas.drawLine(Offset(startX, size.height), Offset(startX + dashWidth, size.height), paint);
      startX += dashWidth + dashSpace;
    }
    double startY = 12.0;
    while (startY < size.height - 12) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
    startY = 12.0;
    while (startY < size.height - 12) {
      canvas.drawLine(Offset(size.width, startY), Offset(size.width, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
    canvas.drawArc(const Rect.fromLTWH(0, 0, 12, 12), 3.14, 1.57, false, paint);
    canvas.drawArc(Rect.fromLTWH(size.width - 12, 0, 12, 12), -1.57, 1.57, false, paint);
    canvas.drawArc(Rect.fromLTWH(size.width - 12, size.height - 12, 12, 12), 0, 1.57, false, paint);
    canvas.drawArc(Rect.fromLTWH(0, size.height - 12, 12, 12), 1.57, 1.57, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Finish Button 3D ────────────────────────────────────────────────────────
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
              ? [const BoxShadow(color: Color(0xFF93000A), offset: Offset(0, 2), blurRadius: 0)]
              : [
                  const BoxShadow(color: Color(0xFF93000A), offset: Offset(0, 4), blurRadius: 0),
                  BoxShadow(color: AppColors.error.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 8)),
                ],
          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
        ),
        child: const Center(
          child: Text(
            'Selesaikan Latihan',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// ── Rest Adjust Button ──────────────────────────────────────────────────────
class _RestAdjustButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _RestAdjustButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }
}

// ── Summary Stat Tile ───────────────────────────────────────────────────────
class _SummaryStatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool wide;

  const _SummaryStatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Exercise Search Sheet ───────────────────────────────────────────────────
class _ExerciseSearchSheet extends StatefulWidget {
  final void Function(ExerciseDictionaryData) onExerciseSelected;
  const _ExerciseSearchSheet({required this.onExerciseSelected});

  @override
  State<_ExerciseSearchSheet> createState() => _ExerciseSearchSheetState();
}

class _ExerciseSearchSheetState extends State<_ExerciseSearchSheet> {
  String _searchQuery = '';
  String _selectedBodyPart = 'all';
  List<ExerciseDictionaryData> _results = [];
  bool _isLoading = true;

  static const _bodyParts = [
    'all', 'chest', 'back', 'shoulders', 'upper arms', 'lower arms',
    'upper legs', 'lower legs', 'waist', 'cardio', 'neck',
  ];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    final query = db.select(db.exerciseDictionary);
    if (_searchQuery.isNotEmpty) {
      query.where((t) => t.name.like('%$_searchQuery%'));
    }
    if (_selectedBodyPart != 'all') {
      query.where((t) => t.primaryMuscles.like('%$_selectedBodyPart%'));
    }
    query.limit(50);
    final results = await query.get();
    if (mounted) {
      setState(() {
        _results = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Grabber
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.search, color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Add Exercise',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search exercise (e.g. Bench Press)',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                filled: true,
                fillColor: AppColors.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
              onChanged: (val) {
                _searchQuery = val;
                _loadExercises();
              },
            ),
          ),
          const SizedBox(height: 10),
          // Body part filter chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _bodyParts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final bp = _bodyParts[index];
                final isSelected = bp == _selectedBodyPart;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedBodyPart = bp);
                    _loadExercises();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Text(
                      bp == 'all' ? 'All' : bp[0].toUpperCase() + bp.substring(1),
                      style: TextStyle(
                        color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _results.isEmpty
                    ? Center(
                        child: Text(
                          'No exercises found',
                          style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final ex = _results[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                            title: Text(
                              ex.name,
                              style: const TextStyle(color: AppColors.onSurface, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              '${ex.primaryMuscles}${ex.equipment != null ? ' • ${ex.equipment}' : ''}',
                              style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 12),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
                            ),
                            onTap: () {
                              widget.onExerciseSelected(ex);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ── Rest Time Settings Sheet ────────────────────────────────────────────────
class _RestTimeSettingsSheet extends StatefulWidget {
  final int currentDefault;
  final ValueChanged<int> onChanged;
  const _RestTimeSettingsSheet({required this.currentDefault, required this.onChanged});

  @override
  State<_RestTimeSettingsSheet> createState() => _RestTimeSettingsSheetState();
}

class _RestTimeSettingsSheetState extends State<_RestTimeSettingsSheet> {
  late int _value;

  static const _presets = [30, 60, 90, 120, 180, 300];

  @override
  void initState() {
    super.initState();
    _value = widget.currentDefault;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const Text(
            'Default Rest Time',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose how long the rest timer counts down between sets',
            style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _presets.map((seconds) {
              final isSelected = seconds == _value;
              final label = seconds >= 60
                  ? '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}'
                  : '0:${seconds.toString().padLeft(2, '0')}';
              return GestureDetector(
                onTap: () {
                  setState(() => _value = seconds);
                  widget.onChanged(seconds);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
