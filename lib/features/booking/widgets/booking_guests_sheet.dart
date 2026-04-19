import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/property_model.dart';
import '../../../app.dart';

/// Booking guests bottom sheet - pixel-perfect design from old project
class BookingGuestsSheet extends StatefulWidget {
  final Property property;
  final DateTime startDate;
  final DateTime endDate;

  final int? initialAdults;
  final int? initialChildren;
  final int? initialBabies;
  final bool isEditing;

  const BookingGuestsSheet({
    super.key,
    required this.property,
    required this.startDate,
    required this.endDate,
    this.initialAdults,
    this.initialChildren,
    this.initialBabies,
    this.isEditing = false,
  });

  @override
  State<BookingGuestsSheet> createState() => _BookingGuestsSheetState();
}

class _BookingGuestsSheetState extends State<BookingGuestsSheet> {
  late int _adults;
  late int _children;
  late int _babies;
  bool _pets = false;

  @override
  void initState() {
    super.initState();
    _adults = widget.initialAdults ?? 1;
    _children = widget.initialChildren ?? 0;
    _babies = widget.initialBabies ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          _buildHeader(),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildGuestRow(
                    'adults_label'.tr,
                    'adults_info'.tr,
                    _adults,
                    (val) => setState(() => _adults = val),
                    min: 1,
                  ),
                  Divider(
                    height: 40,
                    thickness: 0.5,
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                  _buildGuestRow(
                    'children_label'.tr,
                    'children_info'.tr,
                    _children,
                    (val) => setState(() => _children = val),
                  ),
                  Divider(
                    height: 40,
                    thickness: 0.5,
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                  _buildGuestRow(
                    'babies_label'.tr,
                    'babies_info'.tr,
                    _babies,
                    (val) => setState(() => _babies = val),
                  ),
                  Divider(
                    height: 40,
                    thickness: 0.5,
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                  _buildPetsRow(),
                ],
              ),
            ),
          ),
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'who_heading'.tr,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.8,
                ),
              ),
              Text(
                'guests_subheading'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? const Color(0xFFF9F9F9)
                    : Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.onSurface,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestRow(
    String title,
    String subtitle,
    int count,
    Function(int) onChanged, {
    int min = 0,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.32,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                  letterSpacing: -0.32,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            _buildStepperButton(
              icon: Icons.remove,
              onPressed: count > min ? () => onChanged(count - 1) : null,
              isEnabled: count > min,
            ),
            const SizedBox(width: 8),
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildStepperButton(
              icon: Icons.add,
              onPressed: () => onChanged(count + 1),
              isEnabled: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    VoidCallback? onPressed,
    required bool isEnabled,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isEnabled
              ? AppColors.primary
              : (Theme.of(context).brightness == Brightness.light
                  ? const Color(0xFFF9F9F9)
                  : Colors.white.withOpacity(0.05)),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isEnabled ? Colors.white : const Color(0xFF999999),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildPetsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'pets_label'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.32,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'pets_sublabel'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  letterSpacing: -0.32,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _pets = !_pets),
          child: Container(
            width: 51,
            height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: _pets
                  ? AppColors.primary
                  : (Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFFD9D9D9)
                      : Colors.white.withOpacity(0.1)),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  left: _pets ? 23 : 3,
                  top: 3,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _adults = 1;
                  _children = 0;
                  _babies = 0;
                  _pets = false;
                });
              },
              child: Text(
                'reset_all'.tr,
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (widget.isEditing) {
                    Navigator.pop(context, {
                      'adults': _adults,
                      'children': _children,
                      'babies': _babies,
                    });
                  } else {
                    Navigator.pop(context); // close guests sheet
                    Get.toNamed(
                      AppRoutes.bookingFlow,
                      arguments: {
                        'property': widget.property,
                        'checkIn': widget.startDate,
                        'checkOut': widget.endDate,
                        'adults': _adults,
                        'children': _children,
                        'babies': _babies,
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: Color(0xFF9AFFC9), width: 1),
                  ),
                ),
                child: Text(
                  widget.isEditing ? 'save'.tr : 'next'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
