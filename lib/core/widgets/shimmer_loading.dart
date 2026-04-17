import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AnimatedShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AnimatedShimmerBox({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A35) : const Color(0xFFE0E0E0),
      highlightColor: isDark ? const Color(0xFF3A3A45) : const Color(0xFFF5F5F5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
