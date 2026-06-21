import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/database.dart';
import '../../theme.dart';
import '../activity/activity_detail_screen.dart';
import '../../widgets/profile_avatar.dart';


class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
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
                      const ProfileAvatar(),
                      const SizedBox(width: 10),
                      Text(
                        'Stats',
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
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: StreamBuilder<List<ActivityLog>>(
                    stream: db.select(db.activityLogs).watch(),
                    builder: (context, activitySnapshot) {
                      return StreamBuilder<List<WorkoutLog>>(
                        stream: db.select(db.workoutLogs).watch(),
                        builder: (context, workoutSnapshot) {
                          return StreamBuilder<List<BodyWeight>>(
                            stream: db.select(db.bodyWeights).watch(),
                            builder: (context, weightSnapshot) {
                              final activities = activitySnapshot.data ?? [];
                              final workouts = workoutSnapshot.data ?? [];
                              final weights = weightSnapshot.data ?? [];

                              final List<Map<String, dynamic>> combined = [];
                              
                              for (final a in activities) {
                                String label = 'Activity';
                                if (a.type == 'run') label = 'Run';
                                if (a.type == 'bike') label = 'Bike';
                                
                                String detail = '${a.durationSeconds ~/ 60} min';
                                if (a.distanceMeters > 0) {
                                  detail = '${(a.distanceMeters / 1000).toStringAsFixed(1)} km - $detail';
                                }
                                
                                combined.add({
                                  'label': label,
                                  'detail': detail,
                                  'type': a.type,
                                  'calories': a.caloriesBurned.toInt(),
                                  'date': a.date,
                                  'raw': a,
                                });
                              }
                              
                              for (final w in workouts) {
                                combined.add({
                                  'label': w.templateName,
                                  'detail': '${w.durationMinutes} min • ${w.totalVolumeKg.toInt()} kg',
                                  'type': 'gym',
                                  'calories': w.caloriesBurned.toInt(),
                                  'date': w.date,
                                  'raw': w,
                                });
                              }
                              
                              combined.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 20),
                                  _buildToggle(),
                                  const SizedBox(height: 24),
                                  if (activities.isNotEmpty) ...[
                                    _buildOutdoorSummary(activities),
                                    const SizedBox(height: 24),
                                  ],
                                  _buildCalorieChartCard(activities, workouts),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Activity History',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: AppColors.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (activities.isEmpty && workouts.isEmpty)
                                    const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: Text('No activities yet', style: TextStyle(color: Colors.white54)),
                                      ),
                                    )
                                  else
                                    ...combined.map((a) {
                                      String type = a['type'];
                                      String label = a['label'];
                                      String detail = a['detail'];

                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            if (type == 'run' || type == 'bike') {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ActivityDetailScreen(activity: a['raw']),
                                                ),
                                              );
                                            }
                                          },
                                          child: _GlassCard(
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 48,
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.surfaceContainerHigh,
                                                    borderRadius: BorderRadius.circular(16),
                                                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                                  ),
                                                  child: Icon(
                                                    type == 'run' ? Icons.directions_run : (type == 'bike' ? Icons.directions_bike : Icons.fitness_center),
                                                    color: AppColors.secondary,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        label,
                                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                              color: AppColors.onSurface,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                      ),
                                                      Text(
                                                        detail,
                                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                              color: AppColors.onSurfaceVariant,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      '${a['calories']}',
                                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                            color: AppColors.secondary,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                    ),
                                                    Text(
                                                      'kcal',
                                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                            color: AppColors.onSurfaceVariant,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  const SizedBox(height: 100),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(child: _buildToggleButton('This Week', 0)),
          Expanded(child: _buildToggleButton('This Month', 1)),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, int index) {
    final bool isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: isActive
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color:
                  isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutdoorSummary(List<ActivityLog> activities) {
    if (activities.isEmpty) return const SizedBox.shrink();

    int totalActivities = activities.length;
    double totalDistanceKm = activities.fold(0.0, (sum, a) => sum + a.distanceMeters) / 1000;
    double totalCalories = activities.fold(0.0, (sum, a) => sum + a.caloriesBurned);
    int totalDurationSecs = activities.fold(0, (sum, a) => sum + a.durationSeconds);

    String avgPaceStr = "-'--\"";
    if (totalDistanceKm > 0) {
      double paceMin = (totalDurationSecs / 60) / totalDistanceKm;
      int m = paceMin.floor();
      int s = ((paceMin - m) * 60).round();
      avgPaceStr = "$m'${s.toString().padLeft(2, '0')}\"";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Outdoor Summary',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildSummaryCard(Icons.directions_run_rounded, 'Activities', '$totalActivities')),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCard(Icons.map_rounded, 'Distance', '${totalDistanceKm.toStringAsFixed(1)} km')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSummaryCard(Icons.local_fire_department_rounded, 'Calories', '${totalCalories.toInt()} kcal', iconColor: const Color(0xFFFF7043))),
            const SizedBox(width: 12),
            Expanded(child: _buildSummaryCard(Icons.speed_rounded, 'Avg Pace', avgPaceStr)),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(IconData icon, String label, String value, {Color iconColor = AppColors.primary}) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieChartCard(List<ActivityLog> activities, List<WorkoutLog> workouts) {
    final now = DateTime.now();
    final List<double> weeklyCalories = List.filled(7, 0.0);
    double maxCal = 100.0;

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: 6 - i));
      double dayCal = 0;

      for (var a in activities) {
        if (a.date.year == date.year && a.date.month == date.month && a.date.day == date.day) {
          dayCal += a.caloriesBurned;
        }
      }
      for (var w in workouts) {
        if (w.date.year == date.year && w.date.month == date.month && w.date.day == date.day) {
          dayCal += w.caloriesBurned;
        }
      }
      weeklyCalories[i] = dayCal;
      if (dayCal > maxCal) maxCal = dayCal;
    }
    
    maxCal = (maxCal * 1.2).ceilToDouble();
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Burned Calories',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const List<String> days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ];
                        if (value >= 0 && value < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              days[value.toInt()],
                              style: const TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  for (int i = 0; i < 7; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: weeklyCalories[i],
                          width: 16,
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxCal,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChartCard(List<BodyWeight> weights) {
    // Sort weights ascending by date
    final sortedWeights = List<BodyWeight>.from(weights)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = <FlSpot>[];
    double minWeight = 50.0;
    double maxWeight = 100.0;

    if (sortedWeights.isNotEmpty) {
      minWeight = sortedWeights.map((e) => e.weightKg).reduce((a, b) => a < b ? a : b);
      maxWeight = sortedWeights.map((e) => e.weightKg).reduce((a, b) => a > b ? a : b);
      
      // Pad min and max
      minWeight = (minWeight - 5).floorToDouble();
      maxWeight = (maxWeight + 5).ceilToDouble();

      // Take up to last 7 weights
      final recent = sortedWeights.length > 7 ? sortedWeights.sublist(sortedWeights.length - 7) : sortedWeights;
      for (int i = 0; i < recent.length; i++) {
        spots.add(FlSpot(i.toDouble(), recent[i].weightKg));
      }
    } else {
      spots.add(const FlSpot(0, 0));
      minWeight = 0;
      maxWeight = 10;
    }
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weight Trend',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'M${value.toInt()}',
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.secondary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.secondary.withValues(alpha: 0.3),
                          AppColors.secondary.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    shadow: Shadow(
                      color: AppColors.secondary.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ),
                ],
                minX: 0,
                maxX: (spots.length > 1 ? spots.length - 1 : 1).toDouble(),
                minY: minWeight,
                maxY: maxWeight,
              ),
            ),
          ),
        ],
      ),
    );
  }


}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 32,
            spreadRadius: 0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xB3292839),
                  Color(0xE61E1E2E),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
