import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock/mock_data.dart' show MockData;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedWhen;
  int _adults = 2;
  int _children = 0;
  bool _pets = false;
  late AnimationController _animationController;
  Timer? _debounce;
  final _searchQuery = ''.obs;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  bool get _isDateSelected {
    return _selectedWhen != null &&
        _selectedWhen != 'search_week'.tr &&
        _selectedWhen != 'search_not_selected'.tr;
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
                color: isDark ? Colors.black.withAlpha(77) : Colors.black.withAlpha(13),
                blurRadius: 42,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface, size: 20),
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
              const SizedBox(height: 30),
              _buildActionButtons(context, isDark),
              const SizedBox(height: 30),
              // Show results, typing animation, or popular destinations
              Obx(() {
                if (_searchQuery.value.isNotEmpty) {
                  if (_searchQuery.value.length < 2) {
                    return _buildSearchingAnimation(context);
                  }
                  return _buildSearchResults(context, isDark);
                }
                return _buildPopularDestinations(context, isDark);
              }),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ─── WHERE section ──────────────────────────────────────────────────────────
  Widget _buildWhereSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withAlpha(51) : Colors.black.withAlpha(13),
            blurRadius: 42,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: isDark ? AppColors.darkTextSecondary : const Color(0xFF999999)),
          hintText: 'search_where'.tr,
          hintStyle: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : const Color(0xFF999999)),
          border: InputBorder.none,
        ),
        onChanged: (val) {
          _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 300), () {
            _searchQuery.value = val;
          });
        },
      ),
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
            color: isDark ? Colors.black.withAlpha(51) : Colors.black.withAlpha(13),
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
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF999999),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final result = await Get.toNamed(
                AppRoutes.calendar,
                arguments: {'selectedWhen': _selectedWhen, 'adults': _adults, 'children': _children, 'pets': _pets},
              );
              if (result != null && result is String) {
                setState(() => _selectedWhen = result);
              }
            },
            child: Row(
              children: [
                Text(
                  (_selectedWhen == null || _selectedWhen == 'search_week'.tr || _selectedWhen == 'search_not_selected'.tr)
                      ? 'search_not_selected'.tr
                      : _selectedWhen!,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey.shade600, size: 18),
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
            color: isDark ? Colors.black.withAlpha(51) : Colors.black.withAlpha(13),
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
            style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : const Color(0xFF999999)),
          ),
          GestureDetector(
            onTap: () async {
              final result = await Get.toNamed(
                AppRoutes.guests,
                arguments: {'adults': _adults, 'children': _children, 'pets': _pets},
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
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey.shade600, size: 18),
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
                color: _isDateSelected ? const Color(0xFF9AFFC9) : const Color(0xFF9AFFC9).withAlpha(128),
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
            ),
          ),
        ),
      ],
    );
  }

  // ─── Popular Destinations ───────────────────────────────────────────────────
  Widget _buildPopularDestinations(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'popular_directions'.tr,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: MockData.popularDirections.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final dest = MockData.popularDirections[index];
              return SizedBox(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        image: DecorationImage(image: AssetImage(dest['image']!), fit: BoxFit.cover),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 10, offset: const Offset(0, 4)),
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
                                colors: [Colors.transparent, Colors.black.withAlpha(153)],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(dest['title']!.tr, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                Text(dest['desc']!.tr, style: TextStyle(color: Colors.white.withAlpha(204), fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
        ),
      ],
    );
  }

  // ─── Search Results ─────────────────────────────────────────────────────────
  Widget _buildSearchResults(BuildContext context, bool isDark) {
    // Mock: filter properties by query
    final query = _searchQuery.value.toLowerCase();
    final results = MockData.properties.where((p) {
      return p.title.toLowerCase().contains(query) || p.location.city.toLowerCase().contains(query);
    }).toList();

    if (results.isEmpty) {
      return Column(
        children: [
          Text('search_no_results'.tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 8),
          Text('search_try_again'.tr, style: TextStyle(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade600)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${'search_results'.tr} (${results.length})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 16),
        ...results.map((property) => _buildPropertyCard(context, isDark, property)),
      ],
    );
  }

  Widget _buildPropertyCard(BuildContext context, bool isDark, property) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: isDark ? Colors.black.withAlpha(51) : Colors.black.withAlpha(13), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => Get.toNamed(AppRoutes.listingDetail, arguments: {'property': property}),
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  image: DecorationImage(image: AssetImage(property.images.first.url), fit: BoxFit.cover),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          '${property.price!.toInt().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ' ')} so\'m/tun',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(property.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text('${property.location.city}, ${property.location.address}', style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: AppColors.yellow),
                        const SizedBox(width: 4),
                        Text(property.averageRating.toStringAsFixed(1), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 8),
                        Text('(${property.commentCount})', style: TextStyle(fontSize: 13, color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
            final animationValue = (animationController.value + delay) % 1.0;
            final opacity = (animationValue < 0.5) ? (animationValue * 2) : (2 - animationValue * 2);
            final scale = 0.8 + (opacity * 0.2);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8 * scale,
              height: 8 * scale,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha((opacity * 255).round()),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}
