import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' hide Column;
import '../../theme.dart';
import '../../shared/widgets/calorie_ring.dart';
import 'dashboard_dummy.dart';
import 'dart:io';
import '../../data/database.dart';
import '../weather/weather_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../profile/profile_provider.dart';
import '../../widgets/profile_avatar.dart';
import '../../data/sync_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sync log notification removed as per request


    final profile = ref.watch(profileProvider);

    // Calculate Calorie Goal (Mifflin-St Jeor)
    double bmr;
    if (profile.gender == 'Female') {
      bmr = (10 * profile.weight) + (6.25 * profile.height) - (5 * profile.age) - 161;
    } else {
      bmr = (10 * profile.weight) + (6.25 * profile.height) - (5 * profile.age) + 5;
    }

    double activityMultiplier = 1.2;
    switch (profile.activityLevel) {
      case 'Lightly Active': activityMultiplier = 1.375; break;
      case 'Moderately Active': activityMultiplier = 1.55; break;
      case 'Very Active': activityMultiplier = 1.725; break;
      default: activityMultiplier = 1.2;
    }

    double tdee = bmr * activityMultiplier;
    if (profile.mainGoal == 'Lose Weight') {
      tdee -= 500;
    } else if (profile.mainGoal == 'Build Muscle') {
      tdee += 500;
    }
    int targetCalories = tdee.round();

    final todayStr = DateFormat('EEEE, d MMMM').format(DateTime.now());
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<FoodLog>>(
        stream: (db.select(db.foodLogs)
              ..where((t) => t.date.isBetweenValues(startOfDay, endOfDay))
              ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
            .watch(),
        builder: (context, foodSnapshot) {
          return StreamBuilder<List<ActivityLog>>(
            stream: (db.select(db.activityLogs)
                  ..where((t) => t.date.isBetweenValues(startOfDay, endOfDay))
                  ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
                .watch(),
            builder: (context, activitySnapshot) {
              return StreamBuilder<List<WorkoutLog>>(
                stream: (db.select(db.workoutLogs)
                      ..where((t) => t.date.isBetweenValues(startOfDay, endOfDay))
                      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
                    .watch(),
                builder: (context, workoutSnapshot) {
                  final foods = foodSnapshot.data ?? [];
                  final activities = activitySnapshot.data ?? [];
                  final workouts = workoutSnapshot.data ?? [];

              int caloriesIn = 0;
              for (final f in foods) {
                caloriesIn += f.calories.toInt();
              }

                  int caloriesOut = 0;
                  for (final a in activities) {
                    caloriesOut += a.caloriesBurned.toInt();
                  }
                  for (final w in workouts) {
                    caloriesOut += w.caloriesBurned.toInt();
                  }

              final meals = foods.map((f) => MealItem(
                    name: f.foodName,
                    time: DateFormat('HH:mm').format(f.date),
                    calories: f.calories.toInt(),
                  )).toList();

                  final activityItems = activities.map((a) {
                    String label = 'Activity';
                    if (a.type == 'run') label = 'Running';
                    if (a.type == 'bike') label = 'Cycling';
                    if (a.type == 'gym') label = 'Weight Training';

                    String detail = '${a.durationSeconds ~/ 60} min';
                    if (a.distanceMeters > 0) {
                      detail = '${(a.distanceMeters / 1000).toStringAsFixed(1)} km - $detail';
                    }

                    return ActivityItem(
                      type: a.type,
                      label: label,
                      detail: detail,
                      caloriesBurned: a.caloriesBurned.toInt(),
                    );
                  }).toList();

                  final workoutItems = workouts.map((w) => ActivityItem(
                    type: 'gym',
                    label: w.templateName,
                    detail: '${w.durationMinutes} min • ${w.totalVolumeKg.toInt()} kg',
                    caloriesBurned: w.caloriesBurned.toInt(),
                  )).toList();

                  final summary = DailySummary(
                    caloriesIn: caloriesIn,
                    caloriesOut: caloriesOut,
                    calorieGoal: targetCalories,
                    activities: [...activityItems, ...workoutItems],
                    meals: meals,
                  );

              return Stack(
                children: [
                  // Radial background gradient (3D depth effect)
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0, -0.9),
                          radius: 1.0,
                          colors: [
                            Color(0xFF1E1E3E),
                            AppColors.background,
                          ],
                          stops: [0.0, 1.0],
                        ),
                      ),
                    ),
                  ),

          CustomScrollView(
            slivers: [
              // ── Top App Bar ──────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                expandedHeight: 0,
                leadingWidth: 200,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Row(
                    children: [
                      // Avatar with primary border
                      const ProfileAvatar(),
                      const SizedBox(width: 10),
                      Text(
                        'FitFad',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              shadows: const [
                                Shadow(
                                  color: Color(0x80C4C0FF),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        GoRouter.of(context).push('/profile');
                      },
                      icon: const Icon(
                        Icons.person_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              // ── Scrollable Content ───────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Greeting & Weather Inline
                    WeatherCard(
                      greeting: _buildGreeting(context, todayStr, profile.name),
                    ),
                    const SizedBox(height: 28),

                    // Calorie Ring + Pill Stats
                    _buildCalorieSection(context, summary),
                    const SizedBox(height: 28),



                    // Activity
                    _buildSectionHeader(context, 'Activity', 'View All', Icons.chevron_right, onTap: () {
                      GoRouter.of(context).go('/activity');
                    }),
                    const SizedBox(height: 12),
                    ...summary.activities.map((a) => _ActivityCard(item: a)),
                    const SizedBox(height: 28),

                    // Makanan
                    _buildSectionHeader(context, 'Foods', 'Add', Icons.add, onTap: () {
                      GoRouter.of(context).go('/food');
                    }),
                    const SizedBox(height: 12),
                    _MealList(meals: summary.meals),
                  ]),
                ),
              ),
            ],
          ),

          // ── FAB 3D ───────────────────────────────────────────────────
          Positioned(
            bottom: 96,
            right: 20,
            child: _Fab3D(onTap: () {
              GoRouter.of(context).go('/food');
            }),
          ),
        ],
      );
    },
  );
},
);
},
),
    );
  }

  Widget _buildGreeting(BuildContext context, String todayStr, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, $name! 👋',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.onSurface,
                shadows: const [
                  Shadow(
                    color: Color(0x80C4C0FF),
                    blurRadius: 20,
                  ),
                ],
              ),
        ),
        const SizedBox(height: 4),
        Text(
          todayStr,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
              ),
        ),
      ],
    );
  }

  Widget _buildCalorieSection(BuildContext context, DailySummary summary) {
    return Column(
      children: [
        Center(
          child: CalorieRing(
            consumed: summary.caloriesIn,
            burned: summary.caloriesOut,
            goal: summary.calorieGoal,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _Pill3D(
                label: 'Intake',
                value: summary.caloriesIn,
                color: AppColors.secondary,
                borderColor: const Color(0x8001CAA8),
                topBorderColor: const Color(0xCC01CAA8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _Pill3D(
                label: 'Outtake',
                value: summary.caloriesOut,
                color: AppColors.tertiary,
                borderColor: const Color(0x80F1589A),
                topBorderColor: const Color(0xCCF1589A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, String action, IconData icon, {VoidCallback? onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon == Icons.add) ...[
                Icon(icon, color: AppColors.primary, size: 16),
                const SizedBox(width: 4),
              ],
              Text(
                action,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                    ),
              ),
              if (icon != Icons.add) ...[
                const SizedBox(width: 4),
                Icon(icon, color: AppColors.primary, size: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── 3D FAB ────────────────────────────────────────────────────────────────────

class _Fab3D extends StatefulWidget {
  final VoidCallback? onTap;

  const _Fab3D({this.onTap});

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
          Icons.add,
          color: AppColors.onPrimary,
          size: 28,
          weight: 600,
        ),
      ),
    );
  }
}

// ── 3D Pill Stat ──────────────────────────────────────────────────────────────

class _Pill3D extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final Color borderColor;
  final Color topBorderColor;

  const _Pill3D({
    required this.label,
    required this.value,
    required this.color,
    required this.borderColor,
    required this.topBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.15),
          ],
        ),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.05),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
          const BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color.withValues(alpha: 0.85),
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            '$value kcal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Glass Activity Card ───────────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  final ActivityItem item;
  const _ActivityCard({required this.item});

  IconData get _icon {
    switch (item.type) {
      case 'run':
        return Icons.directions_run;
      case 'bike':
        return Icons.directions_bike;
      default:
        return Icons.fitness_center;
    }
  }

  Color get _iconColor =>
      item.type == 'gym' ? AppColors.tertiary : AppColors.secondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xB3292839),
            Color(0xE61E1E2E),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
        boxShadow: [
          const BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 32,
            spreadRadius: 0,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.03),
            blurRadius: 0,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container with colored border
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _iconColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(_icon, color: _iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.detail,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '${item.caloriesBurned} kcal',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: _iconColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Meal List (Glass) ─────────────────────────────────────────────────────────

class _MealList extends StatelessWidget {
  final List<MealItem> meals;
  const _MealList({required this.meals});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xB3292839),
            Color(0xE61E1E2E),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 32,
            spreadRadius: 0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < meals.length; i++) ...[
            _MealRow(item: meals[i]),
            if (i < meals.length - 1)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Colors.white.withValues(alpha: 0.06),
              ),
          ],
        ],
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  final MealItem item;
  const _MealRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              item.time,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Text(
            '${item.calories} kcal',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
