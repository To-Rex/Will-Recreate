import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/property_model.dart';
import '../../data/repositories/booking_repository.dart';
import '../../app.dart';

// ===================== Controller =====================

class BookingHistoryController extends GetxController {
  final groupedBookings = <DateTime, List<BookingHistoryModel>>{}.obs;
  final isLoading = true.obs;
  final errorMessage = Rx<String?>(null);
  final _bookingRepository = BookingRepository();

  @override
  void onInit() {
    super.onInit();
    loadBookings();
  }

  Future<void> loadBookings() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _bookingRepository.getBookingHistory();
      result.when(
        success: (bookings) {
          final grouped = <DateTime, List<BookingHistoryModel>>{};
          for (var booking in bookings) {
            final date = DateTime(
              booking.createdAt.year,
              booking.createdAt.month,
              booking.createdAt.day,
            );
            if (!grouped.containsKey(date)) {
              grouped[date] = [];
            }
            grouped[date]!.add(booking);
          }
          groupedBookings.value = grouped;
        },
        failure: (msg) => errorMessage.value = msg,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    }
    isLoading.value = false;
  }

  Future<void> refreshBookings() async {
    await loadBookings();
  }

  /// Booking detailni API dan olish
  Future<BookingHistoryModel?> getBookingDetail(String bookingId) async {
    final result = await _bookingRepository.getBookingHistoryDetail(bookingId);
    return result.when(
      success: (data) => data,
      failure: (_) => null,
    );
  }
}

class BookingHistoryBinding extends Bindings {
  @override
  void dependencies() =>
      Get.lazyPut<BookingHistoryController>(() => BookingHistoryController());
}

// ===================== Screen =====================

