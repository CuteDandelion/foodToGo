import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodbegood/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:foodbegood/shared/services/mock_data_service.dart';

/// Edge Case Tests for ProfileBloc
/// 
/// These tests cover boundary conditions, error scenarios, and
/// unusual situations in the profile management flow.
void main() {
  late ProfileBloc profileBloc;
  late MockDataService mockDataService;

  setUp(() {
    mockDataService = MockDataService();
    profileBloc = ProfileBloc(mockDataService: mockDataService);
  });

  tearDown(() {
    profileBloc.close();
  });

  group('ProfileBloc Edge Cases', () {
    
    group('Edge Case: Empty and Null Values', () {
      blocTest<ProfileBloc, ProfileState>(
        'handles update with all null values',
        build: () => profileBloc,
        seed: () {
          final user = mockDataService.getUserByStudentId('61913042')!;
          return ProfileState(
            status: ProfileStatus.loaded,
            user: user,
            totalMeals: 34,
            monthlyAverage: 12.3,
            currentStreak: 5,
          );
        },
        act: (bloc) => bloc.add(const ProfileUpdate()),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.updating),
          isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.loaded)
            .having((s) => s.user?.profile.firstName, 'first name', 'Zain') // Unchanged
            .having((s) => s.user?.profile.lastName, 'last name', 'Ul Ebad'), // Unchanged
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'handles update with empty strings',
        build: () => profileBloc,
        seed: () {
          final user = mockDataService.getUserByStudentId('61913042')!;
          return ProfileState(
            status: ProfileStatus.loaded,
            user: user,
            totalMeals: 34,
            monthlyAverage: 12.3,
            currentStreak: 5,
          );
        },
        act: (bloc) => bloc.add(const ProfileUpdate(
          firstName: '',
          lastName: '',
          department: '',
        )),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.updating),
          isA<ProfileState>()
            .having((s) => s.user?.profile.firstName, 'first name', '')
            .having((s) => s.user?.profile.lastName, 'last name', '')
            .having((s) => s.user?.profile.department, 'department', ''),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'handles photo update with null path',
        build: () => profileBloc,
        seed: () {
          final user = mockDataService.getUserByStudentId('61913042')!;
          return ProfileState(
            status: ProfileStatus.loaded,
            user: user,
            totalMeals: 34,
            monthlyAverage: 12.3,
            currentStreak: 5,
          );
        },
        act: (bloc) => bloc.add(const ProfilePhotoUpdate(null)),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.updating),
          isA<ProfileState>()
            .having((s) => s.user?.profile.photoPath, 'photo path', isNull),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'handles photo update with empty path',
        build: () => profileBloc,
        seed: () {
          final user = mockDataService.getUserByStudentId('61913042')!;
          return ProfileState(
            status: ProfileStatus.loaded,
            user: user,
            totalMeals: 34,
            monthlyAverage: 12.3,
            currentStreak: 5,
          );
        },
        act: (bloc) => bloc.add(const ProfilePhotoUpdate('')),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.updating),
          isA<ProfileState>()
            .having((s) => s.user?.profile.photoPath, 'photo path', ''),
        ],
      );
    });

    group('Edge Case: Special Characters and Unicode', () {
      blocTest<ProfileBloc, ProfileState>(
        'handles unicode characters in names',
        build: () => profileBloc,
        seed: () {
          final user = mockDataService.getUserByStudentId('61913042')!;
          return ProfileState(
            status: ProfileStatus.loaded,
            user: user,
            totalMeals: 34,
            monthlyAverage: 12.3,
            currentStreak: 5,
          );
        },
        act: (bloc) => bloc.add(const ProfileUpdate(
          firstName: 'José',
          lastName: 'García',
        )),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.updating),
          isA<ProfileState>()
            .having((s) => s.user?.profile.firstName, 'first name', 'José')
            .having((s) => s.user?.profile.lastName, 'last name', 'García'),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'handles emoji in names',
        build: () => profileBloc,
        seed: () {
          final user = mockDataService.getUserByStudentId('61913042')!;
          return ProfileState(
            status: ProfileStatus.loaded,
            user: user,
            totalMeals: 34,
            monthlyAverage: 12.3,
            currentStreak: 5,
          );
        },
        act: (bloc) => bloc.add(const ProfileUpdate(
          firstName: 'John 👨‍💻',
          lastName: 'Doe 🚀',
        )),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.updating),
          isA<ProfileState>()
            .having((s) => s.user?.profile.firstName, 'first name', 'John 👨‍💻')
            .having((s) => s.user?.profile.lastName, 'last name', 'Doe 🚀'),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'handles RTL text',
        build: () => profileBloc,
        seed: () {
          final user = mockDataService.getUserByStudentId('61913042')!;
          return ProfileState(
            status: ProfileStatus.loaded,
            user: user,
            totalMeals: 34,
            monthlyAverage: 12.3,
            currentStreak: 5,
          );
        },
        act: (bloc) => bloc.add(const ProfileUpdate(
          firstName: 'محمد',
          lastName: 'أحمد',
        )),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.updating),
          isA<ProfileState>()
            .having((s) => s.user?.profile.firstName, 'first name', 'محمد')
            .having((s) => s.user?.profile.lastName, 'last name', 'أحمد'),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'handles special characters in department',
        build: () => profileBloc,
        seed: () {
          final user = mockDataService.getUserByStudentId('61913042')!;
          return ProfileState(
            status: ProfileStatus.loaded,
            user: user,
            totalMeals: 34,
            monthlyAverage: 12.3,
            currentStreak: 5,
          );
        },
        act: (bloc) => bloc.add(const ProfileUpdate(
          department: 'Computer Science & Engineering (B.Sc.)',
        )),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.updating),
          isA<ProfileState>()
            .having((s) => s.user?.profile.department, 'department', 'Computer Science & Engineering (B.Sc.)'),
        ],
      );
    });

    group('Edge Case: Very Long Values', () {
      blocTest<ProfileBloc, ProfileState>(
        'handles very long first name (1000 chars)',
        build: () => profileBloc,
        seed: () {
          final user = mockDataService.getUserByStudentId('61913042')!;
          return ProfileState(
            status: ProfileStatus.loaded,
            user: user,
            totalMeals: 34,
            monthlyAverage: 12.3,
            currentStreak: 5,
          );
        },
        act: (bloc) => bloc.add(ProfileUpdate(
          firstName: 'A' * 1000,
        )),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.updating),
          isA<ProfileState>()
            .having((s) => s.user?.profile.firstName, 'first name', 'A' * 1000),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'handles very long photo path (1000 chars)',
        build: () => profileBloc,
        seed: () {
          final user = mockDataService.getUserByStudentId('61913042')!;
          return ProfileState(
            status: ProfileStatus.loaded,
            user: user,
            totalMeals: 34,
            monthlyAverage: 12.3,
            currentStreak: 5,
          );
        },
        act: (bloc) => bloc.add(ProfilePhotoUpdate(
          '/path/${'subfolder/' * 100}photo.jpg',
        )),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.updating),
          isA<ProfileState>()
            .having((s) => s.user?.profile.photoPath, 'photo path', contains('subfolder')),
        ],
      );
    });

    group('Edge Case: Boundary Values', () {
      blocTest<ProfileBloc, ProfileState>(
        'handles year of study at minimum (0)',
        build: () => profileBloc,
        seed: () {
          final user = mockDataService.getUserByStudentId('61913042')!;
          return ProfileState(
            status: ProfileStatus.loaded,
            user: user,
            totalMeals: 34,
            monthlyAverage: 12.3,
            currentStreak: 5,
          );
        },
        act: (bloc) => bloc.add(const ProfileUpdate(
          yearOfStudy: 0,
        )),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.updating),
          isA<ProfileState>()
            .having((s) => s.user?.profile.yearOfStudy, 'year', 0),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'handles year of study at maximum (10)',
        build: () => profileBloc,
        seed: () {
          final user = mockDataService.getUserByStudentId('61913042')!;
          return ProfileState(
            status: ProfileStatus.loaded,
            user: user,
            totalMeals: 34,
            monthlyAverage: 12.3,
            currentStreak: 5,
          );
        },
        act: (bloc) => bloc.add(const ProfileUpdate(
          yearOfStudy: 10,
        )),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.updating),
          isA<ProfileState>()
            .having((s) => s.user?.profile.yearOfStudy, 'year', 10),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'handles negative year of study',
        build: () => profileBloc,
        seed: () {
          final user = mockDataService.getUserByStudentId('61913042')!;
          return ProfileState(
            status: ProfileStatus.loaded,
            user: user,
            totalMeals: 34,
            monthlyAverage: 12.3,
            currentStreak: 5,
          );
        },
        act: (bloc) => bloc.add(const ProfileUpdate(
          yearOfStudy: -1,
        )),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.updating),
          isA<ProfileState>()
            .having((s) => s.user?.profile.yearOfStudy, 'year', -1),
        ],
      );
    });

    group('Edge Case: Rapid Operations', () {
      blocTest<ProfileBloc, ProfileState>(
        'handles rapid profile updates',
        build: () => profileBloc,
        seed: () {
          final user = mockDataService.getUserByStudentId('61913042')!;
          return ProfileState(
            status: ProfileStatus.loaded,
            user: user,
            totalMeals: 34,
            monthlyAverage: 12.3,
            currentStreak: 5,
          );
        },
        act: (bloc) async {
          bloc.add(const ProfileUpdate(firstName: 'Name1'));
          bloc.add(const ProfileUpdate(firstName: 'Name2'));
          bloc.add(const ProfileUpdate(firstName: 'Name3'));
        },
        wait: const Duration(milliseconds: 2000),
        expect: () => [
          // First update starts
          isA<ProfileState>().having((s) => s.status, 'status', ProfileStatus.updating),
          // Subsequent updates are processed (may combine due to async timing)
          isA<ProfileState>().having((s) => s.status, 'status', ProfileStatus.loaded),
          isA<ProfileState>().having((s) => s.status, 'status', ProfileStatus.loaded),
          isA<ProfileState>().having((s) => s.status, 'status', ProfileStatus.loaded),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'handles rapid photo updates',
        build: () => profileBloc,
        seed: () {
          final user = mockDataService.getUserByStudentId('61913042')!;
          return ProfileState(
            status: ProfileStatus.loaded,
            user: user,
            totalMeals: 34,
            monthlyAverage: 12.3,
            currentStreak: 5,
          );
        },
        act: (bloc) async {
          bloc.add(const ProfilePhotoUpdate('/path/1'));
          bloc.add(const ProfilePhotoUpdate('/path/2'));
          bloc.add(const ProfilePhotoUpdate('/path/3'));
        },
        wait: const Duration(milliseconds: 2000),
        expect: () => [
          // First update starts
          isA<ProfileState>().having((s) => s.status, 'status', ProfileStatus.updating),
          // Subsequent updates are processed (may combine due to async timing)
          isA<ProfileState>().having((s) => s.status, 'status', ProfileStatus.loaded),
          isA<ProfileState>().having((s) => s.status, 'status', ProfileStatus.loaded),
          isA<ProfileState>().having((s) => s.status, 'status', ProfileStatus.loaded),
        ],
      );
    });

    group('Edge Case: State Transitions', () {
      blocTest<ProfileBloc, ProfileState>(
        'handles update from initial state',
        build: () => profileBloc,
        seed: () => const ProfileState(
          status: ProfileStatus.initial,
          user: null,
          totalMeals: 0,
          monthlyAverage: 0,
          currentStreak: 0,
        ),
        act: (bloc) => bloc.add(const ProfileUpdate(
          firstName: 'Test',
        )),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.updating),
          isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.error)
            .having((s) => s.errorMessage, 'error', contains('Null check operator')),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'handles load after clear',
        build: () => profileBloc,
        seed: () {
          final user = mockDataService.getUserByStudentId('61913042')!;
          return ProfileState(
            status: ProfileStatus.loaded,
            user: user,
            totalMeals: 34,
            monthlyAverage: 12.3,
            currentStreak: 5,
          );
        },
        act: (bloc) async {
          bloc.add(const ProfileClear());
          bloc.add(const ProfileLoad());
        },
        wait: const Duration(milliseconds: 100),
        expect: () => [
          isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.initial)
            .having((s) => s.user, 'user', isNull),
          isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.loading),
          isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.loaded)
            .having((s) => s.user, 'user', isNotNull),
        ],
      );
    });

    group('Edge Case: State Properties', () {
      test('ProfileState props includes all fields', () {
        final user = mockDataService.getUserByStudentId('61913042')!;
        final state = ProfileState(
          status: ProfileStatus.loaded,
          user: user,
          totalMeals: 34,
          monthlyAverage: 12.3,
          currentStreak: 5,
          errorMessage: 'Test error',
        );
        
        expect(state.props, contains(ProfileStatus.loaded));
        expect(state.props, contains(user));
        expect(state.props, contains(34));
        expect(state.props, contains(12.3));
        expect(state.props, contains(5));
        expect(state.props, contains('Test error'));
      });

      test('ProfileUpdate props includes all fields', () {
        const update = ProfileUpdate(
          firstName: 'John',
          lastName: 'Doe',
          department: 'CS',
          yearOfStudy: 3,
        );
        
        expect(update.props, equals(['John', 'Doe', 'CS', 3]));
      });

      test('ProfilePhotoUpdate props includes path', () {
        const update = ProfilePhotoUpdate('/path/to/photo.jpg');
        
        expect(update.props, equals(['/path/to/photo.jpg']));
      });

      test('ProfileStatus enum values', () {
        expect(ProfileStatus.values.length, equals(5));
        expect(ProfileStatus.values, contains(ProfileStatus.initial));
        expect(ProfileStatus.values, contains(ProfileStatus.loading));
        expect(ProfileStatus.values, contains(ProfileStatus.loaded));
        expect(ProfileStatus.values, contains(ProfileStatus.updating));
        expect(ProfileStatus.values, contains(ProfileStatus.error));
      });
    });

    group('Edge Case: User fullName', () {
      test('fullName combines first and last name', () {
        final profile = Profile(
          firstName: 'John',
          lastName: 'Doe',
        );
        
        expect(profile.fullName, equals('John Doe'));
      });

      test('fullName with empty strings', () {
        final profile = Profile(
          firstName: '',
          lastName: '',
        );
        
        expect(profile.fullName, equals(' '));
      });

      test('fullName with unicode', () {
        final profile = Profile(
          firstName: 'José',
          lastName: 'García',
        );
        
        expect(profile.fullName, equals('José García'));
      });
    });
  });
}
