import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/property_model.dart';
import 'widgets/booking_confirmation_content.dart';
import 'widgets/booking_payment_content.dart';
import 'widgets/booking_success_content.dart';
import '../../../app.dart';

/// Main booking flow screen with 3 steps: Confirmation → Payment → Success
class BookingFlowScreen extends StatefulWidget {
  const BookingFlowScreen({super.key});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  int _currentStep = 0;
  late Property _property;
  late DateTime _checkIn;
  DateTime? _checkOut;
  late int _adults;
  late int _children;
  late int _babies;
  String? _selectedCardId;
  int _totalAmount = 0;
  Map<String, dynamic>? _bookingDetails;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _property = args['property'] as Property;
    _checkIn = args['checkIn'] as DateTime;
    _checkOut = args['checkOut'] as DateTime?;
    _adults = args['adults'] as int? ?? 1;
    _children = args['children'] as int? ?? 0;
    _babies = args['babies'] as int? ?? 0;
    _calculateTotalAmount();
  }

  void _calculateTotalAmount() {
    final effectiveCheckOutDate =
        _checkOut ?? _checkIn.add(const Duration(days: 1));
    int nights = effectiveCheckOutDate.difference(_checkIn).inDays;
    if (nights <= 0) nights = 1;
    _totalAmount = (_property.price ?? 0 * nights).toInt();
    if (_property.price != null) {
      _totalAmount = (_property.price! * nights).toInt();
    }
  }

  void _onNextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _onPreviousStep() {
    if (_currentStep == 2) {
      Get.offAllNamed(AppRoutes.home);
    } else if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Get.back();
    }
  }

  void _updateBookingData({
    DateTime? checkIn,
    DateTime? checkOut,
    int? adults,
    int? children,
    int? babies,
    String? cardId,
  }) {
    setState(() {
      if (checkIn != null) {
        _checkIn = checkIn;
        _checkOut = checkOut;
      }
      if (adults != null) _adults = adults;
      if (children != null) _children = children;
      if (babies != null) _babies = babies;
      if (cardId != null) _selectedCardId = cardId;
      _calculateTotalAmount();
    });
  }

  void _onBookingSuccess(Map<String, dynamic> details) {
    setState(() {
      _bookingDetails = details;
      _currentStep = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressIndicator(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _buildCurrentStepContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titles = [
      'confirmation'.tr,
      'payment_methods_title'.tr,
      'owner_contacts_title'.tr,
    ];
    final isSuccessStep = _currentStep == 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: SizedBox(
        height: 48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (isSuccessStep)
              const SizedBox(width: 44)
            else
              GestureDetector(
                onTap: _onPreviousStep,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black.withOpacity(0.05)
                            : Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                titles[_currentStep],
                key: ValueKey<int>(_currentStep),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (isSuccessStep)
              GestureDetector(
                onTap: () => Get.offAllNamed(AppRoutes.home),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black.withOpacity(0.05)
                            : Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              )
            else
              const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(child: _buildProgressSegment(_currentStep >= 0)),
          const SizedBox(width: 8),
          Expanded(child: _buildProgressSegment(_currentStep >= 1)),
          const SizedBox(width: 8),
          Expanded(child: _buildProgressSegment(_currentStep >= 2)),
        ],
      ),
    );
  }

  Widget _buildProgressSegment(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 4,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary
            : Theme.of(context).dividerColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return BookingConfirmationContent(
          key: const ValueKey('confirmation'),
          property: _property,
          checkIn: _checkIn,
          checkOut: _checkOut,
          adults: _adults,
          children: _children,
          babies: _babies,
          onNext: _onNextStep,
          onUpdateData: _updateBookingData,
        );
      case 1:
        return BookingPaymentContent(
          key: const ValueKey('payment'),
          property: _property,
          checkIn: _checkIn,
          checkOut: _checkOut ?? _checkIn.add(const Duration(days: 1)),
          adults: _adults,
          children: _children,
          babies: _babies,
          totalAmount: _totalAmount,
          selectedCardId: _selectedCardId,
          onCardSelected: (cardId) => _updateBookingData(cardId: cardId),
          onBookingSuccess: _onBookingSuccess,
        );
      case 2:
        if (_bookingDetails != null) {
          return BookingSuccessContent(
            key: const ValueKey('success'),
            bookingDetails: _bookingDetails!,
          );
        }
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }
}
