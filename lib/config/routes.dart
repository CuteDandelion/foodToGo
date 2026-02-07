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
        builder: (context, state) => const RoleSelectionPage(),
      ),

      // Login
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) {
          final role = state.uri.queryParameters['role'] ?? 'student';
          return LoginPage(role: role);
        },
      ),

      // Student Dashboard
      GoRoute(
        path: RoutePaths.studentDashboard,
        builder: (context, state) => const StudentDashboardPage(),
      ),

      // Canteen Dashboard
      GoRoute(
        path: RoutePaths.canteenDashboard,
        builder: (context, state) => const CanteenDashboardPage(),
      ),

      // Pickup
      GoRoute(
        path: RoutePaths.pickup,
        builder: (context, state) => const PickupPage(),
      ),

      // QR Code
      GoRoute(
        path: RoutePaths.qrCode,
        builder: (context, state) {
          final pickupId = state.uri.queryParameters['pickupId'] ?? '';
          return QRCodePage(pickupId: pickupId);
        },
      ),

      // Profile
      GoRoute(
        path: RoutePaths.profile,
        builder: (context, state) => const ProfilePage(),
      ),

      // Settings
      GoRoute(
        path: RoutePaths.settings,
        builder: (context, state) => const SettingsPage(),
      ),

      // Meal History
      GoRoute(
        path: RoutePaths.mealHistory,
        builder: (context, state) => const MealHistoryPage(),
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
  void goQRCode({required String pickupId}) => go('${RoutePaths.qrCode}?pickupId=$pickupId');
  void goProfile() => go(RoutePaths.profile);
  void goSettings() => go(RoutePaths.settings);
  void goMealHistory() => go(RoutePaths.mealHistory);
}
