import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/section_divider.dart';
import '../../../core/utils/service_icon_mapper.dart';
import '../../../data/models/property_model.dart';
import '../favorites/favorites_controller.dart';
import 'widgets/listing_image_carousel.dart';
import 'widgets/listing_location_section.dart';
import 'widgets/listing_bottom_bar.dart';
import 'widgets/cancellation_rules_sheet.dart';

String? _formatTime(String? time) {
  if (time == null || time.isEmpty) return null;
  final parts = time.split(':');
  if (parts.length >= 2) return '${parts[0]}:${parts[1]}';
  return time;
}

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({super.key});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  bool _showFullDescription = false;
  bool _showAllAmenities = false;
  bool _showRules = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _rulesKey = GlobalKey();
  Property? _property;
  final _favoritesController = Get.find<FavoritesController>();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _property = args['property'] as Property?;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_property == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('No data')),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListingImageCarousel(
                  property: _property!,
                  favoritesController: _favoritesController,
                ),
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildTitleSection(),
                          const SectionDivider(),
                          if ((_property?.averageRating ?? 0.0) >= 2.0 ||
                              (_property?.commentCount ?? 0) > 0) ...[
                            _buildRatingSection(),
                            const SectionDivider(),
                          ],
                          if (_property?.description != null &&
                              _property!.description!.isNotEmpty) ...[
                            _buildDescriptionSection(),
                            const SectionDivider(),
                          ],
                          if (_property?.services.isNotEmpty ?? false) ...[
                            _buildAmenitiesSection(),
                            const SectionDivider(),
                          ],
                          ListingLocationSection(property: _property!),
                          const SectionDivider(),
                          _buildLivingConditionsSection(),
                          const SectionDivider(),
                          _buildCancellationRulesSection(),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListingBottomBar(property: _property!),
        ],
      ),
    );
  }

  // ==================== Title Section ====================
  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _property?.title ?? '',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.6,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                _buildInfoChip('${_property?.room?.maxGuests ?? 0} ${'guest'.tr}'),
                _buildDot(),
                _buildInfoChip('${_property?.room?.beds ?? 0} ${'beds'.tr}'),
                _buildDot(),
                _buildInfoChip('${_property?.room?.bedrooms ?? 0} ${'bedrooms'.tr}'),
                _buildDot(),
                _buildInfoChip('${_property?.room?.bathrooms ?? 0} ${'bathrooms'.tr}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        fontSize: 14,
        letterSpacing: -0.32,
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: 2,
      height: 2,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
    );
  }

  // ==================== Rating Section ====================
  Widget _buildRatingSection() {
    final rating = _property?.averageRating ?? 0.0;
    final showRating = rating >= 2.0;
    final commentCount = _property?.commentCount ?? 0;
    final showComments = commentCount > 0;

    if (!showRating && !showComments) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          if (showRating) ...[
            Expanded(
              child: Column(
                children: [
                  Text(
                    rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.6,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Icon(
                        Icons.star,
                        size: 11,
                        color: index < rating.floor()
                            ? AppColors.yellow
                            : Colors.grey.shade300,
                      );
                    }),
                  ),
                ],
              ),
            ),
            if (showComments)
              Container(
                width: 1,
                height: 50,
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
          ],
          if (showComments)
            Expanded(
              child: Column(
                children: [
                  Text(
                    commentCount.toString(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.6,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'reviews_title'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: -0.32,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ==================== Description Section ====================
  Widget _buildDescriptionSection() {
    final description = _property?.description;
    if (description == null || description.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              letterSpacing: -0.32,
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: _showFullDescription ? null : 3,
            overflow: _showFullDescription ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          _buildToggleButton(
            _showFullDescription ? 'show_less'.tr : 'show_more'.tr,
            () => setState(() => _showFullDescription = !_showFullDescription),
          ),
        ],
      ),
    );
  }

  // ==================== Amenities Section ====================
  Widget _buildAmenitiesSection() {
    final allServices = _property?.services ?? [];
    if (allServices.isEmpty) return const SizedBox.shrink();

    final visibleServices = _showAllAmenities || allServices.length <= 6
        ? allServices
        : allServices.sublist(0, 6);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'amenities'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.6,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: visibleServices.map((service) {
              return _AmenityChip(service: service);
            }).toList(),
          ),
          if (allServices.length > 6) ...[
            const SizedBox(height: 20),
            _buildToggleButton(
              _showAllAmenities ? 'show_less'.tr : 'show_all'.tr,
              () => setState(() => _showAllAmenities = !_showAllAmenities),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== Living Conditions Section ====================
  Widget _buildLivingConditionsSection() {
    return Padding(
      key: _rulesKey,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() => _showRules = !_showRules);
              if (_showRules) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (_rulesKey.currentContext != null) {
                    Scrollable.ensureVisible(
                      _rulesKey.currentContext!,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.fastOutSlowIn,
                      alignment: 0.2,
                    );
                  }
                });
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'living_conditions'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.6,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Icon(
                  _showRules ? Icons.expand_less : Icons.expand_more,
                  size: 38,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
          ),
          if (_showRules) ...[
            const SizedBox(height: 20),
            _ConditionItem(
              title: 'age_restrictions'.tr,
              value: 'age_restriction_text'.tr,
            ),
            const SectionDivider(),
            _ConditionItem(
              title: 'check_in_check_out_time'.tr,
              value: '${'check_in_from'.trParams({'time': _formatTime(_property?.checkInTime) ?? '19:00'})}, '
                  '${'check_out_until'.trParams({'time': _formatTime(_property?.checkOutTime) ?? '17:00'})}',
            ),
            const SectionDivider(),
            _ConditionItem(
              title: 'quiet_hours'.tr,
              value: _property?.isQuietHours == true
                  ? 'quiet_hours_range'.tr
                  : 'not_allowed'.tr,
            ),
            const SectionDivider(),
            _ConditionItem(
              title: 'alcohol'.tr,
              value: _property?.isAllowedAlcohol == true
                  ? 'allowed'.tr
                  : 'not_allowed'.tr,
            ),
            const SectionDivider(),
            _ConditionItem(
              title: 'corporate_parties'.tr,
              value: _property?.isAllowedCorporate == true
                  ? 'allowed'.tr
                  : 'not_allowed'.tr,
            ),
            const SectionDivider(),
            _ConditionItem(
              title: 'pets'.tr,
              value: _property?.isAllowedPets == true
                  ? 'pets_allowed'.tr
                  : 'pets_not_allowed'.tr,
            ),
          ],
        ],
      ),
    );
  }

  // ==================== Cancellation Rules Section ====================
  Widget _buildCancellationRulesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: _ConditionItem(
        title: 'cancellation_rules'.tr,
        value: 'view_cancellation_rules'.tr,
        isLink: true,
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const CancellationRulesSheet(),
          );
        },
      ),
    );
  }

  // ==================== Shared Toggle Button ====================
  Widget _buildToggleButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          side: BorderSide.none,
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFFAFAFA)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.32,
          ),
        ),
      ),
    );
  }
}

// ==================== Amenity Chip Widget ====================
class _AmenityChip extends StatelessWidget {
  final dynamic service;

  const _AmenityChip({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBorder
              : const Color(0xFFE6E6E6),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(minHeight: 40),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (service.iconUrl.isNotEmpty && service.iconUrl.endsWith('.svg'))
            SvgPicture.network(
              service.iconUrl,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onSurface,
                BlendMode.srcIn,
              ),
              placeholderBuilder: (context) => const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Icon(
              getServiceIcon(service.title),
              size: 20,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          const SizedBox(width: 6),
          Text(
            service.title,
            style: TextStyle(
              fontSize: 12,
              letterSpacing: -0.32,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ==================== Condition Item Widget ====================
class _ConditionItem extends StatelessWidget {
  final String title;
  final String value;
  final bool isLink;
  final VoidCallback? onTap;

  const _ConditionItem({
    required this.title,
    required this.value,
    this.isLink = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.32,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                letterSpacing: -0.32,
                decoration: isLink ? TextDecoration.underline : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
