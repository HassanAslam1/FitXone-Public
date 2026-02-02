import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/responsive.dart';

// --- IMPORTS (Kept exactly as you had them) ---
import 'timer_workout.dart';
import 'core_exercises.dart';

class SelectWorkoutScreen extends StatefulWidget {
  const SelectWorkoutScreen({super.key});

  @override
  State<SelectWorkoutScreen> createState() => _SelectWorkoutScreenState();
}

class _SelectWorkoutScreenState extends State<SelectWorkoutScreen> {
  String? _selectedWorkout;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.wp(6)), // Optimized padding
          child: Column(
            children: [
              SizedBox(height: responsive.hp(2)),

              // 1. HEADER
              _buildHeader(context, responsive),

              SizedBox(height: responsive.hp(4)),

              // 2. THE GRID LAYOUT
              Expanded(
                child: _buildWorkoutLayout(responsive),
              ),

              // 3. START BUTTON
              _buildStartButton(responsive),

              SizedBox(height: responsive.hp(4)),
            ],
          ),
        ),
      ),
    );
  }

  // --- Header Section ---
  Widget _buildHeader(BuildContext context, Responsive responsive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back Button
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: EdgeInsets.all(responsive.wp(3)),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: responsive.hp(2.2),
            ),
          ),
        ),

        // Title
        Text(
          'Select Workout',
          style: TextStyle(
            color: Colors.white,
            fontSize: responsive.hp(2.8),
            fontWeight: FontWeight.bold,
            fontFamily: "Plus Jakarta Sans",
          ),
        ),

        // Invisible spacer to balance the row center alignment
        SizedBox(width: responsive.wp(12)),
      ],
    );
  }

  // --- Grid Layout ---
  Widget _buildWorkoutLayout(Responsive responsive) {
    // Calculated dimensions for perfect responsiveness
    final double cardWidth = responsive.wp(42);
    final double gap = responsive.hp(2);
    // Height for small cards (Running/Walking)
    final double smallHeight = responsive.hp(22);
    // Height for tall card (Core) = 2 small cards + gap
    final double tallHeight = (smallHeight * 2) + gap;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column (Running + Walking)
          Column(
            children: [
              _WorkoutCard(
                title: 'Running',
                icon: Icons.directions_run_rounded,
                width: cardWidth,
                height: smallHeight,
                isSelected: _selectedWorkout == 'Running',
                onTap: () => _select('Running'),
                responsive: responsive,
              ),
              SizedBox(height: gap),
              _WorkoutCard(
                title: 'Walking',
                icon: Icons.directions_walk_rounded,
                width: cardWidth,
                height: smallHeight,
                isSelected: _selectedWorkout == 'Walking',
                onTap: () => _select('Walking'),
                responsive: responsive,
              ),
            ],
          ),

          // Right Column (Core Exercises)
          _WorkoutCard(
            title: 'Core\nExercises', // Added newline for better vertical fit
            icon: Icons.fitness_center_rounded,
            width: cardWidth,
            height: tallHeight,
            isSelected: _selectedWorkout == 'Core Exercises',
            onTap: () => _select('Core Exercises'),
            responsive: responsive,
          ),
        ],
      ),
    );
  }

  // --- Start Button ---
  Widget _buildStartButton(Responsive responsive) {
    return SizedBox(
      width: double.infinity,
      height: responsive.hp(7),
      child: ElevatedButton(
        onPressed: _selectedWorkout == null ? null : _handleNavigation,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.cardSurface.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: _selectedWorkout == null ? 0 : 8,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
        ),
        child: _selectedWorkout == null
            ? Text(
          'Select a Workout',
          style: TextStyle(
            color: Colors.white38,
            fontSize: responsive.hp(2),
            fontWeight: FontWeight.w600,
          ),
        )
            : Text(
          'Start',
          style: TextStyle(
            color: Colors.white,
            fontSize: responsive.hp(2.4),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _select(String workout) {
    setState(() {
      _selectedWorkout = (_selectedWorkout == workout) ? null : workout;
    });
  }

  // --- NAVIGATION LOGIC (Preserved) ---
  void _handleNavigation() {
    Widget nextScreen;

    switch (_selectedWorkout) {
      case 'Running':
        nextScreen = const TimerWorkoutScreen(workoutType: 'Running');
        break;
      case 'Walking':
        nextScreen = const TimerWorkoutScreen(workoutType: 'Walking');
        break;
      case 'Core Exercises':
        nextScreen = const CoreExercisesScreen();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }
}

// --- The Card Component (Styled) ---

class _WorkoutCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final double width;
  final double height;
  final bool isSelected;
  final VoidCallback onTap;
  final Responsive responsive;

  const _WorkoutCard({
    required this.title,
    required this.icon,
    required this.width,
    required this.height,
    required this.isSelected,
    required this.onTap,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isSelected ? Colors.white : AppColors.primary;
    final Color textColor = isSelected ? Colors.white : Colors.white70;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.05),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ]
              : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Circle Background
            Container(
              padding: EdgeInsets.all(responsive.wp(4)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                icon,
                size: responsive.hp(4.5), // Responsive Icon Size
                color: iconColor,
              ),
            ),
            SizedBox(height: responsive.hp(2)),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: responsive.hp(2.0), // Responsive Font Size
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}