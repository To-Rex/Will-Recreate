import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/extensions/num_extensions.dart';
import '../../data/models/property_model.dart';
import '../../app.dart';
import 'home_controller.dart';
import 'widgets/sort_bottom_sheet.dart';
import 'widgets/app_drawer.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      drawer: const AppDrawer(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildHomeShimmer();
        }
        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverPadding(
                padding: const EdgeInsets.only(top: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildStories(context),
                    const SizedBox(height: 8),
                  ]),
                ),
              ),
              SliverAppBar(
                pinned: true,
                floating: false,
                automaticallyImplyLeading: false,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                titleSpacing: 0,
                title: _buildSearchBar(context),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(72.h),
                  child: Container(
                    padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
                    decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
                    child: _buildCategoryTabs(context),
                  ),
                ),
              ),
            ];
          },
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: controller.refreshData,
            child: Obx(() {
              if (controller.isLoadingProperties.value) {
                return _buildPropertyListShimmer();
              }
              if (controller.properties.isEmpty) {
                return _buildEmptyState(context);
              }
              return ListView.builder(
                itemCount: controller.properties.length,
                itemBuilder: (context, index) {
                  return _ListingItemCard(property: controller.properties[index]);
                },
              );
            }),
          ),
        );
      }),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      title: SvgPicture.asset('assets/logo/weel_booking_logo.svg', height: 32),
      centerTitle: true,
    );
  }

  Widget _buildStories(BuildContext context) {
    return Obx(() {
      final stories = controller.stories;
      if (stories.isEmpty) return const SizedBox.shrink();
      return SizedBox(
        height: 100.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: stories.length,
          itemBuilder: (context, index) {
            final story = stories[index];
            final hasUnwatched = !story.isWatched;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: SizedBox(
                width: 70.r,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(3.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: hasUnwatched ? AppColors.primary : Colors.grey.shade300, width: 2.w),
                      ),
                      child: ClipOval(
                        child: SizedBox(
                          width: 60.r,
                          height: 60.r,
                          child: story.media.isNotEmpty && story.media.first.isImage
                              ? CachedNetworkImage(imageUrl: story.media.first.mediaUrl, fit: BoxFit.cover)
                              : Container(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      story.property.title,
                      style: TextStyle(fontSize: 10.sp, color: Theme.of(context).colorScheme.onSurface, overflow: TextOverflow.ellipsis),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => SortBottomSheet(
                  initialOrder: controller.selectedOrder.value,
                  onSortSelected: controller.setOrder,
                ),
              );
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withAlpha(30) : Colors.black.withAlpha(60),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(Icons.swap_vert, color: Theme.of(context).colorScheme.onSurface, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.search),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.light ? Colors.grey.withAlpha(30) : Colors.black.withAlpha(60),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface, size: 20),
                    const SizedBox(width: 8),
                    Text('start_search'.tr, style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
    return Obx(() {
      final cats = controller.categories;
      final selected = controller.selectedCategoryGuid.value;
      return Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: cats.map((cat) {
              final isSelected = cat.guid == selected;
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: GestureDetector(
                  onTap: () => controller.selectCategory(cat.guid),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(cat.iconUrl, width: 24.r, height: 24.r, colorFilter: ColorFilter.mode(isSelected ? AppColors.primary : Colors.grey, BlendMode.srcIn)),
                      SizedBox(height: 4.h),
                      Text(
                        cat.title,
                        style: TextStyle(
                          color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12.sp,
                        ),
                      ),
                      if (isSelected)
                        Container(margin: EdgeInsets.only(top: 4.h), width: 24.w, height: 2.h, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2.r)))
                      else
                        SizedBox(height: 6.h),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: 60.h),
        Icon(Icons.other_houses_outlined, size: 80.r, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.15)),
        SizedBox(height: 16.h),
        Text('search_no_results'.tr, textAlign: TextAlign.center, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
        SizedBox(height: 8.h),
        Text('search_try_again'.tr, textAlign: TextAlign.center, style: TextStyle(fontSize: 13.sp, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
      ],
    );
  }

  Widget _buildStoriesShimmer() {
    return SizedBox(
      height: 100.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: SizedBox(
              width: 70.r,
              child: Column(
                children: [
                  AnimatedShimmerBox(
                    width: 66.r,
                    height: 66.r,
                    borderRadius: 33.r,
                  ),
                  SizedBox(height: 4.h),
                  AnimatedShimmerBox(
                    width: 40.w,
                    height: 10.h,
                    borderRadius: 4.r,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomeShimmer() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            _buildStoriesShimmer(),
            const SizedBox(height: 8),
            _buildSearchBarShimmer(),
            _buildCategoryTabsShimmer(),
            const SizedBox(height: 8),
            ...List.generate(3, (_) => _buildShimmerItem()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBarShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          AnimatedShimmerBox(
            width: 48,
            height: 48,
            borderRadius: 24.r,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedShimmerBox(
              height: 48,
              borderRadius: 30.r,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabsShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: List.generate(5, (index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedShimmerBox(
                    width: 24.r,
                    height: 24.r,
                    borderRadius: 4.r,
                  ),
                  SizedBox(height: 4.h),
                  AnimatedShimmerBox(
                    width: 30.w,
                    height: 10.h,
                    borderRadius: 4.r,
                  ),
                  SizedBox(height: 4.h),
                  AnimatedShimmerBox(
                    width: 24.w,
                    height: 2.h,
                    borderRadius: 2.r,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AnimatedShimmerBox(height: 250, borderRadius: 20),
          const SizedBox(height: 12),
          AnimatedShimmerBox(width: 200.w, height: 18, borderRadius: 4),
          const SizedBox(height: 8),
          AnimatedShimmerBox(width: 150.w, height: 14, borderRadius: 4),
        ],
      ),
    );
  }

  Widget _buildPropertyListShimmer() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) => _buildShimmerItem(),
    );
  }
}

class _ListingItemCard extends StatefulWidget {
  final Property property;
  const _ListingItemCard({required this.property});

  @override
  State<_ListingItemCard> createState() => _ListingItemCardState();
}

class _ListingItemCardState extends State<_ListingItemCard> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final imageUrls = property.images.map((e) => e.imageUrl).toList();
    if (imageUrls.isEmpty) imageUrls.add('https://via.placeholder.com/400x250?text=No+Image');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.listingDetail, arguments: {'property': property}),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(imageUrls),
            const SizedBox(height: 12),
            _buildInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel(List<String> imageUrls) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 250,
            child: PageView.builder(
              onPageChanged: (v) => setState(() => _currentPage = v),
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: imageUrls[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const AnimatedShimmerBox(height: 250, borderRadius: 20),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                  ),
                );
              },
            ),
          ),
        ),
        if (imageUrls.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                imageUrls.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: _currentPage == index ? 8 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.white : Colors.white.withAlpha(128),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.black.withAlpha(128), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 14),
                const SizedBox(width: 2),
                Text('${widget.property.averageRating}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfo(BuildContext context) {
    final property = widget.property;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(property.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
              const SizedBox(width: 4),
              Expanded(child: Text(property.displayLocation, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 4),
          if (property.price != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  property.price!.formatPrice,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
                Text('${property.commentCount} ${'comments_label'.tr}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
              ],
            ),
        ],
      ),
    );
  }
}
