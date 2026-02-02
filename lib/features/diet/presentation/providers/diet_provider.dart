import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_fit_xone/features/workout/data/datasources/groq_service.dart';
import 'package:the_fit_xone/features/diet/data/models/fruit_model.dart';
import 'package:intl/intl.dart';

class DietProvider extends ChangeNotifier {
  final GroqService _groqService = GroqService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- STATE ---
  int _dailyCalorieTarget = 0;
  int _caloriesConsumed = 0;
  bool _isLoading = false;

  int get dailyCalorieTarget => _dailyCalorieTarget;
  int get caloriesConsumed => _caloriesConsumed;
  bool get isLoading => _isLoading;

  double get progressPercentage {
    if (_dailyCalorieTarget == 0) return 0.0;
    return (_caloriesConsumed / _dailyCalorieTarget).clamp(0.0, 1.0);
  }

  int get caloriesRemaining => (_dailyCalorieTarget - _caloriesConsumed).clamp(0, 9999);

  // --- 1. INITIALIZE (The Master Function) ---
  // Call this once from HomeScreen. It handles everything.
  Future<void> initializeDietData(int age, String gender, int weight, int height, String goal) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // A. First, try to load TODAY'S logs from Firebase
    try {
      final doc = await _firestore.collection('users').doc(uid).collection('diet_logs').doc(today).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        // ✅ FOUND DATA! Use it and STOP.
        _dailyCalorieTarget = data['target'] ?? 0;
        _caloriesConsumed = data['consumed'] ?? 0;

        // If for some reason target is 0 in DB (rare error), recalc it
        if (_dailyCalorieTarget > 0) {
          notifyListeners();
          return;
        }
      }
    } catch (e) {
      debugPrint("Error loading diet data: $e");
    }

    // B. If NO data in Firebase (New Day or First Time), Calculate via AI
    await _calculateAndSaveTarget(age, gender, weight, height, goal, uid, today);
  }
// --- 4. FORCE RECALCULATE (Call this when Profile Updates) ---
  Future<void> recalculateTargetPreservingLogs(int age, String gender, int weight, int height, String goal) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // 1. Calculate NEW Target based on NEW weight
      int newTarget = await _groqService.calculateDailyCalories(
        age: age,
        gender: gender,
        weight: weight,
        height: height,
        goal: goal,
      );

      if (newTarget == 0) newTarget = 2000;

      // 2. Update State (Update Target, KEEP Consumed)
      _dailyCalorieTarget = newTarget;
      // Note: We DO NOT touch _caloriesConsumed here.

      // 3. Save to Firebase (Merge updates only the target)
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await _firestore.collection('users').doc(uid).collection('diet_logs').doc(today).set({
        'target': _dailyCalorieTarget,
        // We don't send 'consumed' so it stays whatever it was in DB
      }, SetOptions(merge: true));

    } catch (e) {
      debugPrint("Recalc Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
  // --- 2. AI CALCULATION (Internal Helper) ---
  Future<void> _calculateAndSaveTarget(int age, String gender, int weight, int height, String goal, String uid, String today) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Ask AI
      int calculatedTarget = await _groqService.calculateDailyCalories(
        age: age,
        gender: gender,
        weight: weight,
        height: height,
        goal: goal,
      );

      // 2. Safety Check (Prevent 0)
      if (calculatedTarget == 0) calculatedTarget = 2000;

      // 3. Update State
      _dailyCalorieTarget = calculatedTarget;
      _caloriesConsumed = 0; // New day starts at 0

      // 4. Save to Firebase PERMANENTLY
      await _firestore.collection('users').doc(uid).collection('diet_logs').doc(today).set({
        'target': _dailyCalorieTarget,
        'consumed': 0,
        'date': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

    } catch (e) {
      debugPrint("AI Calc Error: $e");
      _dailyCalorieTarget = 2000; // Fallback
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- 3. LOG FRUIT & SAVE ---
  Future<void> logFruit(FruitModel fruit, int quantityInGrams) async {
    final int caloriesToAdd = ((fruit.caloriesPer100g / 100) * quantityInGrams).round();

    // 1. Optimistic Update (Update UI instantly)
    _caloriesConsumed += caloriesToAdd;
    notifyListeners();

    // 2. Save to Firebase
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      await _firestore.collection('users').doc(uid).collection('diet_logs').doc(today).set({
        'consumed': _caloriesConsumed,
        'target': _dailyCalorieTarget, // Always ensure target is saved too
      }, SetOptions(merge: true));

    } catch (e) {
      debugPrint("Error saving meal: $e");
      // Optional: Rollback state if needed, but rarely necessary for calories
    }
  }
}