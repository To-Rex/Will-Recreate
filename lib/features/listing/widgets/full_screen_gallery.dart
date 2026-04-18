import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

class FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenGallery({super.key, required this.images, required this.initialIndex});

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late ScrollController _thumbnailScrollController;
  late int _currentIndex;
  bool _showThumbnails = true;

  late AnimationController _dismissAnimationController;
  double _dragOffset = 0;
  double _dragOpacity = 1.0;
  bool _isDragging = false;
  bool _isDismissing = false;

  final TransformationController _transformationController =
      TransformationController();
  bool _canSwipe = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _thumbnailScrollController = ScrollController();

    _dismissAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToThumbnail(_currentIndex);
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _pageController.dispose();
    _thumbnailScrollController.dispose();
    _dismissAnimationController.dispose();
    super.dispose();
  }

  void _scrollToThumbnail(int index) {
    if (!_thumbnailScrollController.hasClients) return;

    const thumbnailWidth = 70.0;
    const thumbnailSpacing = 8.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final targetOffset =
        (index * (thumbnailWidth + thumbnailSpacing)) - (screenWidth / 2) + (thumbnailWidth / 2);

    _thumbnailScrollController.animateTo(
      targetOffset.clamp(0.0, _thumbnailScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
      setState(() => _canSwipe = true);
    } else {
      const double scale = 2.5;
      final Matrix4 zoomed = Matrix4.identity()..scale(scale);
      _transformationController.value = zoomed;
      setState(() => _canSwipe = false);
    }
  }

  void _goToPage(int index) {
    _transformationController.value = Matrix4.identity();
    setState(() => _canSwipe = true);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _toggleThumbnails() {
    setState(() => _showThumbnails = !_showThumbnails);
  }

  void _onVerticalDragStart(DragStartDetails details) {
    if (_isDismissing || !_canSwipe) return;
    setState(() => _isDragging = true);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_isDismissing || !_canSwipe) return;
    if (_dragOffset + details.delta.dy < 0) return;
    setState(() {
      _dragOffset += details.delta.dy;
      final screenHeight = MediaQuery.of(context).size.height;
      final progress = (_dragOffset / screenHeight).clamp(0.0, 1.0);
      _dragOpacity = (1.0 - (progress * 0.8)).clamp(0.0, 1.0);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_isDismissing || !_canSwipe) return;
    final velocity = details.primaryVelocity ?? 0;
    final screenHeight = MediaQuery.of(context).size.height;

    if (_dragOffset > screenHeight * 0.2 || velocity > 500) {
      _dismissWithAnimation();
    } else {
      _resetDragState();
    }
  }

  void _dismissWithAnimation() {
    setState(() => _isDismissing = true);

    final screenHeight = MediaQuery.of(context).size.height;
    final startOffset = _dragOffset;
    final startOpacity = _dragOpacity;
    final targetOffset = screenHeight;
    const targetOpacity = 0.0;

    _dismissAnimationController.reset();

    final animation = CurvedAnimation(
      parent: _dismissAnimationController,
      curve: Curves.easeOut,
    );

    animation.addListener(() {
      if (mounted) {
        setState(() {
          final progress = animation.value;
          _dragOffset = startOffset + (targetOffset - startOffset) * progress;
          _dragOpacity = (startOpacity + (targetOpacity - startOpacity) * progress).clamp(0.0, 1.0);
        });
      }
    });

    _dismissAnimationController.forward().then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _resetDragState() {
    _dismissAnimationController.reset();

    final startOffset = _dragOffset;
    final startOpacity = _dragOpacity;

    final animation = CurvedAnimation(
      parent: _dismissAnimationController,
      curve: Curves.easeOutBack,
    );

    animation.addListener(() {
      if (mounted) {
        setState(() {
          final progress = animation.value;
          _dragOffset = startOffset * (1 - progress);
          _dragOpacity = (startOpacity + (1.0 - startOpacity) * progress).clamp(0.0, 1.0);
        });
      }
    });

    _dismissAnimationController.forward().then((_) {
      if (mounted) {
        setState(() {
          _isDragging = false;
          _dragOffset = 0;
          _dragOpacity = 1.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget galleryContent = Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: _isDragging || _isDismissing ? BorderRadius.circular(24) : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Main image pager
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            physics: _canSwipe
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              _scrollToThumbnail(index);
              _transformationController.value = Matrix4.identity();
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onDoubleTap: _handleDoubleTap,
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 1.0,
                  maxScale: 5.0,
                  onInteractionUpdate: (details) {
                    final isZoomed =
                        _transformationController.value.getMaxScaleOnAxis() > 1.0;
                    if (isZoomed != !_canSwipe) {
                      setState(() => _canSwipe = !isZoomed);
                    }
                  },
                  onInteractionEnd: (details) {
                    if (_transformationController.value.getMaxScaleOnAxis() <= 1.0) {
                      setState(() => _canSwipe = true);
                    }
                  },
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: widget.images[index],
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Container(
                        color: Colors.black,
                        child: Center(
                          child: Container(
                            width: 50,
                            height: 50,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade900,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image_outlined, size: 60, color: Colors.grey.shade600),
                            const SizedBox(height: 16),
                            Text('gallery_fail_load'.tr, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Top gradient
          Positioned(
            top: 0, left: 0, right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: (_isDragging || _isDismissing) ? 0.0 : (_showThumbnails ? 1.0 : 0.0),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),

          // Top bar (close + counter)
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              bottom: false,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: (_isDragging || _isDismissing) ? 0.0 : (_showThumbnails ? 1.0 : 0.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(50),
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(Icons.close_rounded, color: Colors.white, size: 24),
                            ),
                          ),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          key: ValueKey<int>(_currentIndex),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${_currentIndex + 1}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(' / ${widget.images.length}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom gradient
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: (_isDragging || _isDismissing) ? 0.0 : (_showThumbnails ? 1.0 : 0.0),
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),

          // Bottom thumbnails
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: SafeArea(
              top: false,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                offset: Offset(0, (_isDragging || !_showThumbnails || _isDismissing) ? 1.5 : 0),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: (_isDragging || !_showThumbnails || _isDismissing) ? 0.0 : 1.0,
                  child: Column(
                    children: [
                      if (widget.images.length <= 10)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              widget.images.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: _currentIndex == index ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _currentIndex == index ? Colors.white : Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 70,
                        child: ListView.builder(
                          controller: _thumbnailScrollController,
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: widget.images.length,
                          itemBuilder: (context, index) {
                            final isSelected = _currentIndex == index;
                            return GestureDetector(
                              onTap: () => _goToPage(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 8),
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: 2,
                                  ),
                                  boxShadow: isSelected
                                      ? [BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 8)]
                                      : null,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 200),
                                    opacity: isSelected ? 1.0 : 0.5,
                                    child: CachedNetworkImage(
                                      imageUrl: widget.images[index],
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey.shade800,
                                        child: const Center(
                                          child: SizedBox(
                                            width: 20, height: 20,
                                            child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.grey.shade800,
                                        child: Icon(Icons.broken_image, color: Colors.grey.shade600, size: 24),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Zoom hint
          Positioned(
            bottom: 160, left: 0, right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: !_canSwipe ? 1.0 : 0.0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.zoom_in, color: Colors.white.withOpacity(0.8), size: 18),
                      const SizedBox(width: 8),
                      Text('gallery_double_tap_to_reset'.tr, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      onTap: _isDismissing ? null : _toggleThumbnails,
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(_dragOpacity.clamp(0.0, 1.0)),
        body: Transform.translate(
          offset: Offset(0, _dragOffset),
          child: galleryContent,
        ),
      ),
    );
  }
}
