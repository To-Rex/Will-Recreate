import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/app_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../app.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : Theme.of(context).scaffoldBackgroundColor,
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.darkBackground,
                    AppColors.darkSurface.withAlpha(242),
                    AppColors.darkBackground,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                )
              : null,
        ),
        child: SafeArea(
          child: Column(
            children: [
              GetX<AppController>(
                builder: (ctrl) => _buildHeader(ctrl, isDark),
              ),
              GetX<AppController>(
                builder: (ctrl) => ctrl.isAuthenticated.value
                    ? _buildGradientDivider(isDark)
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildMenuTile(
                      context,
                      icon: Icons.history_rounded,
                      title: 'history'.tr,
                      isDark: isDark,
                      onTap: () {
                        Navigator.of(context).pop();
                        final ctrl = Get.find<AppController>();
                        if (!ctrl.isAuthenticated.value) {
                          _showAuthRequiredSheet(context);
                          return;
                        }
                        Get.toNamed(AppRoutes.history);
                      },
                    ),
                    _buildMenuTile(
                      context,
                      icon: Icons.payment_rounded,
                      title: 'payment_methods_title'.tr,
                      isDark: isDark,
                      onTap: () {
                        Navigator.of(context).pop();
                        final ctrl = Get.find<AppController>();
                        if (!ctrl.isAuthenticated.value) {
                          _showAuthRequiredSheet(context);
                          return;
                        }
                        Get.toNamed(AppRoutes.paymentMethods);
                      },
                    ),
                    _buildMenuTile(
                      context,
                      icon: Icons.favorite_rounded,
                      iconColor: const Color(0xFFFF6B6B),
                      title: 'favorites_title'.tr,
                      isDark: isDark,
                      onTap: () {
                        Navigator.of(context).pop();
                        final ctrl = Get.find<AppController>();
                        if (!ctrl.isAuthenticated.value) {
                          _showAuthRequiredSheet(context);
                          return;
                        }
                        Get.toNamed(AppRoutes.favorites);
                      },
                    ),
                    _buildMenuTile(
                      context,
                      icon: Icons.settings_rounded,
                      title: 'settings'.tr,
                      isDark: isDark,
                      onTap: () {
                        Navigator.of(context).pop();
                        Get.toNamed(AppRoutes.settings);
                      },
                    ),
                    _buildMenuTile(
                      context,
                      icon: Icons.support_agent_rounded,
                      title: 'support'.tr,
                      isDark: isDark,
                      onTap: () {
                        Navigator.of(context).pop();
                        Get.toNamed(AppRoutes.support);
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              GetX<AppController>(
                builder: (ctrl) => !ctrl.isAuthenticated.value
                    ? Column(
                        children: [
                          _buildGradientDivider(isDark),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            child: _buildAuthRow(context, isDark),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAuthRequiredSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _AuthRequiredSheet(isDark: Theme.of(context).brightness == Brightness.dark),
    );
  }

  Widget _buildGradientDivider(bool isDark) {
    if (!isDark) {
      return Divider(color: Colors.grey.shade200, height: 1);
    }
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.accentPurple.withAlpha(77),
            AppColors.primary.withAlpha(77),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppController ctrl, bool isDark) {
    if (!ctrl.isAuthenticated.value) {
      return const SizedBox(height: 20);
    }

    // User ma'lumotlari AppController dan olinadi
    final userName = ctrl.userFullName ?? '';
    final userPhone = ctrl.userPhone ?? '';
    final initials = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkSurface,
                  AppColors.darkSurface.withAlpha(179),
                ],
              )
            : null,
        color: isDark ? null : Colors.grey.shade50,
        border: isDark
            ? Border.all(color: AppColors.darkBorder.withAlpha(128), width: 1)
            : null,
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(77),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.accentPurple.withAlpha(13),
                  blurRadius: 40,
                  spreadRadius: -10,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accentPurple],
              ),
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName.isNotEmpty ? userName : 'User',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userPhone.isNotEmpty ? userPhone : '',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isDark,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    final effectiveIconColor = iconColor ??
        (isDark ? AppColors.darkTextSecondary : Colors.grey.shade600);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.transparent,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.primary.withAlpha(26),
          highlightColor: isDark
              ? AppColors.darkSurface.withAlpha(128)
              : Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isDark
                        ? AppColors.darkSurface.withAlpha(128)
                        : Colors.grey.shade100,
                  ),
                  child: Icon(icon, color: effectiveIconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? AppColors.darkTextTertiary : Colors.grey.shade400,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthRow(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildAuthButton(
          context,
          title: 'create_account'.tr,
          isPrimary: true,
          isDark: isDark,
          onTap: () {
            Navigator.of(context).pop();
            Get.toNamed(AppRoutes.userInfo);
          },
        ),
        const SizedBox(height: 12),
        _buildAuthButton(
          context,
          title: 'log_in'.tr,
          isPrimary: false,
          isDark: isDark,
          onTap: () {
            Navigator.of(context).pop();
            Get.toNamed(AppRoutes.phoneLogin);
          },
        ),
      ],
    );
  }

  Widget _buildAuthButton(
    BuildContext context, {
    required String title,
    required bool isPrimary,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: isPrimary
                ? LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withGreen(210),
                    ],
                  )
                : null,
            color: isPrimary
                ? null
                : (isDark ? AppColors.darkSurface : Colors.grey.shade100),
            border: isPrimary
                ? null
                : Border.all(
                    color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                  ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isPrimary
                  ? Colors.white
                  : (isDark ? AppColors.darkTextPrimary : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthRequiredSheet extends StatelessWidget {
  final bool isDark;
  const _AuthRequiredSheet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 48, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'auth_required_title'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkTextPrimary : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'auth_required_message'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Get.toNamed(AppRoutes.phoneLogin);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'log_in'.tr,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Get.toNamed(AppRoutes.userInfo);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                side: BorderSide(color: isDark ? AppColors.darkBorder : Colors.grey.shade300),
              ),
              child: Text(
                'create_account'.tr,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
