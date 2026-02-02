import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_fit_xone/features/auth/presentation/providers/auth_provider.dart';
import 'package:the_fit_xone/features/dashboard/presentation/screens/main_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/responsive.dart';

class GoalSelectionScreen extends StatefulWidget {
  // ✅ 1. Accept ALL Data from previous screens
  final String email;
  final String password;
  final String name;
  final int age;
  final String gender;
  final double weight;
  final double height;

  const GoalSelectionScreen({
    super.key,
    this.email = '',    // Default values to prevent errors if tested standalone
    this.password = '',
    this.name = '',
    this.age = 25,
    this.gender = 'Male',
    this.weight = 70,
    this.height = 170,
  });

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  // Local state for immediate UI feedback
  String _selectedGoal = "Get fit";

  final List<Map<String, dynamic>> goals = [
    {"title": "Get fit", "icon": Icons.fitness_center_outlined},
    {"title": "Be active", "icon": Icons.directions_run_outlined},
    {"title": "Be healthy", "icon": Icons.monitor_heart_outlined},
    {"title": "Find balance", "icon": Icons.spa_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    // Watch the status to trigger the overlay
    final isLoading = context.watch<AuthProvider>().status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          // -----------------------------------------------------------
          // LAYER 1: BACKGROUND GLOW (Same as before)
          // -----------------------------------------------------------
          Positioned(
            bottom: -responsive.hp(10),
            right: -responsive.wp(20),
            child: Container(
              width: responsive.wp(70),
              height: responsive.wp(70),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.12),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 100,
                      spreadRadius: 20)
                ],
              ),
            ),
          ),

          // -----------------------------------------------------------
          // LAYER 2: MAIN CONTENT
          // -----------------------------------------------------------
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: responsive.wp(4),
                      vertical: responsive.hp(1)),
                  child: Row(
                    children: [
                      // Disable Back Button if Loading
                      IgnorePointer(
                        ignoring: isLoading,
                        child: IconButton(
                            icon: Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: responsive.hp(2.5)),
                            onPressed: () => Navigator.pop(context)),
                      ),
                      Expanded(
                          child: Center(
                              child: Text("Step 2 of 2",
                                  style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: responsive.hp(1.6))))),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: responsive.wp(6)),
                    child: Column(
                      children: [
                        SizedBox(height: responsive.hp(3)),
                        Text("What’s your\nmain goal?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: responsive.hp(3.5),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2)),
                        SizedBox(height: responsive.hp(4)),

                        // --- GOAL GRID ---
                        Expanded(
                          child: AbsorbPointer(
                            absorbing: isLoading, // Stop clicks when loading
                            child: GridView.builder(
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: responsive.wp(4),
                                  mainAxisSpacing: responsive.wp(4),
                                  childAspectRatio: 0.85),
                              itemCount: goals.length,
                              itemBuilder: (context, index) {
                                final goal = goals[index];
                                final isSelected =
                                    _selectedGoal == goal['title'];
                                return _GoalCard(
                                  title: goal['title'],
                                  icon: goal['icon'],
                                  isSelected: isSelected,
                                  responsive: responsive,
                                  onTap: () {
                                    setState(() {
                                      _selectedGoal = goal['title'];
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- FINISH BUTTON ---
                Padding(
                  padding: EdgeInsets.all(responsive.wp(6)),
                  child: SizedBox(
                    height: responsive.hp(6.5),
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 8),
                      // Disable click if loading
                      onPressed: isLoading
                          ? null
                          : () async {
                        // 1. CAPTURE REFERENCES BEFORE ASYNC
                        // We grab the messenger now, while we know 'context' is definitely safe.
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        final provider = Provider.of<AuthProvider>(context, listen: false);

                        try {
                          // 2. Perform Async Operation
                          await provider.completeRegistration(
                            email: widget.email,
                            password: widget.password,
                            name: widget.name,
                            age: widget.age,
                            gender: widget.gender,
                            weight: widget.weight,
                            height: widget.height,
                            goal: _selectedGoal,
                          );

                          // 3. Success Navigation
                          // We check provider status directly from our captured variable
                          if (provider.status == AuthStatus.authenticated) {
                            // Use the captured 'navigator' to remove the warning here too
                            navigator.pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const MainScreen()),
                                  (route) => false,
                            );
                          }
                        } catch (e) {
                          // 4. Handle Error safely
                          // Use the captured 'scaffoldMessenger' variable.
                          // The linter is happy because this variable doesn't depend on 'context' anymore.
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Text("Finish",
                          style: TextStyle(
                              fontSize: responsive.hp(2),
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // -----------------------------------------------------------
          // LAYER 3: THE NEW LOADING OVERLAY (Shows only if isLoading)
          // -----------------------------------------------------------
          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.7), // Dim Background
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Creating Profile...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: responsive.hp(2),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Setting up your dashboard",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: responsive.hp(1.5),
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Responsive responsive;

  const _GoalCard(
      {required this.title,
        required this.icon,
        required this.isSelected,
        required this.onTap,
        required this.responsive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: 0.05),
              width: isSelected ? 2 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: EdgeInsets.all(responsive.wp(4)),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.05)),
                child: Icon(icon,
                    size: responsive.hp(3.5),
                    color: isSelected ? Colors.white : Colors.white54)),
            SizedBox(height: responsive.hp(2)),
            Text(title,
                style: TextStyle(
                    fontSize: responsive.hp(1.8),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.white70)),
          ],
        ),
      ),
    );
  }
}