class BookingHistoryScreen extends GetView<BookingHistoryController> {
  const BookingHistoryScreen({super.key});

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
          'history'.tr,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState(context);
        }

        if (controller.errorMessage.value != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/technical_error.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 16),
                Text(
                  'error_default'.tr,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadBookings(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('retry'.tr),
                ),
              ],
            ),
          );
        }

        if (controller.groupedBookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'no_booking_history'.tr,
                  style:
                      const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final sortedDates = controller.groupedBookings.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return RefreshIndicator(
          onRefresh: () => controller.refreshBookings(),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final bookings = controller.groupedBookings[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  ...bookings.map(
                    (booking) => _BookingCard(booking: booking),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ===================== Booking Card =====================

class _BookingCard extends StatelessWidget {
  final BookingHistoryModel booking;

  const _BookingCard({required this.booking});

  void _showDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) =>
          _BookingDetailBottomSheet(booking: booking),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _showDetailsBottomSheet(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: booking.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              booking.category ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (booking.category != null &&
                              booking.category!.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                '•',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                          Text(
                            DateFormat('dd MMMM, HH:mm', 'ru_RU')
                                .format(booking.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (booking.status != null) ...[
                        const SizedBox(height: 6),
                        _buildStatusBadge(context, booking.status!),
                      ],
                    ],
                  ),
                ),

                // Chevron
                const Icon(Icons.chevron_right,
                    color: Colors.grey, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'cancelled':
        color = Colors.red;
        label = 'status_cancelled'.tr;
        break;
      case 'completed':
        color = const Color(0xFF34C759);
        label = 'status_completed'.tr;
        break;
      case 'pending':
        color = Colors.orange;
        label = 'status_pending'.tr;
        break;
      case 'confirmed':
        color = AppColors.primary;
        label = 'status_confirmed'.tr;
        break;
      case 'paid':
        color = Colors.blue;
        label = 'status_paid'.tr;
        break;
      default:
        color = Colors.blue;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ===================== Detail Bottom Sheet =====================

class _BookingDetailBottomSheet extends StatefulWidget {
  final BookingHistoryModel booking;

  const _BookingDetailBottomSheet({required this.booking});

  @override
  State<_BookingDetailBottomSheet> createState() =>
      _BookingDetailBottomSheetState();
}

class _BookingDetailBottomSheetState extends State<_BookingDetailBottomSheet> {
  late BookingHistoryModel _currentBooking;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    final controller = Get.find<BookingHistoryController>();
    final detailedBooking =
        await controller.getBookingDetail(widget.booking.guid);

    if (mounted && detailedBooking != null) {
      setState(() {
        _currentBooking = widget.booking.copyWith(
          partnerName:
              detailedBooking.partnerName ?? widget.booking.partnerName,
          partnerPhone:
              detailedBooking.partnerPhone ?? widget.booking.partnerPhone,
          checkIn: detailedBooking.checkIn ?? widget.booking.checkIn,
          checkOut: detailedBooking.checkOut ?? widget.booking.checkOut,
          city: detailedBooking.city ?? widget.booking.city,
          country: detailedBooking.country ?? widget.booking.country,
          location: detailedBooking.location ?? widget.booking.location,
          price: detailedBooking.price ?? widget.booking.price,
          rating: detailedBooking.rating ?? widget.booking.rating,
          bookingNumber:
              detailedBooking.bookingNumber ?? widget.booking.bookingNumber,
          latitude: detailedBooking.latitude ?? widget.booking.latitude,
          longitude: detailedBooking.longitude ?? widget.booking.longitude,
        );
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'ru_RU');
    return formatter.format(price).replaceAll(',', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color:
                    Theme.of(context).dividerColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: _currentBooking.imageUrl,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 120,
                  height: 120,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image,
                      size: 40, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category
            Text(
              _currentBooking.category ?? '',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),

            const SizedBox(height: 8),

            // Title
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _currentBooking.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),

            // Check-in / Check-out
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoColumn(
                      context,
                      'check_in_label'.tr,
                      _currentBooking.checkIn ?? '-',
                      Icons.login_rounded,
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Theme.of(context)
                        .dividerColor
                        .withOpacity(0.1),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                      context,
                      'check_out_label'.tr,
                      _currentBooking.checkOut ?? '-',
                      Icons.logout_rounded,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Owner section
            _buildOwnerSection(context),

            const SizedBox(height: 24),

            // Info container
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).brightness == Brightness.light
                          ? const Color(0xFFF9F9F9)
                          : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context)
                        .dividerColor
                        .withOpacity(0.1),
                  ),
                ),
                child: Column(
                  children: [
                    _buildBeautyRow(
                      context,
                      'location_label'.tr,
                      _currentBooking.city != null &&
                              _currentBooking.country != null
                          ? '${_currentBooking.city}, ${_currentBooking.country}'
                          : '-',
                    ),
                    const Divider(height: 24),
                    _buildBeautyRow(
                      context,
                      'booking_number_label'.tr,
                      _currentBooking.bookingNumber ?? '-',
                    ),
                    const Divider(height: 24),
                    _buildBeautyRow(
                      context,
                      'rating_label'.tr,
                      _currentBooking.rating?.toString() ?? '5.0',
                      isRating: true,
                    ),
                    const Divider(height: 24),
                    _buildBeautyRow(
                      context,
                      'price_label'.tr,
                      '${_formatPrice(_currentBooking.price ?? 0)} ${'sum'.tr}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  if (_currentBooking.status?.toLowerCase() ==
                          'cancelled' ||
                      _currentBooking.status?.toLowerCase() ==
                          'completed')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Leave review action placeholder
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF34C759),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'leave_review'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final Uri url = Uri.parse(
                              'https://t.me/weelsupport',
                            );
                            if (!await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            )) {
                              // Could not launch
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'support'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Get.toNamed(
                              AppRoutes.listingDetail,
                              arguments: {
                                'property': Property(
                                  guid: _currentBooking.propertyGuid,
                                  title: _currentBooking.title,
                                  location: PropertyLocation(
                                    latitude:
                                        _currentBooking.latitude?.toString() ??
                                            '',
                                    longitude: _currentBooking.longitude
                                            ?.toString() ??
                                        '',
                                    country:
                                        _currentBooking.country ?? '',
                                    city: _currentBooking.city ?? '',
                                  ),
                                  images: [
                                    PropertyImage(
                                      guid: '',
                                      order: 1,
                                      imageUrl:
                                          _currentBooking.imageUrl,
                                    ),
                                  ],
                                  averageRating:
                                      _currentBooking.rating ?? 5.0,
                                ),
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'book_action'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerSection(BuildContext context) {
    if (_isLoading && _currentBooking.partnerName == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentBooking.partnerName == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF34C759).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: Color(0xFF34C759),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'owner_label'.tr,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  _currentBooking.partnerName!,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (_currentBooking.partnerPhone != null)
            IconButton(
              onPressed: () async {
                final Uri url =
                    Uri.parse('tel:${_currentBooking.partnerPhone}');
                if (!await launchUrl(url)) {
                  // Could not launch
                }
              },
              icon: const Icon(Icons.phone_in_talk_outlined),
              color: const Color(0xFF34C759),
            ),
        ],
      ),
    );
  }

  Widget _buildBeautyRow(
    BuildContext context,
    String label,
    String value, {
    bool isRating = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRating) ...[
              const Icon(Icons.star, size: 16, color: Color(0xFFFFD700)),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoColumn(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: Colors.grey[400]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (_isLoading && value == '-')
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 60,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          )
        else
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
      ],
    );
  }
}
