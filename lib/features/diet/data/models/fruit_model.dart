import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class FruitModel {
  final String name;
  final int caloriesPer100g; // Stored as int for calculation
  final double protein;
  final double carbs;
  final double fat;
  final String description;
  final String imageUrl; // Stores path like "assets/images/apple.avif"
  final Color color;

  FruitModel({
    required this.name,
    required this.caloriesPer100g,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.description,
    required this.imageUrl,
    required this.color,
  });
}

// Global list
final List<FruitModel> defaultFruits = [
  FruitModel(
    name: "Apple",
    caloriesPer100g: 52,
    protein: 0.3,
    carbs: 14.0,
    fat: 0.2,
    description: "Apples are nutritious. They may be good for weight loss and good for your heart. As part of a healthful, varied diet, apples can help strengthen your bones.",
    // ✅ CORRECT LOCAL ASSET PATH
    imageUrl: "assets/images/apples.jpeg",
    color: AppColors.fruit1,
  ),
  FruitModel(
    name: "Banana",
    caloriesPer100g: 89,
    protein: 1.1,
    carbs: 23.0,
    fat: 0.3,
    description: "Bananas are high in potassium and contain good levels of protein and dietary fiber. They are rich in energy and make for a perfect pre-workout snack.",
    // ✅ CORRECT LOCAL ASSET PATH
    imageUrl: "assets/images/banana.jpeg",
    color: AppColors.warning,
  ),
  FruitModel(
    name: "Orange",
    caloriesPer100g: 47,
    protein: 0.9,
    carbs: 12.0,
    fat: 0.1,
    description: "Oranges are a healthy source of fiber, vitamin C, thiamine, folate, and antioxidants.",
    imageUrl: "assets/images/oranges.jpeg",
    color: AppColors.fruit2,
  ),
  FruitModel(
    name: "Strawberry",
    caloriesPer100g: 32,
    protein: 0.7,
    carbs: 7.7,
    fat: 0.3,
    description: "Strawberries are an excellent source of vitamin C and manganese.",
    imageUrl: "assets/images/strawberry.jpeg",
    color: AppColors.fruit3,
  ),
  FruitModel(
    name: "Blueberry",
    caloriesPer100g: 57,
    protein: 0.7,
    carbs: 14.0,
    fat: 0.3,
    description: "Blueberries are sweet, nutritious and wildly popular superfoods.",
    imageUrl: "assets/images/blueberries.jpeg",
    color: AppColors.fruit4,
  ),
  FruitModel(
    name: "Grapes",
    caloriesPer100g: 67,
    protein: 0.6,
    carbs: 17.0,
    fat: 0.4,
    description: "Grapes contain many important vitamins and minerals, including copper and vitamins B and K.",
    imageUrl: "assets/images/grapes.jpeg",
    color: AppColors.fruit6,
  ),
  FruitModel(
    name: "Mango",
    caloriesPer100g: 60,
    protein: 0.8,
    carbs: 15.0,
    fat: 0.4,
    description:
    "Mangoes are rich in vitamin A and C. They help boost immunity and support eye health.",
    imageUrl: "assets/images/mangoes.jpeg",
    color: AppColors.fruit7,
  ),

  FruitModel(
    name: "Kiwi",
    caloriesPer100g: 61,
    protein: 1.1,
    carbs: 14.7,
    fat: 0.5,
    description:
    "Kiwis are high in vitamin C and antioxidants. They aid digestion and support immune health.",
    imageUrl: "assets/images/kiwi.jpeg",
    color: AppColors.fruit8,
  ),

  FruitModel(
    name: "Guava",
    caloriesPer100g: 68,
    protein: 2.6,
    carbs: 14.3,
    fat: 1.0,
    description:
    "Guava is rich in fiber and vitamin C. It supports digestion and helps regulate blood sugar levels.",
    imageUrl: "assets/images/guava.jpeg",
    color: AppColors.fruit9,
  ),

  FruitModel(
    name: "Peach",
    caloriesPer100g: 39,
    protein: 0.9,
    carbs: 9.5,
    fat: 0.3,
    description:
    "Peaches are low in calories and contain vitamins A and C. They support skin health and hydration.",
    imageUrl: "assets/images/peach.jpeg",
    color: AppColors.fruit3,
  ),

];