import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../data/models/property_model.dart';
import '../../listing/widgets/cancellation_rules_sheet.dart';
import '../widgets/booking_calendar_sheet.dart';
import '../widgets/booking_guests_sheet.dart';

/// Step 1: Booking confirmation content
class BookingConfirmationContent extends StatefulWidget {
  final Property property;
  final DateTime checkIn;
  final DateTime? checkOut;
  final int adults;
  final int children;
  final int babies;
  final VoidCallback onNext;
  final Function({
    DateTime? checkIn,
    DateTime? checkOut,
    int? adults,
    int? children,
    int? babies,
    String? cardId,
  }) onUpdateData;

  const BookingConfirmationContent({
    super.key,
    required this.property,
    required this.checkIn,
    this.checkOut,
    required this.adults,
    required this.children,
    required this.babies,
    required this.onNext,
    required this.onUpdateData,
  });

  @override
  State<BookingConfirmationContent> createState() =>
      _BookingConfirmationContentState();
}

class _BookingConfirmationContentState
    extends State<BookingConfirmationContent> {
  bool _isConditionsExpanded = false;

  String? _formatTime(String? time) {
    if (time == null || time.isEmpty) return null;
    final parts = time.split(':');
    if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
    return time;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveCheckOutDate =
        widget.checkOut ?? widget.checkIn.add(const Duration(days: 1));

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                _buildPropertyCard(),
                const SizedBox(height: 32),
                _buildInfoItem(
                  'dates_label'.tr,
                  _formatDates(widget.checkIn, widget.checkOut),
                  onTap: () {
                    showModalBottomSheet<Map<String, dynamic>>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => BookingCalendarSheet(
                        property: widget.property,
                        initialStartDate: widget.checkIn,
                        initialEndDate: effectiveCheckOutDate,
                        isEditing: true,
                      ),
                    ).then((result) {
                      if (result != null && result['startDate'] != null) {
                        widget.onUpdateData(
                          checkIn: result['startDate'] as DateTime,
                          checkOut: result['endDate'] as DateTime?,
                        );
                      }
                    });
                  },
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
                _buildInfoItem(
                  'guests'.tr,
                  '${'guests_count'.trParams({'count': '${widget.adults + widget.children}'})}, ${'babies_count'.trParams({'count': '${widget.babies}'})}',
                  onTap: () {
                    showModalBottomSheet<Map<String, dynamic>>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => BookingGuestsSheet(
                        property: widget.property,
                        startDate: widget.checkIn,
                        endDate: effectiveCheckOutDate,
                        initialAdults: widget.adults,
                        initialChildren: widget.children,
                        initialBabies: widget.babies,
                        isEditing: true,
                      ),
                    ).then((result) {
                      if (result != null) {
                        widget.onUpdateData(
                          adults: result['adults'] as int,
                          children: result['children'] as int,
                          babies: result['babies'] as int,
                        );
                      }
                    });
                  },
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
                _buildExpandableSection(
                  'living_conditions'.tr,
                  _isConditionsExpanded,
                  () => setState(
                    () => _isConditionsExpanded = !_isConditionsExpanded,
                  ),
                ),
                if (_isConditionsExpanded) ...[
                  _buildConditionItem(
                    'age_restrictions'.tr,
                    'age_restriction_text'.tr,
                  ),
                  Divider(height: 1, thickness: 0.5, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                  _buildConditionItem(
                    'check_in_check_out_time'.tr,
                    '${'check_in_from'.trParams({'time': _formatTime(widget.property.checkInTime) ?? '19:00'})}, '
                        '${'check_out_until'.trParams({'time': _formatTime(widget.property.checkOutTime) ?? '17:00'})}',
                  ),
                  Divider(height: 1, thickness: 0.5, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                  _buildConditionItem(
                    'quiet_hours'.tr,
                    widget.property.isQuietHours ? 'quiet_hours_range'.tr : 'not_allowed'.tr,
                  ),
                  Divider(height: 1, thickness: 0.5, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                  _buildConditionItem(
                    'alcohol'.tr,
                    widget.property.isAllowedAlcohol ? 'allowed'.tr : 'not_allowed'.tr,
                  ),
                  Divider(height: 1, thickness: 0.5, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                  _buildConditionItem(
                    'corporate_parties'.tr,
                    widget.property.isAllowedCorporate ? 'allowed'.tr : 'not_allowed'.tr,
                  ),
                  Divider(height: 1, thickness: 0.5, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                  _buildConditionItem(
                    'pets'.tr,
                    widget.property.isAllowedPets ? 'pets_allowed'.tr : 'pets_not_allowed'.tr,
                  ),
                ],
                Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                _buildCancellationSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        _buildBottomButton(),
      ],
    );
  }

  String _formatDates(DateTime start, DateTime? end) {
    final localeStr = Localizations.localeOf(context).toString();

    if (end == null || (start.year == end.year && start.month == end.month && start.day == end.day)) {
      return '${DateFormat('d MMMM', localeStr).format(start)}. ${start.year} ${'year_suffix'.tr}';
    }

    if (start.month == end.month) {
      return '${start.day}-${end.day} ${DateFormat('MMMM', localeStr).format(start)}. ${start.year} ${'year_suffix'.tr}';
    } else {
      return '${DateFormat('d MMM', localeStr).format(start)} - ${DateFormat('d MMM', localeStr).format(end)}. ${end.year} ${'year_suffix'.tr}';
    }
  }

  Widget _buildPropertyCard() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: widget.property.images.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: widget.property.images[0].imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const AnimatedShimmerBox(
                    width: 100, height: 100, borderRadius: 20,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    width: 100, height: 100,
                  ),
                )
              : Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  width: 100, height: 100,
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.property.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${widget.property.location.city}, ${widget.property.location.country}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (widget.property.averageRating >= 2 || widget.property.commentCount > 0)
                Row(
                  children: [
                    if (widget.property.averageRating >= 2) ...[
                      Text(
                        widget.property.averageRating.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      if (widget.property.commentCount > 0) const SizedBox(width: 4),
                    ],
                    if (widget.property.commentCount > 0)
                      Flexible(
                        child: Text(
                          '(${widget.property.commentCount}) ${'reviews_title'.tr.toLowerCase()}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String title, String value, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Row(
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_outlined,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(String title, bool isExpanded, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Theme.of(context).colorScheme.onSurface,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancellationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'cancellation_rules'.tr,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const CancellationRulesSheet(),
              );
            },
            child: Text(
              'view_cancellation_rules'.tr,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
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
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: widget.onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Text(
            'next'.tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
