import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodbegood/shared/services/mock_data_service.dart';

void main() {
  group('MockDataService', () {
    late MockDataService mockDataService;

    setUp(() {
      mockDataService = MockDataService();
    });

    group('Singleton Pattern', () {
      test('should return same instance', () {
        // Act
        final instance1 = MockDataService();
        final instance2 = MockDataService();

        // Assert
        expect(instance1, same(instance2));
      });
    });

    group('verifyPassword', () {
      test('should return true for correct password', () {
        // Arrange
        const password = 'password123';
        final hashedPassword = _hashPassword(password);

        // Act
        final result = mockDataService.verifyPassword(password, hashedPassword);

        // Assert
        expect(result, isTrue);
      });

      test('should return false for incorrect password', () {
        // Arrange
        const password = 'password123';
        const wrongPassword = 'wrongpassword';
        final hashedPassword = _hashPassword(password);

        // Act
        final result = mockDataService.verifyPassword(wrongPassword, hashedPassword);

        // Assert
        expect(result, isFalse);
      });

      test('should return false for empty password', () {
        // Arrange
        final hashedPassword = _hashPassword('password123');

        // Act
        final result = mockDataService.verifyPassword('', hashedPassword);

        // Assert
        expect(result, isFalse);
      });
    });

    group('getUserByStudentId', () {
      test('should return user for valid student ID', () {
        // Act
        final user = mockDataService.getUserByStudentId('61913042');

        // Assert
        expect(user, isNotNull);
        expect(user?.studentId, equals('61913042'));
        expect(user?.role, equals(UserRole.student));
        expect(user?.profile.firstName, equals('Zain'));
        expect(user?.profile.lastName, equals('Ul Ebad'));
      });

      test('should return user for canteen staff ID', () {
        // Act
        final user = mockDataService.getUserByStudentId('canteen001');

        // Assert
        expect(user, isNotNull);
        expect(user?.studentId, equals('canteen001'));
        expect(user?.role, equals(UserRole.canteen));
      });

      test('should be case insensitive', () {
        // Act
        final user = mockDataService.getUserByStudentId('61913042');
        final userUpper = mockDataService.getUserByStudentId('61913042'.toUpperCase());
        final userLower = mockDataService.getUserByStudentId('61913042'.toLowerCase());

        // Assert
        expect(user?.id, equals(userUpper?.id));
        expect(user?.id, equals(userLower?.id));
      });

      test('should return null for invalid student ID', () {
        // Act
        final user = mockDataService.getUserByStudentId('invalid_id');

        // Assert
        expect(user, isNull);
      });

      test('should return null for empty student ID', () {
        // Act
        final user = mockDataService.getUserByStudentId('');

        // Assert
        expect(user, isNull);
      });
    });

    group('getUserById', () {
      test('should return user for valid ID', () {
        // Act
        final user = mockDataService.getUserById('1');

        // Assert
        expect(user, isNotNull);
        expect(user?.id, equals('1'));
      });

      test('should return null for invalid ID', () {
        // Act
        final user = mockDataService.getUserById('999');

        // Assert
        expect(user, isNull);
      });
    });

    group('getDashboardForUser', () {
      test('should return DashboardData for any user ID', () {
        // Act
        final dashboard = mockDataService.getDashboardForUser('any_user_id');

        // Assert
        expect(dashboard, isNotNull);
        expect(dashboard.totalMeals, equals(34));
        expect(dashboard.monthlyGoal, equals(50));
        expect(dashboard.monthlyGoalProgress, equals(0.68));
      });

      test('should return correct money saved data', () {
        // Act
        final dashboard = mockDataService.getDashboardForUser('1');

        // Assert
        expect(dashboard.moneySaved.thisMonth, equals(82.50));
        expect(dashboard.moneySaved.lastMonth, equals(70.00));
        expect(dashboard.moneySaved.trend, equals(0.18));
        expect(dashboard.moneySaved.difference, equals(12.50));
      });

      test('should return correct money saved breakdown', () {
        // Act
        final dashboard = mockDataService.getDashboardForUser('1');

        // Assert
        expect(dashboard.moneySaved.breakdown.length, equals(3));
        expect(dashboard.moneySaved.breakdown['Meals'], equals(45.00));
        expect(dashboard.moneySaved.breakdown['Drinks'], equals(22.50));
        expect(dashboard.moneySaved.breakdown['Snacks'], equals(15.00));
      });

      test('should return correct percentile and streak', () {
        // Act
        final dashboard = mockDataService.getDashboardForUser('1');

        // Assert
        expect(dashboard.percentile, equals(15));
        expect(dashboard.currentStreak, equals(5));
      });

      test('should return next pickup data', () {
        // Act
        final dashboard = mockDataService.getDashboardForUser('1');

        // Assert
        expect(dashboard.nextPickup, isNotNull);
        expect(dashboard.nextPickup?.location, equals('Mensa Viadrina'));
        expect(dashboard.nextPickup?.time.isAfter(DateTime.now()), isTrue);
      });

      test('should return social impact data', () {
        // Act
        final dashboard = mockDataService.getDashboardForUser('1');

        // Assert
        expect(dashboard.socialImpact.studentsHelped, equals(156));
        expect(dashboard.socialImpact.avgMoneySavedPerStudent, equals(12.50));
      });
    });

    group('getCanteenDashboard', () {
      test('should return CanteenDashboard with correct metrics', () {
        // Act
        final dashboard = mockDataService.getCanteenDashboard();

        // Assert
        expect(dashboard.totalMealsSaved, equals(1247));
        expect(dashboard.dailyAverage, equals(89));
        expect(dashboard.weeklyTotal, equals(342));
        expect(dashboard.monthlyTrend, equals(0.23));
      });

      test('should return waste and savings metrics', () {
        // Act
        final dashboard = mockDataService.getCanteenDashboard();

        // Assert
        expect(dashboard.foodWastePrevented, equals(428));
        expect(dashboard.wasteReduction, equals(-0.15));
        expect(dashboard.canteenSavings, equals(3142.00));
      });

      test('should return student metrics', () {
        // Act
        final dashboard = mockDataService.getCanteenDashboard();

        // Assert
        expect(dashboard.studentsHelped, equals(287));
        expect(dashboard.studentsTrend, equals(0.08));
        expect(dashboard.studentSavingsTotal, equals(4235.00));
      });

      test('should return urgent requests count', () {
        // Act
        final dashboard = mockDataService.getCanteenDashboard();

        // Assert
        expect(dashboard.urgentRequests, equals(3));
      });
    });

    group('getFoodCategories', () {
      test('should return list of 6 food categories', () {
        // Act
        final categories = mockDataService.getFoodCategories();

        // Assert
        expect(categories.length, equals(6));
      });

      test('should return unmodifiable list', () {
        // Act
        final categories = mockDataService.getFoodCategories();

        // Assert
        expect(() => categories.add(categories.first), throwsUnsupportedError);
      });

      test('should contain expected categories', () {
        // Act
        final categories = mockDataService.getFoodCategories();

        // Assert
        final names = categories.map((c) => c.name).toList();
        expect(names, contains('Salad'));
        expect(names, contains('Dessert'));
        expect(names, contains('Side'));
        expect(names, contains('Chicken'));
        expect(names, contains('Fish'));
        expect(names, contains('Veggie'));
      });

      test('should have correct food category properties', () {
        // Act
        final categories = mockDataService.getFoodCategories();
        final salad = categories.firstWhere((c) => c.id == 'salad');

        // Assert
        expect(salad.name, equals('Salad'));
        expect(salad.icon, equals('🥗'));
        expect(salad.color, equals('#10B981'));
        expect(salad.maxPerPickup, equals(1));
      });
    });

    group('getMealHistory', () {
      test('should return list of meal history entries', () {
        // Act
        final history = mockDataService.getMealHistory('any_user_id');

        // Assert
        expect(history.length, equals(3));
      });

      test('should have correct meal history structure', () {
        // Act
        final history = mockDataService.getMealHistory('1');
        final firstEntry = history.first;

        // Assert
        expect(firstEntry.containsKey('id'), isTrue);
        expect(firstEntry.containsKey('date'), isTrue);
        expect(firstEntry.containsKey('items'), isTrue);
        expect(firstEntry.containsKey('totalValue'), isTrue);
      });

      test('should return items as list of strings', () {
        // Act
        final history = mockDataService.getMealHistory('1');
        final firstEntry = history.first;

        // Assert
        expect(firstEntry['items'], isA<List>());
      });
    });

    group('generateQRCodeData', () {
      test('should generate base64 encoded data', () {
        // Act
        final qrData = mockDataService.generateQRCodeData('pickup_123');

        // Assert
        expect(() => base64Decode(qrData), returnsNormally);
      });

      test('should generate valid JSON when decoded', () {
        // Act
        final qrData = mockDataService.generateQRCodeData('pickup_123');
        final decoded = utf8.decode(base64Decode(qrData));
        final json = jsonDecode(decoded) as Map<String, dynamic>;

        // Assert
        expect(json['pickupId'], equals('pickup_123'));
        expect(json.containsKey('timestamp'), isTrue);
        expect(json.containsKey('expiresAt'), isTrue);
      });

      test('should have expiration time 5 minutes after timestamp', () {
        // Act
        final qrData = mockDataService.generateQRCodeData('pickup_123');
        final decoded = utf8.decode(base64Decode(qrData));
        final json = jsonDecode(decoded) as Map<String, dynamic>;

        final timestamp = DateTime.parse(json['timestamp'] as String);
        final expiresAt = DateTime.parse(json['expiresAt'] as String);

        // Assert
        final difference = expiresAt.difference(timestamp);
        expect(difference.inMinutes, equals(5));
      });

      test('should generate different data for different pickup IDs', () {
        // Act
        final qrData1 = mockDataService.generateQRCodeData('pickup_1');
        final qrData2 = mockDataService.generateQRCodeData('pickup_2');

        // Assert
        expect(qrData1, isNot(equals(qrData2)));
      });
    });
  });
}

// Helper function to hash password (same logic as MockDataService)
String _hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
