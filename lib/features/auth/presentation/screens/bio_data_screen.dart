import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/responsive.dart';
import '../providers/auth_provider.dart';
import 'package:the_fit_xone/features/onboarding/presentation/screens/goal_selection_screen.dart'; // ✅ Ensure this points to your Goal Screen

class BioDataScreen extends StatelessWidget {
  // ✅ 1. Accept Data from Sign Up Screen
  final String email;
  final String password;
  final String name;

  const BioDataScreen({
    super.key,
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -responsive.hp(5),
            left: -responsive.wp(20),
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

          SafeArea(
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Column(
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: responsive.wp(4),
                          vertical: responsive.hp(1)),
                      child: Row(
                        children: [
                          IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () => Navigator.pop(context)),
                          Expanded(
                              child: Center(
                                  child: Text("Step 1 of 2",
                                      style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: responsive.hp(1.6))))),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding:
                        EdgeInsets.symmetric(horizontal: responsive.wp(6)),
                        child: Column(
                          children: [
                            SizedBox(height: responsive.hp(3)),
                            Text("Tell us about\nyourself",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: responsive.hp(3.5),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2)),
                            SizedBox(height: responsive.hp(5)),

                            // AGE
                            _GlassSelector(
                              responsive: responsive,
                              value: "${authProvider.age}",
                              label: "Your Age",
                              icon: Icons.calendar_today_rounded,
                              onTap: () => _showNumberPicker(
                                  context,
                                  "Age",
                                  16,
                                  100,
                                  authProvider.age,
                                      (val) => authProvider.setAge(val),
                                  unit: "yo"),
                            ),
                            SizedBox(height: responsive.hp(2)),

                            // GENDER
                            _GlassSelector(
                              responsive: responsive,
                              value: authProvider.gender,
                              label: "Your Gender",
                              icon: Icons.wc_rounded,
                              onTap: () =>
                                  _showGenderPicker(context, authProvider),
                            ),
                            SizedBox(height: responsive.hp(2)),

                            // WEIGHT
                            _GlassSelector(
                              responsive: responsive,
                              value: "${authProvider.weight} kg",
                              label: "Your Weight",
                              icon: Icons.monitor_weight_outlined,
                              onTap: () => _showNumberPicker(
                                  context,
                                  "Weight",
                                  30,
                                  200,
                                  authProvider.weight,
                                      (val) => authProvider.setWeight(val),
                                  unit: "kg"),
                            ),
                            SizedBox(height: responsive.hp(2)),

                            // HEIGHT
                            _GlassSelector(
                              responsive: responsive,
                              value: "${authProvider.height} cm",
                              label: "Your Height",
                              icon: Icons.height_rounded,
                              onTap: () => _showNumberPicker(
                                  context,
                                  "Height",
                                  100,
                                  250,
                                  authProvider.height,
                                      (val) => authProvider.setHeight(val),
                                  unit: "cm"),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Next Button
                    Padding(
                      padding: EdgeInsets.all(responsive.wp(6)),
                      child: SizedBox(
                        width: double.infinity,
                        height: responsive.hp(6.5),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16))),
                          onPressed: () {
                            // ✅ 2. PASS EVERYTHING TO THE NEXT SCREEN
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GoalSelectionScreen(
                                  email: email,
                                  password: password,
                                  name: name,
                                  age: authProvider.age,
                                  gender: authProvider.gender,
                                  // Convert int to double for consistency
                                  weight: authProvider.weight.toDouble(),
                                  height: authProvider.height.toDouble(),
                                ),
                              ),
                            );
                          },
                          child: Text("Next",
                              style: TextStyle(
                                  fontSize: responsive.hp(2),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- PICKER LOGIC (UNCHANGED) ---
  void _showNumberPicker(BuildContext context, String title, int min, int max,
      int current, Function(int) onSelected,
      {String unit = ""}) {
    List<int> values = List.generate(max - min + 1, (index) => min + index);

    int initialIndex = values.indexOf(current);
    if (initialIndex == -1) initialIndex = 0;

    int selectedIndex = initialIndex;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            height: 350,
            decoration: const BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(10))),
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text("Select $title",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold))),
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    controller:
                    FixedExtentScrollController(initialItem: initialIndex),
                    itemExtent: 60,
                    magnification: 1.2,
                    useMagnifier: true,
                    perspective: 0.003,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedIndex = index;
                      });
                      onSelected(values[index]);
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: values.length,
                      builder: (context, index) {
                        final isSelected = index == selectedIndex;
                        return Container(
                          height: 60,
                          alignment: Alignment.center,
                          child: Text("${values[index]} $unit",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.white)),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary),
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text("Confirm",
                                style: TextStyle(color: Colors.white))))),
              ],
            ),
          );
        });
      },
    );
  }

  void _showGenderPicker(BuildContext context, AuthProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            ...["Male", "Female", "Other"].map((g) => ListTile(
              title: Text(g,
                  style: TextStyle(
                      color: provider.gender == g
                          ? AppColors.primary
                          : Colors.white,
                      fontWeight: FontWeight.bold)),
              trailing: provider.gender == g
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () {
                provider.setGender(g);
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }
}

class _GlassSelector extends StatelessWidget {
  final Responsive responsive;
  final String value, label;
  final IconData icon;
  final VoidCallback onTap;
  const _GlassSelector(
      {required this.responsive,
        required this.value,
        required this.label,
        required this.icon,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(responsive.wp(4)),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
                padding: EdgeInsets.all(responsive.wp(3)),
                decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: Icon(icon,
                    color: AppColors.primary, size: responsive.hp(2.5))),
            SizedBox(width: responsive.wp(4)),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.white54, fontSize: responsive.hp(1.6))),
              SizedBox(height: responsive.hp(0.5)),
              Text(value,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: responsive.hp(2.2),
                      fontWeight: FontWeight.bold)),
            ]),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white24, size: responsive.hp(2)),
          ],
        ),
      ),
    );
  }
}