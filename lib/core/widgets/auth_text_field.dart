import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../extensions/context_extensions.dart';

/// Reusable text input field for auth screens with consistent styling
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.focusNode,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 53,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType ?? TextInputType.text,
        textInputAction: textInputAction ?? TextInputAction.next,
        textAlignVertical: TextAlignVertical.center,
        inputFormatters: inputFormatters,
        style: TextStyle(color: context.colors.onSurface, fontSize: 14),
        cursorColor: context.colors.primary,
        decoration: InputDecoration(
          filled: true,
          fillColor: context.isDark
              ? context.colors.surfaceContainerHighest
              : const Color(0xFFF6F6F8),
          hintText: hintText,
          hintStyle: TextStyle(color: context.colors.onSurface.withAlpha(102), fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: BorderSide.none),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
