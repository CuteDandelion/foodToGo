import 'package:flutter/material.dart';

import '../../../../config/theme.dart';

/// Utility class for getting urgency-based colors for countdown timers
class UrgencyColor {
  static const Color _green = AppTheme.primary;
  static const Color _yellow = AppTheme.warning;
  static const Color _red = AppTheme.error;

  /// Returns a color based on time remaining
  /// - Green: > 1 hour
  /// - Yellow: 30-60 minutes
  /// - Red: < 30 minutes
  static Color getColor(Duration timeRemaining) {
    final minutes = timeRemaining.inMinutes;

    if (minutes > 60) {
      return _green;
    } else if (minutes > 30) {
      // Interpolate between green and yellow
      final t = (60 - minutes) / 30; // 0.0 at 60min, 1.0 at 30min
      return Color.lerp(_green, _yellow, t) ?? _yellow;
    } else if (minutes > 0) {
      // Interpolate between yellow and red
      final t = (30 - minutes) / 30; // 0.0 at 30min, 1.0 at 0min
      return Color.lerp(_yellow, _red, t) ?? _red;
    } else {
      return _red;
    }
  }
}

/// Utility class for dynamic greetings based on time of day
class DynamicGreeting {
  /// Returns appropriate greeting based on current time
  /// - Morning: 05:00 - 11:59
  /// - Afternoon: 12:00 - 16:59
  /// - Evening: 17:00 - 04:59
  static String getGreeting(String userName, [DateTime? currentTime]) {
    final time = currentTime ?? DateTime.now();
    final hour = time.hour;

    if (hour >= 5 && hour < 12) {
      return 'Good morning, $userName! 👋';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon, $userName! 👋';
    } else {
      return 'Good evening, $userName! 👋';
    }
  }
}
