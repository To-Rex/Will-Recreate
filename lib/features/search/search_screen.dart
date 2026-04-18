import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../app.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/property_model.dart';
import '../../data/repositories/property_repository.dart';
import '../../data/mock/mock_data.dart' show MockData;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedWhen;
  int _adults = 2;
  int _children = 0;
  bool _pets = false;
  late AnimationController _animationController;
  Timer? _typingTimer;
  Timer? _debounce;
  final _searchQuery = ''.obs;
  final _isSearching = false.obs;
  final _searchResults = <Property>[].obs;
  final _propertyRepository = PropertyRepository();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _typingTimer?.cancel();
    _debounce?.cancel();
    super.dispose();
  }

  bool get _isDateSelected {
    return _selectedWhen != null &&
        _selectedWhen != 'search_week'.tr &&
        _selectedWhen != 'search_not_selected'.tr;
  }

  /// API orqali qidirish
  Future<void> _performSearch(String query) async {
    final result = await _propertyRepository.getProperties(search: query);
    result.when(
      success: (properties) {
        _searchResults.value = properties;
        _isSearching.value = false;
      },
      failure: (_) {
        _searchResults.clear();
        _isSearching.value = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withAlpha(77)
                    : Colors.black.withAlpha(13),
                blurRadius: 42,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            onPressed: () => Get.back(),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildWhereSection(context, isDark),
              const SizedBox(height: 20),
              _buildWhenSection(context, isDark),
              const SizedBox(height: 20),
              _buildWhoSection(context, isDark),
              const SizedBox(height: 50),
              _buildActionButtons(context, isDark),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ─── WHERE section ──────────────────────────────────────────────────────────
  Widget _buildWhereSection(BuildContext context, bool isDark) {
    final hasSearchInput = _searchController.text.isNotEmpty;

    return Container(
      height: (hasSearchInput) ? 550.0 : null,
      constraints: BoxConstraints(
        minHeight: (hasSearchInput) ? 550.0 : 0.0,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(51)
                : Colors.black.withAlpha(13),
            blurRadius: 42,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'search_where'.tr,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withAlpha(13) : Colors.transparent,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : const Color(0xFFE6E6E6),
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'search_directions_hint'.tr,
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : const Color(0xFF999999),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.grey,
                  size: 18,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _searchQuery.value = '';
                          _isSearching.value = false;
                          _searchResults.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
              onChanged: (value) {
                setState(() {});

                _debounce?.cancel();
                if (value.length > 2) {
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    _searchQuery.value = value;
                    _isSearching.value = true;
                    _performSearch(value);
                  });
                }

                // Animation timer
                _typingTimer?.cancel();

                if (value.isNotEmpty) {
                  if (!_animationController.isAnimating) {
                    _animationController.repeat();
                  }
                  _isSearching.value = value.length <= 2;

                  _typingTimer = Timer(const Duration(seconds: 2), () {
                    if (mounted) {
                      _animationController.stop();
                      _animationController.reset();
                    }
                  });
                } else {
                  _animationController.stop();
                  _animationController.reset();
                  _isSearching.value = false;
                  _searchQuery.value = '';
                }
              },
            ),
          ),
          if (_searchController.text.isEmpty) ...[
            const SizedBox(height: 24),
            _buildCreativeDestinationsSection(context, isDark),
          ] else if (_searchController.text.length > 2) ...[
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                if (_isSearching.value) {
                  return Center(child: _buildSearchingAnimation(context));
                }

                if (_searchResults.isEmpty) {
                  return Center(child: _buildNoResultsSection(context, isDark));
                }
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    return _buildHorizontalPropertyCard(
                      context,
                      isDark,
                      _searchResults[index],
                    );
                  },
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Horizontal Property Card (inside Where section) ────────────────────────
  Widget _buildHorizontalPropertyCard(
    BuildContext context,
    bool isDark,
    property,
  ) {
    final imageUrl = property.images.isNotEmpty
        ? property.images.first.imageUrl
        : 'https://via.placeholder.com/400x250?text=No+Image';

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.listingDetail,
        arguments: {'property': property},
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withAlpha(77)
                  : Colors.black.withAlpha(13),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey.shade100),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.location.city,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : const Color(0xFF999999),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF999999),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Creative Destinations Section (inside Where section) ───────────────────
  Widget _buildCreativeDestinationsSection(BuildContext context, bool isDark) {
    final destinations = MockData.popularDirections;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'popular_directions'.tr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color:
                    Theme.of(context).colorScheme.onSurface.withAlpha(204),
                letterSpacing: -0.4,
              ),
            ),
            Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: destinations.length,
            itemBuilder: (context, index) {
              final dest = destinations[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    _searchController.text = dest['title'] as String;
                    setState(() {});
                    _searchQuery.value = dest['title'] as String;
                    _isSearching.value = true;
                    _performSearch(dest['title'] as String);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          image: DecorationImage(
                            image: AssetImage(dest['image'] as String),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(26),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withAlpha(153),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              left: 12,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (dest['title'] as String).tr,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  Text(
                                    (dest['desc'] as String).tr,
                                    style: TextStyle(
                                      color: Colors.white.withAlpha(204),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Searching Animation ────────────────────────────────────────────────────
  Widget _buildSearchingAnimation(BuildContext context) {
    return Column(
      children: [
        _AnimatedTypingDots(animationController: _animationController),
        const SizedBox(height: 24),
        Text(
          'search_placeholder'.tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  // ─── No Results Section ─────────────────────────────────────────────────────
  Widget _buildNoResultsSection(BuildContext context, bool isDark) {
    return Column(
      children: [
        Text(
          'search_no_results'.tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'search_try_again'.tr,
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextSecondary
                : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ─── WHEN section ───────────────────────────────────────────────────────────
  Widget _buildWhenSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(51)
                : Colors.black.withAlpha(13),
            blurRadius: 42,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'search_when'.tr,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : const Color(0xFF999999),
              letterSpacing: -0.32,
            ),
          ),
          GestureDetector(
            onTap: () async {
              final result = await Get.toNamed(
                AppRoutes.calendar,
                arguments: {
                  'selectedWhen': _selectedWhen,
                  'adults': _adults,
                  'children': _children,
                  'pets': _pets,
                },
              );
              if (result != null && result is String) {
                setState(() => _selectedWhen = result);
              }
            },
            child: Row(
              children: [
                Text(
                  (_selectedWhen == null ||
                          _selectedWhen == 'search_week'.tr ||
                          _selectedWhen == 'search_not_selected'.tr)
                      ? 'search_not_selected'.tr
                      : _selectedWhen!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.32,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade600,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── WHO section ────────────────────────────────────────────────────────────
  Widget _buildWhoSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(51)
                : Colors.black.withAlpha(13),
            blurRadius: 42,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'search_who'.tr,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : const Color(0xFF999999),
              letterSpacing: -0.32,
            ),
          ),
          GestureDetector(
            onTap: () async {
              final result = await Get.toNamed(
                AppRoutes.guests,
                arguments: {
                  'adults': _adults,
                  'children': _children,
                  'pets': _pets,
                },
              );
              if (result != null && result is Map) {
                setState(() {
                  _adults = result['adults'] as int;
                  _children = result['children'] as int;
                  _pets = result['pets'] as bool;
                });
              }
            },
            child: Row(
              children: [
                Text(
                  _getGuestsText(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.32,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade600,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Action Buttons ─────────────────────────────────────────────────────────
  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: _resetAll,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'reset_all'.tr,
            style: TextStyle(
              decoration: TextDecoration.underline,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.32,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isDateSelected
              ? () {
                  Get.offAllNamed(
                    AppRoutes.home,
                    arguments: {
                      'location': _searchController.text,
                      'adults': _adults,
                      'children': _children,
                      'pets': _pets,
                      'selectedWhen': _selectedWhen,
                    },
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary.withAlpha(128),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 17),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(
                color: _isDateSelected
                    ? const Color(0xFF9AFFC9)
                    : const Color(0xFF9AFFC9).withAlpha(128),
                width: 1,
              ),
            ),
            elevation: 0,
          ),
          child: Text(
            'next'.tr,
            style: TextStyle(
              color: _isDateSelected ? Colors.white : Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.32,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────
  void _resetAll() {
    setState(() {
      _searchController.clear();
      _selectedWhen = null;
      _adults = 2;
      _children = 0;
      _pets = false;
    });
    _searchQuery.value = '';
    _isSearching.value = false;
  }

  String _getGuestsText() {
    final total = _adults + _children;
    if (total == 0) return 'add_guests'.tr;
    return '$total ${'guest'.tr}';
  }
}

// ─── Animated Typing Dots ─────────────────────────────────────────────────────
class _AnimatedTypingDots extends StatelessWidget {
  final AnimationController animationController;
  const _AnimatedTypingDots({required this.animationController});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            final delay = index * 0.2;
            final animationValue =
                (animationController.value + delay) % 1.0;
            final opacity = (animationValue < 0.5)
                ? (animationValue * 2)
                : (2 - animationValue * 2);
            final scale = 0.8 + (opacity * 0.2);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8 * scale,
              height: 8 * scale,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: opacity),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
