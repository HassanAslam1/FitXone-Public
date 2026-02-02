import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Import Provider
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/responsive.dart';
import '../../data/models/fruit_model.dart'; // ✅ Import Model
import '../providers/diet_provider.dart';    // ✅ Import Diet Provider

class FruitDetailScreen extends StatelessWidget {
  final FruitModel fruit; // ✅ Now accepts FruitModel

  const FruitDetailScreen({super.key, required this.fruit});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      // Floating Action Button to Log Meal
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildLogMealButton(context, responsive),

      body: Stack(
        children: [
          // 1. BACKGROUND GLOW
          Positioned(
            top: -responsive.hp(15),
            left: -responsive.wp(20),
            child: Container(
              width: responsive.wp(90),
              height: responsive.wp(90),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: fruit.color.withValues(alpha:0.2),
                    blurRadius: 120,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 2. NAV BAR
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: responsive.wp(6), vertical: responsive.hp(1)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: _NavIconBox(
                            responsive: responsive,
                            icon: Icons.arrow_back_ios_new_rounded
                        ),
                      ),
                      Text(
                        "Details",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: responsive.hp(2.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _NavIconBox(
                          responsive: responsive,
                          icon: Icons.share_rounded,
                          color: AppColors.primary
                      ),
                    ],
                  ),
                ),

                // 3. MAIN CONTENT
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: responsive.wp(6)),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: responsive.hp(2)),

                        // HERO IMAGE
                        Hero(
                          tag: fruit.name,
                          child: Container(
                            width: responsive.wp(45),
                            height: responsive.wp(45),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(fruit.imageUrl),   // ✅ NEW
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha:0.1),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: fruit.color.withValues(alpha:0.3),
                                  blurRadius: 25,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: responsive.hp(2.5)),

                        // TITLE
                        Text(
                          fruit.name,
                          style: TextStyle(
                            fontSize: responsive.hp(3.2),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: "Plus Jakarta Sans",
                          ),
                        ),
                        SizedBox(height: responsive.hp(0.5)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: fruit.color.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Healthy & Fresh",
                            style: TextStyle(
                              fontSize: responsive.hp(1.4),
                              color: fruit.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        SizedBox(height: responsive.hp(3)),

                        // MACROS GRID
                        Container(
                          padding: EdgeInsets.symmetric(vertical: responsive.hp(2), horizontal: responsive.wp(2)),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface.withValues(alpha:0.9),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha:0.05)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _MacroItem(
                                label: "Calories",
                                value: "${fruit.caloriesPer100g} kcal",
                                icon: Icons.local_fire_department_rounded,
                                color: Colors.orangeAccent,
                                responsive: responsive,
                              ),
                              _VerticalDivider(responsive: responsive),
                              _MacroItem(
                                label: "Carbs",
                                value: "${fruit.carbs}g",
                                icon: Icons.grain_rounded,
                                color: Colors.amber,
                                responsive: responsive,
                              ),
                              _VerticalDivider(responsive: responsive),
                              _MacroItem(
                                label: "Protein",
                                value: "${fruit.protein}g",
                                icon: Icons.fitness_center_rounded,
                                color: Colors.blueAccent,
                                responsive: responsive,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: responsive.hp(3)),

                        // DESCRIPTION
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Overview",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: responsive.hp(2.0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: responsive.hp(1)),
                        Text(
                          fruit.description,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: responsive.hp(1.6),
                            height: 1.5,
                          ),
                        ),

                        SizedBox(height: responsive.hp(3)),

                        // HIGHLIGHTS
                        Row(
                          children: [
                            Expanded(child: _HighlightCard(
                              label: "Fat",
                              value: "${fruit.fat}g",
                              icon: Icons.opacity_rounded,
                              color: Colors.redAccent,
                              responsive: responsive,
                            )),
                            SizedBox(width: responsive.wp(3)),
                            Expanded(child: _HighlightCard(
                              label: "Quality",
                              value: "Grade A",
                              icon: Icons.verified_rounded,
                              color: Colors.greenAccent,
                              responsive: responsive,
                            )),
                          ],
                        ),

                        SizedBox(height: responsive.hp(12)), // Space for FAB
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- LOG MEAL BUTTON ---
  Widget _buildLogMealButton(BuildContext context, Responsive responsive) {
    return Container(
      width: responsive.wp(90),
      height: responsive.hp(7),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: fruit.color.withValues(alpha:0.4),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _showLogDialog(context, responsive),
        style: ElevatedButton.styleFrom(
          backgroundColor: fruit.color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: responsive.hp(3)),
            SizedBox(width: responsive.wp(2)),
            Text(
              "Add to Daily Intake",
              style: TextStyle(
                fontSize: responsive.hp(2.2),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LOG DIALOG ---
  void _showLogDialog(BuildContext context, Responsive responsive) {
    final TextEditingController gramsController = TextEditingController(text: "100");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("How much did you eat?",
            style: TextStyle(color: Colors.white, fontSize: responsive.hp(2.2), fontWeight: FontWeight.bold)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: gramsController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                suffixText: "g",
                suffixStyle: const TextStyle(color: Colors.white54, fontSize: 20),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: fruit.color)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: fruit.color, width: 2)),
              ),
            ),
            SizedBox(height: responsive.hp(2)),
            Text(
              "Default serving size is 100g",
              style: TextStyle(color: Colors.white38, fontSize: responsive.hp(1.6)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: fruit.color),
            onPressed: () {
              final int grams = int.tryParse(gramsController.text) ?? 100;

              // ✅ CALL PROVIDER TO LOG
              Provider.of<DietProvider>(context, listen: false).logFruit(fruit, grams);

              Navigator.pop(ctx);

              // Show Success
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Added ${fruit.name} to your daily log!"),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text("Add Log", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// --- KEEPING YOUR EXISTING HELPER WIDGETS (Slightly optimized) ---

class _NavIconBox extends StatelessWidget {
  final Responsive responsive;
  final IconData icon;
  final Color? color;

  const _NavIconBox({required this.responsive, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(responsive.wp(2.5)),
      decoration: BoxDecoration(
        color: color ?? AppColors.cardSurface,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha:0.08)),
      ),
      child: Icon(icon, color: Colors.white, size: responsive.hp(2.0)),
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Responsive responsive;

  const _MacroItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: responsive.hp(2.8)),
        SizedBox(height: responsive.hp(0.8)),
        Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: responsive.hp(1.6))),
        SizedBox(height: responsive.hp(0.3)),
        Text(label, style: TextStyle(color: Colors.white38, fontSize: responsive.hp(1.3))),
      ],
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Responsive responsive;

  const _HighlightCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: responsive.hp(1.5), horizontal: responsive.wp(3)),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha:0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(responsive.wp(2)),
            decoration: BoxDecoration(color: color.withValues(alpha:0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: responsive.hp(2.0)),
          ),
          SizedBox(width: responsive.wp(3)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: responsive.hp(1.6))),
              Text(label, style: TextStyle(color: Colors.white54, fontSize: responsive.hp(1.3))),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final Responsive responsive;
  const _VerticalDivider({required this.responsive});
  @override
  Widget build(BuildContext context) {
    return Container(height: responsive.hp(4), width: 1, color: Colors.white.withValues(alpha:0.1));
  }
}