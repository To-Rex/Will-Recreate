import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../data/models/property_model.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../app.dart';

// Controller
class FavoritesController extends GetxController {
  final _isLoading = true.obs;
  final _hasError = false.obs;
  final favorites = <Property>[].obs;
  final _repository = FavoritesRepository();

  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    _isLoading.value = true;
    _hasError.value = false;
    try {
      favorites.value = await _repository.getFavorites();
    } catch (e) {
      _hasError.value = true;
    }
    _isLoading.value = false;
  }

  /// Sevimliga qo'shish yoki o'chirish (toggle)
  Future<void> toggleFavorite(Property property) async {
    final isFav = isFavorite(property.guid);
    if (isFav) {
      await _repository.removeFavorite(property.guid);
      favorites.removeWhere((p) => p.guid == property.guid);
    } else {
      await _repository.saveFavorite(property);
      favorites.add(property);
    }
  }

  /// Sevimlidan o'chirish
  Future<void> removeFavorite(String guid) async {
    await _repository.removeFavorite(guid);
    favorites.removeWhere((p) => p.guid == guid);
  }

  /// Sevimlilarda ekanligini tekshirish
  bool isFavorite(String guid) {
    return favorites.any((p) => p.guid == guid);
  }
}

// Binding
class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FavoritesController>()) {
      Get.put<FavoritesController>(FavoritesController(), permanent: true);
    }
  }
}

// Screen
class FavoritesScreen extends GetView<FavoritesController> {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: Theme.of(context).colorScheme.onSurface,
            size: 28.sp,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'favorites_title'.tr,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return _buildLoadingState(context);
        } else if (controller.hasError) {
          return _buildErrorState(context);
        } else if (controller.favorites.isEmpty) {
          return _buildEmptyState(context);
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          itemCount: controller.favorites.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildFavoriteItem(context, controller.favorites[index]),
            );
          },
        );
      }),
    );
  }

  // Empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.r,
              height: 120.r,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.light
                    ? const Color(0xFFF5F5F5)
                    : Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_outline,
                size: 60.r,
                color: const Color(0xFFCCCCCC),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'favorites_empty_title'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'favorites_empty_subtext'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF999999),
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.toNamed(AppRoutes.home),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'favorites_start_search'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Favorite item card
  Widget _buildFavoriteItem(BuildContext context, Property property) {
    final imageUrl = property.images.isNotEmpty
        ? property.images.first.imageUrl
        : 'https://via.placeholder.com/400x250?text=No+Image';

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.listingDetail,
          arguments: {'property': property},
        );
      },
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 56.r,
                height: 56.r,
                fit: BoxFit.cover,
                placeholder: (context, url) => AnimatedShimmerBox(
                  width: 56.r,
                  height: 56.r,
                  borderRadius: 12.r,
                ),
                errorWidget: (context, url, error) => Container(
                  width: 56.r,
                  height: 56.r,
                  color: Colors.grey.shade200,
                  child: Center(
                    child: Icon(
                      Icons.image,
                      size: 24.r,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.location.city,
                    style: TextStyle(
                      color: const Color(0xFF999999),
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    property.title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: const Color(0xFF999999),
              size: 20.r,
            ),
          ],
        ),
      ),
    );
  }

  // Loading shimmer state
  Widget _buildLoadingState(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                AnimatedShimmerBox(
                  width: 56.r,
                  height: 56.r,
                  borderRadius: 12.r,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedShimmerBox(
                        width: 60.w,
                        height: 12.h,
                        borderRadius: 4.r,
                      ),
                      SizedBox(height: 8.h),
                      AnimatedShimmerBox(
                        width: 150.w,
                        height: 16.h,
                        borderRadius: 4.r,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Error state
  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56.w,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
            ),
            SizedBox(height: 20.h),
            Text(
              'server_error'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: 180.w,
              height: 44.h,
              child: ElevatedButton(
                onPressed: () => controller.loadFavorites(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'retry'.tr,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
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
