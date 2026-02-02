import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_fit_xone/features/auth/presentation/providers/auth_provider.dart';
import 'package:the_fit_xone/features/auth/presentation/providers/home_provider.dart';
import 'package:the_fit_xone/features/workout/presentation/providers/workout_provider.dart';
// ✅ Import Diet Provider
import 'package:the_fit_xone/features/diet/presentation/providers/diet_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/responsive.dart';

import '../../../diet/presentation/screens/nutrition_screen.dart';
import '../widgets/activity_card.dart';
import '../widgets/daily_summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final diet = Provider.of<DietProvider>(context, listen: false);
      final workout = Provider.of<WorkoutProvider>(context, listen: false);

      workout.initWorkoutStream();

      // ✅ FIX: Use the new master function 'initializeDietData'
      void loadDietData() {
        // If data is ready, initialize immediately
        if (auth.age > 0 && auth.weight > 0) {
          diet.initializeDietData(
            auth.age,
            auth.gender,
            auth.weight,
            auth.height,
            auth.goal,
          );
        } else {
          // If data is missing, load user data first, THEN initialize
          auth.loadUserData().then((_) {
            if (auth.age > 0) {
              diet.initializeDietData(
                auth.age,
                auth.gender,
                auth.weight,
                auth.height,
                auth.goal,
              );
            }
          });
        }
      }

      loadDietData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final now = DateTime.now();
    final weekDays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    final currentDay = weekDays[now.weekday - 1];

    // Added DietProvider to Consumer
    return Consumer4<HomeProvider, AuthProvider, WorkoutProvider, DietProvider>(
      builder: (context, homeProvider, authProvider, workoutProvider, dietProvider, child) {

        // DATA PREP
        final int exerciseMinutes = workoutProvider.todaysTotalMinutes;
        final double exercisePercent = (exerciseMinutes / 60.0).clamp(0.0, 1.0);

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: Stack(
            children: [
              // --- 1. BACKGROUND GLOW ---
              Positioned(
                top: -responsive.hp(15),
                left: -responsive.wp(20),
                child: Container(
                  width: responsive.wp(70),
                  height: responsive.wp(70),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha:0.08),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha:0.08),
                        blurRadius: 100,
                        spreadRadius: 20,
                      )
                    ],
                  ),
                ),
              ),

              // --- 2. MAIN CONTENT ---
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: responsive.wp(6)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: responsive.hp(2)),

                      // --- HEADER ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Good Morning,",
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: responsive.hp(1.8),
                                ),
                              ),
                              SizedBox(height: responsive.hp(0.5)),
                              Text(
                                currentDay,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsive.hp(3.5),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                              SizedBox(height: responsive.hp(0.5)),

                              // Goal Pill (From Auth)
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: responsive.wp(3),
                                    vertical: responsive.hp(0.5)),
                                decoration: BoxDecoration(
                                  color: AppColors.cardSurface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Text(
                                  "Goal: ${authProvider.goal}",
                                  style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: responsive.hp(1.4),
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),

                          // --- REPLACED NOTIFICATION WITH CALORIE TARGET ---
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: responsive.wp(4),
                                vertical: responsive.hp(1.5)
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha:0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha:0.1)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha:0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "Daily Intake",
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: responsive.hp(1.2),
                                  ),
                                ),
                                SizedBox(height: responsive.hp(0.5)),
                                dietProvider.isLoading
                                    ? SizedBox(
                                  width: responsive.hp(1.5),
                                  height: responsive.hp(1.5),
                                  child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                                    : Text(
                                  "${dietProvider.dailyCalorieTarget} kcal", // ✅ AI Calculated Value
                                  style: TextStyle(
                                    color: const Color(0xFF2ED573), // Healthy Green
                                    fontSize: responsive.hp(1.8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: responsive.hp(4)),

                      // --- SUMMARY CARD ---
                      // We can assume DailySummaryCard connects to providers internally
                      // OR you might need to update it next if it doesn't show the circle yet.
                      const Center(child: DailySummaryCard()),

                      SizedBox(height: responsive.hp(4)),

                      // --- ACTIVITY RINGS ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 1. SLEEP
                          Expanded(
                            child: ActivityCard(
                              label: "Sleep",
                              value: homeProvider.sleepValueStr,
                              color: const Color(0xFF8E44AD), // Purple
                              percentage: homeProvider.sleepPercentage,
                            ),
                          ),
                          SizedBox(width: responsive.wp(3)),
                          // 2. EXERCISE
                          Expanded(
                            child: ActivityCard(
                              label: "Exercise",
                              value: "${exerciseMinutes}m",
                              color: const Color(0xFFFFB74D), // Orange
                              percentage: exercisePercent,
                            ),
                          ),
                          SizedBox(width: responsive.wp(3)),
                          // 3. WATER
                          Expanded(
                            child: ActivityCard(
                              label: "Water",
                              value: homeProvider.waterValueStr,
                              color: const Color(0xFF4FC3F7), // Blue
                              percentage: homeProvider.waterPercentage,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: responsive.hp(4)),

                      // --- ACTION BUTTONS ---
                      Row(
                        children: [
                          Expanded(
                            child: _StyledActionButton(
                              text: "Log Sleep",
                              icon: Icons.bedtime_rounded,
                              gradientColors: const [
                                Color(0xFF512DA8),
                                Color(0xFF673AB7)
                              ],
                              onTap: () =>
                                  _showSleepDialog(context, homeProvider),
                              responsive: responsive,
                            ),
                          ),
                          SizedBox(width: responsive.wp(4)),
                          Expanded(
                            child: _StyledActionButton(
                              text: "Nutrition", // Changed from "Doctors"
                              icon: Icons.restaurant_menu_rounded, // Changed Icon
                              gradientColors: const [
                                Color(0xFFD32F2F),
                                Color(0xFFE57373)
                              ],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const NutritionScreen(),
                                  ),
                                );
                              },
                              responsive: responsive,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: responsive.hp(15)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSleepDialog(BuildContext context, HomeProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.bedtime, color: Colors.purpleAccent),
            SizedBox(width: 10),
            Text("Log Sleep", style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text("Did you get 8 hours of sleep last night?",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              provider.logSleep(8.0);
              Navigator.pop(ctx);
            },
            child:
            const Text("Confirm 8h", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// --- STYLED ACTION BUTTON (Preserved) ---
class _StyledActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final Responsive responsive;

  const _StyledActionButton({
    required this.text,
    required this.icon,
    required this.gradientColors,
    required this.onTap,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: responsive.hp(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withValues(alpha:0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: responsive.hp(2.5)),
            SizedBox(width: responsive.wp(2)),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: responsive.hp(1.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}