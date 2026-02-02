class WorkoutEntity {
  final String id;
  final String userId;
  final String type; // "Running", "Walking", "Core"
  final DateTime date;
  final int durationSeconds; // For Running/Walking
  final int caloriesBurned;
  final List<String>
      exercisesCompleted; // For Core (e.g., ["Push Ups", "Plank"])

  WorkoutEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.date,
    required this.durationSeconds,
    required this.caloriesBurned,
    this.exercisesCompleted = const [],
  });
}
