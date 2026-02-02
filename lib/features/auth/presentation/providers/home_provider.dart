import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeProvider extends ChangeNotifier {
  final SharedPreferences sharedPreferences;
  String? _userId; // Stores current user ID

  HomeProvider({required this.sharedPreferences});

  // Called automatically when Auth state changes (see main.dart)
  void setUserId(String? userId) {
    if (_userId != userId) {
      _userId = userId;
      if (_userId != null) {
        _loadDailyStats(); // Load data specifically for this user
      } else {
        // User logged out: clear memory (UI) but keep storage
        _resetMemory();
      }
    }
  }

  // Navigation State
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  // Daily Activity State
  int _waterMl = 0;
  final int _waterGoal = 2500;

  double _sleepHours = 0.0;
  final double _sleepGoal = 8.0;

  int _exerciseMins = 0;
  final int _exerciseGoal = 60;

  // Dynamic Keys Scoped to User
  String get _keyWater => 'daily_water_$_userId';
  String get _keySleep => 'daily_sleep_$_userId';
  String get _keyExercise => 'daily_exercise_$_userId';
  String get _keyLastDate => 'last_active_date_$_userId';

  // Getters
  int get waterMl => _waterMl;
  double get waterPercentage => (_waterMl / _waterGoal).clamp(0.0, 1.0);
  String get waterValueStr => "${(waterPercentage * 100).toInt()}%";

  String get sleepValueStr => "${_sleepHours.toStringAsFixed(1)}h";
  double get sleepPercentage => (_sleepHours / _sleepGoal).clamp(0.0, 1.0);

  String get exerciseValueStr => "${_exerciseMins}m";
  double get exercisePercentage =>
      (_exerciseMins / _exerciseGoal).clamp(0.0, 1.0);

  // --- ACTIONS ---

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void logWater(int amount) {
    if (_userId == null) return;
    _waterMl += amount;
    _saveData(_keyWater, _waterMl);
    notifyListeners();
  }

  void logExercise(int minutes) {
    if (_userId == null) return;
    _exerciseMins += minutes;
    _saveData(_keyExercise, _exerciseMins);
    notifyListeners();
  }

  void logSleep(double hours) {
    if (_userId == null) return;
    _sleepHours = hours;
    _saveDouble(_keySleep, _sleepHours);
    notifyListeners();
  }

  // --- PERSISTENCE LOGIC ---

  Future<void> _loadDailyStats() async {
    if (_userId == null) return;

    // 1. Check if it's a new day for THIS user
    final lastDate = sharedPreferences.getString(_keyLastDate);
    final today = DateTime.now().toIso8601String().split('T').first;

    if (lastDate != today) {
      // It's a new day! Reset everything for this user.
      await resetDailyStats();
      await sharedPreferences.setString(_keyLastDate, today);
    } else {
      // Load values for this user
      _waterMl = sharedPreferences.getInt(_keyWater) ?? 0;
      _exerciseMins = sharedPreferences.getInt(_keyExercise) ?? 0;
      _sleepHours = sharedPreferences.getDouble(_keySleep) ?? 0.0;
    }
    notifyListeners();
  }

  Future<void> _saveData(String key, int value) async {
    await sharedPreferences.setInt(key, value);
  }

  Future<void> _saveDouble(String key, double value) async {
    await sharedPreferences.setDouble(key, value);
  }

  Future<void> resetDailyStats() async {
    _waterMl = 0;
    _exerciseMins = 0;
    _sleepHours = 0;
    // Clear storage for this user
    await sharedPreferences.remove(_keyWater);
    await sharedPreferences.remove(_keyExercise);
    await sharedPreferences.remove(_keySleep);
    notifyListeners();
  }

  void _resetMemory() {
    _waterMl = 0;
    _exerciseMins = 0;
    _sleepHours = 0;
    notifyListeners();
  }
}
