import 'package:flutter_test/flutter_test.dart';
import 'package:foodbegood/core/errors/failures.dart';

void main() {
  group('Failure', () {
    test('should be abstract and equatable', () {
      // Arrange
      const failure1 = ServerFailure('test message', code: 'TEST_CODE');
      const failure2 = ServerFailure('test message', code: 'TEST_CODE');
      const failure3 = ServerFailure('different message', code: 'TEST_CODE');

      // Assert
      expect(failure1, equals(failure2));
      expect(failure1, isNot(equals(failure3)));
    });

    test('should store message and code', () {
      // Arrange
      const message = 'Something went wrong';
      const code = 'ERROR_001';

      // Act
      const failure = ServerFailure(message, code: code);

      // Assert
      expect(failure.message, equals(message));
      expect(failure.code, equals(code));
    });
  });

  group('ServerFailure', () {
    test('should create ServerFailure with message and code', () {
      // Arrange
      const message = 'Server error occurred';
      const code = '500';

      // Act
      const failure = ServerFailure(message, code: code);

      // Assert
      expect(failure.message, equals(message));
      expect(failure.code, equals(code));
      expect(failure, isA<Failure>());
    });

    test('should create ServerFailure without code', () {
      // Act
      const failure = ServerFailure('Server error');

      // Assert
      expect(failure.code, isNull);
    });
  });

  group('CacheFailure', () {
    test('should create CacheFailure with message and code', () {
      // Arrange
      const message = 'Cache miss';
      const code = 'CACHE_001';

      // Act
      const failure = CacheFailure(message, code: code);

      // Assert
      expect(failure.message, equals(message));
      expect(failure.code, equals(code));
      expect(failure, isA<Failure>());
    });
  });

  group('AuthFailure', () {
    test('should create AuthFailure with message and code', () {
      // Arrange
      const message = 'Authentication failed';
      const code = 'AUTH_001';

      // Act
      const failure = AuthFailure(message, code: code);

      // Assert
      expect(failure.message, equals(message));
      expect(failure.code, equals(code));
      expect(failure, isA<Failure>());
    });

    group('factory constructors', () {
      test('userNotFound should create correct failure', () {
        // Act
        final failure = AuthFailure.userNotFound();

        // Assert
        expect(failure.message, equals('User not found'));
        expect(failure.code, equals('USER_NOT_FOUND'));
      });

      test('invalidCredentials should create correct failure', () {
        // Act
        final failure = AuthFailure.invalidCredentials();

        // Assert
        expect(failure.message, equals('Invalid credentials'));
        expect(failure.code, equals('INVALID_CREDENTIALS'));
      });

      test('invalidToken should create correct failure', () {
        // Act
        final failure = AuthFailure.invalidToken();

        // Assert
        expect(failure.message, equals('Invalid token'));
        expect(failure.code, equals('INVALID_TOKEN'));
      });

      test('sessionExpired should create correct failure', () {
        // Act
        final failure = AuthFailure.sessionExpired();

        // Assert
        expect(failure.message, equals('Session expired'));
        expect(failure.code, equals('SESSION_EXPIRED'));
      });

      test('unknown should create failure with error message', () {
        // Arrange
        const error = 'Unknown error occurred';

        // Act
        final failure = AuthFailure.unknown(error);

        // Assert
        expect(failure.message, equals('Authentication error: $error'));
        expect(failure.code, equals('AUTH_ERROR'));
      });
    });
  });

  group('ValidationFailure', () {
    test('should create ValidationFailure with message and errors map', () {
      // Arrange
      const message = 'Validation failed';
      final errors = {
        'email': 'Invalid email format',
        'password': 'Password too short',
      };

      // Act
      final failure = ValidationFailure(message, errors: errors);

      // Assert
      expect(failure.message, equals(message));
      expect(failure.errors, equals(errors));
      expect(failure, isA<Failure>());
    });

    test('should be equatable with errors', () {
      // Arrange
      final errors = {'field': 'error'};
      final failure1 = ValidationFailure('message', errors: errors);
      final failure2 = ValidationFailure('message', errors: errors);
      final failure3 = ValidationFailure('message', errors: {'field': 'different'});

      // Assert
      expect(failure1, equals(failure2));
      expect(failure1, isNot(equals(failure3)));
    });
  });

  group('NetworkFailure', () {
    test('should create NetworkFailure with message', () {
      // Act
      const failure = NetworkFailure('Network connection lost');

      // Assert
      expect(failure.message, equals('Network connection lost'));
      expect(failure, isA<Failure>());
    });
  });

  group('PermissionFailure', () {
    test('should create PermissionFailure with message', () {
      // Act
      const failure = PermissionFailure('Permission denied');

      // Assert
      expect(failure.message, equals('Permission denied'));
      expect(failure, isA<Failure>());
    });
  });
}
