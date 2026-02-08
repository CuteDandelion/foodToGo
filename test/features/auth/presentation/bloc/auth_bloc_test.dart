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

void main() {
  group('AuthBloc', () {
    late AuthBloc authBloc;
    late MockMockDataService mockDataService;
    late MockStorageManager mockStorage;
    late MockSharedPrefsStorage mockPrefs;

    setUp(() {
      mockDataService = MockMockDataService();
      mockStorage = MockStorageManager();
      mockPrefs = MockSharedPrefsStorage();

      // Setup storage mock to return prefs
      when(() => mockStorage.prefs).thenReturn(mockPrefs);

      authBloc = AuthBloc(
        mockDataService: mockDataService,
        storage: mockStorage,
      );
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthInitial', () {
      expect(authBloc.state, equals(AuthInitial()));
    });

    group('AuthLoginRequested', () {
      final testUser = User(
        id: '1',
        studentId: '61913042',
        passwordHash: 'hashed_password',
        role: UserRole.student,
        profile: Profile(
          firstName: 'Test',
          lastName: 'User',
        ),
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when login is successful',
        setUp: () {
          when(() => mockDataService.getUserByStudentId('61913042'))
              .thenReturn(testUser);
          when(() => mockDataService.verifyPassword('password123', any()))
              .thenReturn(true);
          when(() => mockPrefs.setString(AppConstants.storageKeyUserId, '1'))
              .thenAnswer((_) async => {});
          when(() => mockPrefs.setString(AppConstants.storageKeyToken, any()))
              .thenAnswer((_) async => {});
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          studentId: '61913042',
          password: 'password123',
        )),
        expect: () => [
          AuthLoading(),
          const AuthAuthenticated(
            userId: '1',
            role: UserRole.student,
          ),
        ],
        verify: (_) {
          verify(() => mockDataService.getUserByStudentId('61913042')).called(1);
          verify(() => mockDataService.verifyPassword('password123', any())).called(1);
          verify(() => mockPrefs.setString(AppConstants.storageKeyUserId, '1')).called(1);
          verify(() => mockPrefs.setString(AppConstants.storageKeyToken, any(that: contains('mock_token')))).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when user is not found',
        setUp: () {
          when(() => mockDataService.getUserByStudentId('invalid_id'))
              .thenReturn(null);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          studentId: 'invalid_id',
          password: 'password123',
        )),
        expect: () => [
          AuthLoading(),
          const AuthError('User not found'),
        ],
        verify: (_) {
          verify(() => mockDataService.getUserByStudentId('invalid_id')).called(1);
          verifyNever(() => mockDataService.verifyPassword(any(), any()));
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when password is invalid',
        setUp: () {
          when(() => mockDataService.getUserByStudentId('61913042'))
              .thenReturn(testUser);
          when(() => mockDataService.verifyPassword('wrongpassword', any()))
              .thenReturn(false);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          studentId: '61913042',
          password: 'wrongpassword',
        )),
        expect: () => [
          AuthLoading(),
          const AuthError('Invalid password'),
        ],
        verify: (_) {
          verify(() => mockDataService.getUserByStudentId('61913042')).called(1);
          verify(() => mockDataService.verifyPassword('wrongpassword', any())).called(1);
          verifyNever(() => mockPrefs.setString(any(), any()));
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when an exception occurs',
        setUp: () {
          when(() => mockDataService.getUserByStudentId('61913042'))
              .thenThrow(Exception('Network error'));
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          studentId: '61913042',
          password: 'password123',
        )),
        expect: () => [
          AuthLoading(),
          const AuthError('Login failed: Exception: Network error'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'stores session data when rememberMe is true',
        setUp: () {
          when(() => mockDataService.getUserByStudentId('61913042'))
              .thenReturn(testUser);
          when(() => mockDataService.verifyPassword('password123', any()))
              .thenReturn(true);
          when(() => mockPrefs.setString(any(), any()))
              .thenAnswer((_) async => {});
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthLoginRequested(
          studentId: '61913042',
          password: 'password123',
          rememberMe: true,
        )),
        expect: () => [
          AuthLoading(),
          const AuthAuthenticated(
            userId: '1',
            role: UserRole.student,
          ),
        ],
        verify: (_) {
          verify(() => mockPrefs.setString(AppConstants.storageKeyUserId, '1')).called(1);
          verify(() => mockPrefs.setString(AppConstants.storageKeyToken, any())).called(1);
        },
      );
    });

    group('AuthLogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthUnauthenticated] and clears session',
        setUp: () {
          when(() => mockPrefs.remove(AppConstants.storageKeyUserId))
              .thenAnswer((_) async => {});
          when(() => mockPrefs.remove(AppConstants.storageKeyToken))
              .thenAnswer((_) async => {});
        },
        build: () => authBloc,
        seed: () => const AuthAuthenticated(
          userId: '1',
          role: UserRole.student,
        ),
        act: (bloc) => bloc.add(AuthLogoutRequested()),
        expect: () => [AuthUnauthenticated()],
        verify: (_) {
          verify(() => mockPrefs.remove(AppConstants.storageKeyUserId)).called(1);
          verify(() => mockPrefs.remove(AppConstants.storageKeyToken)).called(1);
        },
      );
    });

    group('AuthCheckRequested', () {
      final testUser = User(
        id: '1',
        studentId: '61913042',
        passwordHash: 'hashed_password',
        role: UserRole.student,
        profile: Profile(
          firstName: 'Test',
          lastName: 'User',
        ),
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthAuthenticated] when valid session exists',
        setUp: () {
          when(() => mockPrefs.getString(AppConstants.storageKeyUserId))
              .thenAnswer((_) async => '1');
          when(() => mockDataService.getUserById('1'))
              .thenReturn(testUser);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [
          const AuthAuthenticated(
            userId: '1',
            role: UserRole.student,
          ),
        ],
        verify: (_) {
          verify(() => mockPrefs.getString(AppConstants.storageKeyUserId)).called(1);
          verify(() => mockDataService.getUserById('1')).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthUnauthenticated] when no session exists',
        setUp: () {
          when(() => mockPrefs.getString(AppConstants.storageKeyUserId))
              .thenAnswer((_) async => null);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [AuthUnauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthUnauthenticated] when user not found',
        setUp: () {
          when(() => mockPrefs.getString(AppConstants.storageKeyUserId))
              .thenAnswer((_) async => '999');
          when(() => mockDataService.getUserById('999'))
              .thenReturn(null);
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [AuthUnauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthUnauthenticated] when an error occurs',
        setUp: () {
          when(() => mockPrefs.getString(AppConstants.storageKeyUserId))
              .thenThrow(Exception('Storage error'));
        },
        build: () => authBloc,
        act: (bloc) => bloc.add(AuthCheckRequested()),
        expect: () => [AuthUnauthenticated()],
      );
    });
  });
}
