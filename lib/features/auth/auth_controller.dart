import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../app.dart';
import '../../core/controllers/app_controller.dart';

// Phone formatting utilities
bool validateUzPhone(String digits) {
  final only = digits.replaceAll(RegExp(r'[^0-9]'), '');
  return only.length == 9;
}

String maskPhone(String digits) {
  final only = digits.replaceAll(RegExp(r'[^0-9]'), '');
  final b = StringBuffer();
  for (int i = 0; i < only.length && i < 9; i++) {
    if (i == 0) b.write('(');
    if (i == 2) b.write(') ');
    if (i == 5 || i == 7) b.write('-');
    b.write(only[i]);
  }
  return b.toString();
}

class UzbekistanPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('998') && digits.length > 9) {
      digits = digits.substring(3);
    }
    if (digits.length > 9) {
      digits = digits.substring(0, 9);
    }
    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}

class AuthController extends GetxController {
  final firstName = ''.obs;
  final lastName = ''.obs;
  final phoneDigits = ''.obs;
  final otpCode = ''.obs;
  final isLoading = false.obs;
  final resendTimer = 0.obs;
  final isLogin = false.obs;
  final userInfoValid = false.obs;
  final phoneValid = false.obs;

  Timer? _timer;

  void setLoginMode(bool value) => isLogin.value = value;

  void checkUserInfoValid() {
    userInfoValid.value =
        firstName.value.trim().isNotEmpty && lastName.value.trim().isNotEmpty;
  }

  void onPhoneChanged(String rawDigits) {
    final digits = rawDigits.replaceAll(RegExp(r'\D'), '');
    phoneDigits.value = digits;
    phoneValid.value = validateUzPhone(digits);
  }

  void submitUserInfo() {
    if (!userInfoValid.value) return;
    Get.toNamed(
      AppRoutes.phoneRegister,
      arguments: {
        'first_name': firstName.value.trim(),
        'last_name': lastName.value.trim(),
      },
    );
  }

  void submitPhone() {
    if (!phoneValid.value) return;
    Get.toNamed(
      AppRoutes.otp,
      arguments: {
        'phone': '998$phoneDigits',
        'is_login': isLogin.value,
        'first_name': firstName.value.trim(),
        'last_name': lastName.value.trim(),
      },
    );
  }

  void verifyOtp() {
    isLoading.value = true;
    Future.delayed(const Duration(seconds: 1), () {
      isLoading.value = false;
      final appController = Get.find<AppController>();
      appController.login();
      Get.offAllNamed(AppRoutes.home);
    });
  }

  void startResendTimer() {
    _timer?.cancel();
    resendTimer.value = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
