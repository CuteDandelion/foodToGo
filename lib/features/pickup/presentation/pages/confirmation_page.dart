import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/food_item.dart';
import '../bloc/pickup_bloc.dart';

/// Confirmation page showing receipt after order submission
class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        // Reset and go back to dashboard
        context.read<PickupBloc>().add(const PickupReset());
        context.goStudentDashboard();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkBackgroundGradient
              : AppTheme.lightBackgroundGradient,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: BlocBuilder<PickupBloc, PickupState>(
            builder: (context, state) {
              final order = state.currentOrder;

              if (order == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return SafeArea(
                child: Column(
                  children: [
                    // Success animation/icon
                    _buildSuccessHeader(context),

                    // Receipt card
                    Expanded(
                      child: _buildReceiptCard(context, order),
                    ),

                    // Action buttons
                    _buildActionButtons(context),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(24.r),
      child: Column(
        children: [
          // Success checkmark with animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 100.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 60.r,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24.h),
          Text(
            'Order Confirmed!',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your order has been sent to the canteen',
            style: TextStyle(
              fontSize: 16.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCard(BuildContext context, PickupOrder order) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: AppCard(
        padding: EdgeInsets.all(24.r),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(order.id.length - 6)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.primary,
                          size: 14.r,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Confirmed',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(height: 32.h),

              // Items
              Text(
                'Items',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 12.h),
              ...order.items.map((item) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (item.subCategory != null)
                        Text(
                          item.subCategory!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                    ],
                  ),
                );
              }),
              Divider(height: 32.h),

              // Pickup time
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: theme.colorScheme.primary,
                    size: 24.r,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pickup Time',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${DateFormat('EEEE, MMM d').format(order.timeSlot.date)} at ${order.timeSlot.time}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: theme.colorScheme.primary,
                    size: 24.r,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Mensa Viadrina',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(height: 32.h),

              // Canteen message
              if (order.canteenMessage != null)
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 20.r,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          order.canteenMessage!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final order = context.select((PickupBloc bloc) => bloc.state.currentOrder);

    return Container(
      padding: EdgeInsets.all(16.r),
      child: SafeArea(
        child: Column(
          children: [
            // Back to dashboard button
            ElevatedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.read<PickupBloc>().add(const PickupReset());
                context.goStudentDashboard();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                minimumSize: Size(double.infinity, 56.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.home),
                  SizedBox(width: 12.w),
                  Text(
                    'Back to Dashboard',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // View QR code button
            OutlinedButton(
              onPressed: order == null
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      final pickupTime =
                          '${DateFormat('EEEE, MMM d').format(order.timeSlot.date)} at ${order.timeSlot.time}';
                      context.goQRCode(
                        pickupId: order.id,
                        studentName: 'Zain Ul Ebad',
                        orderItems:
                            order.items.map((item) => item.name).toList(),
                        pickupTime: pickupTime,
                        expiresAt:
                            DateTime.now().add(const Duration(minutes: 5)),
                      );
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                minimumSize: Size(double.infinity, 56.h),
                side: BorderSide(color: theme.colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code),
                  SizedBox(width: 12.w),
                  Text(
                    'View QR Code',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
