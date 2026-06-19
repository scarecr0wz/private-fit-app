class WorkoutTemplate {
  final String id;
  final String name;

  const WorkoutTemplate({required this.id, required this.name});
}

class WorkoutSet {
  final String id;
  final double weight;
  final int reps;
  final bool completed;

  const WorkoutSet({
    required this.id,
    required this.weight,
    required this.reps,
    this.completed = false,
  });
}

class Exercise {
  final String id;
  final String name;
  final List<WorkoutSet> sets;

  const Exercise({
    required this.id,
    required this.name,
    required this.sets,
  });
}

const List<WorkoutTemplate> dummyTemplates = [
  WorkoutTemplate(id: '1', name: 'Push Day'),
  WorkoutTemplate(id: '2', name: 'Pull Day'),
  WorkoutTemplate(id: '3', name: 'Leg Day'),
  WorkoutTemplate(id: '4', name: 'Cardio'),
];

const List<Exercise> dummyActiveWorkout = [
  Exercise(
    id: 'e1',
    name: 'Bench Press',
    sets: [
      WorkoutSet(id: 's1', weight: 60, reps: 12, completed: true),
      WorkoutSet(id: 's2', weight: 65, reps: 10, completed: true),
      WorkoutSet(id: 's3', weight: 70, reps: 8, completed: false),
    ],
  ),
  Exercise(
    id: 'e2',
    name: 'Squat',
    sets: [
      WorkoutSet(id: 's4', weight: 80, reps: 12, completed: true),
      WorkoutSet(id: 's5', weight: 90, reps: 10, completed: false),
    ],
  ),
];
