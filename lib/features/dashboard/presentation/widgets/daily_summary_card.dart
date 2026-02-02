import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/responsive.dart';
import '../../../diet/presentation/providers/diet_provider.dart'; // ✅ Import Diet Provider

class DailySummaryCard extends StatelessWidget {
  const DailySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Initialize Responsive
    final responsive = Responsive(context);

    // 2. Listen to DietProvider
    return Consumer<DietProvider>(
      builder: (context, dietProvider, child) {
        // Calculate Percentage (0.0 to 1.0)
        final double percentage = dietProvider.progressPercentage;

        // Calculate Ticks (Total 60 ticks)
        // e.g., 50% = 30 ticks
        final int activeTicks = (percentage * 60).round();

        return Container(
          width: responsive.wp(70), // Responsive Width
          height: responsive.wp(70), // Responsive Height
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha:0.05),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha:0.05),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Custom Painter for the ticks
              SizedBox(
                width: responsive.wp(55),
                height: responsive.wp(55),
                child: CustomPaint(
                  painter: _TickPainter(
                    activeTickCount: activeTicks,
                    primaryColor: const Color(0xFF2ED573), // Healthy Green
                  ),
                ),
              ),

              // Inner Text
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Icon(
                      Icons.local_fire_department_rounded,
                      color: const Color(0xFF2ED573),
                      size: responsive.hp(3.5)
                  ),

                  SizedBox(height: responsive.hp(1)),

                  // Percentage Text
                  Text(
                    "${(percentage * 100).toInt()}%",
                    style: TextStyle(
                      fontSize: responsive.hp(5.5),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: "Plus Jakarta Sans",
                    ),
                  ),

                  // Calorie Subtitle
                  Text(
                    "${dietProvider.caloriesConsumed} / ${dietProvider.dailyCalorieTarget}",
                    style: TextStyle(
                      fontSize: responsive.hp(1.8),
                      color: Colors.white54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: responsive.hp(0.5)),

                  Text(
                    "kcal eaten",
                    style: TextStyle(
                      fontSize: responsive.hp(1.4),
                      color: AppColors.textSecondary.withValues(alpha:0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// Custom Painter to draw the dashes/ticks
class _TickPainter extends CustomPainter {
  final int activeTickCount;
  final Color primaryColor;

  _TickPainter({required this.activeTickCount, required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..strokeWidth = 3 // Slightly thicker for better visibility
      ..strokeCap = StrokeCap.round;

    // Draw 60 ticks
    for (int i = 0; i < 60; i++) {
      // Calculate angle (Starting from top - pi/2)
      final angle = (2 * pi * i) / 60;

      // Determine color
      // Logic: If current index 'i' is less than active count, paint it Green
      final isActive = i < activeTickCount;
      paint.color = isActive ? primaryColor : Colors.white.withValues(alpha:0.1);

      // Draw tick
      final innerRadius = radius - 15; // Length of tick
      final outerRadius = radius;

      final p1 = Offset(
        center.dx + innerRadius * cos(angle - pi / 2),
        center.dy + innerRadius * sin(angle - pi / 2),
      );

      final p2 = Offset(
        center.dx + outerRadius * cos(angle - pi / 2),
        center.dy + outerRadius * sin(angle - pi / 2),
      );

      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TickPainter oldDelegate) {
    return oldDelegate.activeTickCount != activeTickCount;
  }
}