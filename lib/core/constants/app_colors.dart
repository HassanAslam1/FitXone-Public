import 'package:flutter/material.dart';

class AppColors {
  // Prevent instantiation
  AppColors._();

  // Main Background (Dark almost black)
  static const Color scaffoldBackground = Color(0xFF121212);

  // The "Next" Button & Accents (Soft Lavender)
  static const Color primary = Color(0xFF8E87FA);

  // Added this to fix the error in main.dart
  // Using the primary color as accent, or you can pick a different one like Pink (0xFFFF6F91)
  static const Color accent = Color(0xFF8E87FA);

  // The Cards (Get Fit, Be Active, etc.) - Slightly lighter grey
  static const Color cardSurface = Color(0xFF1E1E24);
  static const Color mutedOrange = Color(0xFFE65534);
  static const Color bgcolor = Color(0xFF2C2C2E);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // White headings
  static const Color textSecondary = Color(0xFFB3B3B3); // Grey subtext

  // Success/Error (for logic later)
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFB74D); // Added warning color

  //fruit models colors
  static const Color fruit1 = Colors.redAccent;
  static const Color fruit2 = Colors.orange;
  static const Color fruit3 = Colors.pinkAccent;
  static const Color fruit4 = Colors.blue;
  static const Color fruit8 = Colors.greenAccent;
  static const Color fruit6 = Colors.purpleAccent;
  static const Color fruit7 = Colors.deepOrangeAccent;
  static const Color fruit9 = Colors.lightGreen;
}
