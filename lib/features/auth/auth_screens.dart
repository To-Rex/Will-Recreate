import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import 'auth_controller.dart';

// ─── User Info Registration Screen ────────────────────────────────────────────
class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ctrl = Get.find<AuthController>();

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
            leading: InkWell(
              onTap: () => Get.back(),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
                  const SizedBox(width: 4),
                  Text('back'.tr, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 16)),
                ],
              ),
            ),
          ),
          bottomNavigationBar: AnimatedPadding(
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
                  Obx(() {
                    final enabled = ctrl.userInfoValid.value;
                    return SizedBox(
                      width: double.infinity,
                      height: 53,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: enabled ? AppColors.primary : (isDark ? theme.colorScheme.surfaceContainerHighest : const Color(0xFFFAFAFA)),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: enabled ? () { FocusScope.of(context).unfocus(); ctrl.submitUserInfo(); } : null,
                        child: Text('continue_button'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () async {
                      final url = Uri.parse('https://weel.uz/privacy-policy');
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    },
                    child: Text(
                      'privacy_policy'.tr,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 12,
                        color: isDark ? theme.colorScheme.onSurface : Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                                        colorFilter: isDark ? const ColorFilter.mode(Colors.white, BlendMode.srcIn) : null,
                                      ),
                                      const SizedBox(height: 30),
                                      Text(
                                        'auth_slogan'.tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark ? theme.colorScheme.onSurface.withAlpha(153) : const Color(0xFF999999),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 50),
                                      _buildTextField(
                                        context,
                                        controller: _firstNameController,
                                        hintText: 'first_name_hint'.tr,
                                        isDark: isDark,
                                        onChanged: (val) { ctrl.firstName.value = val; ctrl.checkUserInfoValid(); },
                                      ),
                                      const SizedBox(height: 16),
                                      _buildTextField(
                                        context,
                                        controller: _lastNameController,
                                        hintText: 'last_name_hint'.tr,
                                        isDark: isDark,
                                        onChanged: (val) { ctrl.lastName.value = val; ctrl.checkUserInfoValid(); },
                                      ),
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

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    required ValueChanged<String> onChanged,
  }) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 53,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.next,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
        cursorColor: theme.colorScheme.primary,
        decoration: InputDecoration(
          filled: true,
          fillColor: isDark ? theme.colorScheme.surfaceContainerHighest : const Color(0xFFF6F6F8),
          hintText: hintText,
          hintStyle: TextStyle(color: theme.colorScheme.onSurface.withAlpha(102), fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: BorderSide.none),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

// ─── Phone Register Screen ────────────────────────────────────────────────────
class PhoneRegisterScreen extends StatefulWidget {
  const PhoneRegisterScreen({super.key});

  @override
  State<PhoneRegisterScreen> createState() => _PhoneRegisterScreenState();
}

class _PhoneRegisterScreenState extends State<PhoneRegisterScreen> {
  late final TextEditingController _phoneController;
  late final FocusNode _phoneFocus;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _phoneFocus = FocusNode();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ctrl = Get.find<AuthController>();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final isRegistration = !(args['is_login'] == true);

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
            leading: InkWell(
              onTap: () => Get.back(),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
                  const SizedBox(width: 4),
                  Text('back'.tr, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 16)),
                ],
              ),
            ),
          ),
          bottomNavigationBar: AnimatedPadding(
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
                  Obx(() {
                    final enabled = ctrl.phoneValid.value && !ctrl.isLoading.value;
                    final buttonText = isRegistration ? 'create_button'.tr : 'continue_button'.tr;
                    return SizedBox(
                      width: double.infinity,
                      height: 53,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: enabled ? AppColors.primary : (isDark ? theme.colorScheme.surfaceContainerHighest : const Color(0xFFFAFAFA)),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: enabled ? () { FocusScope.of(context).unfocus(); ctrl.submitPhone(); } : null,
                        child: ctrl.isLoading.value
                            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(buttonText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () async {
                      final url = Uri.parse('https://weel.uz/privacy-policy');
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    },
                    child: Text(
                      'privacy_policy'.tr,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 12,
                        color: isDark ? theme.colorScheme.onSurface : Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                                        colorFilter: isDark ? const ColorFilter.mode(Colors.white, BlendMode.srcIn) : null,
                                      ),
                                      const SizedBox(height: 30),
                                      Text(
                                        'auth_slogan'.tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark ? theme.colorScheme.onSurface.withAlpha(153) : const Color(0xFF999999),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 50),
                                      // Phone input row: +998 prefix + phone field
                                      Row(
                                        children: [
                                          // +998 prefix container
                                          Container(
                                            height: 53,
                                            width: 76,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: isDark ? theme.colorScheme.surfaceContainerHighest : const Color(0xFFF6F6F8),
                                              borderRadius: BorderRadius.circular(32),
                                            ),
                                            child: Text(
                                              '+998',
                                              style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          // Phone text field
                                          Expanded(
                                            child: SizedBox(
                                              height: 53,
                                              child: TextField(
                                                controller: _phoneController,
                                                focusNode: _phoneFocus,
                                                keyboardType: TextInputType.phone,
                                                textInputAction: TextInputAction.done,
                                                autofillHints: const [AutofillHints.telephoneNumber],
                                                textAlignVertical: TextAlignVertical.center,
                                                inputFormatters: [UzbekistanPhoneFormatter()],
                                                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
                                                cursorColor: theme.colorScheme.primary,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: isDark ? theme.colorScheme.surfaceContainerHighest : const Color(0xFFF6F6F8),
                                                  hintText: 'phone_number_hint'.tr,
                                                  hintStyle: TextStyle(color: theme.colorScheme.onSurface.withAlpha(102), fontSize: 14),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: BorderSide.none),
                                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: BorderSide.none),
                                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: BorderSide.none),
                                                ),
                                                onChanged: (val) {
                                                  final digits = val.replaceAll(RegExp(r'\D'), '');
                                                  ctrl.onPhoneChanged(digits);
                                                  // Apply mask formatting
                                                  final masked = maskPhone(digits);
                                                  _phoneController.value = _phoneController.value.copyWith(
                                                    text: masked,
                                                    selection: TextSelection.collapsed(offset: masked.length),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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

// ─── Phone Login Screen ───────────────────────────────────────────────────────
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  late final TextEditingController _phoneController;
  late final FocusNode _phoneFocus;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _phoneFocus = FocusNode();
    final ctrl = Get.find<AuthController>();
    ctrl.setLoginMode(true);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ctrl = Get.find<AuthController>();

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
            leading: InkWell(
              onTap: () => Get.back(),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
                  const SizedBox(width: 4),
                  Text('back'.tr, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 16)),
                ],
              ),
            ),
          ),
          bottomNavigationBar: AnimatedPadding(
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
                  Obx(() {
                    final enabled = ctrl.phoneValid.value && !ctrl.isLoading.value;
                    return SizedBox(
                      width: double.infinity,
                      height: 53,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: enabled ? AppColors.primary : (isDark ? theme.colorScheme.surfaceContainerHighest : const Color(0xFFFAFAFA)),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: enabled ? () { FocusScope.of(context).unfocus(); ctrl.submitPhone(); } : null,
                        child: ctrl.isLoading.value
                            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text('continue_button'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () async {
                      final url = Uri.parse('https://weel.uz/privacy-policy');
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    },
                    child: Text(
                      'privacy_policy'.tr,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 12,
                        color: isDark ? theme.colorScheme.onSurface : Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
                                        colorFilter: isDark ? const ColorFilter.mode(Colors.white, BlendMode.srcIn) : null,
                                      ),
                                      const SizedBox(height: 30),
                                      Text(
                                        'auth_slogan'.tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark ? theme.colorScheme.onSurface.withAlpha(153) : const Color(0xFF999999),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 50),
                                      // Phone input row
                                      Row(
                                        children: [
                                          Container(
                                            height: 53,
                                            width: 76,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: isDark ? theme.colorScheme.surfaceContainerHighest : const Color(0xFFF6F6F8),
                                              borderRadius: BorderRadius.circular(32),
                                            ),
                                            child: Text(
                                              '+998',
                                              style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Expanded(
                                            child: SizedBox(
                                              height: 53,
                                              child: TextField(
                                                controller: _phoneController,
                                                focusNode: _phoneFocus,
                                                keyboardType: TextInputType.phone,
                                                textInputAction: TextInputAction.done,
                                                autofillHints: const [AutofillHints.telephoneNumber],
                                                textAlignVertical: TextAlignVertical.center,
                                                inputFormatters: [UzbekistanPhoneFormatter()],
                                                style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
                                                cursorColor: theme.colorScheme.primary,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: isDark ? theme.colorScheme.surfaceContainerHighest : const Color(0xFFF6F6F8),
                                                  hintText: 'phone_number_hint'.tr,
                                                  hintStyle: TextStyle(color: theme.colorScheme.onSurface.withAlpha(102), fontSize: 14),
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: BorderSide.none),
                                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: BorderSide.none),
                                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(32), borderSide: BorderSide.none),
                                                ),
                                                onChanged: (val) {
                                                  final digits = val.replaceAll(RegExp(r'\D'), '');
                                                  ctrl.onPhoneChanged(digits);
                                                  final masked = maskPhone(digits);
                                                  _phoneController.value = _phoneController.value.copyWith(
                                                    text: masked,
                                                    selection: TextSelection.collapsed(offset: masked.length),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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

// ─── OTP Screen ───────────────────────────────────────────────────────────────
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late final TextEditingController _ctrl;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    _focusNode = FocusNode();
    final ctrl = Get.find<AuthController>();
    ctrl.startResendTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ctrl = Get.find<AuthController>();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final phone = args['phone'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        leadingWidth: 100,
        leading: InkWell(
          onTap: () => Get.back(),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
              const SizedBox(width: 4),
              Text('back'.tr, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 16)),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Text(
                'confirmation_code_title'.tr,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
              ),
              const SizedBox(height: 10),
              Text(
                '${'sent_to'.tr} +$phone',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: theme.colorScheme.onSurface.withAlpha(179)),
              ),
              const SizedBox(height: 50),
              // OTP input area
              GestureDetector(
                onTap: () => _focusNode.requestFocus(),
                child: SizedBox(
                  height: 50,
                  child: Stack(
                    children: [
                      // Visual digit boxes (4 boxes)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (i) {
                          final code = _ctrl.text;
                          final hasDigit = i < code.length;
                          final isActive = i == code.length && _focusNode.hasFocus;

                          return Container(
                            width: 50,
                            height: 50,
                            margin: EdgeInsets.only(left: i == 0 ? 0 : 10, right: i == 3 ? 0 : 10),
                            decoration: BoxDecoration(
                              color: isDark ? theme.colorScheme.surfaceContainerHighest : const Color(0xFFF6F6F8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isActive ? theme.colorScheme.primary : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              hasDigit ? code[i] : '',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface),
                            ),
                          );
                        }),
                      ),
                      // Invisible real TextField for input + autofill
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0,
                          child: TextField(
                            controller: _ctrl,
                            focusNode: _focusNode,
                            autofillHints: const [AutofillHints.oneTimeCode],
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            decoration: const InputDecoration(counterText: '', border: InputBorder.none),
                            onChanged: (v) {
                              ctrl.otpCode.value = v.replaceAll(RegExp(r'[^0-9]'), '');
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              // Resend timer / button
              Obx(() {
                if (ctrl.resendTimer.value > 0) {
                  return Text(
                    '${'resend_code_timer'.tr.replaceAll('{time}', '0:${ctrl.resendTimer.value.toString().padLeft(2, '0')}')}',
                    style: theme.textTheme.bodyMedium,
                  );
                }
                return SizedBox(
                  height: 53,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? theme.colorScheme.surfaceContainerHighest : Colors.black,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () {
                      _ctrl.clear();
                      ctrl.otpCode.value = '';
                      ctrl.startResendTimer();
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text('resend_code_action'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
              // Confirm button
              Obx(() {
                final isComplete = ctrl.otpCode.value.length == 4;
                return SizedBox(
                  height: 53,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: isComplete && !ctrl.isLoading.value
                        ? () { _focusNode.unfocus(); ctrl.verifyOtp(); }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ctrl.isLoading.value
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text('confirm_button'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
