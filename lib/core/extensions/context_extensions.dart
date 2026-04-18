import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => Theme.of(this).colorScheme;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  TextTheme get textStyles => Theme.of(this).textTheme;

  double get viewPaddingBottom => MediaQuery.of(this).viewPadding.bottom;

  double get viewInsetsBottom => MediaQuery.of(this).viewInsets.bottom;
}
