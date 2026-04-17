import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import 'onboarding_controller.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Obx(() {
            final index = controller.currentIndex.value;
            final items = controller.onboardingItems;
            if (items.isEmpty) return const SizedBox.shrink();
            final item = items[index];
            return AnimatedSwitcher(
              duration: const Duration(seconds: 1),
              child: TweenAnimationBuilder<double>(
                key: ValueKey<int>(index),
                tween: Tween<double>(begin: 1.0, end: 1.15),
                duration: const Duration(seconds: 6),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(item['image']!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withAlpha(242), Colors.black.withAlpha(100)],
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                stops: const [0.0, 1.0],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withAlpha(229), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.center,
                stops: const [0.0, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                children: [
                  _buildTopBar(),
                  const Spacer(),
                  _buildCenterContent(),
                  const Spacer(),
                  _buildBottomControls(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Obx(() {
      final items = controller.onboardingItems;
      if (items.isEmpty) return const SizedBox.shrink();
      final item = items[controller.currentIndex.value];
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['title']!, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(item['location']!, style: TextStyle(color: Colors.white.withAlpha(229), fontSize: 14)),
                ],
              ),
            ],
          ),
          TextButton(
            onPressed: controller.skip,
            child: Text(
              'skip'.tr,
              style: const TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.underline, decorationColor: Colors.white),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCenterContent() {
    return Column(
      children: [
        SvgPicture.asset('assets/logo/weel_logo.svg', height: 64, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
        const SizedBox(height: 16),
        Text(
          'onboarding_slogan'.tr,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.3),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.goToRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text('create_account'.tr, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.goToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: Text('log_in'.tr, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 24),
        _buildLegalText(),
      ],
    );
  }

  Widget _buildLegalText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(color: Colors.white.withAlpha(178), fontSize: 12, height: 1.5),
        children: [
          TextSpan(text: 'legal_agreement_prefix'.tr),
          TextSpan(text: 'legal_terms_of_use'.tr, style: const TextStyle(decoration: TextDecoration.underline)),
          TextSpan(text: 'legal_privacy_policy_prefix'.tr),
          TextSpan(text: 'legal_privacy_policy'.tr, style: const TextStyle(decoration: TextDecoration.underline)),
          TextSpan(text: 'legal_cookie_policy'.tr),
        ],
      ),
    );
  }
}
