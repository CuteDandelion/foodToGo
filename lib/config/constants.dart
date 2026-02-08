/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'FoodBeGood';
  static const String appVersion = '1.0.0';
  static const String apiVersion = 'v1';

  // Storage Keys
  static const String storageKeyUserId = 'user_id';
  static const String storageKeyToken = 'auth_token';
  static const String storageKeyRefreshToken = 'refresh_token';
  static const String storageKeyTheme = 'theme_dark_mode';
  static const String storageKeyLanguage = 'language';
  static const String storageKeyFirstLaunch = 'first_launch';
  static const String storageKeyLastSync = 'last_sync';

  // Database
  static const String databaseName = 'foodbegood.db';
  static const int databaseVersion = 1;

  // Hive Boxes
  static const String hiveBoxSettings = 'settings';
  static const String hiveBoxProfile = 'profile';
  static const String hiveBoxDashboard = 'dashboard_cache';
  static const String hiveBoxPickups = 'pickups';

  // Timeouts
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // QR Code
  static const int qrCodeExpirationMinutes = 5;

  // Animations
  static const Duration animationDurationFast = Duration(milliseconds: 200);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);

  // Cache
  static const Duration cacheExpirationDashboard = Duration(minutes: 5);
  static const Duration cacheExpirationProfile = Duration(hours: 1);

  // UI
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 16.0;
  static const double iconSize = 24.0;
  static const double buttonHeight = 56.0;
}
