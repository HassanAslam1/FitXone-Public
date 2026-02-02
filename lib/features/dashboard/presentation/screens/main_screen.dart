import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_fit_xone/features/auth/presentation/providers/home_provider.dart';
import 'package:the_fit_xone/features/dashboard/presentation/screens/discover_screen.dart';
import 'package:the_fit_xone/features/dashboard/presentation/screens/home_screen.dart';
import 'package:the_fit_xone/features/dashboard/presentation/screens/insights_screen.dart';
import 'package:the_fit_xone/features/dashboard/presentation/screens/profile_screen.dart';
import 'package:the_fit_xone/features/diet/presentation/screens/nutrition_screen.dart';
import 'package:the_fit_xone/core/constants/app_colors.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static final List<Widget> _screens = [
    const HomeScreen(key: PageStorageKey('HomeScreen')),
    const DiscoverScreen(key: PageStorageKey('DiscoverScreen')),
    const SizedBox(), // Placeholder for Add button
    const InsightsScreen(key: PageStorageKey('InsightsScreen')),
    const ProfileScreen(key: PageStorageKey('ProfileScreen')),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: Stack(
            children: [
              IndexedStack(
                index: homeProvider.currentIndex,
                children: _screens,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: CustomBottomNav(
                  currentIndex: homeProvider.currentIndex,
                  onTap: (index) {
                    if (index == 2) {
                      _showQuickAddMenu(context);
                    } else {
                      homeProvider.setIndex(index);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // THE REDESIGNED QUICK ADD MENU
  // -------------------------------------------------------------------------
  void _showQuickAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          decoration: BoxDecoration(
            color: AppColors.cardSurface.withValues(alpha:0.98),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(35),
              topRight: Radius.circular(35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.5),
                blurRadius: 50,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),

              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 35),

              // Responsive Grid of Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickActionItem(
                    icon: Icons.local_drink_rounded,
                    label: "Add Water",
                    color: AppColors.fruit4,
                    gradient: [
                       AppColors.fruit8.withValues(alpha:0.2),
                       AppColors.fruit9.withValues(alpha:0.05)
                    ],
                    onTap: () {
                      Navigator.pop(sheetContext);
                      context.read<HomeProvider>().logWater(250);
                      _showSuccessSnackBar(context, "💧 250ml Water logged!");
                    },
                  ),
                  _QuickActionItem(
                    icon: Icons.restaurant_menu_rounded,
                    label: "Track Meal",
                    color:  AppColors.fruit2, // Soft Orange
                    gradient: [
                      AppColors.fruit7.withValues(alpha:0.2),
                      AppColors.fruit1.withValues(alpha:0.05)
                    ],
                    onTap: () {
                      Navigator.pop(sheetContext);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const NutritionScreen()));
                    },
                  ),
                  _QuickActionItem(
                    icon: Icons.bed_rounded,
                    label: "Log Sleep",
                    color: AppColors.fruit6, // Soft Purple
                    gradient: [
                      AppColors.fruit6.withValues(alpha:0.2),
                      AppColors.fruit6.withValues(alpha:0.05)
                    ],
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showSleepUpdateDialog(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  // Dialog for Logging Sleep
  void _showSleepUpdateDialog(BuildContext context) {
    final TextEditingController sleepController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cardSurface,
          title: const Text("Log Sleep", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: sleepController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter hours (e.g. 7.5)",
              hintStyle: TextStyle(color: Colors.grey[600]),
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurpleAccent)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                final val = double.tryParse(sleepController.text);
                if (val != null) {
                  context.read<HomeProvider>().logSleep(val);
                  Navigator.pop(dialogContext);
                  _showSuccessSnackBar(context, "Sleep updated to $val hours!");
                }
              },
              child: const Text("Save",
                  style: TextStyle(color: Colors.deepPurpleAccent)),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.cardSurface,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// -------------------------------------------------------------------------
// STYLISH ACTION ITEM WIDGET
// -------------------------------------------------------------------------
class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
              border: Border.all(
                color: color.withValues(alpha:0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha:0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}