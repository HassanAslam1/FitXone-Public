import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/responsive.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    // Reduced height for a sleeker look
    final double navHeight = responsive.hp(7.5);
    final double iconSize = responsive.hp(2.6);

    return Container(
      // Tighter margins to feel less "disconnected"
      margin: EdgeInsets.fromLTRB(
          responsive.wp(6), // Horizontal
          0,
          responsive.wp(6),
          responsive.hp(2.5) // Bottom margin (closer to edge)
      ),
      height: navHeight,
      decoration: BoxDecoration(
        // Use .withOpacity() if .withValues() isn't supported in your Flutter version yet,
        // but sticking to .withValues as per your request.
        color: AppColors.cardSurface.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(25), // Slightly softer curve
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavIcon(
            // CLOSEST MATCH to 'home_app_logo' in standard icons
            icon: Icons.cottage_rounded,
            label: "Home",
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
            responsive: responsive,
            baseIconSize: iconSize,
          ),
          _NavIcon(
            // "Compass" is perfect for Discover
            icon: Icons.explore_rounded,
            label: "Discover",
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
            responsive: responsive,
            baseIconSize: iconSize,
          ),

          // --- CENTER ADD BUTTON ---
          GestureDetector(
            onTap: () => onTap(2),
            child: Container(
              width: responsive.hp(5.5),
              height: responsive.hp(5.5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: responsive.hp(3.2)
              ),
            ),
          ),

          _NavIcon(
            // "Insights" is more semantic than "bar_chart"
            icon: Icons.insights_rounded,
            label: "Insights",
            isSelected: currentIndex == 3,
            onTap: () => onTap(3),
            responsive: responsive,
            baseIconSize: iconSize,
          ),
          _NavIcon(
            // "Account Circle" looks fuller and friendlier
            icon: Icons.account_circle_rounded,
            label: "Profile",
            isSelected: currentIndex == 4,
            onTap: () => onTap(4),
            responsive: responsive,
            baseIconSize: iconSize,
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Responsive responsive;
  final double baseIconSize;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.responsive,
    required this.baseIconSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: responsive.wp(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary.withValues(alpha: 0.7),
                size: isSelected ? baseIconSize * 1.1 : baseIconSize,
              ),
            ),
            SizedBox(height: responsive.hp(0.4)),

            Text(
              label,
              style: TextStyle(
                fontSize: responsive.hp(1.1),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary.withValues(alpha: 0.7),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}