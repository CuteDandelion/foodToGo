import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme.dart';

/// Glassmorphism card widget with frosted glass effect
class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadows;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blur = 10,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius.r),
        boxShadow: shadows ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor ??
                  (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.7)),
              borderRadius: BorderRadius.circular(borderRadius.r),
              border: Border.all(
                color: borderColor ??
                    (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.5)),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(borderRadius.r),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(borderRadius.r),
                child: Container(
                  padding: padding ?? EdgeInsets.all(24.r),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Gradient border card with animated glow effect
class GradientBorderCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final List<Color> gradientColors;
  final double borderWidth;
  final VoidCallback? onTap;
  final bool animate;

  const GradientBorderCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.gradientColors = const [
      AppTheme.primary,
      AppTheme.primaryLight,
      AppTheme.primaryDark,
    ],
    this.borderWidth = 2,
    this.onTap,
    this.animate = false,
  });

  @override
  State<GradientBorderCard> createState() => _GradientBorderCardState();
}

class _GradientBorderCardState extends State<GradientBorderCard>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller = AnimationController(
        duration: const Duration(seconds: 3),
        vsync: this,
      )..repeat();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget cardContent = Container(
      margin: widget.margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.gradientColors.first.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(widget.borderWidth.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              (widget.borderRadius - widget.borderWidth).r,
            ),
            color: theme.cardTheme.color,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(
              (widget.borderRadius - widget.borderWidth).r,
            ),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(
                (widget.borderRadius - widget.borderWidth).r,
              ),
              child: Container(
                padding: widget.padding ?? EdgeInsets.all(24.r),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.animate && _controller != null) {
      return AnimatedBuilder(
        animation: _controller!,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius.r),
              boxShadow: [
                BoxShadow(
                  color: widget.gradientColors.first.withValues(
                    alpha: 0.3 + 0.2 * _controller!.value,
                  ),
                  blurRadius: 20 + 10 * _controller!.value,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          );
        },
        child: cardContent,
      );
    }

    return cardContent;
  }
}

/// Animated card with entrance animation
class AnimatedCard extends StatelessWidget {
  final Widget child;
  final int index;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final List<BoxShadow>? shadows;

  const AnimatedCard({
    super.key,
    required this.child,
    this.index = 0,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.onTap,
    this.backgroundColor,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final delayedValue = (value - (index * 0.1)).clamp(0.0, 1.0);

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
      child: Container(
        margin: margin ?? EdgeInsets.zero,
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.cardTheme.color,
          borderRadius: BorderRadius.circular(borderRadius.r),
          boxShadow: shadows ??
              [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius.r),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius.r),
            child: Container(
              padding: padding ?? EdgeInsets.all(24.r),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer loading card
class ShimmerCard extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;

  const ShimmerCard({
    super.key,
    this.height = 120,
    this.margin,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: margin ?? EdgeInsets.zero,
      height: height.h,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius.r),
        child: _buildShimmerEffect(isDark),
      ),
    );
  }

  Widget _buildShimmerEffect(bool isDark) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.5),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: const SizedBox.expand(),
    );
  }
}
