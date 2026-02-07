import 'package:flutter_test/flutter_test.dart';
import 'package:foodbegood/features/auth/domain/entities/user_role.dart';

void main() {
  group('UserRole', () {
    test('should have correct enum values', () {
      // Assert
      expect(UserRole.values.length, equals(2));
      expect(UserRole.values, contains(UserRole.student));
      expect(UserRole.values, contains(UserRole.canteen));
    });

    group('UserRoleExtension', () {
      group('displayName', () {
        test('should return "Student" for UserRole.student', () {
          // Act & Assert
          expect(UserRole.student.displayName, equals('Student'));
        });

        test('should return "Canteen Staff" for UserRole.canteen', () {
          // Act & Assert
          expect(UserRole.canteen.displayName, equals('Canteen Staff'));
        });
      });

      group('homeRoute', () {
        test('should return "/student-dashboard" for UserRole.student', () {
          // Act & Assert
          expect(UserRole.student.homeRoute, equals('/student-dashboard'));
        });

        test('should return "/canteen-dashboard" for UserRole.canteen', () {
          // Act & Assert
          expect(UserRole.canteen.homeRoute, equals('/canteen-dashboard'));
        });
      });

      group('iconAsset', () {
        test('should return correct student icon path', () {
          // Act & Assert
          expect(
            UserRole.student.iconAsset,
            equals('assets/icons/student.svg'),
          );
        });

        test('should return correct canteen icon path', () {
          // Act & Assert
          expect(
            UserRole.canteen.iconAsset,
            equals('assets/icons/canteen.svg'),
          );
        });
      });
    });
  });
}
