import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/responsive.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/home_provider.dart';
import '../../../workout/presentation/providers/workout_provider.dart';
import '../../../workout/presentation/screens/workout_history_screen.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).loadUserData();
      // We keep this just in case you use history elsewhere,
      // but the graph logic is gone from this screen.
      Provider.of<WorkoutProvider>(context, listen: false).initWorkoutStream();
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Consumer3<AuthProvider, HomeProvider, WorkoutProvider>(
      builder: (context, auth, home, workout, child) {
        // --- DATA PREP ---
        final height = auth.height;
        final weight = auth.weight;
        final waterPercent = (home.waterPercentage * 100).toInt();
        final sleepVal = home.sleepValueStr;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: responsive.wp(6)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: responsive.hp(3)),

                  // --- 1. HEADER & HISTORY BUTTON ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Insights",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: responsive.hp(3.5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: responsive.hp(0.5)),
                          Text(
                            "Your health summary",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: responsive.hp(1.8),
                            ),
                          ),
                        ],
                      ),

                      // History Button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                const WorkoutHistoryScreen()),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: responsive.wp(4),
                              vertical: responsive.hp(1)),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            children: [
                              Text("History",
                                  style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: responsive.hp(1.6),
                                      fontWeight: FontWeight.bold)),
                              SizedBox(width: responsive.wp(1)),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  color: AppColors.primary,
                                  size: responsive.hp(1.4)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: responsive.hp(4)),

                  // --- 2. NEW: BMI CALCULATOR CARD (Replaces Graph) ---
                  _buildBMICard(responsive, height, weight),

                  SizedBox(height: responsive.hp(3)),

                  // --- 3. YOUR BODY GRID ---
                  Container(
                    padding: EdgeInsets.all(responsive.wp(5)),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Row
                        Row(
                          children: [
                            Icon(Icons.person_outline_rounded,
                                color: Colors.white,
                                size: responsive.hp(2.5)),
                            SizedBox(width: responsive.wp(3)),
                            Text(
                              "Your Body",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: responsive.hp(2.2),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: responsive.hp(3)),

                        // The 2x2 Grid Layout
                        Column(
                          children: [
                            // Row 1: Height & Weight
                            Row(
                              children: [
                                Expanded(
                                  child: _StatTile(
                                    responsive,
                                    label: "Height",
                                    value: "$height cm",
                                    icon: Icons.height_rounded,
                                    color: const Color(0xFF6E85B7), // Soft Blue
                                  ),
                                ),
                                SizedBox(width: responsive.wp(3)),
                                Expanded(
                                  child: _StatTile(
                                    responsive,
                                    label: "Weight",
                                    value: "$weight kg",
                                    icon: Icons.monitor_weight_outlined,
                                    color: const Color(0xFFE65534), // Orange
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: responsive.hp(2)),

                            // Row 2: Water & Sleep
                            Row(
                              children: [
                                Expanded(
                                  child: _StatTile(
                                    responsive,
                                    label: "Hydration",
                                    value: "$waterPercent%",
                                    icon: Icons.water_drop_outlined,
                                    color:
                                    const Color(0xFF42A5F5), // Water Blue
                                  ),
                                ),
                                SizedBox(width: responsive.wp(3)),
                                Expanded(
                                  child: _StatTile(
                                    responsive,
                                    label: "Sleep",
                                    value: sleepVal,
                                    icon: Icons.bedtime_outlined,
                                    color:
                                    const Color(0xFF9575CD), // Sleep Purple
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: responsive.hp(15)), // Bottom Padding
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- NEW WIDGET: BMI CARD (Simple Math, No Database) ---
  // --- NEW: PREMIUM BMI CARD ---
  Widget _buildBMICard(Responsive responsive, int heightCm, int weightKg) {
    // 1. Calculate BMI
    double bmi = 0;
    String status = "--";
    Color statusColor = Colors.grey;
    String message = "Update profile to see score.";
    double progress = 0; // Position on the bar (0.0 to 1.0)

    if (heightCm > 0 && weightKg > 0) {
      double heightM = heightCm / 100.0;
      bmi = weightKg / (heightM * heightM);

      // logic to determine status & color
      if (bmi < 18.5) {
        status = "Underweight";
        statusColor = const Color(0xFFFFB74D); // Orange
        message = "Eat nutrient-rich foods.";
        progress = 0.15;
      } else if (bmi < 24.9) {
        status = "Normal";
        statusColor = const Color(0xFF66BB6A); // Green
        message = "You are in a healthy range!";
        progress = 0.5;
      } else if (bmi < 29.9) {
        status = "Overweight";
        statusColor = const Color(0xFFFF7043); // Deep Orange
        message = "Regular exercise can help.";
        progress = 0.85;
      } else {
        status = "Obese";
        statusColor = const Color(0xFFEF5350); // Red
        message = "Consult a health expert.";
        progress = 1.0;
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.wp(6)),
      decoration: BoxDecoration(
        // Subtle Gradient Background
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cardSurface,
            AppColors.cardSurface.withValues(alpha: 0.6), // Slightly lighter
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("BMI Score",
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: responsive.hp(1.6),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1)),
                  SizedBox(height: responsive.hp(0.5)),
                  Text(status,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: responsive.hp(2.2),
                          fontWeight: FontWeight.bold)),
                ],
              ),
              // Big Number
              Text(
                bmi > 0 ? bmi.toStringAsFixed(1) : "--",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.hp(5.0),
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),

          SizedBox(height: responsive.hp(2.5)),

          // VISUAL SPECTRUM BAR
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              // The Background Bar
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFB74D), // Underweight (Orange)
                      Color(0xFF66BB6A), // Normal (Green)
                      Color(0xFFFF7043), // Overweight
                      Color(0xFFEF5350), // Obese (Red)
                    ],
                  ),
                ),
              ),
              // The Indicator Dot (Animated)
              AnimatedAlign(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutBack,
                alignment: Alignment(
                    (progress * 2) - 1.0, 0), // Map 0..1 to -1..1 for Align
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 5,
                      )
                    ],
                    border: Border.all(color: statusColor, width: 3),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: responsive.hp(2)),

          // FOOTER MESSAGE
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: Colors.white38, size: responsive.hp(2)),
              SizedBox(width: responsive.wp(2)),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                      color: Colors.white54, fontSize: responsive.hp(1.5)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- HELPER: STAT TILE ---
class _StatTile extends StatelessWidget {
  final Responsive responsive;
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile(
      this.responsive, {
        required this.label,
        required this.value,
        required this.icon,
        required this.color,
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: responsive.wp(4), vertical: responsive.hp(2)),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            padding: EdgeInsets.all(responsive.wp(2)),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: responsive.hp(2.2)),
          ),
          SizedBox(height: responsive.hp(1.5)),

          // Value
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: responsive.hp(2.0),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.hp(0.5)),

          // Label
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: responsive.hp(1.6),
            ),
          ),
        ],
      ),
    );
  }
}