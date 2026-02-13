import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/animated_progress.dart';
import '../../../../shared/widgets/animations.dart';
import '../../../../shared/widgets/custom_icons.dart' as custom_icons;
import '../bloc/dashboard_bloc.dart';
import '../widgets/animated_countdown.dart';
import '../widgets/beating_heart.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/flame_animation.dart';
import '../widgets/swipeable_dashboard.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc()..add(const DashboardLoaded()),
      child: const _StudentDashboardView(),
    );
  }
}

class _StudentDashboardView extends StatelessWidget {
  const _StudentDashboardView();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitConfirmation(context);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
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
              onPressed: () {
                // TODO: Open drawer
              },
            ),
            title: _buildLogo(context),
            actions: [
              custom_icons.AnimatedIconButton(
                icon: Icons.settings_outlined,
                onPressed: () {
                  context.goSettings();
                },
              ),
              SizedBox(width: 8.w),
              custom_icons.AnimatedIconButton(
                icon: Icons.notifications_outlined,
                onPressed: () {
                  // TODO: Show notifications
                },
              ),
              SizedBox(width: 8.w),
            ],
          ),
          body: SwipeableDashboard(
            dashboardContent: _buildDashboardContent(context),
          ),
          floatingActionButton: const _PulsingFAB(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Food',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            'BE',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          'Good',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(const DashboardRefreshed());
      },
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: EdgeInsets.all(16.r),
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const _DashboardShimmer();
            }

            if (state is DashboardError) {
              return Center(child: Text(state.message));
            }

            if (state is DashboardLoadSuccess) {
              final data = state.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard Header with date/time and greeting
                  DashboardHeader(
                    userName: 'Zain',
                    testTime: DateTime.now(),
                  ),
                  SizedBox(height: 24.h),

                  // Total Meals Card with pop-up animation
                  _PopUpMetricCard(
                    index: 0,
                    icon: custom_icons.FoodIcons.meals,
                    iconColor: Colors.white,
                    title: 'Total Meals',
                    value: data.totalMeals,
                    subtitle: 'Meals Saved',
                    progress: data.monthlyGoalProgress,
                    isHighlight: true,
                    isLarge: true,
                  ),

                  SizedBox(height: 16.h),

                  // Money Saved Card with enhanced animations
                  _PopUpCard(
                    index: 1,
                    child: _buildMoneySavedCard(context, data),
                  ),

                  SizedBox(height: 16.h),

                  // Stats Grid with enhanced animations
                  Row(
                    children: [
                      Expanded(
                        child: _PopUpStatCard(
                          index: 2,
                          icon: custom_icons.FoodIcons.chart,
                          iconColor: const Color(0xFFF59E0B),
                          title: '${data.monthlyAverage} Avg meal/Month',
                          value: data.monthlyAverage,
                          subtitle: 'Top ${data.percentile}%',
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _PopUpStatCard(
                          index: 3,
                          iconWidget: const FlameAnimation(size: 28),
                          title: 'Day Streak',
                          value: data.currentStreak.toDouble(),
                          subtitle: '🔥 Keep it going!',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Next Pickup Card with animated countdown
                  if (data.nextPickup != null)
                    _PopUpCard(
                      index: 4,
                      child: _buildNextPickupCard(context, data),
                    ),

                  SizedBox(height: 16.h),

                  // Social Impact Card with beating heart
                  _PopUpCard(
                    index: 5,
                    child: _buildSocialImpactCard(context, data),
                  ),

                  SizedBox(height: 100.h), // Space for FAB
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildMoneySavedCard(BuildContext context, dynamic data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                custom_icons.FoodIcons.money,
                size: 24.w,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Money Saved',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'vs Last Month',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            _TrendIndicator(
              value: data.moneySaved.trend,
              isPositive: data.moneySaved.trend > 0,
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _ComparisonBar(
                label: 'This Month',
                value: data.moneySaved.thisMonth,
                progress: data.moneySaved.thisMonth / 100,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _ComparisonBar(
                label: 'Last Month',
                value: data.moneySaved.lastMonth,
                progress: data.moneySaved.lastMonth / 100,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: data.moneySaved.breakdown.entries.map((entry) {
            return Column(
              children: [
                Text(
                  '€${entry.value.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              Icon(
                custom_icons.FoodIcons.savings,
                size: 20.w,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  "You're on track to save €1,000+ this year!",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextPickupCard(BuildContext context, dynamic data) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            custom_icons.FoodIcons.time,
            size: 24.w,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Next Pickup',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                data.nextPickup!.location,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        AnimatedCountdown(
          targetTime: data.nextPickup!.time,
          label: 'remaining',
        ),
      ],
    );
  }

  Widget _buildSocialImpactCard(BuildContext context, dynamic data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const BeatingHeart(size: 24),
            SizedBox(width: 8.w),
            Text(
              'Social Impact',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Text(
          'Together with ${data.socialImpact.studentsHelped} other students, you\'ve helped save food and reduce waste in your community.',
          style: TextStyle(
            fontSize: 13.sp,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.only(top: 16.h),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerTheme.color ??
                    Colors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedCounter(
                      target: data.socialImpact.studentsHelped,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    Text(
                      'Students Helped',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDoubleCounter(
                      target: data.socialImpact.avgMoneySavedPerStudent,
                      prefix: '€',
                      decimalPlaces: 2,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    Text(
                      'Avg Saved/Student',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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

/// Pop-up metric card with enhanced animation
class _PopUpMetricCard extends StatelessWidget {
  final int index;
  final IconData icon;
  final Color iconColor;
  final String title;
  final int value;
  final String subtitle;
  final double progress;
  final bool isHighlight;
  final bool isLarge;

  const _PopUpMetricCard({
    required this.index,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.progress,
    this.isHighlight = false,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      curve: Curves.elasticOut,
      builder: (context, animationValue, child) {
        final delayedValue = (animationValue - (index * 0.1)).clamp(0.0, 1.0);

        return Opacity(
          opacity: delayedValue,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - delayedValue)),
            child: Transform.scale(
              scale: 0.8 + (0.2 * delayedValue),
              child: child,
            ),
          ),
        );
      },
      child: AppCard(
        variant: isHighlight ? CardVariant.highlight : CardVariant.default_,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: isHighlight
                        ? Colors.white.withValues(alpha: 0.2)
                        : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    icon,
                    size: 24.w,
                    color: isHighlight ? iconColor : Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: isHighlight ? Colors.white : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            AnimatedCounter(
              target: value,
              style: TextStyle(
                fontSize: 36.sp,
                fontWeight: FontWeight.w800,
                color: isHighlight ? Colors.white : Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13.sp,
                color: isHighlight
                    ? Colors.white.withValues(alpha: 0.8)
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            if (isHighlight) ...[
              SizedBox(height: 8.h),
              Text(
                '${(progress * 100).toInt()}% of monthly goal',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
            SizedBox(height: 12.h),
            AnimatedProgressBar(
              progress: progress,
              height: 8,
              color: isHighlight ? Colors.white : Theme.of(context).colorScheme.primary,
              backgroundColor: isHighlight ? Colors.white.withValues(alpha: 0.3) : null,
              showGlow: isHighlight,
            ),
          ],
        ),
      ),
    );
  }
}

/// Pop-up stat card with enhanced animation
class _PopUpStatCard extends StatelessWidget {
  final int index;
  final IconData? icon;
  final Widget? iconWidget;
  final Color? iconColor;
  final String title;
  final num value;
  final String? subtitle;

  const _PopUpStatCard({
    required this.index,
    this.icon,
    this.iconWidget,
    this.iconColor,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      curve: Curves.elasticOut,
      builder: (context, animationValue, child) {
        final delayedValue = (animationValue - (index * 0.1)).clamp(0.0, 1.0);

        return Opacity(
          opacity: delayedValue,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - delayedValue)),
            child: Transform.scale(
              scale: 0.8 + (0.2 * delayedValue),
              child: child,
            ),
          ),
        );
      },
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (iconWidget != null)
              iconWidget!
            else if (icon != null)
              Icon(
                icon,
                size: 28.w,
                color: iconColor,
              ),
            SizedBox(height: 12.h),
            AnimatedCounter(
              target: value,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: iconColor ?? Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: 4.h),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pop-up card wrapper with enhanced animation
class _PopUpCard extends StatelessWidget {
  final int index;
  final Widget child;

  const _PopUpCard({
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 100)),
      curve: Curves.elasticOut,
      builder: (context, animationValue, child) {
        final delayedValue = (animationValue - (index * 0.1)).clamp(0.0, 1.0);

        return Opacity(
          opacity: delayedValue,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - delayedValue)),
            child: Transform.scale(
              scale: 0.8 + (0.2 * delayedValue),
              child: child,
            ),
          ),
        );
      },
      child: AppCard(child: child),
    );
  }
}

/// Trend indicator widget
class _TrendIndicator extends StatelessWidget {
  final double value;
  final bool isPositive;

  const _TrendIndicator({
    required this.value,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
          size: 16.w,
          color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        ),
        SizedBox(width: 4.w),
        Text(
          '${(value * 100).abs().toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
        ),
      ],
    );
  }
}

/// Comparison bar widget
class _ComparisonBar extends StatelessWidget {
  final String label;
  final double value;
  final double progress;
  final Color color;

  const _ComparisonBar({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Text(
              '€${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6.h,
          ),
        ),
      ],
    );
  }
}

/// Pulsing FAB with gradient
class _PulsingFAB extends StatefulWidget {
  const _PulsingFAB();

  @override
  State<_PulsingFAB> createState() => _PulsingFABState();
}

class _PulsingFABState extends State<_PulsingFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(
                  alpha: 0.3 + 0.2 * _controller.value,
                ),
                blurRadius: 20 + 10 * _controller.value,
                spreadRadius: 2 + 2 * _controller.value,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: FloatingActionButton.extended(
              onPressed: () {
                AppHaptics.mediumImpact();
                context.goPickup();
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: const Icon(custom_icons.FoodIcons.pickup),
              label: const Text('Pickup My Meal'),
            ),
          ),
        );
      },
    );
  }
}

/// Dashboard shimmer loading state
class _DashboardShimmer extends StatelessWidget {
  const _DashboardShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting shimmer
        Container(
          width: 120.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 150.w,
          height: 28.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(height: 24.h),

        // Cards shimmer
        ...List.generate(5, (index) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                height: 120.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          );
        }),
      ],
    );
  }
}
