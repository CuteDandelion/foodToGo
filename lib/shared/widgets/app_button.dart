import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme.dart';
import 'animations.dart';

/// Button size variants
enum ButtonSize { small, medium, large }

/// Button style variants
enum ButtonVariant { primary, secondary, ghost, gradient }

/// Primary button widget with enhanced animations
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.large,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.disabled = false,
    this.gradientColors,
  });

  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final bool disabled;
  final List<Color>? gradientColors;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    AppHaptics.mediumImpact();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.disabled || widget.isLoading || widget.onPressed == null;

    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: SizedBox(
        width: widget.isFullWidth ? double.infinity : null,
        height: _getHeight(),
        child: widget.variant == ButtonVariant.gradient
            ? _buildGradientButton(isDisabled)
            : ElevatedButton(
                onPressed: isDisabled ? null : () {
                  AppHaptics.mediumImpact();
                  widget.onPressed?.call();
                },
                style: _getButtonStyle(context),
                child: widget.isLoading
                    ? _buildLoadingIndicator()
                    : _buildContent(),
              ),
      ),
    );
  }

  Widget _buildGradientButton(bool isDisabled) {
    final colors = widget.gradientColors ??
        const [
          Color(0xFF10B981),
          Color(0xFF059669),
        ];

    return GestureDetector(
      onTapDown: isDisabled ? null : _handleTapDown,
      onTapUp: isDisabled ? null : _handleTapUp,
      onTapCancel: isDisabled ? null : _handleTapCancel,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDisabled
                ? colors.map((c) => c.withValues(alpha: 0.5)).toList()
                : colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: colors.first.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: widget.isLoading
              ? _buildLoadingIndicator()
              : _buildContent(isDisabled: isDisabled),
        ),
      ),
    );
  }

  double _getHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return 40.h;
      case ButtonSize.medium:
        return 48.h;
      case ButtonSize.large:
        return 56.h;
    }
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final theme = Theme.of(context);

    switch (widget.variant) {
      case ButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
        );
      case ButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: theme.cardTheme.color,
          foregroundColor: AppTheme.primary,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
            side: BorderSide(color: theme.dividerTheme.color ?? AppTheme.lightBorder, width: 2),
          ),
          disabledBackgroundColor: theme.cardTheme.color?.withValues(alpha: 0.5),
          disabledForegroundColor: AppTheme.primary.withValues(alpha: 0.5),
        );
      case ButtonVariant.ghost:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppTheme.primary,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          disabledForegroundColor: AppTheme.primary.withValues(alpha: 0.5),
        );
      case ButtonVariant.gradient:
        // Handled separately in _buildGradientButton
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        );
    }
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 24.w,
      height: 24.w,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          widget.variant == ButtonVariant.primary || widget.variant == ButtonVariant.gradient
              ? Colors.white
              : AppTheme.primary,
        ),
      ),
    );
  }

  Widget _buildContent({bool isDisabled = false}) {
    final textColor = widget.variant == ButtonVariant.primary ||
            widget.variant == ButtonVariant.gradient
        ? Colors.white
        : AppTheme.primary;

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, size: 20.w, color: isDisabled ? textColor.withValues(alpha: 0.7) : textColor),
          SizedBox(width: 8.w),
          Text(
            widget.text,
            style: TextStyle(
              fontSize: _getFontSize(),
              fontWeight: FontWeight.w600,
              color: isDisabled ? textColor.withValues(alpha: 0.7) : textColor,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: TextStyle(
        fontSize: _getFontSize(),
        fontWeight: FontWeight.w600,
        color: isDisabled ? textColor.withValues(alpha: 0.7) : textColor,
      ),
    );
  }

  double _getFontSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 14.sp;
      case ButtonSize.medium:
        return 15.sp;
      case ButtonSize.large:
        return 16.sp;
    }
  }
}
