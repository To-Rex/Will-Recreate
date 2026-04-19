import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/property_model.dart';
import '../../data/repositories/payment_repository.dart';
import '../../app.dart';

// ===================== Controller =====================

class PaymentController extends GetxController {
  final cards = <CardModel>[].obs;
  final selectedCardId = Rx<String?>(null);
  final isEditing = false.obs;
  final isLoading = false.obs;
  final isAddingCard = false.obs;
  final isVerifying = false.obs;
  final otpSession = Rx<String?>(null);
  final errorMessage = Rx<String?>(null);
  final _paymentRepository = PaymentRepository();

  @override
  void onInit() {
    super.onInit();
    loadCards();
  }

  Future<void> loadCards() async {
    isLoading.value = true;
    final result = await _paymentRepository.getCards();
    result.when(
      success: (data) {
        cards.value = data;
        if (cards.isNotEmpty && selectedCardId.value == null) {
          selectedCardId.value = cards.first.guid;
        }
      },
      failure: (_) {},
    );
    isLoading.value = false;
  }

  void selectCard(String cardId) {
    selectedCardId.value = cardId;
  }

  void toggleEditing() {
    isEditing.value = !isEditing.value;
  }

  /// Kartani API orqali o'chirish
  Future<void> deleteCard(int index) async {
    final card = cards[index];
    final result = await _paymentRepository.deleteCard(card.id);
    result.when(
      success: (_) {
        cards.removeAt(index);
        if (selectedCardId.value == card.guid) {
          selectedCardId.value = cards.isNotEmpty ? cards.first.guid : null;
        }
      },
      failure: (_) {},
    );
  }

  /// Karta qo'shish - API ga murojaat
  Future<bool> addCard({
    required String cardNumber,
    required String expireDate,
  }) async {
    isAddingCard.value = true;
    errorMessage.value = null;
    final result = await _paymentRepository.addCard(
      cardNumber: cardNumber,
      expireDate: expireDate,
    );
    isAddingCard.value = false;
    return result.when(
      success: (response) {
        otpSession.value = response.session;
        return true;
      },
      failure: (msg) {
        errorMessage.value = msg;
        return false;
      },
    );
  }

  /// OTP tasdiqlash
  Future<bool> verifyCard({required String otp}) async {
    final session = otpSession.value;
    if (session == null) return false;

    isVerifying.value = true;
    errorMessage.value = null;
    final result = await _paymentRepository.verifyCard(
      session: session,
      otp: otp,
    );
    isVerifying.value = false;
    return result.when(
      success: (_) {
        otpSession.value = null;
        loadCards();
        return true;
      },
      failure: (msg) {
        errorMessage.value = msg;
        return false;
      },
    );
  }

  /// OTP qayta yuborish
  Future<bool> resendOtp() async {
    final session = otpSession.value;
    if (session == null) return false;

    errorMessage.value = null;
    final result = await _paymentRepository.resendOtp(session);
    return result.when(
      success: (_) => true,
      failure: (msg) {
        errorMessage.value = msg;
        return false;
      },
    );
  }
}

class PaymentBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<PaymentController>(() => PaymentController());
}

// ===================== Payment Methods Screen =====================

