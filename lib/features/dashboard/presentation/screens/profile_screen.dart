import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_fit_xone/features/auth/presentation/providers/auth_provider.dart';
import 'package:the_fit_xone/features/auth/presentation/screens/login_screen.dart';
import 'package:the_fit_xone/features/workout/presentation/screens/workout_history_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/responsive.dart';
import '../../../diet/presentation/providers/diet_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).loadUserData();
    });
  }

  // --- 1. EDIT PROFILE DIALOG (Logic Preserved) ---
  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final TextEditingController nameController =
    TextEditingController(text: authProvider.user?.displayName ?? "");
    final TextEditingController weightController =
    TextEditingController(text: authProvider.weight.toString());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.cardSurface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              title: const Text("Edit Profile",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogTextField(
                      controller: nameController,
                      label: "Display Name",
                      icon: Icons.person),
                  const SizedBox(height: 16),
                  _buildDialogTextField(
                      controller: weightController,
                      label: "Weight (kg)",
                      icon: Icons.monitor_weight,
                      isNumber: true),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(ctx),
                  child: Text("Cancel",
                      style: TextStyle(
                          color: isSaving ? Colors.grey : Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                    setState(() {
                      isSaving = true;
                    });

                    // 1. CAPTURE REFERENCES BEFORE ASYNC
                    // This removes the "BuildContext across async gaps" warning completely
                    // because we grab the objects while the context is definitely valid.
                    final navigator = Navigator.of(ctx);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final dietProvider = Provider.of<DietProvider>(context, listen: false);

                    try {
                      // 2. Update Auth Profile
                      await authProvider.updateUserProfile(
                          name: nameController.text.trim(),
                          weight: weightController.text.trim());

                      // 3. Recalculate Diet
                      final int newWeight = int.tryParse(weightController.text.trim()) ?? authProvider.weight;

                      await dietProvider.recalculateTargetPreservingLogs(
                        authProvider.age,
                        authProvider.gender,
                        newWeight,
                        authProvider.height,
                        authProvider.goal,
                      );

                      // 4. USE CAPTURED REFERENCES
                      // No 'mounted' check needed for these variables since they are already captured.
                      navigator.pop();

                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: const Text("Profile & Calories updated!"),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    } catch (e) {
                      // Handle potential errors (optional but good practice)
                      setState(() => isSaving = false);
                    }
                  },
                  child: isSaving
                      ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : const Text("Save Changes",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- 2. PERSONAL DATA POPUP (Logic Preserved) ---
  void _showPersonalDataDialog(BuildContext context, String? email) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha:0.1)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha:0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_rounded,
                  color: AppColors.primary, size: 40),
              const SizedBox(height: 16),
              const Text("Personal Account",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha:0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email_outlined,
                        color: Colors.white70, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        email ?? "No Email Found",
                        style:
                        const TextStyle(color: Colors.white, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Close",
                      style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    String initial = "U";
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      initial = user.displayName![0].toUpperCase();
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          // --- BACKGROUND GLOW ---
          Positioned(
            top: -responsive.hp(15), // Moved higher up
            right: -responsive.wp(25),
            child: Container(
              width: responsive.wp(80),
              height: responsive.wp(80),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha:0.06),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withValues(alpha:0.06),
                      blurRadius: 100,
                      spreadRadius: 20)
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: responsive.wp(6)),
              child: Column(
                children: [
                  SizedBox(height: responsive.hp(1.5)), // Reduced top spacing

                  // TITLE
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "My Profile",
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: responsive.hp(3.0), // Slightly smaller
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(height: responsive.hp(3)), // Reduced spacing

                  // --- AVATAR (Optimized Size) ---
                  Container(
                    padding: const EdgeInsets.all(3), // Thinner border padding
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cardSurface,
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.primary.withValues(alpha:0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8))
                      ],
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: responsive.hp(5.5), // ✅ REDUCED from 7
                      backgroundColor: Colors.grey[800],
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? Text(
                        initial,
                        style: TextStyle(
                          fontSize: responsive.hp(4),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                          : null,
                    ),
                  ),

                  SizedBox(height: responsive.hp(1.5)), // Reduced

                  // NAME
                  Text(
                    user?.displayName?.isNotEmpty == true
                        ? user!.displayName!
                        : (user?.email.split('@')[0] ?? "User"),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: responsive.hp(2.4), // Slightly smaller
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: responsive.hp(0.5)),

                  // GOAL PILL
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: responsive.wp(3.5),
                        vertical: responsive.hp(0.5)),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha:0.2)),
                    ),
                    child: Text(
                      "Goal: ${authProvider.goal}",
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: responsive.hp(1.5),
                          fontWeight: FontWeight.w600),
                    ),
                  ),

                  SizedBox(height: responsive.hp(2)),

                  // --- EDIT PROFILE BUTTON (Optimized) ---
                  TextButton.icon(
                    onPressed: () =>
                        _showEditProfileDialog(context, authProvider),
                    icon: Icon(Icons.edit_rounded,
                        color: Colors.white70, size: responsive.hp(1.8)),
                    label: Text("Edit Profile",
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: responsive.hp(1.5))),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha:0.05),
                      padding: EdgeInsets.symmetric(
                          horizontal: responsive.wp(4),
                          vertical: responsive.hp(0.8)), // Slimmer button
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      minimumSize: Size.zero, // Removes default constraints
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),

                  SizedBox(height: responsive.hp(3.5)), // Spacing before Stats

                  // --- STATS ROW (Optimized) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Better spacing
                    children: [
                      _ProfileStat(
                          label: "Height",
                          value: "${authProvider.height}cm",
                          responsive: responsive),
                      _ProfileStat(
                          label: "Weight",
                          value: "${authProvider.weight}kg",
                          responsive: responsive),
                      _ProfileStat(
                          label: "Age",
                          value: "${authProvider.age}yo",
                          responsive: responsive),
                    ],
                  ),

                  SizedBox(height: responsive.hp(3.5)), // Spacing before Menu

                  // --- MENU OPTIONS (Compact) ---
                  _ProfileMenuTile(
                    icon: Icons.person_outline_rounded,
                    title: "Personal Data",
                    subtitle: "View account details",
                    responsive: responsive,
                    onTap: () => _showPersonalDataDialog(context, user?.email),
                  ),

                  SizedBox(height: responsive.hp(1.5)), // Reduced gap

                  _ProfileMenuTile(
                    icon: Icons.history_rounded,
                    title: "Workout History",
                    subtitle: "Check your past sessions",
                    responsive: responsive,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const WorkoutHistoryScreen()));
                    },
                  ),

                  SizedBox(height: responsive.hp(4)), // Reduced gap

                  // --- LOGOUT BUTTON ---
                  _LogoutButton(
                    responsive: responsive,
                    onTap: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppColors.cardSurface,
                          title: const Text("Log Out",
                              style: TextStyle(color: Colors.white)),
                          content: const Text(
                              "Are you sure you want to log out?",
                              style: TextStyle(color: Colors.white70)),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel",
                                    style: TextStyle(color: Colors.grey))),
                            TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Log Out",
                                    style: TextStyle(color: Colors.redAccent))),
                          ],
                        ),
                      );

                      if (shouldLogout == true && context.mounted) {
                        await context.read<AuthProvider>().logout();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                                  (route) => false);
                        }
                      }
                    },
                  ),

                  SizedBox(height: responsive.hp(5)), // Bottom Padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for Dialog Input Fields
  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: AppColors.primary),
        enabledBorder: UnderlineInputBorder(
            borderSide:
            BorderSide(color: AppColors.primary.withValues(alpha:0.5))),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary)),
      ),
    );
  }
}

