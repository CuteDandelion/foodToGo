import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../bloc/pickup_bloc.dart';

/// Page for selecting pickup time slot
class TimeSlotSelectionPage extends StatelessWidget {
  const TimeSlotSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
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
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Select Pickup Time',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        body: BlocConsumer<PickupBloc, PickupState>(
          listener: (context, state) {
            if (state.status == PickupStatus.submitted) {
              // Navigate to confirmation page
              context.goConfirmation();
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                // Selected items summary
                _buildSelectedItemsSummary(context, state),

                // Calendar
                _buildCalendar(context, state),

                // Time slots
                Expanded(
                  child: _buildTimeSlots(context, state),
                ),

                // Confirm button
                _buildConfirmButton(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectedItemsSummary(BuildContext context, PickupState state) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                'Selected Items (${state.selectedItems.length})',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: state.selectedItems.map((item) {
              return Chip(
                label: Text(
                  item.name,
                  style: TextStyle(fontSize: 12.sp),
                ),
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                side: BorderSide.none,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, PickupState state) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final days = List.generate(7, (index) => now.add(Duration(days: index)));

    return Container(
      height: 100.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = state.availableTimeSlots.isNotEmpty &&
              state.availableTimeSlots.first.date.day == day.day;
          final isToday = day.day == now.day;

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.read<PickupBloc>().add(PickupLoadTimeSlots(day));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 70.w,
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : isToday
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16.r),
                border: isToday && !isSelected
                    ? Border.all(color: theme.colorScheme.primary, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(day),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  if (isToday)
                    Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlots(BuildContext context, PickupState state) {
    final theme = Theme.of(context);

    if (state.status == PickupStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.availableTimeSlots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              size: 48.r,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              'No available time slots',
              style: TextStyle(
                fontSize: 16.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Times',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              itemCount: state.availableTimeSlots.length,
              itemBuilder: (context, index) {
                final slot = state.availableTimeSlots[index];
                final isSelected = state.selectedTimeSlot?.id == slot.id;
                final isAvailable = slot.isAvailable;

                return GestureDetector(
                  onTap: isAvailable
                      ? () {
                          HapticFeedback.lightImpact();
                          context
                              .read<PickupBloc>()
                              .add(PickupTimeSlotSelected(slot));
                        }
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : isAvailable
                              ? theme.colorScheme.surface
                              : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12.r),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: isAvailable
                                  ? theme.colorScheme.primary
                                      .withValues(alpha: 0.3)
                                  : Colors.grey[400]!,
                            ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slot.time,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : isAvailable
                                      ? theme.colorScheme.onSurface
                                      : Colors.grey[600],
                            ),
                          ),
                          if (isAvailable && slot.availableSpots != null)
                            Text(
                              '${slot.availableSpots} spots',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                        .withValues(alpha: 0.8)
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, PickupState state) {
    final theme = Theme.of(context);
    final canConfirm = state.selectedTimeSlot != null;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: canConfirm
              ? () {
                  HapticFeedback.mediumImpact();
                  context.read<PickupBloc>().add(const PickupSubmitToCanteen());
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            disabledBackgroundColor: Colors.grey[300],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (state.status == PickupStatus.confirming)
                SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                const Icon(Icons.send),
              SizedBox(width: 12.w),
              Text(
                state.status == PickupStatus.confirming
                    ? 'Sending to Canteen...'
                    : 'Send to Canteen',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
