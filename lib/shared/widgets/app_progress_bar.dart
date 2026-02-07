import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/constants.dart';
import '../../config/theme.dart';

/// Progress bar widget
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.color,
    this.backgroundColor,
    this.showPercentage = false,
    this.label,
  });

  final double progress;
  final double height;
  final Color? color;
  final Color? backgroundColor;
  final bool showPercentage;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || showPercentage)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                if (showPercentage)
                  Text(
                    '${(clampedProgress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: color ?? AppTheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular((height / 2).r),
          child: Container(
            height: height.h,
            decoration: BoxDecoration(
              color: backgroundColor ??
                  theme.dividerTheme.color?.withOpacity(0.3) ??
                  AppTheme.lightBorder.withOpacity(0.3),
              borderRadius: BorderRadius.circular((height / 2).r),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  width: (MediaQuery.of(context).size.width -
                          (AppConstants.defaultPadding * 2)) *
                      clampedProgress,
                  height: height.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color ?? AppTheme.primary,
                        (color ?? AppTheme.primary).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular((height / 2).r),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
