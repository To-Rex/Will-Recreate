import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/property_model.dart';
import '../../favorites/favorites_controller.dart';
import 'full_screen_gallery.dart';

class ListingImageCarousel extends StatefulWidget {
  final Property property;
  final FavoritesController favoritesController;

  const ListingImageCarousel({
    super.key,
    required this.property,
    required this.favoritesController,
  });

  @override
  State<ListingImageCarousel> createState() => _ListingImageCarouselState();
}

class _ListingImageCarouselState extends State<ListingImageCarousel> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.property.images.map((e) => e.imageUrl).toList();

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
                      size: 60,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Top gradient
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 200,
          child: IgnorePointer(
            child: _GradientOverlay(
              colors: [Color(0x99000000), Colors.transparent],
              stops: [0.29, 0.76],
            ),
          ),
        ),

        // Bottom gradient
        const Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 200,
          child: IgnorePointer(
            child: _GradientOverlay(
              colors: [Colors.transparent, Color(0x99000000)],
              stops: [0.29, 0.76],
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
                  _GlassCircleButton(
                    icon: Icons.arrow_back,
                    onPressed: () => Get.back(),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _GlassCircleButton(
                      icon: Icons.favorite,
                      child: Obx(() {
                        final isFav = widget.favoritesController
                            .isFavorite(widget.property.guid);
                        return Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.white,
                        );
                      }),
                      onPressed: () {
                        widget.favoritesController.toggleFavorite(widget.property);
                      },
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
}

/// Glassmorphism circle button — DRY prinsipi uchun ajratildi
class _GlassCircleButton extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final VoidCallback onPressed;

  const _GlassCircleButton({
    this.icon,
    this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            icon: child ?? Icon(icon, color: Colors.white),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}

/// Gradient overlay — DRY prinsipi uchun ajratildi
class _GradientOverlay extends StatelessWidget {
  final List<Color> colors;
  final List<double> stops;

  const _GradientOverlay({required this.colors, required this.stops});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: stops,
        ),
      ),
    );
  }
}
