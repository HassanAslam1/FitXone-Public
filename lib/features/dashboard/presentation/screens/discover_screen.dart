import 'package:flutter/material.dart';
import '../../../gymNearby/presentation/events_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/responsive.dart'; // Ensure correct import path
import '../../../diet/presentation/screens/nutrition_screen.dart';
import '../../../workout/presentation/screens/select_workout.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      // Using Scaffold background for the base dark color
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          // --- OPTIONAL: Subtle Background Decoration ---
          Positioned(
            top: -responsive.hp(20),
            right: -responsive.wp(20),
            child: Container(
              width: responsive.wp(70),
              height: responsive.wp(70),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // background color (optional, usually removed if you want a pure soft glow)
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary
                        .withValues(alpha: 0.05), // Color goes here
                    blurRadius: 100, // Blur radius goes here
                    spreadRadius: 20, // Controls how much the glow expands
                  ),
                ],
              ),
            ),
          ),

          // --- MAIN CONTENT ---
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: responsive.wp(6)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: responsive.hp(4)),

                  // Title Header
                  Text(
                    "Discover your\npath to fitness.",
                    style: TextStyle(
                      // Assuming you are using Plus Jakarta Sans globally in theme
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: responsive.hp(3.8),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),

                  SizedBox(height: responsive.hp(4)),

                  // 1. Nutrition Card (Mint Green)
                  _StyledDiscoverCard(
                    responsive: responsive,
                    title: "Nutrition Plan",
                    subtitle: "Fuel your body with the perfect diet.",
                    color: const Color(0xFF00C896), // Mint
                    icon: Icons.restaurant_menu_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NutritionScreen()),
                      );
                    },
                  ),

                  SizedBox(height: responsive.hp(2.5)),

                  // 2. Workouts Card (Primary Purple)
                  _StyledDiscoverCard(
                    responsive: responsive,
                    title: "Workout Routines",
                    subtitle: "Programs designed for your goals.",
                    color: AppColors.primary,
                    icon: Icons.fitness_center_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SelectWorkoutScreen()),
                      );
                    },
                  ),

                  SizedBox(height: responsive.hp(2.5)),

                  // 3. Gyms Nearby Card (Standard Green)
                  _StyledDiscoverCard(
                    responsive: responsive,
                    title: "Find Nearby Gyms",
                    subtitle: "Explore fitness centers around you.",
                    color: const Color(0xFF4CAF50), // Grass Green
                    icon: Icons.map_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EventsScreen()),
                      );
                    },
                  ),

                  SizedBox(height: responsive.hp(15)), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- HELPER WIDGET: STYLED CARD ---
class _StyledDiscoverCard extends StatelessWidget {
  final Responsive responsive;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _StyledDiscoverCard({
    required this.responsive,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: responsive.hp(15), // Fixed height for uniform look
        padding: EdgeInsets.symmetric(
            horizontal: responsive.wp(5), vertical: responsive.hp(2)),
        decoration: BoxDecoration(
          // Subtle gradient background instead of solid color
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cardSurface,
              AppColors.cardSurface.withValues(alpha: 0.6),
              color.withValues(
                  alpha: 0.15), // Subtle tint of the accent color at the end
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          borderRadius: BorderRadius.circular(24),
          // Subtle border matching the accent color
          border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left Side: Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color, // Title uses accent color
                      fontSize: responsive.hp(2.2),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: responsive.hp(0.8)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      fontSize: responsive.hp(1.6),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // Right Side: Glowing Icon Container
            Container(
              padding: EdgeInsets.all(responsive.wp(3)),
              decoration: BoxDecoration(
                // Glass-morphism style circle
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  // Subtle inner glow effect
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: responsive.hp(3.2),
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
