import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../app.dart';
import '../../core/controllers/app_controller.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _navigate();
  }

  Future<void> _navigate() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      final appController = Get.find<AppController>();
      if (appController.isAuthenticated.value) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.onboarding);
      }
    } catch (e) {
      debugPrint('Splash navigation error: $e');
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(SplashController());
  }
}
