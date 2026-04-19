import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/property_model.dart';
import '../../../data/repositories/booking_repository.dart';
import 'booking_guests_sheet.dart';

/// Booking calendar bottom sheet - pixel-perfect design from old project
class BookingCalendarSheet extends StatefulWidget {
  final Property property;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final bool isEditing;

  const BookingCalendarSheet({
    super.key,
    required this.property,
    this.initialStartDate,
    this.initialEndDate,
    this.isEditing = false,
  });

  @override
  State<BookingCalendarSheet> createState() => _BookingCalendarSheetState();
}

class _BookingCalendarSheetState extends State<BookingCalendarSheet> {
  DateTime? _startDate;
  DateTime? _endDate;
  final DateTime _today = DateTime.now();
  List<CalendarDate> _calendarDates = [];
  bool _isLoadingCalendar = false;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _fetchCalendarData();
  }

  Future<void> _fetchCalendarData() async {
    setState(() => _isLoadingCalendar = true);
    try {
      final repository = BookingRepository();
      final fromDateStr = DateFormat('yyyy-MM-dd').format(_today);
      final nextMonth = DateTime(_today.year, _today.month + 1);
      final nextMonthLastDay = DateTime(nextMonth.year, nextMonth.month + 1, 0);
      final toDateStr = DateFormat('yyyy-MM-dd').format(nextMonthLastDay);

      final result = await repository.getPropertyCalendar(
        propertyId: widget.property.guid,
        fromDate: fromDateStr,
        toDate: toDateStr,
      );

      if (mounted) {
        result.when(
          success: (dates) {
            setState(() {
              _calendarDates = dates;
              _isLoadingCalendar = false;
            });
          },
          failure: (_) {
            setState(() => _isLoadingCalendar = false);
          },
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingCalendar = false);
    }
  }

  CalendarDate? _getStatusForDate(DateTime date) {
    try {
      return _calendarDates.firstWhere(
        (d) =>
            d.date.year == date.year &&
            d.date.month == date.month &&
            d.date.day == date.day,
      );
    } catch (_) {
      return null;
    }
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isInRange(DateTime date) {
    if (_startDate == null || _endDate == null) return false;
    return date.isAfter(_startDate!) && date.isBefore(_endDate!);
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = date;
        _endDate = null;
      } else if (_startDate != null && _endDate == null) {
        if (date.isBefore(_startDate!)) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
          const SizedBox(height: 16),
          _buildWeekDaysRow(),
          Divider(
            height: 32,
            thickness: 1,
            color: Theme.of(context).dividerColor.withOpacity(0.1),
          ),
          _isLoadingCalendar
              ? const Expanded(child: _CalendarShimmer())
              : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      final month = DateTime(_today.year, _today.month + index);
                      return _buildMonthCalendar(month);
                    },
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
                'calendar'.tr,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.8,
                ),
              ),
              Text(
                'available_dates'.tr,
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

  Widget _buildWeekDaysRow() {
    final weekDays = [
      'mon'.tr, 'tue'.tr, 'wed'.tr, 'thu'.tr, 'fri'.tr, 'sat'.tr, 'sun'.tr,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weekDays
            .map((d) => SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildMonthCalendar(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDayWeekday = DateTime(month.year, month.month, 1).weekday;
    final localeStr = Localizations.localeOf(context).toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          child: Text(
            '${DateFormat('MMMM', localeStr).format(month).substring(0, 1).toUpperCase()}${DateFormat('MMMM', localeStr).format(month).substring(1)} ${month.year} ${'year_suffix'.tr}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 0,
            childAspectRatio: 1,
          ),
          itemCount: daysInMonth + (firstDayWeekday - 1),
          itemBuilder: (context, index) {
            if (index < firstDayWeekday - 1) return const SizedBox.shrink();

            final day = index - (firstDayWeekday - 2);
            final date = DateTime(month.year, month.month, day);
            final isPast = date.isBefore(
              DateTime(_today.year, _today.month, _today.day),
            );

            final isStart = _isSameDay(date, _startDate);
            final isEnd = _isSameDay(date, _endDate);
            final isInRange = _isInRange(date);
            final calendarStatus = _getStatusForDate(date);

            return _buildDateCell(date, day, isPast, isStart, isEnd, isInRange, calendarStatus);
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDateCell(
    DateTime date,
    int day,
    bool isPast,
    bool isStart,
    bool isEnd,
    bool isInRange,
    CalendarDate? calendarStatus,
  ) {
    final bool isSelected = isStart || isEnd;
    final bool isBooked = calendarStatus?.isBooked ?? false;
    final bool isHeld = calendarStatus?.isHeld ?? false;
    final bool isBlocked = calendarStatus?.isBlocked ?? false;
    final bool isDisabled = isPast || isBooked || isHeld || isBlocked;

    return GestureDetector(
      onTap: isDisabled ? null : () => _onDateSelected(date),
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isInRange
                    ? (Theme.of(context).brightness == Brightness.light
                        ? const Color(0xFFF8F8F8)
                        : Colors.white.withOpacity(0.05))
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Text(
            '$day',
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (isDisabled
                      ? (Theme.of(context).brightness == Brightness.light
                          ? const Color(0xFFD1D1D1)
                          : Colors.white.withOpacity(0.2))
                      : Theme.of(context).colorScheme.onSurface),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
              decoration: isBlocked ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    final bool canContinue = _startDate != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 34),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(text: 'booking_pre_order_note'.tr),
                TextSpan(
                  text: 'up_to_one_month_ahead'.tr,
                  style: TextStyle(color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: canContinue
                  ? () {
                      if (widget.isEditing) {
                        Navigator.pop(context, {
                          'startDate': _startDate,
                          'endDate': _endDate,
                        });
                      } else {
                        final finalEndDate =
                            _endDate ?? _startDate!.add(const Duration(days: 1));
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => BookingGuestsSheet(
                            property: widget.property,
                            startDate: _startDate!,
                            endDate: finalEndDate,
                          ),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                widget.isEditing ? 'save'.tr : 'book'.tr,
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
    );
  }
}

/// Calendar shimmer loading widget
class _CalendarShimmer extends StatelessWidget {
  const _CalendarShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month title shimmer
          Container(
            width: 180,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          // Grid shimmer
          Wrap(
            spacing: 0,
            runSpacing: 8,
            children: List.generate(35, (index) {
              return SizedBox(
                width: (MediaQuery.of(context).size.width - 48) / 7,
                height: 40,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
