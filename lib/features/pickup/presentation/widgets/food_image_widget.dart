import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// Widget to display food images with fallback
class FoodImageWidget extends StatelessWidget {
  final String? imageUrl;
  final String? localImagePath;
  final String foodName;
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const FoodImageWidget({
    super.key,
    this.imageUrl,
    this.localImagePath,
    required this.foodName,
    this.width = 80,
    this.height = 80,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final defaultBorderRadius = BorderRadius.circular(12);

    // Try local image first, then network
    if (localImagePath != null) {
      return _buildLocalImage(defaultBorderRadius, isDark);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      return _buildNetworkImage(defaultBorderRadius, isDark);
    } else {
      return _buildPlaceholder(defaultBorderRadius, isDark);
    }
  }

  Widget _buildLocalImage(BorderRadius borderRadius, bool isDark) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.asset(
        localImagePath!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(borderRadius, isDark);
        },
      ),
    );
  }

  Widget _buildNetworkImage(BorderRadius borderRadius, bool isDark) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildShimmer(borderRadius, isDark),
        errorWidget: (context, url, error) => _buildPlaceholder(borderRadius, isDark),
      ),
    );
  }

  Widget _buildShimmer(BorderRadius borderRadius, bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[300],
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BorderRadius borderRadius, bool isDark) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.grey[800]!, Colors.grey[700]!]
              : [Colors.grey[300]!, Colors.grey[200]!],
        ),
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 32,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                foodName,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
