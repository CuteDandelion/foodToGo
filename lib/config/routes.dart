import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/role_selection_page.dart';
import '../features/canteen/presentation/pages/canteen_dashboard_page.dart';
import '../features/dashboard/presentation/pages/student_dashboard_page.dart';
import '../features/pickup/presentation/pages/pickup_page.dart';
import '../features/pickup/presentation/pages/qr_code_page.dart';
import '../features/profile/presentation/pages/meal_history_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';

/// Route paths
class RoutePaths {
  RoutePaths._();

  static const String roleSelection = '/';
  static const String login = '/login';
  static const String studentDashboard = '/student/dashboard';
  static const String canteenDashboard = '/canteen/dashboard';
  static const String pickup = '/pickup';
  static const String qrCode = '/qr-code';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String mealHistory = '/meal-history';
}

/// Custom page transitions
class AppPageTransitions {
  AppPageTransitions._();

  /// Slide from right transition
  static CustomTransitionPage slideFromRight({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  /// Fade transition
  static CustomTransitionPage fade({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Scale and fade transition
  static CustomTransitionPage scaleFade({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// Slide up transition (for modals)
  static CustomTransitionPage slideUp({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}

/// App router configuration
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: RoutePaths.roleSelection,
    routes: [
      // Role Selection
      GoRoute(
        path: RoutePaths.roleSelection,
        pageBuilder: (context, state) => AppPageTransitions.fade(
          key: state.pageKey,
          child: const RoleSelectionPage(),
        ),
      ),

      // Login
      GoRoute(
        path: RoutePaths.login,
        pageBuilder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'student';
          return AppPageTransitions.slideFromRight(
            key: state.pageKey,
            child: LoginPage(role: role),
          );
        },
      ),

      // Student Dashboard
      GoRoute(
        path: RoutePaths.studentDashboard,
        pageBuilder: (context, state) => AppPageTransitions.scaleFade(
          key: state.pageKey,
          child: const StudentDashboardPage(),
        ),
      ),

      // Canteen Dashboard
      GoRoute(
        path: RoutePaths.canteenDashboard,
        pageBuilder: (context, state) => AppPageTransitions.scaleFade(
          key: state.pageKey,
          child: const CanteenDashboardPage(),
        ),
      ),

      // Pickup
      GoRoute(
        path: RoutePaths.pickup,
        pageBuilder: (context, state) => AppPageTransitions.slideFromRight(
          key: state.pageKey,
          child: const PickupPage(),
        ),
      ),

      // QR Code
      GoRoute(
        path: RoutePaths.qrCode,
        pageBuilder: (context, state) {
          final pickupId = state.uri.queryParameters['pickupId'] ?? '';
          final qrData = state.uri.queryParameters['qrData'] ?? '';
          final expiresAtStr = state.uri.queryParameters['expiresAt'];
          final expiresAt = expiresAtStr != null ? DateTime.tryParse(expiresAtStr) : null;
          return AppPageTransitions.scaleFade(
            key: state.pageKey,
            child: QRCodePage(
              pickupId: pickupId,
              qrData: qrData.isNotEmpty ? Uri.decodeComponent(qrData) : null,
              expiresAt: expiresAt,
            ),
          );
        },
      ),

      // Profile
      GoRoute(
        path: RoutePaths.profile,
        pageBuilder: (context, state) => AppPageTransitions.slideFromRight(
          key: state.pageKey,
          child: const ProfilePage(),
        ),
      ),

      // Settings
      GoRoute(
        path: RoutePaths.settings,
        pageBuilder: (context, state) => AppPageTransitions.slideFromRight(
          key: state.pageKey,
          child: const SettingsPage(),
        ),
      ),

      // Meal History
      GoRoute(
        path: RoutePaths.mealHistory,
        pageBuilder: (context, state) => AppPageTransitions.slideFromRight(
          key: state.pageKey,
          child: const MealHistoryPage(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(
          'Page not found: ${state.uri.path}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    ),
  );
}

/// Extension for easy navigation
extension GoRouterExtension on BuildContext {
  void goRoleSelection() => go(RoutePaths.roleSelection);
  void goLogin({String? role}) => go('${RoutePaths.login}${role != null ? '?role=$role' : ''}');
  void goStudentDashboard() => go(RoutePaths.studentDashboard);
  void goCanteenDashboard() => go(RoutePaths.canteenDashboard);
  void goPickup() => go(RoutePaths.pickup);
  void goQRCode({
    required String pickupId,
    String? qrData,
    DateTime? expiresAt,
    List<dynamic>? items,
  }) {
    final params = <String, String>{
      'pickupId': pickupId,
      if (qrData != null) 'qrData': Uri.encodeComponent(qrData),
      if (expiresAt != null) 'expiresAt': expiresAt.toIso8601String(),
    };
    final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    go('${RoutePaths.qrCode}?$queryString');
  }
  void goProfile() => go(RoutePaths.profile);
  void goSettings() => go(RoutePaths.settings);
  void goMealHistory() => go(RoutePaths.mealHistory);
}
