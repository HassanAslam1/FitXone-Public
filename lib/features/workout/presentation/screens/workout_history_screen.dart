import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/responsive.dart';
import '../../data/repositories/workout_repository.dart';
import '../../domain/entities/workout_entity.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final WorkoutRepository repository = WorkoutRepository();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: responsive.hp(2.5)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "History",
          style: TextStyle(
            color: Colors.white,
            fontSize: responsive.hp(2.5),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.wp(6)),
          child: Column(
            children: [
              SizedBox(height: responsive.hp(2)),

              // --- 1. Header Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Progress",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: responsive.hp(1.8),
                          letterSpacing: 1.1,
                        ),
                      ),
                      SizedBox(height: responsive.hp(0.5)),
                      Text(
                        DateFormat('MMMM yyyy').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: responsive.hp(3.5),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(responsive.wp(2.5)),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Icon(Icons.calendar_month,
                        color: AppColors.primary, size: responsive.hp(2.5)),
                  ),
                ],
              ),

              SizedBox(height: responsive.hp(3)),

              // --- 2. List Section ---
              Expanded(
                child: StreamBuilder<List<WorkoutEntity>>(
                  stream: repository.getWorkoutHistory(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyState(responsive);
                    }

                    final workouts = snapshot.data!;
                    // Sort: Newest first
                    workouts.sort((a, b) => b.date.compareTo(a.date));

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: workouts.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: responsive.hp(1.5)),
                      itemBuilder: (context, index) {
                        return _HistoryCard(
                          workout: workouts[index],
                          responsive: responsive,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Responsive responsive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center,
              color: Colors.white24, size: responsive.hp(8)),
          SizedBox(height: responsive.hp(2)),
          Text(
            "No workouts yet",
            style: TextStyle(
                color: Colors.white,
                fontSize: responsive.hp(2.5),
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: responsive.hp(1)),
          Text(
            "Start your journey today!",
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: responsive.hp(1.8)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Simplified & Efficient Card
// ---------------------------------------------------------------------------
class _HistoryCard extends StatelessWidget {
  final WorkoutEntity workout;
  final Responsive responsive;

  const _HistoryCard({
    required this.workout,
    required this.responsive,
  });

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Running':
        return Icons.directions_run;
      case 'Walking':
        return Icons.directions_walk;
      case 'Core Exercises':
        return Icons.fitness_center;
      default:
        return Icons.bolt;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Formatting
    final dateStr =
        DateFormat('MMM d').format(workout.date); // Short Date: "Oct 12"
    final timeStr =
        DateFormat('jm').format(workout.date); // Short Time: "10:30 AM"

    return Container(
      // Comfortable Padding (Bigger looking)
      padding: EdgeInsets.all(responsive.wp(4)),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // --- 1. BIGGER ICON (Fixed Width) ---
          Container(
            height: responsive.hp(6.5), // Bigger size
            width: responsive.hp(6.5),
            decoration: BoxDecoration(
              color: AppColors.bgcolor,
              shape: BoxShape.circle,
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Icon(
              _getIconForType(workout.type),
              color: AppColors.primary,
              size: responsive.hp(3.0),
            ),
          ),

          SizedBox(width: responsive.wp(3.5)),

          // --- 2. SMART CONTENT COLUMN (Takes all remaining space) ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // TOP ROW: Name + Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Name (Flexible, prevents overflow)
                    Expanded(
                      child: Text(
                        workout.type,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, // <--- SAFETY LOCK
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: responsive.hp(2.1), // Bigger Font
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Date (Fixed at right)
                    Text(
                      dateStr,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: responsive.hp(1.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: responsive.hp(0.8)),

                // BOTTOM ROW: Calories + Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Calories Section
                    Row(
                      children: [
                        Icon(Icons.local_fire_department,
                            color: AppColors.mutedOrange,
                            size: responsive.hp(1.8)),
                        SizedBox(width: responsive.wp(1)),
                        Text(
                          "${workout.caloriesBurned} kcal",
                          style: TextStyle(
                            color: AppColors.mutedOrange,
                            fontSize: responsive.hp(1.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // Time Section
                    Text(
                      timeStr,
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                        fontSize: responsive.hp(1.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
