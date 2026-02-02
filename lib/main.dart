import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:the_fit_xone/features/auth/presentation/providers/home_provider.dart';
import 'package:the_fit_xone/features/onboarding/presentation/screens/splash_screen.dart';
import 'features/workout/presentation/providers/workout_provider.dart';
import 'package:the_fit_xone/features/diet/presentation/providers/diet_provider.dart';
import 'injection_container.dart' as di;

// Core Imports
import 'core/constants/app_colors.dart';

// Feature Imports
import 'features/auth/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => di.sl<AuthProvider>()),
        ChangeNotifierProvider(create: (_) => DietProvider()),
        ChangeNotifierProxyProvider<AuthProvider, HomeProvider>(
          create: (_) => di.sl<HomeProvider>(),
          update: (_, auth, home) {
            if (home != null) home.setUserId(auth.user?.uid);
            return home!;
          },
        ),
      ],
      child: MaterialApp(
        title: 'TheFitXOne',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.scaffoldBackground,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.accent,
            surface: AppColors.cardSurface,
          ),
          fontFamily: 'Plus Jakarta Sans',
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
