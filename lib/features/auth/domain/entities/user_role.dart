/// Enum representing the different user roles in the FoodBeGood app.
enum UserRole {
  /// Student user role - can pick up meals, view dashboard, etc.
  student,

  /// Canteen staff role - can manage food status, view analytics, etc.
  canteen,
}

/// Extension methods for UserRole enum
extension UserRoleExtension on UserRole {
  /// Returns the display name for the role
  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.canteen:
        return 'Canteen Staff';
    }
  }

  /// Returns the route path for the role's home screen
  String get homeRoute {
    switch (this) {
      case UserRole.student:
        return '/student-dashboard';
      case UserRole.canteen:
        return '/canteen-dashboard';
    }
  }

  /// Returns the icon asset path for the role
  String get iconAsset {
    switch (this) {
      case UserRole.student:
        return 'assets/icons/student.svg';
      case UserRole.canteen:
        return 'assets/icons/canteen.svg';
    }
  }
}
