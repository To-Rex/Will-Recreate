import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../app.dart';

class SettingsController extends GetxController {
  final appController = Get.find<AppController>();

  final notificationsEnabled = true.obs;

  void changeLanguage(String code) {
    appController.changeLocale(code);
  }

  void toggleTheme() {
    appController.toggleTheme();
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
  }
}

class SettingsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<SettingsController>(() => SettingsController());
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<SettingsController>();
    final appController = controller.appController;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(8.r),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkSurface : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.chevron_left,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        title: Text(
          'settings'.tr,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        children: [
          _buildSettingItem(
            isDark: isDark,
            title: 'language'.tr,
            onTap: () => Get.toNamed(AppRoutes.language),
            trailing: Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.darkTextTertiary : Colors.grey.shade400,
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : Colors.grey.shade100,
          ),
          Obx(() => _buildSettingItem(
            isDark: isDark,
            title: 'dark_theme'.tr,
            trailing: Switch.adaptive(
              value: appController.isDarkTheme.value,
              activeColor: AppColors.primary,
              onChanged: (value) => controller.toggleTheme(),
            ),
          )),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : Colors.grey.shade100,
          ),
          Obx(() => _buildSettingItem(
            isDark: isDark,
            title: 'notifications'.tr,
            trailing: Switch.adaptive(
              value: controller.notificationsEnabled.value,
              activeColor: AppColors.primary,
              onChanged: (value) => controller.toggleNotifications(value),
            ),
          )),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkBorder : Colors.grey.shade100,
          ),
          Obx(() => appController.isAuthenticated.value
              ? Column(
                  children: [
                    SizedBox(height: 32.h),
                    _buildLogoutButton(context, controller, isDark),
                    SizedBox(height: 12.h),
                    _buildDeleteAccountButton(context, controller, isDark),
                  ],
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8.h),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextPrimary : Colors.black,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    SettingsController controller,
    bool isDark,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLogoutConfirm(context, controller, isDark),
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            color: isDark
                ? const Color(0xFFE53935).withOpacity(0.1)
                : const Color(0xFFE53935).withOpacity(0.05),
            border: Border.all(color: const Color(0xFFE53935).withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: const Color(0xFFE53935),
                size: 22.sp,
              ),
              SizedBox(width: 10.w),
              Text(
                'sign_out'.tr,
                style: TextStyle(
                  color: const Color(0xFFE53935),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(
    BuildContext context,
    SettingsController controller,
    bool isDark,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showDeleteConfirm(context, controller, isDark),
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_remove_outlined,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : Colors.grey.shade600,
                size: 22.sp,
              ),
              SizedBox(width: 10.w),
              Text(
                'delete_account'.tr,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : Colors.grey.shade600,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirm(
    BuildContext context,
    SettingsController controller,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, -10),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                SizedBox(height: 24.h),
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE53935).withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: const Color(0xFFE53935),
                    size: 32.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'sign_out_confirm'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                    color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          controller.appController.logout();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          side: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : Colors.grey.shade300,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          'yes'.tr,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.r),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withGreen(210),
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            'no'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirm(
    BuildContext context,
    SettingsController controller,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, -10),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                SizedBox(height: 24.h),
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE53935).withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: const Color(0xFFE53935),
                    size: 32.sp,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'delete_account_confirm'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                    color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          controller.appController.deleteAccount();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          side: const BorderSide(color: Color(0xFFE53935)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          'yes'.tr,
                          style: const TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.r),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withGreen(210),
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            'no'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LanguageScreen extends GetView<SettingsController> {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocale = controller.appController.locale.value.languageCode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(8.r),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkSurface : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                Icons.chevron_left,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        title: Text(
          'language'.tr,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
            child: Text(
              'interface_language'.tr,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          _buildLanguageItem(
            context,
            title: 'russian'.tr,
            subtitle: 'Русский',
            localeCode: 'ru',
            isSelected: currentLocale == 'ru',
            isDark: isDark,
          ),
          _buildLanguageItem(
            context,
            title: 'uzbek'.tr,
            subtitle: "O'zbek",
            localeCode: 'uz',
            isSelected: currentLocale == 'uz',
            isDark: isDark,
          ),
          _buildLanguageItem(
            context,
            title: 'english'.tr,
            subtitle: 'English',
            localeCode: 'en',
            isSelected: currentLocale == 'en',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String localeCode,
    required bool isSelected,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isDark ? AppColors.darkTextPrimary : Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
        ),
      ),
      trailing: isSelected
          ? Container(
              width: 28.r,
              height: 28.r,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: Icon(Icons.check, color: Colors.white, size: 18.r),
            )
          : Container(
              width: 28.r,
              height: 28.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkSurface : Colors.grey.shade100,
              ),
            ),
      onTap: () {
        controller.changeLanguage(localeCode);
      },
    );
  }
}
