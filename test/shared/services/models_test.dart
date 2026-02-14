import 'package:flutter_test/flutter_test.dart';
import 'package:foodbegood/shared/services/mock_data_service.dart';

void main() {
  group('User Model', () {
    test('should create User with all properties', () {
      // Arrange
      const id = '123';
      const studentId = '61913042';
      const passwordHash = 'hashed_password';
      const role = UserRole.student;
      final profile = Profile(
        firstName: 'John',
        lastName: 'Doe',
        department: 'CS',
        yearOfStudy: 3,
      );

      // Act
      final user = User(
        id: id,
        studentId: studentId,
        passwordHash: passwordHash,
        role: role,
        profile: profile,
      );

      // Assert
      expect(user.id, equals(id));
      expect(user.studentId, equals(studentId));
      expect(user.passwordHash, equals(passwordHash));
      expect(user.role, equals(role));
      expect(user.profile, equals(profile));
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        // Arrange
        final user = User(
          id: '123',
          studentId: '61913042',
          passwordHash: 'hash123',
          role: UserRole.student,
          profile: Profile(
            firstName: 'John',
            lastName: 'Doe',
          ),
        );

        // Act
        final json = user.toJson();

        // Assert
        expect(json['id'], equals('123'));
        expect(json['studentId'], equals('61913042'));
        expect(json['passwordHash'], equals('hash123'));
        expect(json['role'], equals('student'));
        expect(json['profile'], isA<Map>());
      });

      test('should deserialize from JSON correctly', () {
        // Arrange
        final json = {
          'id': '123',
          'studentId': '61913042',
          'passwordHash': 'hash123',
          'role': 'student',
          'profile': {
            'firstName': 'John',
            'lastName': 'Doe',
            'photoPath': null,
            'department': null,
            'yearOfStudy': null,
          },
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.id, equals('123'));
        expect(user.studentId, equals('61913042'));
        expect(user.role, equals(UserRole.student));
        expect(user.profile.firstName, equals('John'));
      });

      test('should handle canteen role in JSON', () {
        // Arrange
        final json = {
          'id': '456',
          'studentId': 'canteen001',
          'passwordHash': 'hash456',
          'role': 'canteen',
          'profile': {
            'firstName': 'Staff',
            'lastName': 'Member',
            'photoPath': null,
            'department': null,
            'yearOfStudy': null,
          },
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.role, equals(UserRole.canteen));
      });

      test('should default to student for unknown role', () {
        // Arrange
        final json = {
          'id': '789',
          'studentId': 'test',
          'passwordHash': 'hash',
          'role': 'unknown_role',
          'profile': {
            'firstName': 'Test',
            'lastName': 'User',
            'photoPath': null,
            'department': null,
            'yearOfStudy': null,
          },
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.role, equals(UserRole.student));
      });

      test('round-trip serialization should preserve data', () {
        // Arrange
        final original = User(
          id: '123',
          studentId: '61913042',
          passwordHash: 'hash',
          role: UserRole.student,
          profile: Profile(
            firstName: 'John',
            lastName: 'Doe',
            department: 'CS',
            yearOfStudy: 3,
          ),
        );

        // Act
        final json = original.toJson();
        final restored = User.fromJson(json);

        // Assert
        expect(restored.id, equals(original.id));
        expect(restored.studentId, equals(original.studentId));
        expect(restored.role, equals(original.role));
        expect(restored.profile.fullName, equals(original.profile.fullName));
      });
    });
  });

  group('Profile Model', () {
    test('should create Profile with required fields', () {
      // Act
      final profile = Profile(
        firstName: 'John',
        lastName: 'Doe',
      );

      // Assert
      expect(profile.firstName, equals('John'));
      expect(profile.lastName, equals('Doe'));
      expect(profile.photoPath, isNull);
      expect(profile.department, isNull);
      expect(profile.yearOfStudy, isNull);
    });

    test('should create Profile with all fields', () {
      // Act
      final profile = Profile(
        firstName: 'Jane',
        lastName: 'Smith',
        photoPath: '/path/to/photo.jpg',
        department: 'Computer Science',
        yearOfStudy: 4,
      );

      // Assert
      expect(profile.photoPath, equals('/path/to/photo.jpg'));
      expect(profile.department, equals('Computer Science'));
      expect(profile.yearOfStudy, equals(4));
    });

    test('fullName should return concatenated name', () {
      // Arrange
      final profile = Profile(
        firstName: 'John',
        lastName: 'Doe',
      );

      // Act & Assert
      expect(profile.fullName, equals('John Doe'));
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        // Arrange
        final profile = Profile(
          firstName: 'John',
          lastName: 'Doe',
          department: 'CS',
          yearOfStudy: 3,
        );

        // Act
        final json = profile.toJson();

        // Assert
        expect(json['firstName'], equals('John'));
        expect(json['lastName'], equals('Doe'));
        expect(json['department'], equals('CS'));
        expect(json['yearOfStudy'], equals(3));
        expect(json['photoPath'], isNull);
      });

      test('should deserialize from JSON correctly', () {
        // Arrange
        final json = {
          'firstName': 'Jane',
          'lastName': 'Smith',
          'photoPath': '/photo.jpg',
          'department': 'Business',
          'yearOfStudy': 2,
        };

        // Act
        final profile = Profile.fromJson(json);

        // Assert
        expect(profile.firstName, equals('Jane'));
        expect(profile.lastName, equals('Smith'));
        expect(profile.photoPath, equals('/photo.jpg'));
        expect(profile.department, equals('Business'));
        expect(profile.yearOfStudy, equals(2));
      });

      test('round-trip serialization should preserve data', () {
        // Arrange
        final original = Profile(
          firstName: 'Test',
          lastName: 'User',
          photoPath: '/path.jpg',
          department: 'Test Dept',
          yearOfStudy: 1,
        );

        // Act
        final json = original.toJson();
        final restored = Profile.fromJson(json);

        // Assert
        expect(restored.firstName, equals(original.firstName));
        expect(restored.lastName, equals(original.lastName));
        expect(restored.photoPath, equals(original.photoPath));
        expect(restored.department, equals(original.department));
        expect(restored.yearOfStudy, equals(original.yearOfStudy));
      });
    });
  });

  group('DashboardData Model', () {
    test('should create DashboardData with all properties', () {
      // Act
      final dashboard = DashboardData(
        totalMeals: 34,
        monthlyGoal: 50,
        monthlyGoalProgress: 0.68,
        moneySaved: MoneySaved(
          thisMonth: 82.50,
          lastMonth: 70.00,
          trend: 0.18,
          breakdown: {'Meals': 45.00},
        ),
        monthlyAverage: 12.3,
        percentile: 15,
        currentStreak: 5,
        socialImpact: SocialImpact(
          studentsHelped: 156,
          avgMoneySavedPerStudent: 12.50,
        ),
      );

      // Assert
      expect(dashboard.totalMeals, equals(34));
      expect(dashboard.monthlyGoalProgress, equals(0.68));
      expect(dashboard.nextPickup, isNull);
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        // Arrange
        final dashboard = DashboardData(
          totalMeals: 34,
          monthlyGoal: 50,
          monthlyGoalProgress: 0.68,
          moneySaved: MoneySaved(
            thisMonth: 82.50,
            lastMonth: 70.00,
            trend: 0.18,
            breakdown: {'Meals': 45.00},
          ),
          monthlyAverage: 12.3,
          percentile: 15,
          currentStreak: 5,
          nextPickup: NextPickup(
            location: 'Mensa',
            time: DateTime(2025, 2, 6, 12, 0),
          ),
          socialImpact: SocialImpact(
            studentsHelped: 156,
            avgMoneySavedPerStudent: 12.50,
          ),
        );

        // Act
        final json = dashboard.toJson();

        // Assert
        expect(json['totalMeals'], equals(34));
        expect(json['moneySaved'], isA<Map>());
        expect(json['nextPickup'], isA<Map>());
        expect(json['socialImpact'], isA<Map>());
      });

      test('should deserialize from JSON correctly', () {
        // Arrange
        final json = {
          'totalMeals': 34,
          'monthlyGoal': 50,
          'monthlyGoalProgress': 0.68,
          'moneySaved': {
            'thisMonth': 82.50,
            'lastMonth': 70.00,
            'trend': 0.18,
            'breakdown': {'Meals': 45.00},
          },
          'monthlyAverage': 12.3,
          'percentile': 15,
          'currentStreak': 5,
          'nextPickup': null,
          'socialImpact': {
            'studentsHelped': 156,
            'avgMoneySavedPerStudent': 12.50,
          },
        };

        // Act
        final dashboard = DashboardData.fromJson(json);

        // Assert
        expect(dashboard.totalMeals, equals(34));
        expect(dashboard.moneySaved.thisMonth, equals(82.50));
        expect(dashboard.nextPickup, isNull);
      });

      test('round-trip serialization should preserve data', () {
        // Arrange
        final original = DashboardData(
          totalMeals: 34,
          monthlyGoal: 50,
          monthlyGoalProgress: 0.68,
          moneySaved: MoneySaved(
            thisMonth: 82.50,
            lastMonth: 70.00,
            trend: 0.18,
            breakdown: {'Meals': 45.00, 'Drinks': 22.50},
          ),
          monthlyAverage: 12.3,
          percentile: 15,
          currentStreak: 5,
          nextPickup: NextPickup(
            location: 'Mensa Viadrina',
            time: DateTime(2025, 2, 6, 14, 30),
          ),
          socialImpact: SocialImpact(
            studentsHelped: 156,
            avgMoneySavedPerStudent: 12.50,
          ),
        );

        // Act
        final json = original.toJson();
        final restored = DashboardData.fromJson(json);

        // Assert
        expect(restored.totalMeals, equals(original.totalMeals));
        expect(restored.moneySaved.thisMonth,
            equals(original.moneySaved.thisMonth));
        expect(restored.nextPickup?.location,
            equals(original.nextPickup?.location));
      });
    });
  });

  group('MoneySaved Model', () {
    test('should calculate difference correctly', () {
      // Arrange
      final moneySaved = MoneySaved(
        thisMonth: 100.0,
        lastMonth: 80.0,
        trend: 0.25,
        breakdown: {},
      );

      // Act & Assert
      expect(moneySaved.difference, equals(20.0));
    });

    test('should handle negative difference', () {
      // Arrange
      final moneySaved = MoneySaved(
        thisMonth: 70.0,
        lastMonth: 100.0,
        trend: -0.30,
        breakdown: {},
      );

      // Act & Assert
      expect(moneySaved.difference, equals(-30.0));
    });

    group('JSON Serialization', () {
      test('should serialize and deserialize correctly', () {
        // Arrange
        final original = MoneySaved(
          thisMonth: 82.50,
          lastMonth: 70.00,
          trend: 0.18,
          breakdown: {'Meals': 45.00, 'Drinks': 22.50, 'Snacks': 15.00},
        );

        // Act
        final json = original.toJson();
        final restored = MoneySaved.fromJson(json);

        // Assert
        expect(restored.thisMonth, equals(original.thisMonth));
        expect(restored.lastMonth, equals(original.lastMonth));
        expect(restored.trend, equals(original.trend));
        expect(restored.breakdown, equals(original.breakdown));
      });
    });
  });

  group('NextPickup Model', () {
    test('should format time difference correctly for hours and minutes', () {
      // Arrange
      final pickup = NextPickup(
        location: 'Mensa',
        time: DateTime.now().add(const Duration(hours: 2, minutes: 30)),
      );

      // Act
      final formatted = pickup.formattedTime;

      // Assert
      expect(formatted, contains('h'));
      expect(formatted, contains('m'));
    });

    test('should format time difference correctly for days', () {
      // Arrange
      final pickup = NextPickup(
        location: 'Mensa',
        time: DateTime.now().add(const Duration(days: 1, hours: 5)),
      );

      // Act
      final formatted = pickup.formattedTime;

      // Assert
      expect(formatted, contains('d'));
    });

    test('should format time difference correctly for minutes only', () {
      // Arrange
      final pickup = NextPickup(
        location: 'Mensa',
        time: DateTime.now().add(const Duration(minutes: 45)),
      );

      // Act
      final formatted = pickup.formattedTime;

      // Assert
      expect(formatted, contains('m'));
      expect(formatted, isNot(contains('h')));
    });

    group('JSON Serialization', () {
      test('should serialize and deserialize correctly', () {
        // Arrange
        final time = DateTime(2025, 2, 6, 14, 30);
        final original = NextPickup(
          location: 'Mensa Viadrina',
          time: time,
        );

        // Act
        final json = original.toJson();
        final restored = NextPickup.fromJson(json);

        // Assert
        expect(restored.location, equals(original.location));
        expect(restored.time, equals(time));
      });
    });
  });

  group('SocialImpact Model', () {
    group('JSON Serialization', () {
      test('should serialize and deserialize correctly', () {
        // Arrange
        final original = SocialImpact(
          studentsHelped: 156,
          avgMoneySavedPerStudent: 12.50,
        );

        // Act
        final json = original.toJson();
        final restored = SocialImpact.fromJson(json);

        // Assert
        expect(restored.studentsHelped, equals(original.studentsHelped));
        expect(
          restored.avgMoneySavedPerStudent,
          equals(original.avgMoneySavedPerStudent),
        );
      });
    });
  });

  group('CanteenDashboard Model', () {
    test('should create CanteenDashboard with all properties', () {
      // Act
      final dashboard = CanteenDashboard(
        totalMealsSaved: 1247,
        dailyAverage: 89,
        weeklyTotal: 342,
        monthlyTrend: 0.23,
        foodWastePrevented: 428,
        wasteReduction: -0.15,
        canteenSavings: 3142.00,
        studentsHelped: 287,
        studentsTrend: 0.08,
        studentSavingsTotal: 4235.00,
        urgentRequests: 3,
      );

      // Assert
      expect(dashboard.totalMealsSaved, equals(1247));
      expect(dashboard.urgentRequests, equals(3));
    });

    group('JSON Serialization', () {
      test('should serialize and deserialize correctly', () {
        // Arrange
        final original = CanteenDashboard(
          totalMealsSaved: 1247,
          dailyAverage: 89,
          weeklyTotal: 342,
          monthlyTrend: 0.23,
          foodWastePrevented: 428,
          wasteReduction: -0.15,
          canteenSavings: 3142.00,
          studentsHelped: 287,
          studentsTrend: 0.08,
          studentSavingsTotal: 4235.00,
          urgentRequests: 3,
        );

        // Act
        final json = original.toJson();
        final restored = CanteenDashboard.fromJson(json);

        // Assert
        expect(restored.totalMealsSaved, equals(original.totalMealsSaved));
        expect(restored.canteenSavings, equals(original.canteenSavings));
        expect(restored.urgentRequests, equals(original.urgentRequests));
      });
    });
  });

  group('FoodCategory Model', () {
    test('should create FoodCategory with all properties', () {
      // Act
      final category = FoodCategory(
        id: 'salad',
        name: 'Salad',
        icon: '🥗',
        color: '#10B981',
        maxPerPickup: 1,
      );

      // Assert
      expect(category.id, equals('salad'));
      expect(category.name, equals('Salad'));
      expect(category.icon, equals('🥗'));
      expect(category.color, equals('#10B981'));
      expect(category.maxPerPickup, equals(1));
    });
  });
}