// --- HELPER COMPONENTS (Optimized) ---

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final Responsive responsive;

  const _ProfileStat(
      {required this.label, required this.value, required this.responsive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: responsive.wp(24), // Slightly narrower
      padding: EdgeInsets.symmetric(vertical: responsive.hp(1.5)), // Less padding
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha:0.05)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
                color: Colors.white,
                fontSize: responsive.hp(2.0), // Slightly smaller font
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: responsive.hp(0.3)),
          Text(
            label,
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: responsive.hp(1.4)),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Responsive responsive;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: responsive.wp(4), vertical: responsive.hp(1.8)), // Tighter padding
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha:0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(responsive.wp(2.2)),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: responsive.hp(2.2)),
            ),
            SizedBox(width: responsive.wp(4)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive.hp(1.8),
                        fontWeight: FontWeight.w600)),
                SizedBox(height: responsive.hp(0.2)),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.white38, fontSize: responsive.hp(1.4))),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white24, size: responsive.hp(2.5)),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  final Responsive responsive;

  const _LogoutButton({required this.onTap, required this.responsive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: responsive.wp(6), vertical: responsive.hp(1.5)), // Slimmer
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.redAccent.withValues(alpha:0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout_rounded,
                color: Colors.redAccent, size: responsive.hp(2.0)),
            SizedBox(width: responsive.wp(2)),
            Text(
              "Log Out",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: responsive.hp(1.6),
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}