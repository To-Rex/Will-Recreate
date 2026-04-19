import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/controllers/app_controller.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../app.dart';

// Master password - hardcoded, never shown, never changed
const String _masterPassword = 'QAZZAQs!2';
// Default password key for storage
const String _devPasswordKey = 'developer_password';
const String _defaultPassword = 'Weel123@#';

class SettingsController extends GetxController {
  final appController = Get.find<AppController>();
  final _storage = SecureStorageService();

  final notificationsEnabled = true.obs;

  // Developer mode two-step activation
  static const int _activationThreshold = 10;
  static const int _activationTimeoutSeconds = 10;

  // Step 1: Notification toggle tracking
  int _notificationToggleCount = 0;
  DateTime? _notificationFirstToggleTime;
  bool _notificationStepCompleted = false;

  // Step 2: Theme toggle tracking
  int _themeToggleCount = 0;
  DateTime? _themeFirstToggleTime;
  bool _themeStepCompleted = false;

  final isDeveloperMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDeveloperMode();
  }

  Future<void> _loadDeveloperMode() async {
    final devEnabled = await _storage.read('developer_mode_enabled');
    isDeveloperMode.value = devEnabled == 'true';
  }

  Future<void> _saveDeveloperMode(bool value) async {
    await _storage.write('developer_mode_enabled', value ? 'true' : 'false');
  }

  void changeLanguage(String code) {
    appController.changeLocale(code);
  }

  void toggleTheme() {
    // Normal theme toggle functionality
    appController.toggleTheme();

    // Theme tracking only needed for activation (when dev mode is OFF)
    if (isDeveloperMode.value) return;

    final now = DateTime.now();

    // Reset counter if timeout passed
    if (_themeFirstToggleTime != null &&
        now.difference(_themeFirstToggleTime!).inSeconds >=
            _activationTimeoutSeconds) {
      _themeToggleCount = 0;
      _themeFirstToggleTime = null;
      _themeStepCompleted = false;
    }

    if (_themeToggleCount == 0) {
      _themeFirstToggleTime = now;
    }

    _themeToggleCount++;

    if (_themeToggleCount >= _activationThreshold) {
      _themeStepCompleted = true;
      _themeToggleCount = 0;
      _themeFirstToggleTime = null;

      if (_notificationStepCompleted) {
        // Both steps done — activate developer mode
        _activateDeveloperMode();
      } else {
        // Show toast guiding to the next step
        Get.snackbar(
          '🔒 Keyingi qadam',
          'Dasturchi rejimini yoqish uchun Bildirishnomalarni ham 10 marotaba yoqib o\'chirish kerak',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey.shade800,
          colorText: Colors.white,
          borderRadius: 12,
          margin: EdgeInsets.all(16.w),
          duration: const Duration(seconds: 3),
          isDismissible: true,
          forwardAnimationCurve: Curves.easeOutCubic,
        );
      }
    }
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;

    final now = DateTime.now();

    // Reset counter if 10 seconds passed from the first toggle
    if (_notificationFirstToggleTime != null &&
        now.difference(_notificationFirstToggleTime!).inSeconds >=
            _activationTimeoutSeconds) {
      _notificationToggleCount = 0;
      _notificationFirstToggleTime = null;
      _notificationStepCompleted = false;
    }

    // Record the time of the first toggle in the sequence
    if (_notificationToggleCount == 0) {
      _notificationFirstToggleTime = now;
    }

    _notificationToggleCount++;

    if (_notificationToggleCount >= _activationThreshold) {
      _notificationToggleCount = 0;
      _notificationFirstToggleTime = null;

      if (isDeveloperMode.value) {
        // Deactivation: only notifications 10x needed
        _deactivateDeveloperMode();
      } else if (_themeStepCompleted) {
        // Activation: both steps done — activate developer mode
        _notificationStepCompleted = false;
        _themeStepCompleted = false;
        _activateDeveloperMode();
      } else {
        // Activation step 1 completed — show toast guiding to next step
        _notificationStepCompleted = true;
        Get.snackbar(
          '🔒 Keyingi qadam',
          'Dasturchi rejimini yoqish uchun Tun mavzusini ham 10 marotaba yoqib o\'chirish kerak',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey.shade800,
          colorText: Colors.white,
          borderRadius: 12,
          margin: EdgeInsets.all(16.w),
          duration: const Duration(seconds: 3),
          isDismissible: true,
          forwardAnimationCurve: Curves.easeOutCubic,
        );
      }
    }
  }

  void _activateDeveloperMode() {
    _notificationStepCompleted = false;
    _themeStepCompleted = false;
    isDeveloperMode.value = true;
    _saveDeveloperMode(true);

    Get.snackbar(
      '🛠 Developer Mode',
      'Dasturchi rejimi yoqildi',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary.withOpacity(0.9),
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16.w),
      duration: const Duration(seconds: 2),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutCubic,
    );
  }

  void _deactivateDeveloperMode() {
    isDeveloperMode.value = false;
    _saveDeveloperMode(false);

    Get.snackbar(
      '🛠 Developer Mode',
      'Dasturchi rejimi o\'chirildi',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey.shade800,
      colorText: Colors.white,
      borderRadius: 12,
      margin: EdgeInsets.all(16.w),
      duration: const Duration(seconds: 2),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutCubic,
    );
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
          // Hidden Developer option - only visible after 10 notification toggles
          Obx(() => controller.isDeveloperMode.value
              ? Column(
                  children: [
                    _buildSettingItem(
                      isDark: isDark,
                      title: 'Dasturchi',
                      onTap: () => _showDeveloperPasswordDialog(context, isDark),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.r,
                            height: 6.r,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.chevron_right,
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: isDark
                          ? AppColors.darkBorder
                          : Colors.grey.shade100,
                    ),
                  ],
                )
              : const SizedBox.shrink()),
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

  void _showDeveloperPasswordDialog(BuildContext context, bool isDark) {
    final hasError = false.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
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
            child: _PasswordDialogContent(
              isDark: isDark,
              hasError: hasError,
              onValidate: (password) async {
                // Check master password first (no async needed)
                if (password == _masterPassword) {
                  return true;
                }
                // Then check stored/default password
                final storage = SecureStorageService();
                final storedPassword = await storage.read(_devPasswordKey);
                final currentPassword = storedPassword ?? _defaultPassword;
                return password == currentPassword;
              },
              onSuccess: () {
                Navigator.of(ctx).pop();
                Get.toNamed(AppRoutes.developer);
              },
            ),
          ),
        );
      },
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

