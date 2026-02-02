import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/workout_entity.dart';
import '../datasources/groq_service.dart';

class WorkoutRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // USE GROQ SERVICE
  final GroqService _aiService = GroqService();

  // 1. Calculate Calories (Using Groq)
  Future<int> getCaloriesBurned(
      String type, int duration, List<String>? exercises) async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? {};

    return await _aiService.calculateCalories(
      activityType: type,
      durationSeconds: duration,
      userStats: userData,
      coreExercises: exercises,
    );
  }

  // 2. Save Workout to Firestore
  Future<void> saveWorkout(WorkoutEntity workout) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('workouts')
        .doc(workout.id)
        .set({
      'type': workout.type,
      'date': workout.date.toIso8601String(),
      'durationSeconds': workout.durationSeconds,
      'caloriesBurned': workout.caloriesBurned,
      'exercisesCompleted': workout.exercisesCompleted,
    });
  }

  // 3. Get History
  Stream<List<WorkoutEntity>> getWorkoutHistory() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('workouts')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return WorkoutEntity(
          id: doc.id,
          userId: user.uid,
          type: data['type'],
          date: DateTime.parse(data['date']),
          durationSeconds: data['durationSeconds'],
          caloriesBurned: data['caloriesBurned'],
          exercisesCompleted:
              List<String>.from(data['exercisesCompleted'] ?? []),
        );
      }).toList();
    });
  }
} // <--- The closing bracket MUST be here at the very end
