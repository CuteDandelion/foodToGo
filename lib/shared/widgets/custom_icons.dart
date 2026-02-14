import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme.dart';
import 'animations.dart';

/// Custom food category icons to replace emoji
class FoodIcons {
  FoodIcons._();

  // Food category icons using Material Design icons
  static const IconData salad = Icons.eco_outlined;
  static const IconData dessert = Icons.cake_outlined;
  static const IconData side = Icons.rice_bowl_outlined;
  static const IconData chicken = Icons.dinner_dining_outlined;
  static const IconData fish = Icons.set_meal_outlined;
  static const IconData veggie = Icons.spa_outlined;
  static const IconData fruit = Icons.apple_outlined;
  static const IconData drink = Icons.local_drink_outlined;
  static const IconData snack = Icons.cookie_outlined;
  static const IconData bread = Icons.bakery_dining_outlined;

  // Navigation icons
  static const IconData home = Icons.home_outlined;
  static const IconData homeFilled = Icons.home;
  static const IconData profile = Icons.person_outline;
  static const IconData profileFilled = Icons.person;
  static const IconData settings = Icons.settings_outlined;
  static const IconData settingsFilled = Icons.settings;
  static const IconData history = Icons.history_outlined;
  static const IconData historyFilled = Icons.history;
  static const IconData qrCode = Icons.qr_code_outlined;
  static const IconData qrCodeFilled = Icons.qr_code;

  // Action icons
  static const IconData pickup = Icons.handshake_outlined;
  static const IconData pickupFilled = Icons.handshake;
  static const IconData scan = Icons.qr_code_scanner_outlined;
  static const IconData camera = Icons.camera_alt_outlined;
  static const IconData add = Icons.add_circle_outline;
  static const IconData remove = Icons.remove_circle_outline;
  static const IconData check = Icons.check_circle_outline;
  static const IconData checkFilled = Icons.check_circle;
  static const IconData close = Icons.close;
  static const IconData edit = Icons.edit_outlined;
  static const IconData delete = Icons.delete_outline;
  static const IconData share = Icons.share_outlined;
  static const IconData copy = Icons.copy_outlined;
  static const IconData download = Icons.download_outlined;

  // Status icons
  static const IconData success = Icons.check_circle;
  static const IconData error = Icons.error_outline;
  static const IconData warning = Icons.warning_amber_outlined;
  static const IconData info = Icons.info_outline;
  static const IconData pending = Icons.pending_outlined;
  static const IconData expired = Icons.timer_off_outlined;

  // Feature icons
  static const IconData meals = Icons.restaurant_outlined;
  static const IconData money = Icons.euro_outlined;
  static const IconData savings = Icons.savings_outlined;
  static const IconData streak = Icons.local_fire_department_outlined;
  static const IconData impact = Icons.favorite_outline;
  static const IconData chart = Icons.show_chart;
  static const IconData trendUp = Icons.trending_up;
  static const IconData trendDown = Icons.trending_down;
  static const IconData time = Icons.access_time;
  static const IconData calendar = Icons.calendar_today_outlined;
  static const IconData location = Icons.location_on_outlined;
  static const IconData notification = Icons.notifications_outlined;
  static const IconData notificationFilled = Icons.notifications;
  static const IconData badge = Icons.workspace_premium_outlined;
  static const IconData trophy = Icons.emoji_events_outlined;
  static const IconData star = Icons.star_outline;
  static const IconData starFilled = Icons.star;

  // Role icons
  static const IconData student = Icons.school_outlined;
  static const IconData canteen = Icons.restaurant_outlined;
  static const IconData admin = Icons.admin_panel_settings_outlined;

  // Auth icons
  static const IconData login = Icons.login;
  static const IconData logout = Icons.logout;
  static const IconData lock = Icons.lock_outline;
  static const IconData email = Icons.email_outlined;
  static const IconData phone = Icons.phone_outlined;
  static const IconData idCard = Icons.badge_outlined;
  static const IconData visibility = Icons.visibility_outlined;
  static const IconData visibilityOff = Icons.visibility_off_outlined;

