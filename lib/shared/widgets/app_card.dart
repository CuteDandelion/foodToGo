import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme.dart';

/// Card variants
enum CardVariant { default_, highlight, dark, branded }

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
    final isDark = theme.brightness == Brightness.dark;
    final radius = borderRadius ?? 20.r;

    return Container(
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: _getGradient(isDark),
        color: _getColor(theme),
        boxShadow: _getShadow(theme),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            padding: padding ?? EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: _getBorder(theme, isDark),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Gradient? _getGradient(bool isDark) {
    switch (variant) {
      case CardVariant.highlight:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryDark],
        );
      case CardVariant.dark:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.darkSurface, AppTheme.darkBackground],
        );
      case CardVariant.branded:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF064E3B), Color(0xFF065F46)]
              : const [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
        );
      case CardVariant.default_:
        return null;
    }
  }

  Color? _getColor(ThemeData theme) {
    switch (variant) {
      case CardVariant.highlight:
      case CardVariant.dark:
      case CardVariant.branded:
        return null;
      case CardVariant.default_:
        return theme.cardTheme.color;
    }
  }

  Border? _getBorder(ThemeData theme, bool isDark) {
    switch (variant) {
      case CardVariant.default_:
        return Border.all(
          color: theme.dividerTheme.color ?? Colors.transparent,
          width: 1,
        );
      case CardVariant.branded:
        return Border.all(
          color: isDark ? AppTheme.primaryLight : AppTheme.primary,
          width: 2,
        );
      case CardVariant.highlight:
      case CardVariant.dark:
        return null;
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
