import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../app.dart';
import '../../core/controllers/app_controller.dart';
import '../../data/repositories/auth_repository.dart';

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
  final errorMessage = Rx<String?>(null);

  final _authRepository = AuthRepository();
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

  /// OTP yuborish (register yoki login)
  Future<void> submitPhone() async {
    if (!phoneValid.value) return;

    isLoading.value = true;
    errorMessage.value = null;

    final phone = '998${phoneDigits.value}';

    final result = isLogin.value
        ? await _authRepository.login(phoneNumber: phone)
        : await _authRepository.register(
            phoneNumber: phone,
            firstName: firstName.value.trim(),
            lastName: lastName.value.trim(),
          );

    isLoading.value = false;

    result.when(
      success: (_) {
        Get.toNamed(
          AppRoutes.otp,
          arguments: {
            'phone': phone,
            'is_login': isLogin.value,
            'first_name': firstName.value.trim(),
            'last_name': lastName.value.trim(),
          },
        );
        startResendTimer();
      },
      failure: (msg) => errorMessage.value = msg,
    );
  }

  /// OTP tasdiqlash
  Future<void> verifyOtp() async {
    if (otpCode.value.length < 4) return;

    isLoading.value = true;
    errorMessage.value = null;

    final args = Get.arguments as Map<String, dynamic>;
    final phone = args['phone'] as String;
    final isLoginMode = args['is_login'] as bool;

    final result = await _authRepository.verifyOtp(
      phoneNumber: phone,
      otpCode: otpCode.value,
      isLogin: isLoginMode,
    );

    isLoading.value = false;

    result.when(
      success: (verifyResponse) {
        final appController = Get.find<AppController>();
        appController.onLoginSuccess(verifyResponse);
        Get.offAllNamed(AppRoutes.home);
      },
      failure: (msg) => errorMessage.value = msg,
    );
  }

  /// OTP qayta yuborish
  Future<void> resendOtp() async {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args == null) return;

    final phone = args['phone'] as String;
    final isLoginMode = args['is_login'] as bool;

    final result = await _authRepository.resendOtp(
      phoneNumber: phone,
      isLogin: isLoginMode,
    );

    result.when(
      success: (_) => startResendTimer(),
      failure: (msg) => errorMessage.value = msg,
    );
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
