import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/responsive.dart';
import 'bio_data_screen.dart'; // ✅ Ensure this matches your file name

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // ✅ Added Name Controller (Required for the new flow)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    // We don't need Consumer here anymore because we aren't calling the API yet.
    // We are just collecting data and moving to the next screen.
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: responsive.hp(2.5)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // --- STYLING: Background Glow ---
          Positioned(
            top: -responsive.hp(5),
            right: -responsive.wp(15),
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

          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: responsive.wp(6)),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.person_add_alt_1_rounded,
                        size: responsive.hp(8), color: AppColors.primary),
                    SizedBox(height: responsive.hp(2)),

                    Text(
                      "Create Account",
                      style: TextStyle(
                          fontSize: responsive.hp(3.5),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Plus Jakarta Sans'),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: responsive.hp(5)),

                    // --- NEW: NAME FIELD ---
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                          "Full Name", Icons.person_outline, responsive),
                      validator: (value) =>
                      value!.isEmpty ? "Please enter your name" : null,
                    ),
                    SizedBox(height: responsive.hp(2)),

                    // --- EMAIL FIELD ---
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                          "Email", Icons.email_outlined, responsive),
                      validator: (value) =>
                      value!.isEmpty ? "Please enter email" : null,
                    ),
                    SizedBox(height: responsive.hp(2)),

                    // --- PASSWORD FIELD ---
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(
                          "Password", Icons.lock_outline, responsive)
                          .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white54),
                          onPressed: () => setState(() =>
                          _isPasswordVisible = !_isPasswordVisible),
                        ),
                        helperText:
                        "Must have: Upper, Lower, Number, Special Char",
                        helperStyle: const TextStyle(color: Colors.white38),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter password";
                        }
                        if (value.length < 8) return "Min 8 characters";
                        String pattern =
                            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                        if (!RegExp(pattern).hasMatch(value)) {
                          return "Use Uppercase, Lowercase, Number & Symbol";
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: responsive.hp(4)),

                    // --- BUTTON ---
                    SizedBox(
                      height: responsive.hp(6.5),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 5,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // ✅ FIXED FLOW:
                            // We do NOT call authProvider.signUp() here.
                            // We just push to the next screen passing the data.
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BioDataScreen(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                  name: _nameController.text.trim(),
                                ),
                              ),
                            );
                          }
                        },
                        child: Text("Next Step",
                            style: TextStyle(
                                fontSize: responsive.hp(2),
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
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

  InputDecoration _inputDecoration(
      String label, IconData icon, Responsive responsive) {
    return InputDecoration(
      labelText: label,
      labelStyle:
      TextStyle(color: Colors.white54, fontSize: responsive.hp(1.8)),
      prefixIcon: Icon(icon,
          color: AppColors.primary.withValues(alpha: 0.7),
          size: responsive.hp(2.5)),
      filled: true,
      fillColor: AppColors.cardSurface,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }
}