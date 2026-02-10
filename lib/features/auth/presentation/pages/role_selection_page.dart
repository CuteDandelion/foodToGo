import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/routes.dart';
import '../../../../config/theme.dart';
import '../../../../shared/widgets/animations.dart';
import '../../../../shared/widgets/custom_icons.dart' as custom_icons;

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with animation
                ScaleAnimation(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.white, Color(0xFFF8FAFC)],
                      ),
                      border: Border.all(color: AppTheme.primary, width: 2),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'FOOD',
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.lightTextPrimary,
                            letterSpacing: 3,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 4.h),
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.primaryDark],
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Text(
                            'BE',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          'GOOD',
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.lightTextPrimary,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 48.h),

                // Welcome text with fade animation
                FadeInAnimation(
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      Text(
                        'Welcome!',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Select your role to continue',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 48.h),

                // Student Card with animation
                StaggeredAnimation(
                  index: 0,
                  child: _RoleCard(
                    icon: custom_icons.FoodIcons.student,
                    title: 'Student',
                    description: 'Track meals, save money, reduce waste',
                    onTap: () {
                      AppHaptics.mediumImpact();
                      context.goLogin();
                    },
                  ),
                ),

                SizedBox(height: 16.h),

                // Canteen Card with animation
                StaggeredAnimation(
                  index: 1,
                  child: _RoleCard(
                    icon: custom_icons.FoodIcons.canteen,
                    title: 'Canteen Staff',
                    description: 'Manage food, prevent waste, help students',
                    onTap: () {
                      AppHaptics.mediumImpact();
                      context.goLogin();
                    },
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: _isPressed
                  ? AppTheme.primary
                  : AppTheme.lightBorder,
              width: _isPressed ? 2 : 1,
            ),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    gradient: _isPressed
                        ? const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.primaryDark],
                          )
                        : null,
                    color: _isPressed ? null : AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 28.w,
                    color: _isPressed ? Colors.white : AppTheme.primary,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.lightTextPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        widget.description,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppTheme.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 20.w,
                    color: _isPressed ? AppTheme.primary : AppTheme.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
