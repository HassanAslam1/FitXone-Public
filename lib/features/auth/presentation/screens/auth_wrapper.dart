import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_fit_xone/features/dashboard/presentation/screens/main_screen.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Check Auth Status immediately when this widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // While checking, you could show a simple loader,
        // but since we come from Splash, it's usually fast.
        if (authProvider.status == AuthStatus.authenticated) {
          return const MainScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
