import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/theme.dart';
import '../../domain/entities/food_item.dart';

/// 3-column grid of category tiles for food selection
class HorizontalCategoryTabs extends StatelessWidget {
  final MainCategory selectedCategory;
  final Function(MainCategory) onCategorySelected;

  const HorizontalCategoryTabs({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 1.1,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: MainCategory.values.map((category) {
          final isSelected = category == selectedCategory;
          return _CategoryTile(
            category: category,
            isSelected: isSelected,
            isDark: isDark,
            onTap: () => onCategorySelected(category),
          );
        }).toList(),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final MainCategory category;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                )
              : null,
          color: isSelected ? null : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryDark
                : isDark
                    ? AppTheme.darkBorder
                    : AppTheme.lightBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container with gradient background
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                gradient:
                    isSelected ? null : AppTheme.iconBackgroundGradient(isDark),
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : null,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(
                  category.icon,
                  style: TextStyle(fontSize: 22.sp),
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              category.displayName,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