class PaymentMethodsScreen extends GetView<PaymentController> {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'payment_methods_title'.tr,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() => controller.cards.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextButton(
                    onPressed: () => controller.toggleEditing(),
                    child: Text(
                      'change'.tr,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  'confirmed_cards'.tr,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : const Color(0xFF999999),
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Loading shimmer
              if (controller.isLoading.value && controller.cards.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: List.generate(
                      3,
                      (index) => _buildCardShimmer(context),
                    ),
                  ),
                ),

              // Empty state - link card
              if (!controller.isLoading.value && controller.cards.isEmpty)
                _buildItem(
                  context,
                  title: 'link_card'.tr,
                  leading: _buildAddIcon(context),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF999999),
                  ),
                  onTap: () => Get.toNamed(AppRoutes.addCard),
                ),

              // Cards list
              if (controller.cards.isNotEmpty) ...[
                ...controller.cards.asMap().entries.map((entry) {
                  final index = entry.key;
                  final card = entry.value;
                  return _buildItem(
                    context,
                    title: card.cardNumber,
                    leading: _buildCardIcon(context, card.type),
                    trailing: controller.isEditing.value
                        ? _buildDeleteButton(context, index)
                        : _buildRadioButton(
                            controller.selectedCardId.value == card.guid,
                          ),
                    onTap: () {
                      if (!controller.isEditing.value) {
                        controller.selectCard(card.guid);
                      }
                    },
                  );
                }),

                // Link card button (non-editing mode)
                if (!controller.isEditing.value)
                  _buildItem(
                    context,
                    title: 'link_card'.tr,
                    leading: _buildAddIcon(context),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF999999),
                    ),
                    onTap: () => Get.toNamed(AppRoutes.addCard),
                  ),
              ],
            ],
          ),
        );
      }),
    );
  }

  // Card item builder - matches reference project styling
  Widget _buildItem(
    BuildContext context, {
    required String title,
    Widget? leading,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1F) : const Color(0xFFF6F6F8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (leading != null) ...[leading, const SizedBox(width: 16)],
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Card icon with container - matches reference
  Widget _buildCardIcon(BuildContext context, String brand) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String iconPath = '';
    if (brand.toLowerCase().contains('humo')) {
      iconPath = 'assets/icons/humo-icon.svg';
    } else if (brand.toLowerCase().contains('uzcard')) {
      iconPath = 'assets/icons/uzcard-icon.svg';
    }

    return Container(
      width: 48,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E2E3A) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: iconPath.isNotEmpty
            ? SvgPicture.asset(
                iconPath,
                width: 32,
                height: 20,
                fit: BoxFit.contain,
              )
            : const Icon(Icons.credit_card, color: Color(0xFF999999), size: 18),
      ),
    );
  }

  // Add card icon
  Widget _buildAddIcon(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 48,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E26) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.add_rounded,
        color: AppColors.primary,
        size: 24,
      ),
    );
  }

  // Custom radio button - matches reference
  Widget _buildRadioButton(bool isSelected) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : const Color(0xFFE6E6E6),
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }

  // Delete button
  Widget _buildDeleteButton(BuildContext context, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E2E3A) : Colors.white,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: SvgPicture.asset(
          'assets/icons/trash-icon.svg',
          width: 18,
          height: 18,
          colorFilter: const ColorFilter.mode(
            Color(0xFFE53935),
            BlendMode.srcIn,
          ),
        ),
        onPressed: () => _showDeleteConfirm(context, index),
      ),
    );
  }

  // Shimmer placeholder for loading
  Widget _buildCardShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Shimmer.fromColors(
        baseColor: isDark ? const Color(0xFF2E2E3A) : Colors.grey[300]!,
        highlightColor: isDark ? const Color(0xFF3A3A4A) : Colors.grey[100]!,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1F) : const Color(0xFFF6F6F8),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  // Delete confirmation bottom sheet - matches reference
  void _showDeleteConfirm(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),
              Container(
                width: 64,
                height: 6,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'delete_card_confirm'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await controller.deleteCard(index);
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Theme.of(context).dividerColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'yes'.tr,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF15BE63),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'no'.tr,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
            ],
          ),
        );
      },
    );
  }
}

