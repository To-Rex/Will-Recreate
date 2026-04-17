import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppController extends GetxController {
  final isAuthenticated = false.obs;
  final isDarkTheme = false.obs;
  final locale = const Locale('uz', 'UZ').obs;

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

  void logout() {
    isAuthenticated.value = false;
    Get.offAllNamed('/');
  }
}
