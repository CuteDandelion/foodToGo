import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:foodbegood/config/constants.dart';
import 'package:foodbegood/core/storage/storage_manager.dart';
import 'package:foodbegood/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:foodbegood/shared/services/mock_data_service.dart';

class MockMockDataService extends Mock implements MockDataService {}

class MockStorageManager extends Mock implements StorageManager {}

class MockSharedPrefsStorage extends Mock implements SharedPrefsStorage {}

/// Edge Case Tests for AuthBloc
/// 
/// These tests cover boundary conditions, error scenarios, and
/// unusual but possible situations that the auth system should handle.
void main() {
  group('AuthBloc Edge Cases', () {
    late AuthBloc authBloc;
    late MockMockDataService mockDataService;
    late MockStorageManager mockStorage;
    late MockSharedPrefsStorage mockPrefs;

    setUp(() {
      mockDataService = MockMockDataService();
      mockStorage = MockStorageManager();
      mockPrefs = MockSharedPrefsStorage();

      when(() => mockStorage.prefs).thenReturn(mockPrefs);

      authBloc = AuthBloc(
        mockDataService: mockDataService,
        storage: mockStorage,
      );
    });

    tearDown(() {
      authBloc.close();
    });

    group('Edge Case: Empty and Null Inputs', () {
      blocTest<AuthBloc, AuthState>(
        'handles empty student ID',
        setUp: () {
          when(() => mockDataService.getUserByStudentId(''))
              .thenReturn(null);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          studentId: '',
          password: 'password123',
        )),
        expect: () => [
          AuthLoading(),
          const AuthError('User not found'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'handles empty password',
        setUp: () {
          final testUser = User(
            id: '1',
            studentId: '61913042',
            passwordHash: 'hashed_password',
            role: UserRole.student,
            profile: Profile(firstName: 'Test', lastName: 'User'),
          );
          when(() => mockDataService.getUserByStudentId('61913042'))
              .thenReturn(testUser);
          when(() => mockDataService.verifyPassword('', any()))
              .thenReturn(false);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          studentId: '61913042',
          password: '',
        )),
        expect: () => [
          AuthLoading(),
          const AuthError('Invalid password'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'handles both empty student ID and password',
        setUp: () {
          when(() => mockDataService.getUserByStudentId(''))
              .thenReturn(null);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          studentId: '',
          password: '',
        )),
        expect: () => [
          AuthLoading(),
          const AuthError('User not found'),
        ],
      );
    });

    group('Edge Case: Special Characters and Injection', () {
      blocTest<AuthBloc, AuthState>(
        'handles SQL injection attempt in student ID',
        setUp: () {
          when(() => mockDataService.getUserByStudentId("'; DROP TABLE users; --"))
              .thenReturn(null);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          studentId: "'; DROP TABLE users; --",
          password: 'password123',
        )),
        expect: () => [
          AuthLoading(),
          const AuthError('User not found'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'handles special characters in student ID',
        setUp: () {
          when(() => mockDataService.getUserByStudentId('61913042@#\$%'))
              .thenReturn(null);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          studentId: '61913042@#\$%',
          password: 'password123',
        )),
        expect: () => [
          AuthLoading(),
          const AuthError('User not found'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'handles XSS attempt in password',
        setUp: () {
          final testUser = User(
            id: '1',
            studentId: '61913042',
            passwordHash: 'hashed_password',
            role: UserRole.student,
            profile: Profile(firstName: 'Test', lastName: 'User'),
          );
          when(() => mockDataService.getUserByStudentId('61913042'))
              .thenReturn(testUser);
          when(() => mockDataService.verifyPassword('<script>alert("xss")</script>', any()))
              .thenReturn(false);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          studentId: '61913042',
          password: '<script>alert("xss")</script>',
        )),
        expect: () => [
          AuthLoading(),
          const AuthError('Invalid password'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'handles very long student ID (1000 chars)',
        setUp: () {
          final longId = '1' * 1000;
          when(() => mockDataService.getUserByStudentId(longId))
              .thenReturn(null);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(AuthLoginRequested(
          studentId: '1' * 1000,
          password: 'password123',
        )),
        expect: () => [
          AuthLoading(),
          const AuthError('User not found'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'handles very long password (1000 chars)',
        setUp: () {
          final testUser = User(
            id: '1',
            studentId: '61913042',
            passwordHash: 'hashed_password',
            role: UserRole.student,
            profile: Profile(firstName: 'Test', lastName: 'User'),
          );
          when(() => mockDataService.getUserByStudentId('61913042'))
              .thenReturn(testUser);
          when(() => mockDataService.verifyPassword('a' * 1000, any()))
              .thenReturn(false);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(AuthLoginRequested(
          studentId: '61913042',
          password: 'a' * 1000,
        )),
        expect: () => [
          AuthLoading(),
          const AuthError('Invalid password'),
        ],
      );
    });

    group('Edge Case: Whitespace Handling', () {
      blocTest<AuthBloc, AuthState>(
        'handles leading whitespace in student ID',
        setUp: () {
          when(() => mockDataService.getUserByStudentId(' 61913042'))
              .thenReturn(null);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          studentId: ' 61913042',
          password: 'password123',
        )),
        expect: () => [
          AuthLoading(),
          const AuthError('User not found'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'handles trailing whitespace in student ID',
        setUp: () {
          when(() => mockDataService.getUserByStudentId('61913042 '))
              .thenReturn(null);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          studentId: '61913042 ',
          password: 'password123',
        )),
        expect: () => [
          AuthLoading(),
          const AuthError('User not found'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'handles password with whitespace',
        setUp: () {
          final testUser = User(
            id: '1',
            studentId: '61913042',
            passwordHash: 'hashed_password',
            role: UserRole.student,
            profile: Profile(firstName: 'Test', lastName: 'User'),
          );
          when(() => mockDataService.getUserByStudentId('61913042'))
              .thenReturn(testUser);
          when(() => mockDataService.verifyPassword(' password123 ', any()))
              .thenReturn(false);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          studentId: '61913042',
          password: ' password123 ',
        )),
        expect: () => [
          AuthLoading(),
          const AuthError('Invalid password'),
        ],
      );
    });

    group('Edge Case: Unicode and Internationalization', () {
      blocTest<AuthBloc, AuthState>(
        'handles unicode characters in student ID',
        setUp: () {
          when(() => mockDataService.getUserByStudentId('学生61913042'))
              .thenReturn(null);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          studentId: '学生61913042',
          password: 'password123',
        )),
        expect: () => [
          AuthLoading(),
          const AuthError('User not found'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'handles emoji in password',
        setUp: () {
          final testUser = User(
            id: '1',
            studentId: '61913042',
            passwordHash: 'hashed_password',
            role: UserRole.student,
            profile: Profile(firstName: 'Test', lastName: 'User'),
          );
          when(() => mockDataService.getUserByStudentId('61913042'))
              .thenReturn(testUser);
          when(() => mockDataService.verifyPassword('password🔐123', any()))
              .thenReturn(false);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          studentId: '61913042',
          password: 'password🔐123',
        )),
        expect: () => [
          AuthLoading(),
          const AuthError('Invalid password'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'handles RTL characters',
        setUp: () {
          when(() => mockDataService.getUserByStudentId('٦١٩١٣٠٤٢'))
              .thenReturn(null);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          studentId: '٦١٩١٣٠٤٢',
          password: 'password123',
        )),
        expect: () => [
          AuthLoading(),
          const AuthError('User not found'),
        ],
      );
    });

    group('Edge Case: Storage Failures', () {
      blocTest<AuthBloc, AuthState>(
        'handles storage write failure during login',
        setUp: () {
          final testUser = User(
            id: '1',
            studentId: '61913042',
            passwordHash: 'hashed_password',
            role: UserRole.student,
            profile: Profile(firstName: 'Test', lastName: 'User'),
          );
          when(() => mockDataService.getUserByStudentId('61913042'))
              .thenReturn(testUser);
          when(() => mockDataService.verifyPassword('password123', any()))
              .thenReturn(true);
          when(() => mockPrefs.setString(any(), any()))
              .thenThrow(Exception('Storage write failed'));
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          studentId: '61913042',
          password: 'password123',
        )),
        expect: () => [
          AuthLoading(),
          isA<AuthError>().having(
            (e) => e.message,
            'message',
            contains('Storage write failed'),
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'handles storage read failure during session check',
        setUp: () {
          when(() => mockPrefs.getString(AppConstants.storageKeyUserId))
              .thenThrow(Exception('Storage read failed'));
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [AuthUnauthenticated()],
      );


    });

    group('Edge Case: Rapid Operations', () {
      blocTest<AuthBloc, AuthState>(
        'handles rapid login attempts',
        setUp: () {
          final testUser = User(
            id: '1',
            studentId: '61913042',
            passwordHash: 'hashed_password',
            role: UserRole.student,
            profile: Profile(firstName: 'Test', lastName: 'User'),
          );
          when(() => mockDataService.getUserByStudentId('61913042'))
              .thenReturn(testUser);
          when(() => mockDataService.verifyPassword('password123', any()))
              .thenReturn(true);
          when(() => mockPrefs.setString(any(), any()))
              .thenAnswer((_) async => {});
        },
        build: () => authBloc,
        act: (bloc) async {
          // Fire multiple login requests rapidly
          bloc.add(const AuthLoginRequested(
            studentId: '61913042',
            password: 'password123',
          ));
          bloc.add(const AuthLoginRequested(
            studentId: '61913042',
            password: 'password123',
          ));
          bloc.add(const AuthLoginRequested(
            studentId: '61913042',
            password: 'password123',
          ));
        },
        wait: const Duration(milliseconds: 100),
        expect: () => [
          AuthLoading(),
          const AuthAuthenticated(userId: '1', role: UserRole.student),
          AuthLoading(),
          const AuthAuthenticated(userId: '1', role: UserRole.student),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'handles login during logout',
        setUp: () {
          final testUser = User(
            id: '1',
            studentId: '61913042',
            passwordHash: 'hashed_password',
            role: UserRole.student,
            profile: Profile(firstName: 'Test', lastName: 'User'),
          );
          when(() => mockDataService.getUserByStudentId('61913042'))
              .thenReturn(testUser);
          when(() => mockDataService.verifyPassword('password123', any()))
              .thenReturn(true);
          when(() => mockPrefs.setString(any(), any()))
              .thenAnswer((_) async => {});
          when(() => mockPrefs.remove(any()))
              .thenAnswer((_) async => {});
        },
        build: () => authBloc,
        seed: () => const AuthAuthenticated(
          userId: '1',
          role: UserRole.student,
        ),
        act: (bloc) async {
          bloc.add(AuthLogoutRequested());
          bloc.add(const AuthLoginRequested(
            studentId: '61913042',
            password: 'password123',
          ));
        },
        wait: const Duration(milliseconds: 100),
        expect: () => [
          AuthLoading(),
          AuthUnauthenticated(),
          const AuthAuthenticated(userId: '1', role: UserRole.student),
        ],
      );
    });

    group('Edge Case: User Role Variations', () {
      blocTest<AuthBloc, AuthState>(
        'handles canteen staff login',
        setUp: () {
          final canteenUser = User(
            id: '3',
            studentId: 'canteen001',
            passwordHash: 'hashed_password',
            role: UserRole.canteen,
            profile: Profile(firstName: 'John', lastName: 'Smith'),
          );
          when(() => mockDataService.getUserByStudentId('canteen001'))
              .thenReturn(canteenUser);
          when(() => mockDataService.verifyPassword('canteen123', any()))
              .thenReturn(true);
          when(() => mockPrefs.setString(any(), any()))
              .thenAnswer((_) async => {});
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          studentId: 'canteen001',
          password: 'canteen123',
        )),
        expect: () => [
          AuthLoading(),
          const AuthAuthenticated(userId: '3', role: UserRole.canteen),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'handles user with null profile fields',
        setUp: () {
          final userWithNullProfile = User(
            id: '4',
            studentId: '61913044',
            passwordHash: 'hashed_password',
            role: UserRole.student,
            profile: Profile(
              firstName: '',
              lastName: '',
              photoPath: null,
              department: null,
              yearOfStudy: null,
            ),
          );
          when(() => mockDataService.getUserByStudentId('61913044'))
              .thenReturn(userWithNullProfile);
          when(() => mockDataService.verifyPassword('password123', any()))
              .thenReturn(true);
          when(() => mockPrefs.setString(any(), any()))
              .thenAnswer((_) async => {});
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          studentId: '61913044',
          password: 'password123',
        )),
        expect: () => [
          AuthLoading(),
          const AuthAuthenticated(userId: '4', role: UserRole.student),
        ],
      );
    });

    group('Edge Case: Session Edge Cases', () {
      blocTest<AuthBloc, AuthState>(
        'handles session check with empty string userId',
        setUp: () {
          when(() => mockPrefs.getString(AppConstants.storageKeyUserId))
              .thenAnswer((_) async => '');
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [AuthUnauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'handles session check with whitespace userId',
        setUp: () {
          when(() => mockPrefs.getString(AppConstants.storageKeyUserId))
              .thenAnswer((_) async => '   ');
          when(() => mockDataService.getUserById('   '))
              .thenReturn(null);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [AuthUnauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'handles session check with deleted user',
        setUp: () {
          when(() => mockPrefs.getString(AppConstants.storageKeyUserId))
              .thenAnswer((_) async => 'deleted_user_id');
          when(() => mockDataService.getUserById('deleted_user_id'))
              .thenReturn(null);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [AuthUnauthenticated()],
      );
    });

    group('Edge Case: State Properties', () {
      test('AuthError message is not empty', () {
        const error = AuthError('Test error');
        expect(error.message, isNotEmpty);
        expect(error.message, equals('Test error'));
      });

      test('AuthAuthenticated has correct properties', () {
        const auth = AuthAuthenticated(
          userId: 'test-id',
          role: UserRole.student,
        );
        expect(auth.userId, equals('test-id'));
        expect(auth.role, equals(UserRole.student));
      });

      test('AuthLoginRequested has correct properties', () {
        const request = AuthLoginRequested(
          studentId: '61913042',
          password: 'password123',
          rememberMe: true,
        );
        expect(request.studentId, equals('61913042'));
        expect(request.password, equals('password123'));
        expect(request.rememberMe, isTrue);
      });

      test('AuthLoginRequested props includes all fields', () {
        const request1 = AuthLoginRequested(
          studentId: '61913042',
          password: 'password123',
          rememberMe: true,
        );
        const request2 = AuthLoginRequested(
          studentId: '61913042',
          password: 'password123',
          rememberMe: false,
        );
        expect(request1.props, equals(['61913042', 'password123', true]));
        expect(request2.props, equals(['61913042', 'password123', false]));
        expect(request1.props, isNot(equals(request2.props)));
      });
    });
  });
}
