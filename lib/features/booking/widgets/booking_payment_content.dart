import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/property_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../payment/payment_screens.dart';

/// Step 2: Booking payment content
class BookingPaymentContent extends StatefulWidget {
  final Property property;
  final DateTime checkIn;
  final DateTime checkOut;
  final int adults;
  final int children;
  final int babies;
  final int totalAmount;
  final String? selectedCardId;
  final Function(String) onCardSelected;
  final Function(Map<String, dynamic>) onBookingSuccess;

  const BookingPaymentContent({
    super.key,
    required this.property,
    required this.checkIn,
    required this.checkOut,
    required this.adults,
    required this.children,
    required this.babies,
    required this.totalAmount,
    this.selectedCardId,
    required this.onCardSelected,
    required this.onBookingSuccess,
  });

  @override
  State<BookingPaymentContent> createState() => _BookingPaymentContentState();
}

class _BookingPaymentContentState extends State<BookingPaymentContent> {
  late TapGestureRecognizer _privacyPolicyRecognizer;
  bool _isCreatingBooking = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _privacyPolicyRecognizer = TapGestureRecognizer()..onTap = _launchPrivacyPolicy;
  }

  @override
  void dispose() {
    _privacyPolicyRecognizer.dispose();
    super.dispose();
  }

  Future<void> _launchPrivacyPolicy() async {
    final Uri url = Uri.parse('https://weel.uz/privacy-policy');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // ignore
    }
  }

  Future<void> _createBooking() async {
    if (widget.selectedCardId == null) return;

    setState(() {
      _isCreatingBooking = true;
      _errorMessage = null;
    });

    final request = BookingRequest(
      propertyId: widget.property.guid,
      cardId: widget.selectedCardId,
      checkIn: widget.checkIn.toIso8601String().split('T')[0],
      checkOut: widget.checkOut.toIso8601String().split('T')[0],
      adults: widget.adults,
      children: widget.children,
      babies: widget.babies,
    );

    final repository = BookingRepository();
    final result = await repository.createBooking(request);

    result.when(
      success: (response) async {
        final detailsResult = await repository.getBookingDetails(response.id);
        detailsResult.when(
          success: (details) {
            if (mounted) {
              setState(() => _isCreatingBooking = false);
              widget.onBookingSuccess(details);
            }
          },
          failure: (msg) {
            if (mounted) {
              setState(() {
                _isCreatingBooking = false;
                _errorMessage = msg;
              });
            }
          },
        );
      },
      failure: (msg) {
        if (mounted) {
          setState(() {
            _isCreatingBooking = false;
            _errorMessage = msg;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentController = Get.find<PaymentController>();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                _buildCardsSection(paymentController),
                const SizedBox(height: 32),
                _buildPaymentTimeline(),
                const SizedBox(height: 32),
                Divider(
                  height: 1,
                  color: Theme.of(context).dividerColor.withOpacity(
                    Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.1,
                  ),
                ),
                const SizedBox(height: 32),
                _buildPriceSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        _buildBottomSection(paymentController),
      ],
    );
  }

  Widget _buildCardsSection(PaymentController paymentController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'confirmed_cards'.tr,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final cards = paymentController.cards;
          final isLoading = paymentController.isLoading.value;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (cards.isEmpty) {
            return GestureDetector(
              onTap: () => Get.toNamed('/payment-methods/add-card'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFFF9F9F9)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text('add_card'.tr, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: cards.map((card) => _buildCardItem(card)).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildCardItem(CardModel card) {
    final isSelected = widget.selectedCardId == card.guid;
    String iconPath = '';
    if (card.type.toLowerCase().contains('humo')) {
      iconPath = 'assets/icons/humo-icon.svg';
    } else if (card.type.toLowerCase().contains('uzcard')) {
      iconPath = 'assets/icons/uzcard-icon.svg';
    }

    return GestureDetector(
      onTap: () => widget.onCardSelected(card.guid),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? const Color(0xFFF9F9F9)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: iconPath.isNotEmpty
                    ? SvgPicture.asset(iconPath, width: 24, height: 16, fit: BoxFit.contain)
                    : Icon(Icons.credit_card, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), size: 20),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '.... ${card.cardNumber.substring(card.cardNumber.length - 4)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Container(
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withOpacity(0.3)
                        : Theme.of(context).dividerColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTimeline() {
    return Column(
      children: [
        _buildTimelineItem('1', 'payment_timeline_withhold'.tr, showLine: true),
        _buildTimelineItem('2', 'payment_timeline_refund'.tr, showLine: true),
        _buildTimelineItem('3', 'payment_timeline_commission'.tr, showLine: false),
      ],
    );
  }

  Widget _buildTimelineItem(String index, String title, {required bool showLine}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(index, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
            if (showLine) Container(width: 2, height: 30, color: AppColors.primary),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    final commission = (widget.totalAmount * 0.1).toInt();
    final paymentUponArrival = widget.totalAmount - commission;
    final formatter = NumberFormat('#,###', 'uz_UZ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('total_booking_amount_label'.tr, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
        const SizedBox(height: 8),
        Text(
          '${formatter.format(widget.totalAmount).replaceAll(',', ' ')} ${'sum'.tr}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 32),
        Text('advance_payment_label'.tr, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
        const SizedBox(height: 8),
        Text(
          '${formatter.format(commission).replaceAll(',', ' ')} ${'sum'.tr}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 32),
        Text('payment_upon_arrival_label'.tr, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
        const SizedBox(height: 8),
        Text(
          '${formatter.format(paymentUponArrival).replaceAll(',', ' ')} ${'sum'.tr}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
        ),
      ],
    );
  }

  Widget _buildBottomSection(PaymentController paymentController) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black.withOpacity(0.04)
                : Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface, height: 1.4),
                children: [
                  TextSpan(text: 'booking_agreement_prefix'.tr),
                  TextSpan(
                    text: 'booking_agreement_confirm'.tr,
                    style: TextStyle(color: AppColors.primary, decoration: TextDecoration.underline),
                    recognizer: _privacyPolicyRecognizer,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isCreatingBooking || widget.selectedCardId == null
                    ? null
                    : _createBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isCreatingBooking
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('book_action'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
