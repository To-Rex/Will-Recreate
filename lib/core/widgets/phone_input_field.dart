import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../extensions/context_extensions.dart';
import '../../features/auth/auth_controller.dart';

/// Reusable phone input field with +998 prefix and mask formatting
class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String> onChanged;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // +998 prefix container
        Container(
          height: 53,
          width: 76,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.isDark ? context.colors.surfaceContainerHighest : const Color(0xFFF6F6F8),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Text(
            '+998',
            style: TextStyle(fontSize: 14, color: context.colors.onSurface, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 20),
        // Phone text field
        Expanded(
          child: SizedBox(
            height: 53,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.telephoneNumber],
              textAlignVertical: TextAlignVertical.center,
              inputFormatters: [UzbekistanPhoneFormatter()],
              style: TextStyle(color: context.colors.onSurface, fontSize: 14),
              cursorColor: context.colors.primary,
              decoration: _inputDecoration(context),
              onChanged: (val) {
                final digits = val.replaceAll(RegExp(r'\D'), '');
                onChanged(digits);
                final masked = maskPhone(digits);
                controller.value = controller.value.copyWith(
                  text: masked,
                  selection: TextSelection.collapsed(offset: masked.length),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(BuildContext context) {
    return InputDecoration(
      filled: true,
      fillColor: context.isDark ? context.colors.surfaceContainerHighest : const Color(0xFFF6F6F8),
      hintText: 'phone_number_hint'.tr,
      hintStyle: TextStyle(color: context.colors.onSurface.withAlpha(102), fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: BorderSide.none),
    );
  }
}
