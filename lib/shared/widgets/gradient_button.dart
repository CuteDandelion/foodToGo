import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme.dart';
import 'animations.dart';

/// Enhanced button with gradient background and animations
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final bool disabled;
  final double height;
  final List<Color>? gradientColors;
  final double borderRadius;
  final bool enablePulse;
  final bool enableScale;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.disabled = false,
    this.height = 56,
    this.gradientColors,
    this.borderRadius = 14,
    this.enablePulse = false,
    this.enableScale = true,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    if (widget.enablePulse) {
      _pulseController.repeat();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enableScale) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enableScale) {
      setState(() => _isPressed = false);
    }
    AppHaptics.mediumImpact();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    if (widget.enableScale) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled =
        widget.disabled || widget.isLoading || widget.onPressed == null;
    final colors = widget.gradientColors ??
        const [
          AppTheme.primary,
          AppTheme.primaryDark,
        ];

    Widget buttonContent = Container(
      width: widget.isFullWidth ? double.infinity : null,
      height: widget.height.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDisabled
              ? colors.map((c) => c.withValues(alpha: 0.5)).toList()
              : colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(widget.borderRadius.r),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(widget.borderRadius.r),
        child: InkWell(
          onTapDown: isDisabled ? null : _handleTapDown,
          onTapUp: isDisabled ? null : _handleTapUp,
          onTapCancel: isDisabled ? null : _handleTapCancel,
          borderRadius: BorderRadius.circular(widget.borderRadius.r),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: isDisabled ? 0.7 : 1.0),
                      ),
                    ),
                  )
                : _buildContent(isDisabled),
          ),
        ),
      ),
    );

    if (widget.enablePulse && !isDisabled) {
      buttonContent = AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius.r),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withValues(
                    alpha: 0.3 + 0.2 * _pulseController.value,
                  ),
                  blurRadius: 20 + 10 * _pulseController.value,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          );
        },
        child: buttonContent,
      );
    }

    if (widget.enableScale) {
      return AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: buttonContent,
      );
    }

    return buttonContent;
  }

  Widget _buildContent(bool isDisabled) {
    final textWidget = Text(
      widget.text,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Colors.white.withValues(alpha: isDisabled ? 0.7 : 1.0),
      ),
    );

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            size: 20.w,
            color: Colors.white.withValues(alpha: isDisabled ? 0.7 : 1.0),
          ),
          SizedBox(width: 8.w),
          textWidget,
        ],
      );
    }

    return textWidget;
  }
}

/// Glow button with animated glow effect
class GlowButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? color;
  final double height;
  final double borderRadius;

  const GlowButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.color,
    this.height = 56,
    this.borderRadius = 14,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
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
    final isDisabled = widget.isLoading || widget.onPressed == null;
    final buttonColor = widget.color ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.isFullWidth ? double.infinity : null,
          height: widget.height.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius.r),
            gradient: LinearGradient(
              colors: [
                buttonColor,
                buttonColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: isDisabled
                ? null
                : [
                    BoxShadow(
                      color: buttonColor.withValues(
                        alpha: 0.3 + 0.2 * _controller.value,
                      ),
                      blurRadius: 20 + 15 * _controller.value,
                      spreadRadius: 2 + 2 * _controller.value,
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(widget.borderRadius.r),
            child: InkWell(
              onTap: isDisabled
                  ? null
                  : () {
                      AppHaptics.mediumImpact();
                      widget.onPressed?.call();
                    },
              borderRadius: BorderRadius.circular(widget.borderRadius.r),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      )
                    : _buildContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    final textWidget = Text(
      widget.text,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            size: 20.w,
            color: Colors.white,
          ),
          SizedBox(width: 8.w),
          textWidget,
        ],
      );
    }

    return textWidget;
  }
}

/// Icon button with scale animation
class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final double borderRadius;

  const AnimatedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 48,
    this.color,
    this.backgroundColor,
    this.borderRadius = 12,
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        AppHaptics.lightImpact();
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Container(
          width: widget.size.w,
          height: widget.size.w,
          decoration: BoxDecoration(
            color: widget.backgroundColor ??
                theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(widget.borderRadius.r),
          ),
          child: Icon(
            widget.icon,
            size: (widget.size * 0.5).w,
            color: widget.color ?? theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
