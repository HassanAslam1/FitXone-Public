import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../constants/app_colors.dart';

// Define the types of buttons supported based on Figma image_1.png
enum ButtonType { primary, outline }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final bool isFullWidth;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Determine styles based on ButtonType and Enabled state
    // If onPressed is null, Flutter automatically disables the button (greyed out)
    final isPrimary = type == ButtonType.primary;

    // Base colors
    Color textColor = isPrimary ? Colors.white : AppColors.primary;
    Color borderColor = isPrimary ? Colors.transparent : AppColors.primary;

    // 2. Build the appropriate button structure
    Widget buttonContent = isLoading
        ? SpinKitThreeBounce(
            color: textColor,
            size: 20.0,
          )
        : Text(
            text,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
          );

    Widget buttonWidget;

    if (isPrimary) {
      // Uses the theme defined in app_theme.dart automatically,
      // but we override specific properties if needed here.
      buttonWidget = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
            // If we want to override the theme color specifically:
            // backgroundColor: AppColors.primary,
            // The shape is already defined in the theme, so we don't redo it here.
            ),
        child: buttonContent,
      );
    } else {
      // Outline Button Style
      buttonWidget = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: BorderSide(color: borderColor, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: buttonContent,
      );
    }

    // 3. Handle Width
    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: buttonWidget,
      );
    }

    return buttonWidget;
  }
}
