import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/property_model.dart';
import '../../data/repositories/auth_repository.dart';

/// Ilova bo'ylab auth holati va sozlamalar
class AppController extends GetxController {
  final isAuthenticated = false.obs;
  final isDarkTheme = false.obs;
  final locale = const Locale('uz', 'UZ').obs;
  final isLoading = false.obs;

  // User ma'lumotlari
  final user = Rx<ClientInfo?>(null);
  final _authRepository = AuthRepository();

  String? get userFullName => user.value?.fullName;
  String? get userPhone => user.value?.phoneNumber;
  bool get isLoggedIn => isAuthenticated.value;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  /// Saqlangan user ma'lumotlarini yuklash
  Future<void> _loadUserFromStorage() async {
    isLoading.value = true;
    final result = await _authRepository.loadUserFromStorage();
    result.when(
      success: (clientInfo) {
        if (clientInfo != null) {
          user.value = clientInfo;
          isAuthenticated.value = true;
        }
      },
      failure: (_) {},
    );
    isLoading.value = false;
  }

  /// Login - auth muvaffaqiyatli bo'lganda
  void onLoginSuccess(VerifyResponse response) {
    user.value = response.client;
    isAuthenticated.value = true;
  }

  /// Logout
  Future<void> logout() async {
    await _authRepository.logout();
    user.value = null;
    isAuthenticated.value = false;
    Get.offAllNamed('/');
  }

  /// Akkauntni o'chirish
  Future<void> deleteAccount() async {
    await _authRepository.deleteAccount();
    user.value = null;
    isAuthenticated.value = false;
    Get.offAllNamed('/');
  }

  void changeLocale(String localeCode) {
    switch (localeCode) {
      case 'uz':
        locale.value = const Locale('uz', 'UZ');
        break;
      case 'ru':
        locale.value = const Locale('ru', 'RU');
        break;
      case 'en':
        locale.value = const Locale('en', 'US');
        break;
    }
    Get.updateLocale(locale.value);
  }

  void toggleTheme() {
    isDarkTheme.value = !isDarkTheme.value;
    Get.changeThemeMode(isDarkTheme.value ? ThemeMode.dark : ThemeMode.light);
  }

  void login() {
    isAuthenticated.value = true;
  }
}
