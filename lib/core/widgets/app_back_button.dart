import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reusable back button for AppBar leading with "Orqaga" text
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: () => Get.back(),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.arrow_back_ios_new_rounded, color: onSurface, size: 20),
          const SizedBox(width: 4),
          Text(
            'back'.tr,
            style: TextStyle(color: onSurface, fontWeight: FontWeight.w500, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
