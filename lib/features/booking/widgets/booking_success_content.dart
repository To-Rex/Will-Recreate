import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../app.dart';

/// Step 3: Booking success content - owner contacts, dates, location
class BookingSuccessContent extends StatelessWidget {
  final Map<String, dynamic> bookingDetails;

  const BookingSuccessContent({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                _buildOwnerSection(context),
                const SizedBox(height: 24),
                _buildPhoneContainer(context),
                const SizedBox(height: 12),
                _buildTelegramContainer(context),
                const SizedBox(height: 32),
                Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                const SizedBox(height: 24),
                _buildDatesSection(context),
                const SizedBox(height: 24),
                Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                const SizedBox(height: 24),
                _buildLocationSection(context),
                const SizedBox(height: 24),
                Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                _buildSupportSection(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        _buildBottomButton(context),
      ],
    );
  }

  // Extract owner info from booking details
  Map<String, dynamic> get _owner {
    final owner = bookingDetails['owner'] ?? bookingDetails['partner'] ?? {};
    if (owner is Map<String, dynamic>) return owner;
    return {};
  }

  String get _ownerName {
    final first = _owner['first_name']?.toString() ?? '';
    final last = _owner['last_name']?.toString() ?? '';
    final full = _owner['full_name']?.toString() ?? '';
    if (full.isNotEmpty) return full;
    final name = '$first $last'.trim();
    return name.isEmpty ? 'Owner' : name;
  }

  String? get _ownerPhone => _owner['phone_number']?.toString();
  String? get _ownerPhoto => _owner['profile_photo']?.toString();
  String? get _ownerTelegram {
    final tg = _owner['telegram']?.toString() ?? _owner['username']?.toString();
    if (tg == null || tg.isEmpty) return null;
    return tg.startsWith('@') ? tg : '@$tg';
  }

  // Extract location from booking details
  Map<String, dynamic> get _location {
    final loc = bookingDetails['property_location'] ?? bookingDetails['location'] ?? {};
    if (loc is Map<String, dynamic>) return loc;
    return {};
  }

  Widget _buildOwnerSection(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: _ownerPhoto != null && _ownerPhoto!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: _ownerPhoto!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const AnimatedShimmerBox(width: 56, height: 56, borderRadius: 28),
                  errorWidget: (context, url, error) => Container(
                    width: 56, height: 56,
                    color: Theme.of(context).dividerColor.withAlpha(20),
                    child: const Icon(Icons.person, size: 28, color: Colors.grey),
                  ),
                )
              : Container(
                  width: 56, height: 56,
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFFF1F1F1)
                      : Colors.white.withOpacity(0.05),
                  child: const Icon(Icons.person, size: 28, color: Colors.grey),
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _ownerName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                'owner_of_property'.tr,
                style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneContainer(BuildContext context) {
    final phone = _ownerPhone ?? '+998 00 000 00 00';
    return GestureDetector(
      onTap: () => _launchPhone(_ownerPhone),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFF9F9F9)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.phone_outlined, size: 22, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            const SizedBox(width: 16),
            Text(phone, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }

  Widget _buildTelegramContainer(BuildContext context) {
    final telegram = _ownerTelegram;
    if (telegram == null || telegram.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _launchTelegram(telegram),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 22, height: 22,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.send, size: 12, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Text(telegram, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildDatesSection(BuildContext context) {
    String dateText = '';
    final localeStr = Localizations.localeOf(context).toString();

    try {
      final checkInStr = bookingDetails['check_in']?.toString() ?? '';
      final checkOutStr = bookingDetails['check_out']?.toString() ?? '';
      if (checkInStr.isNotEmpty && checkOutStr.isNotEmpty) {
        final checkInDate = DateTime.parse(checkInStr);
        final checkOutDate = DateTime.parse(checkOutStr);
        final startDay = checkInDate.day;
        final endDay = checkOutDate.day;
        final month = DateFormat('MMMM', localeStr).format(checkInDate);
        final year = checkInDate.year;
        if (startDay == endDay) {
          dateText = '$startDay $month. $year ${'year_suffix'.tr}';
        } else {
          dateText = '$startDay-$endDay $month. $year ${'year_suffix'.tr}';
        }
      }
    } catch (_) {
      dateText = '${bookingDetails['check_in'] ?? ''} - ${bookingDetails['check_out'] ?? ''}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('dates_label'.tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 4),
        Text(
          dateText.isNotEmpty ? dateText : 'dates_not_specified'.tr,
          style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    final city = _location['city']?.toString() ?? '';
    final country = _location['country']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'location_on_object'.tr,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 16),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? const Color(0xFFF9F9F9)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 40, color: AppColors.primary),
                  const SizedBox(height: 8),
                  Text(
                    '$city, $country',
                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.location_on_outlined, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            const SizedBox(width: 4),
            Text(
              '$city, $country',
              style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), letterSpacing: -0.32),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final Uri url = Uri.parse('https://t.me/weelsupport');
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('support'.tr, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
            Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
        height: 56,
        child: ElevatedButton(
          onPressed: () => Get.offAllNamed(AppRoutes.home),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Text('done'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );
  }

  Future<void> _launchPhone(String? phoneNumber) async {
    if (phoneNumber == null) return;
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchTelegram(String username) async {
    final cleanUsername = username.replaceAll('@', '');
    final uri = Uri.parse('https://t.me/$cleanUsername');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
