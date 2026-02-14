import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodbegood/config/routes.dart';
import 'package:foodbegood/config/theme.dart';
import 'package:foodbegood/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:foodbegood/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:intl/intl.dart';

/// Meal history page with export functionality
class MealHistoryPage extends StatelessWidget {
  const MealHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.userId : null;

    return BlocProvider(
      create: (_) => ProfileBloc()..add(ProfileMealHistoryLoad(userId: userId)),
      child: const _MealHistoryView(),
    );
  }
}

class _MealHistoryView extends StatelessWidget {
  const _MealHistoryView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.goProfile();
            }
          },
        ),
        title: const Text('Meal History'),
        centerTitle: true,
        actions: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(Icons.download),
                onPressed: state.isMealHistoryLoading
                    ? null
                    : () => _exportHistory(context, state.mealHistory),
                tooltip: 'Export to CSV',
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final history = state.mealHistory;

          if (state.isMealHistoryLoading && history.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.mealHistoryErrorMessage != null && history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.r,
                    color: colorScheme.error,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    state.mealHistoryErrorMessage!,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileBloc>().add(
                            const ProfileMealHistoryLoad(),
                          );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildSummaryCards(colorScheme, textTheme, history),
              Expanded(
                child: history.isEmpty
                    ? _buildEmptyState(colorScheme, textTheme)
                    : _buildHistoryList(colorScheme, textTheme, history),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _buildSummaryCards(
    ColorScheme colorScheme,
    TextTheme textTheme,
    List<Map<String, dynamic>> history,
  ) {
    final totalSavings = _calculateTotalSavings(history);
    final totalMeals = history.length;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              icon: Icons.restaurant,
              value: '$totalMeals',
              label: 'Total Meals',
              color: colorScheme.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _SummaryCard(
              icon: Icons.savings,
              value: '\u20ac${totalSavings.toStringAsFixed(2)}',
              label: 'Total Saved',
              color: AppTheme.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _SummaryCard(
              icon: Icons.calendar_month,
              value: '$totalMeals',
              label: 'This Month',
              color: AppTheme.warning,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildEmptyState(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80.w,
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'No meal history yet',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start picking up meals to see your history',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildHistoryList(
    ColorScheme colorScheme,
    TextTheme textTheme,
    List<Map<String, dynamic>> history,
  ) {
    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        final date = DateTime.parse(item['date'] as String);
        final items = (item['items'] as List).cast<String>();
        final totalValue = item['totalValue'] as double;

        return _HistoryCard(
          date: date,
          items: items,
          totalValue: totalValue,
          index: index,
        );
      },
    );
  }

  static double _calculateTotalSavings(List<Map<String, dynamic>> history) {
    return history.fold(
      0.0,
      (sum, item) => sum + (item['totalValue'] as double),
    );
  }

  static void _exportHistory(
    BuildContext context,
    List<Map<String, dynamic>> history,
  ) {
    final totalSavings = _calculateTotalSavings(history);
    final totalMeals = history.length;

    final csvBuffer = StringBuffer();
    csvBuffer.writeln('Date,Items,Total Value');

    for (final item in history) {
      final date = DateTime.parse(item['date'] as String);
      final items = (item['items'] as List).cast<String>().join('; ');
      final totalValue = item['totalValue'] as double;

      csvBuffer.writeln(
        '${DateFormat('yyyy-MM-dd').format(date)},"$items",${totalValue.toStringAsFixed(2)}',
      );
    }

    csvBuffer.writeln();
    csvBuffer.writeln('Summary,,,');
    csvBuffer.writeln('Total Meals,,$totalMeals,');
    csvBuffer
        .writeln('Total Savings,,\u20ac${totalSavings.toStringAsFixed(2)},');

    Clipboard.setData(ClipboardData(text: csvBuffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12.w),
            const Expanded(
              child: Text('CSV data copied to clipboard!'),
            ),
          ],
        ),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.w),
          SizedBox(height: 8.h),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final DateTime date;
  final List<String> items;
  final double totalValue;
  final int index;

  const _HistoryCard({
    required this.date,
    required this.items,
    required this.totalValue,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('MMM').format(date).toUpperCase(),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    DateFormat('dd').format(date),
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meal #${index + 1}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    children: items.map((item) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          item,
                          style: textTheme.bodySmall,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    DateFormat('EEEE, HH:mm').format(date),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '\u20ac${totalValue.toStringAsFixed(2)}',
                style: textTheme.titleMedium?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