  // Theme icons
  static const IconData lightMode = Icons.light_mode_outlined;
  static const IconData darkMode = Icons.dark_mode_outlined;
  static const IconData brightness = Icons.brightness_6_outlined;

  // Misc icons
  static const IconData menu = Icons.menu;
  static const IconData more = Icons.more_vert;
  static const IconData arrowForward = Icons.arrow_forward_ios;
  static const IconData arrowBack = Icons.arrow_back_ios;
  static const IconData arrowUp = Icons.arrow_upward;
  static const IconData arrowDown = Icons.arrow_downward;
  static const IconData refresh = Icons.refresh;
  static const IconData search = Icons.search;
  static const IconData filter = Icons.filter_list;
  static const IconData sort = Icons.sort;
}

/// Icon data mapping for food categories
class FoodCategoryIcons {
  static IconData getIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('salad') || name.contains('green')) {
      return FoodIcons.salad;
    } else if (name.contains('dessert') || name.contains('sweet')) {
      return FoodIcons.dessert;
    } else if (name.contains('side') || name.contains('rice')) {
      return FoodIcons.side;
    } else if (name.contains('chicken') || name.contains('meat')) {
      return FoodIcons.chicken;
    } else if (name.contains('fish') || name.contains('seafood')) {
      return FoodIcons.fish;
    } else if (name.contains('veggie') || name.contains('vegetable')) {
      return FoodIcons.veggie;
    } else if (name.contains('fruit')) {
      return FoodIcons.fruit;
    } else if (name.contains('drink') || name.contains('beverage')) {
      return FoodIcons.drink;
    } else if (name.contains('snack')) {
      return FoodIcons.snack;
    } else if (name.contains('bread')) {
      return FoodIcons.bread;
    }
    return FoodIcons.meals;
  }

  static Color getColor(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('salad') || name.contains('green')) {
      return AppTheme.primary;
    } else if (name.contains('dessert') || name.contains('sweet')) {
      return AppTheme.warning;
    } else if (name.contains('side') || name.contains('rice')) {
      return const Color(0xFF8B5CF6);
    } else if (name.contains('chicken') || name.contains('meat')) {
      return const Color(0xFFF97316);
    } else if (name.contains('fish') || name.contains('seafood')) {
      return AppTheme.info;
    } else if (name.contains('veggie') || name.contains('vegetable')) {
      return const Color(0xFF22C55E);
    } else if (name.contains('fruit')) {
      return AppTheme.social;
    } else if (name.contains('drink') || name.contains('beverage')) {
      return const Color(0xFF06B6D4);
    } else if (name.contains('snack')) {
      return const Color(0xFFD946EF);
    } else if (name.contains('bread')) {
      return const Color(0xFFD97706);
    }
    return AppTheme.primary;
  }
}

/// Animated icon widget with scale and rotation effects
class AnimatedIconWidget extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color? color;
  final Duration duration;
  final bool animate;

  const AnimatedIconWidget({
    super.key,
    required this.icon,
    this.size = 24,
    this.color,
    this.duration = const Duration(milliseconds: 300),
    this.animate = true,
  });

  @override
  State<AnimatedIconWidget> createState() => _AnimatedIconWidgetState();
}

class _AnimatedIconWidgetState extends State<AnimatedIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Icon(
            widget.icon,
            size: widget.size,
            color: widget.color,
          ),
        );
      },
    );
  }
}

/// Icon container with background and animation
class IconContainer extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? iconColor;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool animate;

  const IconContainer({
    super.key,
    required this.icon,
    this.size = 56,
    this.iconSize = 28,
    this.backgroundColor,
    this.iconColor,
    this.borderRadius = 14,
    this.onTap,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget container = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color:
            backgroundColor ?? theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: animate
            ? AnimatedIconWidget(
                icon: icon,
                size: iconSize,
                color: iconColor ?? theme.colorScheme.primary,
              )
            : Icon(
                icon,
                size: iconSize,
                color: iconColor ?? theme.colorScheme.primary,
              ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: container,
      );
    }

    return container;
  }
}

/// Animated icon button with press feedback
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