// ===================== Add Card Screen =====================

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  bool _showOtp = false;
  Timer? _timer;
  int _secondsLeft = 0;
  static const int _timerDuration = 60;

  @override
  void dispose() {
    _cancelTimer();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _cancelTimer();
    setState(() {
      _secondsLeft = _timerDuration;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _cancelTimer();
      }
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  String get _formattedTime {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get _otpValue => _otpControllers.map((c) => c.text).join();

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _submitCard() async {
    final cardNumber = _cardNumberController.text.replaceAll(' ', '');
    final expireDate = _expiryDateController.text.replaceAll('/', '');

    if (cardNumber.length < 16) {
      _showSnackBar('invalid_card_number'.tr, isError: true);
      return;
    }
    if (expireDate.length < 4) {
      _showSnackBar('invalid_expire_date'.tr, isError: true);
      return;
    }

    final controller = Get.find<PaymentController>();
    final success = await controller.addCard(
      cardNumber: cardNumber,
      expireDate: expireDate,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _showOtp = true;
      });
      _startTimer();
      _showSnackBar('resend_code'.tr);
    } else {
      final error = controller.errorMessage.value;
      if (error != null) {
        _showSnackBar(error, isError: true);
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpValue.length < 6) {
      _showSnackBar('enter_sms_code_hint'.tr, isError: true);
      return;
    }

    final controller = Get.find<PaymentController>();
    final success = await controller.verifyCard(otp: _otpValue);

    if (!mounted) return;

    if (success) {
      _showSnackBar('card_added_success'.tr);
      Get.back();
    } else {
      final error = controller.errorMessage.value;
      if (error != null) {
        _showSnackBar(error, isError: true);
      }
    }
  }

  Future<void> _resendOtp() async {
    final controller = Get.find<PaymentController>();
    final success = await controller.resendOtp();
    if (success) {
      _startTimer();
      _showSnackBar('resend_code'.tr);
    } else {
      final error = controller.errorMessage.value;
      if (error != null) {
        _showSnackBar(error, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GetBuilder<PaymentController>(
      builder: (controller) {
        final isLoading = controller.isAddingCard.value || controller.isVerifying.value;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              onPressed: () {
                if (_showOtp) {
                  setState(() {
                    _showOtp = false;
                  });
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            title: Text(
              _showOtp ? 'confirmation'.tr : 'link_card'.tr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!_showOtp) ...[
                            _buildCardPreview(isDark),
                            const SizedBox(height: 30),
                            // Card number field
                            Text(
                              'enter_card_number'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? const Color(0xFFA1A1AA)
                                    : const Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _cardNumberController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                _CardNumberFormatter(),
                              ],
                              onChanged: (_) => setState(() {}),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: '0000 0000 0000 0000',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFCCCCCC),
                                  fontSize: 16,
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? const Color(0xFF1E1E26)
                                    : const Color(0xFFF6F6F8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? const Color(0xFF2E2E3A)
                                        : const Color(0xFFF1F1F1),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Expiry date field
                            Text(
                              'expiration_date'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? const Color(0xFFA1A1AA)
                                    : const Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _expiryDateController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                _CardExpiryFormatter(),
                              ],
                              onChanged: (_) => setState(() {}),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: 'mm_gg'.tr,
                                hintStyle: const TextStyle(
                                  color: Color(0xFFCCCCCC),
                                  fontSize: 16,
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? const Color(0xFF1E1E26)
                                    : const Color(0xFFF6F6F8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? const Color(0xFF2E2E3A)
                                        : const Color(0xFFF1F1F1),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                'enter_sms_code'.tr,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                'enter_sms_code_hint'.tr,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF999999),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            _buildOtpFields(isDark),
                            const SizedBox(height: 30),
                            if (_secondsLeft > 0)
                              Center(
                                child: Text(
                                  '${'resend_code'.tr} $_formattedTime',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            else
                              Center(
                                child: TextButton(
                                  onPressed: _resendOtp,
                                  child: Text(
                                    'resend_code'.tr,
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                          const Spacer(),
                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (!_showOtp) {
                                        _submitCard();
                                      } else {
                                        _verifyOtp();
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _showOtp
                                    ? const Color(0xFF15BE63)
                                    : AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _showOtp
                                          ? 'confirmation'.tr
                                          : 'get_code'.tr,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Card preview widget - eski project bilan bir xil
  Widget _buildCardPreview(bool isDark) {
    String number = _cardNumberController.text.isEmpty
        ? '•••• •••• •••• ••••'
        : _cardNumberController.text;
    String expire = _expiryDateController.text.isEmpty
        ? 'mm_gg'.tr
        : _expiryDateController.text;

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 45,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
                  ),
                ),
              ),
              _buildCardBrandIcon(number),
            ],
          ),
          Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'card_holder'.tr,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '•••• ••••',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'expires'.tr,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expire,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Karta brand iconini ko'rsatish
  Widget _buildCardBrandIcon(String number) {
    String? iconPath;
    if (number.startsWith('8600') || number.startsWith('5614')) {
      iconPath = 'assets/icons/uzcard-icon.svg';
    } else if (number.startsWith('9860')) {
      iconPath = 'assets/icons/humo-icon.svg';
    }

    if (iconPath != null) {
      return SvgPicture.asset(
        iconPath,
        width: 40,
        height: 25,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      );
    }
    return const Icon(Icons.credit_card, color: Colors.white, size: 30);
  }

  /// OTP maydonlari - eski project bilan bir xil
  Widget _buildOtpFields(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 45,
          height: 50,
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction:
                index < 5 ? TextInputAction.next : TextInputAction.done,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            obscureText: false,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              filled: true,
              fillColor:
                  isDark ? const Color(0xFF1E1E26) : const Color(0xFFF6F6F8),
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? Colors.white : Colors.black,
                  width: 1,
                ),
              ),
            ),
            onChanged: (value) {
              if (value.length > 1) {
                final digits = value.split('').take(6).toList();
                for (int j = 0; j < digits.length; j++) {
                  _otpControllers[j].text = digits[j];
                }
                final nextFocus =
                    digits.length < 6 ? _focusNodes[digits.length] : _focusNodes[5];
                nextFocus.requestFocus();
                setState(() {});
                return;
              }

              if (value.isNotEmpty) {
                if (index < 5) {
                  _focusNodes[index + 1].requestFocus();
                } else {
                  _focusNodes[index].unfocus();
                }
              } else {
                if (index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }
              }
              setState(() {});
            },
          ),
        );
      }),
    );
  }
}

/// Card number formatter: xxxx xxxx xxxx xxxx
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    // Limit to 16 digits
    final trimmed = digits.substring(0, digits.length > 16 ? 16 : digits.length);

    final buffer = StringBuffer();
    for (int i = 0; i < trimmed.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(trimmed[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Card expiry date formatter: MM/yy
class _CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    // Limit to 4 digits
    final trimmed = digits.substring(0, digits.length > 4 ? 4 : digits.length);

    final buffer = StringBuffer();
    for (int i = 0; i < trimmed.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(trimmed[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
