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

  int get caloriesNet => caloriesIn - caloriesOut;
}

class ActivityItem {
  final String type; // 'run', 'bike', 'gym'
  final String label;
  final String detail;
  final int caloriesBurned;
  const ActivityItem({
    required this.type,
    required this.label,
    required this.detail,
    required this.caloriesBurned,
  });
}

class MealItem {
  final String name;
  final String time;
  final int calories;
  const MealItem({
    required this.name,
    required this.time,
    required this.calories,
  });
}

const dummySummary = DailySummary(
  caloriesIn: 1850,
  caloriesOut: 420,
  calorieGoal: 2400,
  activities: [
    ActivityItem(
      type: 'run',
      label: 'Lari Sore',
      detail: '30 min',
      caloriesBurned: 250,
    ),
    ActivityItem(
      type: 'gym',
      label: 'Latihan Beban',
      detail: '45 min',
      caloriesBurned: 170,
    ),
  ],
  meals: [
    MealItem(name: 'Bubur Ayam', time: '08:00', calories: 350),
    MealItem(name: 'Nasi Padang', time: '12:30', calories: 750),
    MealItem(name: 'Apel', time: '16:00', calories: 90),
    MealItem(name: 'Salad Ayam', time: '19:30', calories: 660),
  ],
);
