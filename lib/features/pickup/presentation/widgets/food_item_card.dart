import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/food_item.dart';
import 'food_image_widget.dart';

/// Card widget for displaying food items
class FoodItemCard extends StatelessWidget {
  final FoodItem foodItem;
  final bool isSelected;
  final VoidCallback onTap;
  final int? selectionCount;

  const FoodItemCard({
    super.key,
    required this.foodItem,
    required this.isSelected,
    required this.onTap,
    this.selectionCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 110.w,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : isDark
                  ? Colors.grey[850]
                  : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : isDark
                    ? Colors.grey[700]!
                    : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Selection indicator
            if (isSelected && selectionCount != null)
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$selectionCount',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Food image
            FoodImageWidget(
              imageUrl: foodItem.imageUrl,
              localImagePath: foodItem.localImagePath,
              foodName: foodItem.name,
              width: 70.w,
              height: 70.h,
            ),
            SizedBox(height: 8.h),

            // Food name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                foodItem.name,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Subcategory if available
            if (foodItem.subCategory != null)
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Text(
                  foodItem.subCategory!,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            // Selection indicator dot
            SizedBox(height: 6.h),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 24.w : 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : isDark
                        ? Colors.grey[700]
                        : Colors.grey[300],
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 6.w,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
