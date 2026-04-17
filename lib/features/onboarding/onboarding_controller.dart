import 'dart:async';
import 'package:get/get.dart';
import '../../app.dart';

class OnboardingController extends GetxController {
  final currentIndex = 0.obs;
  Timer? _timer;

  final onboardingItems = <Map<String, String>>[];

  @override
  void onInit() {
    super.onInit();
    _initItems();
    _startTimer();
  }

  void _initItems() {
    onboardingItems.addAll([
      {
        'title': 'onboarding_ski_resorts_title'.tr,
        'location': 'onboarding_ski_resorts_location'.tr,
        'image': 'assets/images/onboarding/1.png',
      },
      {
        'title': 'onboarding_beach_vacation_title'.tr,
        'location': 'onboarding_beach_vacation_location'.tr,
        'image': 'assets/images/onboarding/2.png',
      },
      {
        'title': 'onboarding_city_tours_title'.tr,
        'location': 'onboarding_city_tours_location'.tr,
        'image': 'assets/images/onboarding/3.png',
      },
    ]);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      currentIndex.value = (currentIndex.value + 1) % onboardingItems.length;
    });
  }

  void skip() {
    Get.offAllNamed(AppRoutes.home);
  }

  void goToRegister() {
    Get.toNamed(AppRoutes.userInfo);
  }

  void goToLogin() {
    Get.toNamed(AppRoutes.phoneLogin);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}
