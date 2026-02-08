import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/routes.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_progress_bar.dart';
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
    return Scaffold(
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
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.goSettings();
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
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
                return const Center(child: CircularProgressIndicator());
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
                    SizedBox(height: 24.h),

                    // Total Meals Card
                    _MetricCard(
                      icon: Icons.eco_outlined,
                      iconColor: Colors.white,
                      title: 'Total Meals',
                      value: data.totalMeals.toString(),
                      subtitle: 'Meals Saved',
                      progress: data.monthlyGoalProgress,
                      isHighlight: true,
                      isLarge: true,
                    ),

                    SizedBox(height: 16.h),

                    // Money Saved Card
                    AppCard(
                      variant: CardVariant.default_,
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
                                  Icons.euro,
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
                                  Icons.savings_outlined,
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

                    // Stats Grid
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.show_chart,
                            iconColor: const Color(0xFFF59E0B),
                            title: 'Avg/Month',
                            value: data.monthlyAverage.toString(),
                            subtitle: 'Top 15%',
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.local_fire_department,
                            iconColor: const Color(0xFFEC4899),
                            title: 'Day Streak',
                            value: '${data.currentStreak}',
                            subtitle: '🔥 Keep it going!',
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Next Pickup Card
                    if (data.nextPickup != null)
                      AppCard(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.access_time,
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
                    AppCard(
                      variant: CardVariant.dark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 24.w,
                                color: const Color(0xFFEC4899),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Social Impact',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Together with ${data.socialImpact.studentsHelped} other students, you\'ve helped save food and reduce waste in your community.',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.white.withValues(alpha: 0.8),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Container(
                            padding: EdgeInsets.only(top: 16.h),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.1),
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
                                      Text(
                                        '${data.socialImpact.studentsHelped}',
                                        style: TextStyle(
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF34D399),
                                        ),
                                      ),
                                      Text(
                                        'Students Helped',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.white.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '€${data.socialImpact.avgMoneySavedPerStudent.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF34D399),
                                        ),
                                      ),
                                      Text(
                                        'Avg Saved/Student',
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.white.withValues(alpha: 0.6),
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(50.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            // TODO: Navigate to pickup
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.handshake_outlined),
          label: const Text('Pickup My Meal'),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final double progress;
  final bool isHighlight;
  final bool isLarge;

  const _MetricCard({
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
    return AppCard(
      variant: isHighlight ? CardVariant.highlight : CardVariant.default_,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: isHighlight ? Colors.white.withValues(alpha: 0.2) : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
          Text(
            value,
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
              color: isHighlight ? Colors.white.withValues(alpha: 0.8) : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
          AppProgressBar(
            progress: progress,
            height: 8,
            color: isHighlight ? Colors.white : Theme.of(context).colorScheme.primary,
            backgroundColor: isHighlight ? Colors.white.withValues(alpha: 0.3) : null,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String? subtitle;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 28.w,
            color: iconColor,
          ),
          SizedBox(height: 12.h),
          Text(
            value,
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
    );
  }
}

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
