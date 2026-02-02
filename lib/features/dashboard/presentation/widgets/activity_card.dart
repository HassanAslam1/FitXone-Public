import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ActivityCard extends StatelessWidget {
  final String label;
  final String value; // e.g., "93%"
  final Color color;
  final double percentage; // 0.0 to 1.0

  const ActivityCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // The Ring
        SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Circle (faint)
              // Fixed: Added const here
              const CircularProgressIndicator(
                value: 1.0,
                color: AppColors.cardSurface,
                strokeWidth: 6,
              ),
              // Actual Progress
              CircularProgressIndicator(
                value: percentage,
                color: color,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
              ),
              // Text in Center
              Center(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Label
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
