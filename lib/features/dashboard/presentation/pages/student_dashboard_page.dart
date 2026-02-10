import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/routes.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/animated_progress.dart';
import '../../../../shared/widgets/animations.dart';
import '../../../../shared/widgets/custom_icons.dart' as custom_icons;
import '../bloc/dashboard_bloc.dart';

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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // On back press from dashboard, show exit confirmation or navigate to login
          _showExitConfirmation(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // TODO: Open drawer
            },
          ),
        title: Row(
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
        ),
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
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<DashboardBloc>().add(const DashboardRefreshed());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                    // Greeting
                    FadeInAnimation(
                      duration: const Duration(milliseconds: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good morning,',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            'Zain! 👋',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Total Meals Card with animated counter
                    _AnimatedMetricCard(
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

                    // Money Saved Card
                    _AnimatedCard(
                      index: 1,
                      child: Column(
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
                                        fontWeight: FontWeight.w600,
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
                          // Savings breakdown
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
                          // Motivational message
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
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Stats Grid with animated counters
                    Row(
                      children: [
                        Expanded(
                          child: _AnimatedStatCard(
                            index: 2,
                            icon: custom_icons.FoodIcons.chart,
                            iconColor: const Color(0xFFF59E0B),
                            title: 'Avg/Month',
                            value: data.monthlyAverage,
                            subtitle: 'Top 15%',
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _AnimatedStatCard(
                            index: 3,
                            icon: custom_icons.FoodIcons.streak,
                            iconColor: const Color(0xFFEC4899),
                            title: 'Day Streak',
                            value: data.currentStreak,
                            subtitle: '🔥 Keep it going!',
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Next Pickup Card
                    if (data.nextPickup != null)
                      _AnimatedCard(
                        index: 4,
                        child: Row(
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
                                      fontWeight: FontWeight.w600,
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  data.nextPickup!.formattedTime,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  'remaining',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 16.h),

                    // Social Impact Card
                    _AnimatedCard(
                      index: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                custom_icons.FoodIcons.impact,
                                size: 24.w,
                                color: const Color(0xFFEC4899),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Social Impact',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
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
                      ),
                    ),

                    SizedBox(height: 100.h), // Space for FAB
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      floatingActionButton: const _PulsingFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

/// Animated metric card with counter
class _AnimatedMetricCard extends StatelessWidget {
  final int index;
  final IconData icon;
  final Color iconColor;
  final String title;
  final int value;
  final String subtitle;
  final double progress;
  final bool isHighlight;
  final bool isLarge;

  const _AnimatedMetricCard({
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
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, animationValue, child) {
        final delayedValue = (animationValue - (index * 0.1)).clamp(0.0, 1.0);

        return Opacity(
          opacity: delayedValue,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - delayedValue)),
            child: Transform.scale(
              scale: 0.95 + (0.05 * delayedValue),
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
                    fontWeight: FontWeight.w600,
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

/// Animated stat card
class _AnimatedStatCard extends StatelessWidget {
  final int index;
  final IconData icon;
  final Color iconColor;
  final String title;
  final num value;
  final String? subtitle;

  const _AnimatedStatCard({
    required this.index,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, animationValue, child) {
        final delayedValue = (animationValue - (index * 0.1)).clamp(0.0, 1.0);

        return Opacity(
          opacity: delayedValue,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - delayedValue)),
            child: Transform.scale(
              scale: 0.95 + (0.05 * delayedValue),
              child: child,
            ),
          ),
        );
      },
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                color: iconColor,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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

/// Animated card wrapper
class _AnimatedCard extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedCard({
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, animationValue, child) {
        final delayedValue = (animationValue - (index * 0.1)).clamp(0.0, 1.0);

        return Opacity(
          opacity: delayedValue,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - delayedValue)),
            child: Transform.scale(
              scale: 0.95 + (0.05 * delayedValue),
              child: child,
            ),
          ),
        );
      },
      child: AppCard(child: child),
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
  final bool _isPressed = false;

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
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
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
          ),
        );
      },
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
