import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../extensions/context_extensions.dart';

/// Reusable primary action button used across auth and booking screens
class PrimaryButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final bool isLoading;
  final VoidCallback? onPressed;
  final Color? activeColor;
  final Color? disabledColor;

  const PrimaryButton({
    super.key,
    required this.text,
    this.enabled = true,
    this.isLoading = false,
    this.onPressed,
    this.activeColor,
    this.disabledColor,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = enabled && !isLoading;
    final bgColor = activeColor ?? AppColors.primary;
    final inactiveBg = disabledColor ??
        (context.isDark ? context.colors.surfaceContainerHighest : const Color(0xFFFAFAFA));

    return SizedBox(
      width: double.infinity,
      height: 53,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? bgColor : inactiveBg,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
        ),
        onPressed: isActive ? onPressed : null,
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
