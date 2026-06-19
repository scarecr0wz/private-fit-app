import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme.dart';
import '../../shared/widgets/calorie_ring.dart';
import 'dashboard_dummy.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const summary = dummySummary;
    final today = DateFormat('EEEE, d MMMM', 'id_ID').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
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
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceContainerHigh,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'FitApp',
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
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_outlined,
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
                    // Greeting
                    _buildGreeting(context, today),
                    const SizedBox(height: 28),

                    // Calorie Ring + Pill Stats
                    _buildCalorieSection(context, summary),
                    const SizedBox(height: 28),

                    // Aktivitas
                    _buildSectionHeader(context, 'Aktivitas', 'Lihat Semua'),
                    const SizedBox(height: 12),
                    ...summary.activities.map((a) => _ActivityCard(item: a)),
                    const SizedBox(height: 28),

                    // Makanan
                    _buildSectionHeader(context, 'Makanan', 'Tambah'),
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
            child: _Fab3D(),
          ),
        ],
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, String today) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo, User! 👋',
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
          today,
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
                label: 'Masuk',
                value: summary.caloriesIn,
                color: AppColors.secondary,
                borderColor: const Color(0x8001CAA8),
                topBorderColor: const Color(0xCC01CAA8),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _Pill3D(
                label: 'Keluar',
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
      BuildContext context, String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        GestureDetector(
          onTap: () {},
          child: Text(
            action,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                ),
          ),
        ),
      ],
    );
  }
}

// ── 3D FAB ────────────────────────────────────────────────────────────────────

class _Fab3D extends StatefulWidget {
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
      onTap: () {},
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
