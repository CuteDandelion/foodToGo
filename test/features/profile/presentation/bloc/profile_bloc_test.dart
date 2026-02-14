import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodbegood/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:foodbegood/shared/services/mock_data_service.dart';

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

  group('ProfileBloc', () {
    test('initial state is correct', () {
      expect(profileBloc.state.status, ProfileStatus.initial);
      expect(profileBloc.state.user, isNull);
      expect(profileBloc.state.totalMeals, 0);
      expect(profileBloc.state.monthlyAverage, 0);
      expect(profileBloc.state.currentStreak, 0);
      expect(profileBloc.state.mealHistory, isEmpty);
      expect(profileBloc.state.isMealHistoryLoading, isFalse);
      expect(profileBloc.state.mealHistoryErrorMessage, isNull);
    });

    group('ProfileLoad', () {
      blocTest<ProfileBloc, ProfileState>(
        'emits [loading, loaded] with user data',
        build: () => profileBloc,
        act: (bloc) => bloc.add(const ProfileLoad()),
        expect: () => [
          isA<ProfileState>()
              .having((s) => s.status, 'status', ProfileStatus.loading),
          isA<ProfileState>()
              .having((s) => s.status, 'status', ProfileStatus.loaded)
              .having((s) => s.user, 'user', isNotNull)
              .having((s) => s.totalMeals, 'total meals', greaterThan(0))
              .having(
                  (s) => s.monthlyAverage, 'monthly average', greaterThan(0)),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'loads correct user data',
        build: () => profileBloc,
        act: (bloc) => bloc.add(const ProfileLoad()),
        expect: () => [
          isA<ProfileState>()
              .having((s) => s.status, 'status', ProfileStatus.loading),
          isA<ProfileState>()
              .having((s) => s.user?.studentId, 'student ID', '61913042')
              .having((s) => s.user?.profile.firstName, 'first name', 'Zain')
              .having((s) => s.user?.profile.lastName, 'last name', 'Ul Ebad'),
        ],
      );
    });

    group('ProfileUpdate', () {
      blocTest<ProfileBloc, ProfileState>(
        'emits [updating, loaded] with updated user data',
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
          firstName: 'Updated',
          lastName: 'Name',
        )),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<ProfileState>()
              .having((s) => s.status, 'status', ProfileStatus.updating),
          isA<ProfileState>()
              .having((s) => s.status, 'status', ProfileStatus.loaded)
              .having((s) => s.user?.profile.firstName, 'first name', 'Updated')
              .having((s) => s.user?.profile.lastName, 'last name', 'Name'),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'preserves unchanged fields',
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
          department: 'Updated Department',
        )),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<ProfileState>()
              .having((s) => s.status, 'status', ProfileStatus.updating),
          isA<ProfileState>()
              .having((s) => s.user?.profile.department, 'department',
                  'Updated Department')
              .having((s) => s.user?.profile.firstName, 'first name',
                  'Zain'), // Unchanged
        ],
      );
    });

    group('ProfilePhotoUpdate', () {
      blocTest<ProfileBloc, ProfileState>(
        'emits [updating, loaded] with updated photo path',
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
        act: (bloc) => bloc.add(const ProfilePhotoUpdate('/path/to/photo.jpg')),
        wait: const Duration(milliseconds: 600),
        expect: () => [
          isA<ProfileState>()
              .having((s) => s.status, 'status', ProfileStatus.updating),
          isA<ProfileState>().having((s) => s.user?.profile.photoPath,
              'photo path', '/path/to/photo.jpg'),
        ],
      );
    });

    group('ProfileClear', () {
      blocTest<ProfileBloc, ProfileState>(
        'resets to initial state',
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
        act: (bloc) => bloc.add(const ProfileClear()),
        expect: () => [
          isA<ProfileState>()
              .having((s) => s.status, 'status', ProfileStatus.initial)
              .having((s) => s.user, 'user', isNull)
              .having((s) => s.totalMeals, 'total meals', 0),
        ],
      );
    });

    group('ProfileMealHistoryLoad', () {
      blocTest<ProfileBloc, ProfileState>(
        'emits loading and then meal history data',
        build: () => profileBloc,
        act: (bloc) => bloc.add(const ProfileMealHistoryLoad(userId: '1')),
        expect: () => [
          isA<ProfileState>()
              .having((s) => s.isMealHistoryLoading, 'loading', isTrue)
              .having((s) => s.mealHistoryErrorMessage, 'error', isNull),
          isA<ProfileState>()
              .having((s) => s.isMealHistoryLoading, 'loading', isFalse)
              .having((s) => s.mealHistory, 'history', isNotEmpty)
              .having((s) => s.mealHistoryErrorMessage, 'error', isNull),
        ],
      );
    });

    group('State Properties', () {
      test('ProfileState should be equatable', () {
        final user = mockDataService.getUserByStudentId('61913042')!;

        final state1 = ProfileState(
          status: ProfileStatus.loaded,
          user: user,
          totalMeals: 34,
          monthlyAverage: 12.3,
          currentStreak: 5,
        );

        final state2 = ProfileState(
          status: ProfileStatus.loaded,
          user: user,
          totalMeals: 34,
          monthlyAverage: 12.3,
          currentStreak: 5,
        );

        expect(state1, equals(state2));
      });

      test('ProfileState copyWith should work correctly', () {
        final user = mockDataService.getUserByStudentId('61913042')!;

        final state = ProfileState(
          status: ProfileStatus.loaded,
          user: user,
          totalMeals: 34,
          monthlyAverage: 12.3,
          currentStreak: 5,
        );

        final updatedState = state.copyWith(
          totalMeals: 50,
          currentStreak: 10,
        );

        expect(updatedState.totalMeals, 50);
        expect(updatedState.currentStreak, 10);
        expect(updatedState.monthlyAverage, 12.3); // Unchanged
        expect(updatedState.user, equals(user)); // Unchanged
      });
    });

    group('Event Properties', () {
      test('ProfileUpdate should be equatable', () {
        const event1 = ProfileUpdate(firstName: 'Test');
        const event2 = ProfileUpdate(firstName: 'Test');
        const event3 = ProfileUpdate(firstName: 'Different');

        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });

      test('ProfilePhotoUpdate should be equatable', () {
        const event1 = ProfilePhotoUpdate('/path/1');
        const event2 = ProfilePhotoUpdate('/path/1');
        const event3 = ProfilePhotoUpdate('/path/2');

        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });

      test('ProfileMealHistoryLoad should be equatable', () {
        const event1 = ProfileMealHistoryLoad(userId: '1');
        const event2 = ProfileMealHistoryLoad(userId: '1');
        const event3 = ProfileMealHistoryLoad(userId: '2');

        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });
    });
  });
}
