import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ Required for Auth Check
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/responsive.dart';
import '../../../auth/presentation/screens/auth_wrapper.dart';
import '../../../auth/presentation/providers/auth_provider.dart'; // ✅ Import your AuthProvider

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 1. Start Fade-In Animation immediately
    // We add a tiny delay to ensure the widget is built before animating
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
        });
      }
    });

    // 2. The "Smart Wait"
    // We wait for BOTH the Animation (3 seconds) AND the Auth Check to finish.
    // This ensures we never navigate before we know if the user is logged in.
    await Future.wait([
      Future.delayed(const Duration(seconds: 3)), // Visual Delay
      authProvider.checkAuthStatus(),             // Logic Delay (Firebase)
    ]);

    // 3. Navigation
    // Now that 'authProvider.status' is updated, AuthWrapper will
    // show the correct screen instantly without flashing.
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AuthWrapper(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          // ------------------------------------------------
          // 1. BACKGROUND GLOW (Consistent App Theme)
          // ------------------------------------------------
          Positioned(
            top: -responsive.hp(10),
            left: -responsive.wp(20),
            child: Container(
              width: responsive.wp(80),
              height: responsive.wp(80),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // ------------------------------------------------
          // 2. CENTERED LOGO ANIMATION
          // ------------------------------------------------
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 1500),
              opacity: _opacity,
              curve: Curves.easeOut,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with LARGER responsive size & High Quality
                  Image.asset(
                    'assets/images/splashlogo.png',
                    width: responsive.wp(85), // ✅ 85%
                    height: responsive.wp(85),
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high, // ✅ Ensures HD rendering
                  ),

                  SizedBox(height: responsive.hp(2)),

                  // Spacer Text (Preserved)
                  Text(
                    " ",
                    style: TextStyle(
                      fontSize: responsive.hp(3.5),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}