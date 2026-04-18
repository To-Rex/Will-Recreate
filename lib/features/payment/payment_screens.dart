import 'package:flutter/material.dart';
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

class AddCardScreen extends StatelessWidget {
  const AddCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'link_card'.tr,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card number field
            Text(
              'enter_card_number'.tr,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: '0000 0000 0000 0000',
                hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 16),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E26) : const Color(0xFFF6F6F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF2E2E3A) : const Color(0xFFF1F1F1),
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
                color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.datetime,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'mm_gg'.tr,
                hintStyle: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 16),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E1E26) : const Color(0xFFF6F6F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF2E2E3A) : const Color(0xFFF1F1F1),
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
            const Spacer(),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'continue_button'.tr,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
