import 'dart:convert';
import 'package:flutter/material.dart'; // Added for debugPrint
import 'package:http/http.dart' as http;

class GroqService {
  // ⚠️ PASTE YOUR KEY HERE
  static const String _apiKey =
      '';

  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  // ---------------------------------------------------------
  // 1. WORKOUT LOGIC (EXISTING - UNTOUCHED)
  // ---------------------------------------------------------
  Future<int> calculateCalories({
    required String activityType,
    required int durationSeconds,
    required Map<String, dynamic> userStats,
    List<String>? coreExercises,
  }) async {
    try {
      final url = Uri.parse(_baseUrl);

      final age = userStats['age'] ?? 25;
      final weight = userStats['weight'] ?? 70;
      final height = userStats['height'] ?? 175;
      final gender = userStats['gender'] ?? 'male';

      String promptText;
      if (activityType == 'Core Exercises') {
        promptText =
        "I am a $age year old $gender, $weight kg, $height cm. I did 3 sets of 12 reps of: ${coreExercises?.join(', ')}. Estimate total calories burned. Return ONLY a single integer number.";
      } else {
        final minutes = (durationSeconds / 60).toStringAsFixed(2);
        promptText =
        "I am a $age year old $gender, $weight kg, $height cm. I did $activityType for $minutes minutes. Estimate total calories burned. Return ONLY a single integer number.";
      }

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content":
              "You are a fitness API. You only output raw numbers. No text."
            },
            {"role": "user", "content": promptText}
          ],
          "temperature": 1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'].toString();

        final cleanText = content.replaceAll(RegExp(r'[^0-9]'), '');
        final result = int.tryParse(cleanText) ?? 0;

        if (result > 0) {
          return result;
        }
      }
    } catch (e) {
      // Silently fail and switch to offline
    }

    return _calculateOffline(activityType, durationSeconds, coreExercises);
  }

  int _calculateOffline(String type, int seconds, List<String>? exercises) {
    if (type == 'Core Exercises') return 15 + ((exercises?.length ?? 0) * 5);

    double met = (type == 'Running') ? 9.8 : 3.8;
    double minutes = seconds / 60;
    if (minutes < 0.2) minutes = 0.2;

    int result = ((met * 3.5 * 70) / 200 * minutes).round();
    return result > 0 ? result : 5;
  }

  // ---------------------------------------------------------
  // 2. DIET LOGIC (NEW - ADDED FOR NUTRITION)
  // ---------------------------------------------------------
  Future<int> calculateDailyCalories({
    required int age,
    required String gender,
    required int weight, // in kg
    required int height, // in cm
    required String goal, // e.g. "Get Fit", "Lose Weight"
  }) async {
    try {
      final url = Uri.parse(_baseUrl);

      final String promptText = '''
        I am a $age year old $gender.
        Height: $height cm.
        Weight: $weight kg.
        My fitness goal is: $goal.
        
        Calculate my optimal Total Daily Energy Expenditure (TDEE) / Daily Calorie Intake to achieve this goal.
        
        CRITICAL INSTRUCTION: 
        Reply with ONLY the integer number of calories. 
        Do not add any text, explanations, or units.
        Example response: 2400
      ''';

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile",
          "messages": [
            {
              "role": "system",
              "content": "You are a nutrition API. You only output raw numbers (Daily Calories). No text."
            },
            {"role": "user", "content": promptText}
          ],
          "temperature": 1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'].toString();

        // Clean the response to find the number
        final cleanText = content.trim().replaceAll(RegExp(r'[^0-9]'), '');
        final result = int.tryParse(cleanText);

        if (result != null && result > 0) {
          return result;
        }
      }
    } catch (e) {
      debugPrint("Error calculating daily calories: $e");
    }

    // Fallback Calculation (Mifflin-St Jeor Equation) if AI fails
    double base = (10.0 * weight) + (6.25 * height) - (5.0 * age);
    if (gender.toLowerCase() == 'male') {
      base += 5;
    } else {
      base -= 161;
    }

    // Adjust slightly for activity/goal if fallback is used (generic multiplier 1.2)
    return (base * 1.2).toInt();
  }
}