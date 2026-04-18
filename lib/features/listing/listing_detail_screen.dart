import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '../../core/theme/app_colors.dart';
import '../../data/models/property_model.dart';
import '../../app.dart';
import 'widgets/full_screen_gallery.dart';
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
  int _currentImageIndex = 0;
  bool _showFullDescription = false;
  bool _showAllAmenities = false;
  bool _showRules = false;
  bool _isFavorite = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _rulesKey = GlobalKey();
  Property? _property;

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
                _buildImageCarousel(),
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
                          Divider(
                            height: 1,
                            thickness: 0.5,
                            color: Theme.of(context).dividerColor.withOpacity(0.1),
                          ),
                          if ((_property?.averageRating ?? 0.0) >= 2.0 ||
                              (_property?.commentCount ?? 0) > 0) ...[
                            _buildRatingSection(),
                            Divider(
                              height: 1,
                              thickness: 0.5,
                              color: Theme.of(context).dividerColor.withOpacity(0.1),
                            ),
                          ],
                          if (_property?.description != null &&
                              _property!.description!.isNotEmpty) ...[
                            _buildDescriptionSection(),
                            Divider(
                              height: 1,
                              thickness: 0.5,
                              color: Theme.of(context).dividerColor.withOpacity(0.1),
                            ),
                          ],
                          if (_property?.services.isNotEmpty ?? false) ...[
                            _buildAmenitiesSection(),
                            Divider(
                              height: 1,
                              thickness: 0.5,
                              color: Theme.of(context).dividerColor.withOpacity(0.1),
                            ),
                          ],
                          _buildLocationSection(),
                          Divider(
                            height: 1,
                            thickness: 0.5,
                            color: Theme.of(context).dividerColor.withOpacity(0.1),
                          ),
                          _buildLivingConditionsSection(),
                          Divider(
                            height: 1,
                            thickness: 0.5,
                            color: Theme.of(context).dividerColor.withOpacity(0.1),
                          ),
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
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ==================== Image Carousel ====================
  Widget _buildImageCarousel() {
    final images = _property?.images.map((e) => e.imageUrl).toList() ?? <String>[];

    return Stack(
      children: [
        SizedBox(
          height: 390,
          width: double.infinity,
          child: PageView.builder(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            onPageChanged: (index) {
              setState(() => _currentImageIndex = index);
            },
            itemCount: images.length,
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: images[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  child: Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: Center(
                    child: Icon(
                      Icons.image,
                      size: 60.r,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Top gradient
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 200,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  stops: const [0.29, 0.76],
                ),
              ),
            ),
          ),
        ),

        // Bottom gradient
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 200,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  stops: const [0.29, 0.76],
                ),
              ),
            ),
          ),
        ),

        // Image counter
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  '${_currentImageIndex + 1}/${images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Fullscreen button
        Positioned(
          bottom: 60,
          right: 30,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.fullscreen, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    opaque: false,
                    barrierColor: Colors.black.withOpacity(0.5),
                    pageBuilder: (context, _, __) => FullScreenGallery(
                      images: images,
                      initialIndex: _currentImageIndex,
                    ),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return child;
                    },
                  ),
                );
              },
            ),
          ),
        ),

        // Top bar (back + favorite)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: BackdropFilter(
                        filter: ColorFilter.mode(
                          Colors.white.withOpacity(0.1),
                          BlendMode.overlay,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Get.back(),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: BackdropFilter(
                        filter: ColorFilter.mode(
                          Colors.white.withOpacity(0.1),
                          BlendMode.overlay,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: _isFavorite ? Colors.red : Colors.white,
                          ),
                          onPressed: () {
                            setState(() => _isFavorite = !_isFavorite);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                setState(() => _showFullDescription = !_showFullDescription);
              },
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
                _showFullDescription ? 'show_less'.tr : 'show_more'.tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.32,
                ),
              ),
            ),
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
                        _getIconForService(service.title),
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
            }).toList(),
          ),
          if (allServices.length > 6) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _showAllAmenities = !_showAllAmenities);
                },
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
                  _showAllAmenities ? 'show_less'.tr : 'show_all'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.32,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== Location Section ====================
  Widget _buildLocationSection() {
    final location = _property?.location;
    final lat = double.tryParse(location?.latitude ?? '');
    final lng = double.tryParse(location?.longitude ?? '');

    if (lat == null || lng == null) {
      // Show only address if no coordinates
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'location_on_object'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.6,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _property?.displayLocation ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      letterSpacing: -0.32,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final point = latlong.LatLng(lat, lng);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'location_on_object'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.6,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 270,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: point,
                      initialZoom: 15,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://core-renderer-tiles.maps.yandex.net/tiles?l=map&x={x}&y={y}&z={z}&scale=1&lang=ru_RU',
                        userAgentPackageName: 'uz.weel.weelbooking',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: point,
                            width: 80,
                            height: 80,
                            child: Icon(
                              Icons.location_on,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location?.fullAddress != null && location!.fullAddress!.isNotEmpty
                      ? location!.fullAddress!
                      : _property?.displayLocation ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    letterSpacing: -0.32,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
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
            _buildConditionItem(
              'age_restrictions'.tr,
              'age_restriction_text'.tr,
            ),
            Divider(
              height: 1,
              thickness: 0.5,
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
            _buildConditionItem(
              'check_in_check_out_time'.tr,
              '${'check_in_from'.trParams({'time': _formatTime(_property?.checkInTime) ?? '19:00'})}, '
              '${'check_out_until'.trParams({'time': _formatTime(_property?.checkOutTime) ?? '17:00'})}',
            ),
            Divider(
              height: 1,
              thickness: 0.5,
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
            _buildConditionItem(
              'quiet_hours'.tr,
              _property?.isQuietHours == true
                  ? 'quiet_hours_range'.tr
                  : 'not_allowed'.tr,
            ),
            Divider(
              height: 1,
              thickness: 0.5,
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
            _buildConditionItem(
              'alcohol'.tr,
              _property?.isAllowedAlcohol == true
                  ? 'allowed'.tr
                  : 'not_allowed'.tr,
            ),
            Divider(
              height: 1,
              thickness: 0.5,
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
            _buildConditionItem(
              'corporate_parties'.tr,
              _property?.isAllowedCorporate == true
                  ? 'allowed'.tr
                  : 'not_allowed'.tr,
            ),
            Divider(
              height: 1,
              thickness: 0.5,
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
            _buildConditionItem(
              'pets'.tr,
              _property?.isAllowedPets == true
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
      child: _buildConditionItem(
        'cancellation_rules'.tr,
        'view_cancellation_rules'.tr,
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

  // ==================== Bottom Bar ====================
  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black.withOpacity(0.05)
                  : Colors.black.withOpacity(0.3),
              blurRadius: 42,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _property?.price != null
                            ? 'price_per_night'.trParams({
                                'price': NumberFormat(
                                  '#,###',
                                  Localizations.localeOf(context).toString(),
                                ).format(_property!.price!.toInt()).replaceAll(',', ' '),
                              })
                            : 'price_not_specified'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.32,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'check_available_dates'.tr +
                            ' ${DateFormat('d MMM', Localizations.localeOf(context).toString()).format(DateTime.now().add(const Duration(days: 1)))} - '
                            '${DateFormat('d MMM', Localizations.localeOf(context).toString()).format(DateTime.now().add(const Duration(days: 7)))}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          letterSpacing: -0.32,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_property == null) return;
                    Get.toNamed(
                      AppRoutes.bookingCalendar,
                      arguments: {'property': _property},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 23.5, vertical: 17),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: const BorderSide(color: Color(0xFF9AFFC9), width: 1),
                    ),
                  ),
                  child: Text(
                    'book_now'.tr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: -0.32,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== Helper Methods ====================
  IconData _getIconForService(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('парковк') || lowerTitle.contains('avtoturargoh') || lowerTitle.contains('parking')) return Icons.local_parking;
    if (lowerTitle.contains('бассейн') || lowerTitle.contains('basseyn') || lowerTitle.contains('pool')) return Icons.pool;
    if (lowerTitle.contains('мангал') || lowerTitle.contains('mangal') || lowerTitle.contains('grill')) return Icons.local_fire_department;
    if (lowerTitle.contains('кондиционер') || lowerTitle.contains('konditsioner') || lowerTitle.contains('ac')) return Icons.ac_unit;
    if (lowerTitle.contains('саун') || lowerTitle.contains('бан') || lowerTitle.contains('sauna')) return Icons.hot_tub;
    if (lowerTitle.contains('wifi') || lowerTitle.contains('wi-fi') || lowerTitle.contains('интернет')) return Icons.wifi;
    if (lowerTitle.contains('кухн') || lowerTitle.contains('oshxona') || lowerTitle.contains('kitchen')) return Icons.kitchen;
    if (lowerTitle.contains('телевизор') || lowerTitle.contains('tv')) return Icons.tv;
    if (lowerTitle.contains('nonushta') || lowerTitle.contains('breakfast')) return Icons.free_breakfast;
    return Icons.check_circle_outline;
  }

  Widget _buildConditionItem(
    String title,
    String value, {
    bool isLink = false,
    VoidCallback? onTap,
  }) {
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