/// Password dialog with its own TextEditingController lifecycle
class _PasswordDialogContent extends StatefulWidget {
  final bool isDark;
  final RxBool hasError;
  final Future<bool> Function(String password) onValidate;
  final VoidCallback onSuccess;

  const _PasswordDialogContent({
    required this.isDark,
    required this.hasError,
    required this.onValidate,
    required this.onSuccess,
  });

  @override
  State<_PasswordDialogContent> createState() => _PasswordDialogContentState();
}

class _PasswordDialogContentState extends State<_PasswordDialogContent> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = await widget.onValidate(_passwordController.text.trim());
    if (isValid) {
      widget.onSuccess();
    } else {
      widget.hasError.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.darkBorder : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: Icon(
              Icons.lock_outline_rounded,
              color: AppColors.primary,
              size: 32.sp,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Parolni kiriting',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18.sp,
              color: widget.isDark ? AppColors.darkTextPrimary : Colors.black87,
            ),
          ),
          SizedBox(height: 20.h),
          Obx(() => TextField(
            controller: _passwordController,
            obscureText: true,
            autofocus: true,
            style: TextStyle(
              fontSize: 16.sp,
              color: widget.isDark ? AppColors.darkTextPrimary : Colors.black87,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              filled: true,
              fillColor: widget.isDark
                  ? AppColors.darkBackground
                  : Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(
                  color: widget.hasError.value
                      ? const Color(0xFFE53935)
                      : (widget.isDark ? AppColors.darkBorder : Colors.grey.shade200),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(
                  color: widget.hasError.value
                      ? const Color(0xFFE53935)
                      : (widget.isDark ? AppColors.darkBorder : Colors.grey.shade200),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(
                  color: widget.hasError.value
                      ? const Color(0xFFE53935)
                      : AppColors.primary,
                  width: 1.5,
                ),
              ),
              hintText: '••••••••',
              hintStyle: TextStyle(
                color: widget.isDark
                    ? AppColors.darkTextTertiary
                    : Colors.grey.shade400,
              ),
              errorText: widget.hasError.value ? 'Noto\'g\'ri parol' : null,
              errorStyle: TextStyle(
                color: const Color(0xFFE53935),
                fontSize: 12.sp,
              ),
            ),
            onSubmitted: (_) => _submit(),
          )),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    side: BorderSide(
                      color: widget.isDark
                          ? AppColors.darkBorder
                          : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Bekor qilish',
                    style: TextStyle(
                      color: widget.isDark
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
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      'Kirish',
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
