import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Card variants
enum CardVariant { default_, highlight, dark }

/// Reusable card widget
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = CardVariant.default_,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius,
    this.elevation = 0,
  });

  final Widget child;
  final CardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? borderRadius;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 20.r),
        gradient: _getGradient(),
        color: _getColor(theme),
        boxShadow: _getShadow(theme),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius ?? 20.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? 20.r),
          child: Container(
            padding: padding ?? EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius ?? 20.r),
              border: variant == CardVariant.default_
                  ? Border.all(
                      color: theme.dividerTheme.color ?? Colors.transparent,
                      width: 1,
                    )
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Gradient? _getGradient() {
    switch (variant) {
      case CardVariant.highlight:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF10B981),
            Color(0xFF059669),
          ],
        );
      case CardVariant.dark:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
        );
      case CardVariant.default_:
        return null;
    }
  }

  Color? _getColor(ThemeData theme) {
    switch (variant) {
      case CardVariant.highlight:
      case CardVariant.dark:
        return null;
      case CardVariant.default_:
        return theme.cardTheme.color;
    }
  }

  List<BoxShadow>? _getShadow(ThemeData theme) {
    if (elevation > 0) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: elevation * 4,
          offset: Offset(0, elevation * 2),
        ),
      ];
    }
    return null;
  }
}
