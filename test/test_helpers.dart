import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:foodbegood/core/storage/storage_manager.dart';
import 'package:foodbegood/shared/services/mock_data_service.dart';

// Mock Classes
class MockStorageManager extends Mock implements StorageManager {}

class MockSharedPrefsStorage extends Mock implements SharedPrefsStorage {}

class MockMockDataService extends Mock implements MockDataService {}

/// Test helper for setting up mocktail fallbacks
void setupMocktailFallbacks() {
  // Register fallback values for common types
  registerFallbackValue(MockStorageManager());
  registerFallbackValue(MockSharedPrefsStorage());
  registerFallbackValue(MockMockDataService());
}

/// Custom matcher for checking if a string contains a substring
Matcher containsString(String expected) => contains(expected);

/// Helper to create a test user
User createTestUser({
  String id = '1',
  String studentId = '61913042',
  UserRole role = UserRole.student,
  String firstName = 'Test',
  String lastName = 'User',
}) {
  return User(
    id: id,
    studentId: studentId,
    passwordHash: 'hashed_password',
    role: role,
    profile: Profile(
      firstName: firstName,
      lastName: lastName,
      department: 'Computer Science',
      yearOfStudy: 3,
    ),
  );
}

/// Helper to create test dashboard data
DashboardData createTestDashboardData() {
  return DashboardData(
    totalMeals: 34,
    monthlyGoal: 50,
    monthlyGoalProgress: 0.68,
    moneySaved: MoneySaved(
      thisMonth: 82.50,
      lastMonth: 70.00,
      trend: 0.18,
      breakdown: {
        'Meals': 45.00,
        'Drinks': 22.50,
        'Snacks': 15.00,
      },
    ),
    monthlyAverage: 12.3,
    percentile: 15,
    currentStreak: 5,
    nextPickup: NextPickup(
      location: 'Mensa Viadrina',
      time: DateTime.now().add(const Duration(hours: 2)),
    ),
    socialImpact: SocialImpact(
      studentsHelped: 156,
      avgMoneySavedPerStudent: 12.50,
    ),
  );
}
