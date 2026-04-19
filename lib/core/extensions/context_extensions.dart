import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  // Theme shortcuts
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  ColorScheme get colors => colorScheme; // Alias for backward compatibility
  TextTheme get textTheme => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // Surface colors
  Color get surfaceColor => colorScheme.surface;
  Color get onSurfaceColor => colorScheme.onSurface;
  Color get scaffoldBg => theme.scaffoldBackgroundColor;
  Color get dividerColor => theme.dividerColor;

  // Reusable surface background for cards/sections
  Color get cardSurfaceBg =>
      isDark ? const Color(0xFFFAFAFA) : const Color(0xFFFAFAFA);

  // Border color for chips/tags
  Color get chipBorderColor =>
      isDark ? const Color(0xFF2E2E3A) : const Color(0xFFE6E6E6);

  // Shadow for cards
  BoxShadow get cardShadow => BoxShadow(
        color: isDark ? Colors.black.withAlpha(77) : Colors.black.withAlpha(13),
        blurRadius: 42,
        offset: const Offset(0, 2),
      );

  // Subtle shadow
  BoxShadow get subtleShadow => BoxShadow(
        color: isDark ? Colors.grey.withAlpha(30) : Colors.black.withAlpha(30),
        blurRadius: 4,
      );
}
