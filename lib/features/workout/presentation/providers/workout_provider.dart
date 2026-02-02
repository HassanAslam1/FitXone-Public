import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/workout_entity.dart';
import '../../data/repositories/workout_repository.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutRepository _repository = WorkoutRepository();
  List<WorkoutEntity> _workoutHistory = [];
  StreamSubscription? _subscription;

  // Getter for the list
  List<WorkoutEntity> get history => _workoutHistory;

  // 1. CALCULATE TODAY'S MINUTES
  int get todaysTotalMinutes {
    if (_workoutHistory.isEmpty) return 0;

    final now = DateTime.now();

    final todaysWorkouts = _workoutHistory.where((workout) {
      return workout.date.year == now.year &&
          workout.date.month == now.month &&
          workout.date.day == now.day;
    }).toList();

    int totalSeconds = 0;
    for (var w in todaysWorkouts) {
      totalSeconds += w.durationSeconds;
    }

    return totalSeconds ~/ 60;
  }

  // 2. START LISTENING (FIXED: Added Data Isolation)
  void initWorkoutStream() {
    // If already listening, don't restart (prevents duplicate listeners)
    if (_subscription != null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _subscription = _repository.getWorkoutHistory().listen((workouts) {
      // ✅ THE FIX: Filter the incoming list by the current User ID.
      // This ensures the graph only receives data belonging to THIS account.
      _workoutHistory = workouts.where((w) => w.userId == user.uid).toList();

      notifyListeners();
    }, onError: (e) {
      // Handle stream error silently
      debugPrint("Error in workout stream: $e");
    });
  }

  // 3. FINISH WORKOUT
  Future<WorkoutEntity?> finishWorkout({
    required String type,
    required int durationSeconds,
    List<String>? coreExercises,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      // A. AI Calculation
      int calories = await _repository.getCaloriesBurned(
          type, durationSeconds, coreExercises);

      // B. Fallback
      if (calories == 0) {
        if (type == 'Running') {
          calories = ((durationSeconds / 60) * 11).round();
        } else if (type == 'Walking') {
          calories = ((durationSeconds / 60) * 5).round();
        } else if (type == 'Core Exercises') {
          calories = (coreExercises?.length ?? 0) * 4;
          if (calories == 0 && durationSeconds > 0) calories = 1;
        }
      }

      final workout = WorkoutEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid, // Ensuring we save with the correct UID
        type: type,
        date: DateTime.now(),
        durationSeconds: durationSeconds,
        caloriesBurned: calories,
        exercisesCompleted: coreExercises ?? [],
      );

      await _repository.saveWorkout(workout);

      // The Stream will auto-update the UI
      return workout;
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}