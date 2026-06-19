## Session 2 — Daily Dashboard UI

**Goal**: Layar utama dengan kalori summary, ring progress, dan list aktivitas hari ini — semua dummy data.

### 2.1 Model dummy (sementara, nanti diganti)

Buat `lib/features/dashboard/dashboard_dummy.dart`:

```dart
class DailySummary {
  final int caloriesIn;
  final int caloriesOut;
  final int calorieGoal;
  final List<ActivityItem> activities;
  final List<MealItem> meals;

  const DailySummary({
    required this.caloriesIn,
    required this.caloriesOut,
    required this.calorieGoal,
    required this.activities,
    required this.meals,
  });
}

class ActivityItem {
  final String type; // 'run', 'bike', 'gym'
  final String label;
  final String detail;
  final int caloriesBurned;
  const ActivityItem({required this.type, required this.label, required this.detail, required this.caloriesBurned});
}

class MealItem {
  final String name;
  final String time;
  final int calories;
  const MealItem({required this.name, required this.time, required this.calories});
}

final dummySummary = DailySummary(
  caloriesIn: 1850,
  caloriesOut: 420,
  calorieGoal: 2400,
  activities: const [
    ActivityItem(type: 'run', label: 'Lari pagi', detail: '5.2 km · 28 menit', caloriesBurned: 280),
    ActivityItem(type: 'gym', label: 'Gym — Push day', detail: '6 exercise · 52 menit', caloriesBurned: 140),
  ],
  meals: const [
    MealItem(name: 'Sarapan', time: '07:30', calories: 520),
    MealItem(name: 'Makan siang', time: '12:15', calories: 780),
    MealItem(name: 'Snack sore', time: '15:00', calories: 210),
    MealItem(name: 'Makan malam', time: '19:00', calories: 340),
  ],
);
```

### 2.2 Widget kalori ring

Buat `lib/shared/widgets/calorie_ring.dart`:

```dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class CalorieRing extends StatelessWidget {
  final int consumed;
  final int burned;
  final int goal;

  const CalorieRing({
    super.key,
    required this.consumed,
    required this.burned,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final net = consumed - burned;
    final progress = (net / goal).clamp(0.0, 1.0);

    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(180, 180),
            painter: _RingPainter(progress: progress),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$net',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text('kcal net', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                'dari $goal target',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 14.0;

    final bgPaint = Paint()
      ..color = const Color(0xFF2A2A3E)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = const Color(0xFF6C63FF)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
```

### 2.3 Update `dashboard_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../shared/widgets/calorie_ring.dart';
import 'dashboard_dummy.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final summary = dummySummary;
    final today = DateFormat('EEEE, d MMMM', 'id_ID').format(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(today, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text('Hari ini', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 24),
              Center(
                child: CalorieRing(
                  consumed: summary.caloriesIn,
                  burned: summary.caloriesOut,
                  goal: summary.calorieGoal,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CaloriePill(label: 'Masuk', value: summary.caloriesIn, color: const Color(0xFF63FFDA)),
                  _CaloriePill(label: 'Keluar', value: summary.caloriesOut, color: const Color(0xFFFF6584)),
                ],
              ),
              const SizedBox(height: 28),
              Text('Aktivitas', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ...summary.activities.map((a) => _ActivityCard(item: a)),
              const SizedBox(height: 20),
              Text('Makanan', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ...summary.meals.map((m) => _MealRow(item: m)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaloriePill extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _CaloriePill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value kcal', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ActivityItem item;
  const _ActivityCard({required this.item});

  IconData get _icon {
    switch (item.type) {
      case 'run': return Icons.directions_run;
      case 'bike': return Icons.directions_bike;
      default: return Icons.fitness_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF6C63FF).withOpacity(0.15),
          child: Icon(_icon, color: const Color(0xFF6C63FF)),
        ),
        title: Text(item.label, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(item.detail),
        trailing: Text('−${item.caloriesBurned} kcal',
          style: const TextStyle(color: Color(0xFFFF6584), fontWeight: FontWeight.w500)),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(item.time, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
          const SizedBox(width: 12),
          Expanded(child: Text(item.name, style: Theme.of(context).textTheme.titleMedium)),
          Text('${item.calories} kcal', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
```

**Checkpoint session 2**: Dashboard tampil dengan ring kalori, list aktivitas, dan list makan.

---