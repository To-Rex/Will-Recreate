import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/auth_screen_wrapper.dart';
import '../../core/widgets/auth_text_field.dart';
import '../../core/widgets/phone_input_field.dart';
import '../../core/widgets/primary_button.dart';
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
    final ctrl = Get.find<AuthController>();

    return AuthScreenWrapper(
      body: Column(
        children: [
          AuthTextField(
            controller: _firstNameController,
            hintText: 'first_name_hint'.tr,
            onChanged: (val) { ctrl.firstName.value = val; ctrl.checkUserInfoValid(); },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _lastNameController,
            hintText: 'last_name_hint'.tr,
            onChanged: (val) { ctrl.lastName.value = val; ctrl.checkUserInfoValid(); },
          ),
        ],
      ),
      bottomButton: Obx(() => PrimaryButton(
        text: 'continue_button'.tr,
        enabled: ctrl.userInfoValid.value,
        onPressed: () { FocusScope.of(context).unfocus(); ctrl.submitUserInfo(); },
      )),
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
    final ctrl = Get.find<AuthController>();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final isRegistration = !(args['is_login'] == true);

    return AuthScreenWrapper(
      body: PhoneInputField(
        controller: _phoneController,
        focusNode: _phoneFocus,
        onChanged: (digits) => ctrl.onPhoneChanged(digits),
      ),
      bottomButton: Obx(() {
        final buttonText = isRegistration ? 'create_button'.tr : 'continue_button'.tr;
        return PrimaryButton(
          text: buttonText,
          enabled: ctrl.phoneValid.value,
          isLoading: ctrl.isLoading.value,
          onPressed: () { FocusScope.of(context).unfocus(); ctrl.submitPhone(); },
        );
      }),
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
    final ctrl = Get.find<AuthController>();

    return AuthScreenWrapper(
      body: PhoneInputField(
        controller: _phoneController,
        focusNode: _phoneFocus,
        onChanged: (digits) => ctrl.onPhoneChanged(digits),
      ),
      bottomButton: Obx(() => PrimaryButton(
        text: 'continue_button'.tr,
        enabled: ctrl.phoneValid.value,
        isLoading: ctrl.isLoading.value,
        onPressed: () { FocusScope.of(context).unfocus(); ctrl.submitPhone(); },
      )),
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
    final colorScheme = theme.colorScheme;

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
        leading: const AppBackButton(),
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
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 10),
              Text(
                '${'sent_to'.tr} +$phone',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: colorScheme.onSurface.withAlpha(179)),
              ),
              const SizedBox(height: 50),
              // OTP input area
              GestureDetector(
                onTap: () => _focusNode.requestFocus(),
                child: SizedBox(
                  height: 50,
                  child: Stack(
                    children: [
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
                              color: isDark ? colorScheme.surfaceContainerHighest : const Color(0xFFF6F6F8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isActive ? colorScheme.primary : Colors.transparent,
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              hasDigit ? code[i] : '',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: colorScheme.onSurface),
                            ),
                          );
                        }),
                      ),
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
                      backgroundColor: isDark ? colorScheme.surfaceContainerHighest : Colors.black,
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
