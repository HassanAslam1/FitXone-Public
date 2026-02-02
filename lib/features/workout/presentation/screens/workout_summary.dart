import 'package:flutter/material.dart';
import 'package:the_fit_xone/core/constants/app_colors.dart';
import 'package:the_fit_xone/core/constants/responsive.dart';
import 'package:the_fit_xone/features/workout/presentation/screens/core_exercises.dart';

class WorkoutSummaryScreen extends StatefulWidget {
  final String workoutType;
  final Duration totalTime;
  final int caloriesBurned;
  final List<ExerciseModel>? completedCoreExercises;

  const WorkoutSummaryScreen({
    super.key,
    required this.workoutType,
    required this.totalTime,
    required this.caloriesBurned,
    this.completedCoreExercises,
  });

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    // Format time logic (Preserved)
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String timeString =
        "${twoDigits(widget.totalTime.inMinutes)}:${twoDigits(widget.totalTime.inSeconds.remainder(60))}";

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          // ------------------------------------------------
          // 1. BACKGROUND GLOW (Consistent with other screens)
          // ------------------------------------------------
          Positioned(
            top: -responsive.hp(10),
            left: -responsive.wp(20),
            child: Container(
              width: responsive.wp(80),
              height: responsive.wp(80),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha:0.15),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.wp(6)),
              child: Column(
                children: [
                  // --- SCROLLABLE CONTENT ---
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: responsive.hp(3)),

                          // Header
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(responsive.wp(4)),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardSurface,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: Icon(
                                    Icons.emoji_events_rounded,
                                    color: Colors.amber,
                                    size: responsive.hp(4),
                                  ),
                                ),
                                SizedBox(height: responsive.hp(2)),
                                Text(
                                  "Workout Summary",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: responsive.hp(2.8),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Plus Jakarta Sans',
                                  ),
                                ),
                                SizedBox(height: responsive.hp(0.5)),
                                Text(
                                  "Great job! Here's how you performed.",
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: responsive.hp(1.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: responsive.hp(4)),

                          // Big Stats Cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildBigStatCard(
                                  responsive,
                                  "Total Time",
                                  timeString,
                                  Icons.timer_rounded,
                                  Colors.blueAccent,
                                ),
                              ),
                              SizedBox(width: responsive.wp(4)),
                              Expanded(
                                child: _buildBigStatCard(
                                  responsive,
                                  "Total Burn",
                                  "${widget.caloriesBurned}",
                                  Icons.local_fire_department_rounded,
                                  AppColors.mutedOrange,
                                  unit: "kcal",
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: responsive.hp(4)),

                          // Conditional Content (Logic Preserved)
                          if (widget.workoutType == "Core Exercises") ...[
                            Text(
                              "Exercise Breakdown",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: responsive.hp(2.2),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: responsive.hp(2)),
                            _buildCoreStatsList(responsive),
                          ] else ...[
                            // FOR RUNNING / WALKING
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(responsive.wp(5)),
                              decoration: BoxDecoration(
                                color: AppColors.cardSurface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: Colors.white10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha:0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    widget.workoutType == "Running"
                                        ? Icons.directions_run_rounded
                                        : Icons.directions_walk_rounded,
                                    color: Colors.white70,
                                    size: responsive.hp(5),
                                  ),
                                  SizedBox(height: responsive.hp(2)),
                                  Text(
                                    "Excellent Pace!",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: responsive.hp(2.2),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: responsive.hp(1)),
                                  Text(
                                    "You kept moving consistently.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: responsive.hp(1.8)),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          SizedBox(height: responsive.hp(4)),
                        ],
                      ),
                    ),
                  ),

                  // --- BOTTOM BUTTON ---
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: responsive.hp(3), top: responsive.hp(2)),
                    child: SizedBox(
                      width: double.infinity,
                      height: responsive.hp(6.5), // Consistent height
                      child: ElevatedButton(
                        onPressed: () => Navigator.popUntil(
                            context, (route) => route.isFirst),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 8,
                          shadowColor: AppColors.primary.withValues(alpha:0.4),
                        ),
                        child: Text(
                          "Back to Home",
                          style: TextStyle(
                              fontSize: responsive.hp(2.0),
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- STAT CARD WIDGET ---
  Widget _buildBigStatCard(Responsive responsive, String label, String value,
      IconData icon, Color color,
      {String? unit}) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: responsive.hp(2.5),
          horizontal: responsive.wp(4)
      ),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(responsive.wp(2.5)),
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: responsive.hp(3)),
          ),
          SizedBox(height: responsive.hp(1.5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.hp(2.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit != null) ...[
                SizedBox(width: responsive.wp(1)),
                Text(
                  unit,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: responsive.hp(1.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ]
            ],
          ),
          SizedBox(height: responsive.hp(0.5)),
          Text(
            label,
            style: TextStyle(
                color: Colors.white54,
                fontSize: responsive.hp(1.6)
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIC PRESERVED (Calculation & List Generation) ---
  Widget _buildCoreStatsList(Responsive responsive) {
    final exercises = widget.completedCoreExercises;
    if (exercises == null || exercises.isEmpty) return const SizedBox.shrink();

    // --- Calculation Logic (Untouched) ---
    final Map<String, double> intensityWeights = {
      'Push Ups': 8.0,
      'Pull Ups': 8.0,
      'Squats': 5.0,
      'Sit Ups': 3.8,
      'Crunches': 2.8,
      'default': 4.0,
    };

    double totalEffortPoints = 0.0;
    final Map<int, double> exerciseEffortMap = {};

    for (int i = 0; i < exercises.length; i++) {
      final exercise = exercises[i];
      final key = intensityWeights.keys.firstWhere(
              (k) => k.toLowerCase() == exercise.name.toLowerCase(),
          orElse: () => 'default');
      final double weight = intensityWeights[key]!;
      final double effort = exercise.durationSeconds * weight;
      exerciseEffortMap[i] = effort;
      totalEffortPoints += effort;
    }

    if (totalEffortPoints == 0) totalEffortPoints = 1;
    // ------------------------------------

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exercises.length,
      separatorBuilder: (c, i) => SizedBox(height: responsive.hp(1.5)),
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        final double myEffort = exerciseEffortMap[index] ?? 0;
        final double sharePercentage = myEffort / totalEffortPoints;
        final int myCalories =
        (sharePercentage * widget.caloriesBurned).round();

        return Container(
          padding: EdgeInsets.symmetric(
              horizontal: responsive.wp(4), vertical: responsive.hp(2)),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha:0.05)),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(responsive.wp(2.5)),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.fitness_center_rounded,
                    color: AppColors.primary, size: responsive.hp(2.2)),
              ),
              SizedBox(width: responsive.wp(4)),

              // Name & Reps
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: responsive.hp(2.0),
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: responsive.hp(0.5)),
                    Text(
                      "Completed Set",
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: responsive.hp(1.6),
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              // Calories
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "+$myCalories",
                    style: TextStyle(
                        color: AppColors.mutedOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: responsive.hp(2.0)),
                  ),
                  Text(
                    "kcal",
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: responsive.hp(1.4)
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}