import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'urgency_color.dart';

/// Dashboard header widget displaying date, time, and dynamic greeting
class DashboardHeader extends StatelessWidget {
  final String userName;
  final DateTime? testTime;

  const DashboardHeader({
    super.key,
    required this.userName,
    this.testTime,
  });

  @override
  Widget build(BuildContext context) {
    final now = testTime ?? DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d');
    final timeFormat = DateFormat('HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date and time row
        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16.w,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                dateFormat.format(now),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.access_time_outlined,
              size: 16.w,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
            SizedBox(width: 8.w),
            Text(
              timeFormat.format(now),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        // Dynamic greeting
        Text(
          DynamicGreeting.getGreeting(userName, now),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    );
  }
}
