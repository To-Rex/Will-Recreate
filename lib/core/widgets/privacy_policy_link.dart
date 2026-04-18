import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../extensions/context_extensions.dart';

/// Reusable privacy policy text link used in auth screens
class PrivacyPolicyLink extends StatelessWidget {
  const PrivacyPolicyLink({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final url = Uri.parse('https://weel.uz/privacy-policy');
        await launchUrl(url, mode: LaunchMode.externalApplication);
      },
      child: Text(
        'privacy_policy'.tr,
        style: TextStyle(
          decoration: TextDecoration.underline,
          fontSize: 12,
          color: context.isDark ? context.colors.onSurface : Colors.black,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
