import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme.dart';
import '../../../../shared/services/mock_data_service.dart';
import '../../../../shared/widgets/animations.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/error_widgets.dart' as err;
import '../bloc/canteen_bloc.dart';

class CanteenDashboardPage extends StatelessWidget {
  const CanteenDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CanteenBloc()..add(const CanteenDashboardLoaded()),
      child: const _CanteenDashboardView(),
    );
  }
}

class _CanteenDashboardView extends StatelessWidget {
  const _CanteenDashboardView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitConfirmation(context);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkBackgroundGradient
              : AppTheme.lightBackgroundGradient,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {},
            ),
            title: const Text('Mensa Viadrina'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ],
          ),
          body: BlocBuilder<CanteenBloc, CanteenState>(
            builder: (context, state) {
              if (state is CanteenLoading || state is CanteenInitial) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is CanteenError) {
                return err.ErrorWidget(
                  message: 'Dashboard Unavailable',
                  subtitle: state.message,
                  onRetry: () => context
                      .read<CanteenBloc>()
                      .add(const CanteenDashboardLoaded()),
                );
              }

              if (state is CanteenLoadSuccess) {
                return _CanteenDashboardContent(
                  dashboard: state.dashboard,
                  requests: state.requests,
                );
              }

              return const SizedBox.shrink();
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            backgroundColor: Theme.of(context).colorScheme.primary,
            icon: const Icon(Icons.update),
            label: const Text('Update Food Status'),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              SystemNavigator.pop();
            },
            child: const Text('EXIT'),
          ),
        ],
      ),
    );
  }
}

class _CanteenDashboardContent extends StatelessWidget {
  final CanteenDashboard dashboard;
  final List<CanteenRequest> requests;

  const _CanteenDashboardContent({
    required this.dashboard,
    required this.requests,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 8.h,
        bottom: 100.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page header
          StaggeredAnimation(
            index: 0,
            child: Padding(
              padding: EdgeInsets.only(bottom: 20.h),
              child: Text(
                'Staff Dashboard',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ),

          // 3B: Mission Card
          StaggeredAnimation(
            index: 1,
            child: AppCard(
              variant: CardVariant.highlight,
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'OUR MISSION',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.85),
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Don't Waste Food",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Sustainability & Anti-Pollution',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Total Meals Card
          StaggeredAnimation(
            index: 2,
            child: AppCard(
              variant: CardVariant.highlight,
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.analytics_outlined,
                          size: 24.w,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Total Meals',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    dashboard.totalMealsSaved.toString(),
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Daily: ${dashboard.dailyAverage}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_upward,
                              size: 12.w,
                              color: Colors.white,
                            ),
                            Text(
                              '+${(dashboard.monthlyTrend * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // 3C: Sustainability Impact Section
          StaggeredAnimation(
            index: 3,
            child: _SustainabilityCard(dashboard: dashboard),
          ),

          SizedBox(height: 16.h),

          // 3D: Urgent Requests Section
          if (requests.isNotEmpty) ...[
            StaggeredAnimation(
              index: 4,
              child: _UrgentRequestsCard(requests: requests),
            ),
            SizedBox(height: 16.h),
          ],

          // Status Card
          StaggeredAnimation(
            index: requests.isNotEmpty ? 5 : 4,
            child: AppCard(
              padding: EdgeInsets.all(20.r),
              child: Row(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Status',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Everything is running smoothly',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 3C: Sustainability Impact Card
class _SustainabilityCard extends StatelessWidget {
  final CanteenDashboard dashboard;

  const _SustainabilityCard({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  gradient: AppTheme.iconBackgroundGradient(isDark),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.eco_outlined,
                  size: 20.w,
                  color: AppTheme.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Sustainability Impact',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.4,
            children: [
              _SustainabilityItem(
                value: '${dashboard.foodWastePrevented.toInt()}kg',
                label: 'Food Saved',
                isDark: isDark,
              ),
              _SustainabilityItem(
                value: '€${dashboard.canteenSavings.toInt()}',
                label: 'Cost Savings',
                isDark: isDark,
              ),
              _SustainabilityItem(
                value: dashboard.studentsHelped.toString(),
                label: 'Students Helped',
                isDark: isDark,
              ),
              _SustainabilityItem(
                value: '€${dashboard.studentSavingsTotal.toInt()}',
                label: 'Student Savings',
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SustainabilityItem extends StatelessWidget {
  final String value;
  final String label;
  final bool isDark;

  const _SustainabilityItem({
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.dividerTheme.color ?? AppTheme.lightBorder,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// 3D: Urgent Requests Card
class _UrgentRequestsCard extends StatelessWidget {
  final List<CanteenRequest> requests;

  const _UrgentRequestsCard({required this.requests});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF450A0A), Color(0xFF7F1D1D)]
              : const [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppTheme.error, width: 2),
      ),
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 20.w,
                color: AppTheme.error,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Urgent Access Requests',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.error,
                  ),
                ),
              ),
              Container(
                width: 24.w,
                height: 24.w,
                decoration: const BoxDecoration(
                  color: AppTheme.error,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    requests.length.toString(),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Request list
          ...requests.map(
            (request) => _RequestItem(request: request),
          ),
        ],
      ),
    );
  }
}

class _RequestItem extends StatelessWidget {
  final CanteenRequest request;

  const _RequestItem({required this.request});

  static const List<Color> _avatarColors = [
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFFEC4899),
  ];

  @override
  Widget build(BuildContext context) {
    final avatarColor =
        _avatarColors[request.id.hashCode % _avatarColors.length];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: avatarColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                request.initials,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Name + timestamp
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.studentName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.lightTextPrimary,
                  ),
                ),
                Text(
                  request.timeAgo,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : AppTheme.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Approve button
          GestureDetector(
            onTap: () => context
                .read<CanteenBloc>()
                .add(CanteenRequestApproved(request.id)),
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 18.w,
                color: AppTheme.primary,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Reject button
          GestureDetector(
            onTap: () => context
                .read<CanteenBloc>()
                .add(CanteenRequestRejected(request.id)),
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 18.w,
                color: AppTheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
