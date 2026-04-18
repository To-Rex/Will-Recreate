import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'app_back_button.dart';
import 'privacy_policy_link.dart';

/// Common wrapper for auth screens with logo, slogan, and consistent layout
class AuthScreenWrapper extends StatelessWidget {
  final Widget body;
  final Widget? bottomButton;
  final bool showPrivacyPolicy;

  const AuthScreenWrapper({
    super.key,
    required this.body,
    this.bottomButton,
    this.showPrivacyPolicy = true,
  });

  @override
  Widget build(BuildContext context) {
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leadingWidth: 100,
            leading: const AppBackButton(),
          ),
          bottomNavigationBar: bottomButton != null
              ? AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.only(
                    left: 20, right: 20, top: 12,
                    bottom: viewInsetsBottom > 0 ? viewInsetsBottom + 12 : 90,
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        bottomButton!,
                        const SizedBox(height: 12),
                        if (showPrivacyPolicy) const PrivacyPolicyLink(),
                      ],
                    ),
                  ),
                )
              : null,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 0, bottom: 20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 420),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/logo/weel_booking_logo.svg',
                                        colorFilter: isDark
                                            ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                                            : null,
                                      ),
                                      const SizedBox(height: 30),
                                      Text(
                                        'auth_slogan'.tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark
                                              ? theme.colorScheme.onSurface.withAlpha(153)
                                              : const Color(0xFF999999),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 50),
                                      body,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
