import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/responsive.dart'; // Ensure this exists
import '../providers/auth_provider.dart';
import 'signup_screen.dart';
import '../../../../features/dashboard/presentation/screens/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // UI State for Password Visibility
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Styled Reset Password Dialog ---
  void _showResetPasswordDialog(BuildContext context) {
    final TextEditingController resetEmailController = TextEditingController();
    final responsive = Responsive(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Reset Password",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter your email to receive a reset link.",
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: responsive.hp(2)),
            TextField(
              controller: resetEmailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Email Address",
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                contentPadding: EdgeInsets.symmetric(
                    horizontal: responsive.wp(4), vertical: responsive.hp(1.5)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final email = resetEmailController.text.trim();
              if (email.isNotEmpty) {
                context.read<AuthProvider>().resetPassword(email);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Send",
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context); // Init Responsive Helper

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // 1. Success Check
        if (authProvider.status == AuthStatus.authenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
            );
          });
        }

        // 2. Error Check (THE FIX)
        // We check if there is an error AND if we are not loading
        if (authProvider.status == AuthStatus.error &&
            authProvider.errorMessage != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // A. Show the error
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authProvider.errorMessage!),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );

            // B. ✅ CRITICAL: Wipe the error immediately so it doesn't show again
            // We use 'read' (not watch) to avoid infinite loops
            context.read<AuthProvider>().clearError();
          });
        }
        // -------------------------

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: Stack(
            children: [
              // 1. Background Decor (Subtle Glow)
              Positioned(
                top: -responsive.hp(10),
                left: -responsive.wp(15),
                child: Container(
                  width: responsive.wp(60),
                  height: responsive.wp(60),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.15),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 100,
                          spreadRadius: 20)
                    ],
                  ),
                ),
              ),

              // 2. Main Content
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: responsive.wp(6)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo / Icon
                        Icon(Icons.fitness_center_rounded,
                            size: responsive.hp(8), color: AppColors.primary),
                        SizedBox(height: responsive.hp(2)),

                        // Title
                        Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: responsive.hp(3.5),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: responsive.hp(1)),
                        Text(
                          "Sign in to continue your journey",
                          style: TextStyle(
                              fontSize: responsive.hp(1.8),
                              color: Colors.white54),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: responsive.hp(5)),

                        // Email Field
                        _buildTextField(
                          controller: _emailController,
                          label: "Email",
                          icon: Icons.email_outlined,
                          responsive: responsive,
                          validator: (value) =>
                              value!.isEmpty ? "Please enter email" : null,
                        ),

                        SizedBox(height: responsive.hp(2)),

                        // Password Field
                        _buildTextField(
                          controller: _passwordController,
                          label: "Password",
                          icon: Icons.lock_outline,
                          isPassword: true,
                          isVisible: _isPasswordVisible,
                          responsive: responsive,
                          onVisibilityToggle: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          validator: (value) =>
                              value!.length < 6 ? "Password too short" : null,
                        ),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => _showResetPasswordDialog(context),
                            child: Text("Forgot Password?",
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: responsive.hp(1.6))),
                          ),
                        ),

                        SizedBox(height: responsive.hp(2)),

                        // Login Button
                        SizedBox(
                          height: responsive.hp(6.5),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 5,
                              shadowColor:
                                  AppColors.primary.withValues(alpha: 0.4),
                            ),
                            onPressed: authProvider.status == AuthStatus.loading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      // Unfocus keyboard
                                      FocusScope.of(context).unfocus();
                                      context.read<AuthProvider>().login(
                                            _emailController.text.trim(),
                                            _passwordController.text.trim(),
                                          );
                                    }
                                  },
                            child: authProvider.status == AuthStatus.loading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : Text("Log In",
                                    style: TextStyle(
                                        fontSize: responsive.hp(2),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                          ),
                        ),

                        SizedBox(height: responsive.hp(3)),

                        // Sign Up Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? ",
                                style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: responsive.hp(1.6))),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SignUpScreen())),
                              child: Text("Sign Up",
                                  style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: responsive.hp(1.6))),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Helper: Reusable Text Field ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Responsive responsive,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityToggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: Colors.white54, fontSize: responsive.hp(1.8)),
        prefixIcon: Icon(icon,
            color: AppColors.primary.withValues(alpha: 0.7),
            size: responsive.hp(2.5)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white54,
                  size: responsive.hp(2.5),
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
        filled: true,
        fillColor: AppColors.cardSurface,
        contentPadding: EdgeInsets.symmetric(
            vertical: responsive.hp(2), horizontal: responsive.wp(4)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }
}
