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
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      '${data.socialImpact.studentsHelped} students helped! 👋',
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
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                                        color: Theme.of(context).colorScheme.onBackground,
                                      ),
                                    ),
                                    Text(
                                      'vs Last Month',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
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
                          Wrap(
                            spacing: 16.w,
                            children: data.moneySaved.breakdown.entries.map((entry) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                                    ),
                                  ),
                                  Text(
                                    '€${entry.value.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.onBackground,
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
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
                            title: 'Avg/Mo',
                            value: data.monthlyAverage.toString(),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.local_fire_department,
                            iconColor: const Color(0xFFEC4899),
                            title: 'Streak',
                            value: '${data.currentStreak} days',
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
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                                      color: Theme.of(context).colorScheme.onBackground,
                                    ),
                                  ),
                                  Text(
                                    data.nextPickup!.location,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              data.nextPickup!.formattedTime,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: 16.h),

                    // Social Impact Card
                    AppCard(
                      variant: CardVariant.dark,
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 24.w,
                            color: const Color(0xFFEC4899),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Social Impact',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${data.socialImpact.studentsHelped} students helped save money',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.white.withOpacity(0.7),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to pickup
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('Pick Up My Meal'),
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

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.progress,
    this.isHighlight = false,
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
                  color: isHighlight ? Colors.white.withOpacity(0.2) : Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                  color: isHighlight ? Colors.white : Theme.of(context).colorScheme.onBackground,
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
              color: isHighlight ? Colors.white.withOpacity(0.8) : Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 12.h),
          AppProgressBar(
            progress: progress,
            height: 8,
            color: isHighlight ? Colors.white : Theme.of(context).colorScheme.primary,
            backgroundColor: isHighlight ? Colors.white.withOpacity(0.3) : null,
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

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
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
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
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
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
            Text(
              '€${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6.h,
          ),
        ),
      ],
    );
  }
}
