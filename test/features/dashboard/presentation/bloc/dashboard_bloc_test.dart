import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:foodbegood/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:foodbegood/shared/services/mock_data_service.dart';

class MockMockDataService extends Mock implements MockDataService {}

void main() {
  group('DashboardBloc', () {
    late DashboardBloc dashboardBloc;
    late MockMockDataService mockDataService;

    final testDashboardData = DashboardData(
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

    setUp(() {
      mockDataService = MockMockDataService();
      dashboardBloc = DashboardBloc(
        mockDataService: mockDataService,
      );
    });

    tearDown(() {
      dashboardBloc.close();
    });

    test('initial state is DashboardInitial', () {
      expect(dashboardBloc.state, equals(DashboardInitial()));
    });

    group('DashboardLoaded', () {
      blocTest<DashboardBloc, DashboardState>(
        'emits [DashboardLoading, DashboardLoadSuccess] when data loads successfully',
        setUp: () {
          when(() => mockDataService.getDashboardForUser('user_123'))
              .thenReturn(testDashboardData);
        },
        build: () => dashboardBloc,
        act: (bloc) => bloc.add(const DashboardLoaded(userId: 'user_123')),
        expect: () => [
          DashboardLoading(),
          DashboardLoadSuccess(testDashboardData),
        ],
        verify: (_) {
          verify(() => mockDataService.getDashboardForUser('user_123')).called(1);
        },
      );

      blocTest<DashboardBloc, DashboardState>(
        'emits [DashboardLoading, DashboardLoadSuccess] with default user ID when userId is null',
        setUp: () {
          when(() => mockDataService.getDashboardForUser('1'))
              .thenReturn(testDashboardData);
        },
        build: () => dashboardBloc,
        act: (bloc) => bloc.add(const DashboardLoaded()),
        expect: () => [
          DashboardLoading(),
          DashboardLoadSuccess(testDashboardData),
        ],
        verify: (_) {
          verify(() => mockDataService.getDashboardForUser('1')).called(1);
        },
      );

      blocTest<DashboardBloc, DashboardState>(
        'emits [DashboardLoading, DashboardError] when loading fails',
        setUp: () {
          when(() => mockDataService.getDashboardForUser('user_123'))
              .thenThrow(Exception('Database error'));
        },
        build: () => dashboardBloc,
        act: (bloc) => bloc.add(const DashboardLoaded(userId: 'user_123')),
        expect: () => [
          DashboardLoading(),
          const DashboardError('Failed to load dashboard: Exception: Database error'),
        ],
      );
    });

    group('DashboardRefreshed', () {
      blocTest<DashboardBloc, DashboardState>(
        'emits [DashboardLoading, DashboardLoadSuccess] when refresh is successful',
        setUp: () {
          when(() => mockDataService.getDashboardForUser('1'))
              .thenReturn(testDashboardData);
        },
        build: () => dashboardBloc,
        act: (bloc) => bloc.add(const DashboardRefreshed()),
        expect: () => [
          DashboardLoading(),
          DashboardLoadSuccess(testDashboardData),
        ],
        verify: (_) {
          verify(() => mockDataService.getDashboardForUser('1')).called(1);
        },
      );

      blocTest<DashboardBloc, DashboardState>(
        'emits [DashboardLoading, DashboardError] when refresh fails',
        setUp: () {
          when(() => mockDataService.getDashboardForUser('1'))
              .thenThrow(Exception('Network error'));
        },
        build: () => dashboardBloc,
        act: (bloc) => bloc.add(const DashboardRefreshed()),
        expect: () => [
          DashboardLoading(),
          const DashboardError('Failed to refresh dashboard: Exception: Network error'),
        ],
      );

      blocTest<DashboardBloc, DashboardState>(
        'can be triggered multiple times',
        setUp: () {
          when(() => mockDataService.getDashboardForUser('1'))
              .thenReturn(testDashboardData);
        },
        build: () => dashboardBloc,
        act: (bloc) async {
          bloc.add(const DashboardRefreshed());
          bloc.add(const DashboardRefreshed());
        },
        expect: () => [
          DashboardLoading(),
          DashboardLoadSuccess(testDashboardData),
          DashboardLoading(),
          DashboardLoadSuccess(testDashboardData),
        ],
        verify: (_) {
          verify(() => mockDataService.getDashboardForUser('1')).called(2);
        },
      );
    });

    group('State Properties', () {
      test('DashboardLoadSuccess should contain DashboardData', () {
        // Act
        final state = DashboardLoadSuccess(testDashboardData);

        // Assert
        expect(state.data, equals(testDashboardData));
        expect(state.data.totalMeals, equals(34));
        expect(state.data.monthlyGoalProgress, equals(0.68));
      });

      test('DashboardLoadSuccess props should contain data', () {
        // Arrange
        final state1 = DashboardLoadSuccess(testDashboardData);
        final state2 = DashboardLoadSuccess(testDashboardData);
        final differentData = DashboardData(
          totalMeals: 100,
          monthlyGoal: 50,
          monthlyGoalProgress: 2.0,
          moneySaved: MoneySaved(
            thisMonth: 50.0,
            lastMonth: 40.0,
            trend: 0.25,
            breakdown: {},
          ),
          monthlyAverage: 10.0,
          percentile: 50,
          currentStreak: 10,
          socialImpact: SocialImpact(
            studentsHelped: 100,
            avgMoneySavedPerStudent: 10.0,
          ),
        );
        final state3 = DashboardLoadSuccess(differentData);

        // Assert
        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });

      test('DashboardError should contain error message', () {
        // Arrange
        const errorMessage = 'Something went wrong';

        // Act
        const state = DashboardError(errorMessage);

        // Assert
        expect(state.message, equals(errorMessage));
      });

      test('DashboardError props should contain message', () {
        // Arrange
        const state1 = DashboardError('error 1');
        const state2 = DashboardError('error 1');
        const state3 = DashboardError('error 2');

        // Assert
        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });
    });

    group('Event Properties', () {
      test('DashboardLoaded should contain userId', () {
        // Act
        const event = DashboardLoaded(userId: 'user_123');

        // Assert
        expect(event.userId, equals('user_123'));
      });

      test('DashboardLoaded props should contain userId', () {
        // Arrange
        const event1 = DashboardLoaded(userId: 'user_1');
        const event2 = DashboardLoaded(userId: 'user_1');
        const event3 = DashboardLoaded(userId: 'user_2');
        const event4 = DashboardLoaded();

        // Assert
        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
        expect(event1, isNot(equals(event4)));
      });

      test('DashboardRefreshed should be equatable', () {
        // Arrange
        const event1 = DashboardRefreshed();
        const event2 = DashboardRefreshed();

        // Assert
        expect(event1, equals(event2));
      });
    });
  });
}
