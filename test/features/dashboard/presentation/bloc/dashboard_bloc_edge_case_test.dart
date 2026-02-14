import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:foodbegood/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:foodbegood/shared/services/mock_data_service.dart';

class MockMockDataService extends Mock implements MockDataService {}

/// Edge Case Tests for DashboardBloc
///
/// These tests cover boundary conditions, error scenarios, and
/// unusual situations in the dashboard functionality.
void main() {
  group('DashboardBloc Edge Cases', () {
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

    group('Edge Case: Empty and Null User IDs', () {
      blocTest<DashboardBloc, DashboardState>(
        'handles empty string userId',
        setUp: () {
          when(() => mockDataService.getDashboardForUser(''))
              .thenReturn(testDashboardData);
        },
        build: () => dashboardBloc,
        act: (bloc) => bloc.add(const DashboardLoaded(userId: '')),
        expect: () => [
          DashboardLoading(),
          DashboardLoadSuccess(testDashboardData),
        ],
      );

      blocTest<DashboardBloc, DashboardState>(
        'handles userId with only whitespace',
        setUp: () {
          when(() => mockDataService.getDashboardForUser('   '))
              .thenReturn(testDashboardData);
        },
        build: () => dashboardBloc,
        act: (bloc) => bloc.add(const DashboardLoaded(userId: '   ')),
        expect: () => [
          DashboardLoading(),
          DashboardLoadSuccess(testDashboardData),
        ],
      );

      blocTest<DashboardBloc, DashboardState>(
        'handles very long userId (1000 chars)',
        setUp: () {
          final longId = 'a' * 1000;
          when(() => mockDataService.getDashboardForUser(longId))
              .thenReturn(testDashboardData);
        },
        build: () => dashboardBloc,
        act: (bloc) => bloc.add(DashboardLoaded(userId: 'a' * 1000)),
        expect: () => [
          DashboardLoading(),
          DashboardLoadSuccess(testDashboardData),
        ],
      );

      blocTest<DashboardBloc, DashboardState>(
        'handles userId with special characters',
        setUp: () {
          when(() => mockDataService.getDashboardForUser('user@#\$%123'))
              .thenReturn(testDashboardData);
        },
        build: () => dashboardBloc,
        act: (bloc) => bloc.add(const DashboardLoaded(userId: 'user@#\$%123')),
        expect: () => [
          DashboardLoading(),
          DashboardLoadSuccess(testDashboardData),
        ],
      );

      blocTest<DashboardBloc, DashboardState>(
        'handles userId with unicode characters',
        setUp: () {
          when(() => mockDataService.getDashboardForUser('用户123'))
              .thenReturn(testDashboardData);
        },
        build: () => dashboardBloc,
        act: (bloc) => bloc.add(const DashboardLoaded(userId: '用户123')),
        expect: () => [
          DashboardLoading(),
          DashboardLoadSuccess(testDashboardData),
        ],
      );
    });

    group('Edge Case: Boundary Data Values', () {
      final zeroData = DashboardData(
        totalMeals: 0,
        monthlyGoal: 50,
        monthlyGoalProgress: 0.0,
        moneySaved: MoneySaved(
          thisMonth: 0.0,
          lastMonth: 0.0,
          trend: 0.0,
          breakdown: {},
        ),
        monthlyAverage: 0.0,
        percentile: 0,
        currentStreak: 0,
        socialImpact: SocialImpact(
          studentsHelped: 0,
          avgMoneySavedPerStudent: 0.0,
        ),
      );

      final maxData = DashboardData(
        totalMeals: 999999,
        monthlyGoal: 50,
        monthlyGoalProgress: 19999.98,
        moneySaved: MoneySaved(
          thisMonth: 999999.99,
          lastMonth: 999999.99,
          trend: 999.99,
          breakdown: {
            'Meals': 999999.99,
          },
        ),
        monthlyAverage: 999.99,
        percentile: 100,
        currentStreak: 999,
        socialImpact: SocialImpact(
          studentsHelped: 999999,
          avgMoneySavedPerStudent: 999.99,
        ),
      );

      blocTest<DashboardBloc, DashboardState>(
        'handles zero values in dashboard data',
        setUp: () {
          when(() => mockDataService.getDashboardForUser('1'))
              .thenReturn(zeroData);
        },
        build: () => dashboardBloc,
        act: (bloc) => bloc.add(const DashboardLoaded()),
        expect: () => [
          DashboardLoading(),
          DashboardLoadSuccess(zeroData),
        ],
      );

      blocTest<DashboardBloc, DashboardState>(
        'handles maximum values in dashboard data',
        setUp: () {
          when(() => mockDataService.getDashboardForUser('1'))
              .thenReturn(maxData);
        },
        build: () => dashboardBloc,
        act: (bloc) => bloc.add(const DashboardLoaded()),
        expect: () => [
          DashboardLoading(),
          DashboardLoadSuccess(maxData),
        ],
      );

      blocTest<DashboardBloc, DashboardState>(
        'handles negative values in dashboard data',
        setUp: () {
          final negativeData = DashboardData(
            totalMeals: -10,
            monthlyGoal: 50,
            monthlyGoalProgress: -0.2,
            moneySaved: MoneySaved(
              thisMonth: -50.0,
              lastMonth: -100.0,
              trend: -0.5,
              breakdown: {
                'Meals': -50.0,
              },
            ),
            monthlyAverage: -5.0,
            percentile: -10,
            currentStreak: -5,
            socialImpact: SocialImpact(
              studentsHelped: -100,
              avgMoneySavedPerStudent: -10.0,
            ),
          );
          when(() => mockDataService.getDashboardForUser('1'))
              .thenReturn(negativeData);
        },
        build: () => dashboardBloc,
        act: (bloc) => bloc.add(const DashboardLoaded()),
        expect: () => [
          DashboardLoading(),
          isA<DashboardLoadSuccess>(),
        ],
      );
    });

    group('Edge Case: Null Values in Data', () {
      blocTest<DashboardBloc, DashboardState>(
        'handles null nextPickup',
        setUp: () {
          final dataWithNullPickup = DashboardData(
            totalMeals: 34,
            monthlyGoal: 50,
            monthlyGoalProgress: 0.68,
            moneySaved: MoneySaved(
              thisMonth: 82.50,
              lastMonth: 70.00,
              trend: 0.18,
              breakdown: {},
            ),
            monthlyAverage: 12.3,
            percentile: 15,
            currentStreak: 5,
            nextPickup: null,
            socialImpact: SocialImpact(
              studentsHelped: 156,
              avgMoneySavedPerStudent: 12.50,
            ),
          );
          when(() => mockDataService.getDashboardForUser('1'))
              .thenReturn(dataWithNullPickup);
        },
        build: () => dashboardBloc,
        act: (bloc) => bloc.add(const DashboardLoaded()),
        expect: () => [
          DashboardLoading(),
          isA<DashboardLoadSuccess>()
              .having((s) => s.data.nextPickup, 'nextPickup', isNull),
        ],
      );

      blocTest<DashboardBloc, DashboardState>(
        'handles empty breakdown map',
        setUp: () {
          final dataWithEmptyBreakdown = DashboardData(
            totalMeals: 34,
            monthlyGoal: 50,
            monthlyGoalProgress: 0.68,
            moneySaved: MoneySaved(
              thisMonth: 82.50,
              lastMonth: 70.00,
              trend: 0.18,
              breakdown: {},
            ),
            monthlyAverage: 12.3,
            percentile: 15,
            currentStreak: 5,
            socialImpact: SocialImpact(
              studentsHelped: 156,
              avgMoneySavedPerStudent: 12.50,
            ),
          );
          when(() => mockDataService.getDashboardForUser('1'))
              .thenReturn(dataWithEmptyBreakdown);
        },
        build: () => dashboardBloc,
        act: (bloc) => bloc.add(const DashboardLoaded()),
        expect: () => [
          DashboardLoading(),
          isA<DashboardLoadSuccess>().having(
              (s) => s.data.moneySaved.breakdown.isEmpty,
              'breakdown empty',
              isTrue),
        ],
      );
    });

    group('Edge Case: Rapid Operations', () {
      blocTest<DashboardBloc, DashboardState>(
        'handles rapid load requests',
        setUp: () {
          when(() => mockDataService.getDashboardForUser('1'))
              .thenReturn(testDashboardData);
        },
        build: () => dashboardBloc,
        act: (bloc) async {
          bloc.add(const DashboardLoaded());
          bloc.add(const DashboardLoaded());
          bloc.add(const DashboardLoaded());
        },
        expect: () => [
          DashboardLoading(),
          DashboardLoadSuccess(testDashboardData),
          DashboardLoading(),
          DashboardLoadSuccess(testDashboardData),
          DashboardLoading(),
          DashboardLoadSuccess(testDashboardData),
        ],
        verify: (_) {
          verify(() => mockDataService.getDashboardForUser('1')).called(3);
        },
      );

      blocTest<DashboardBloc, DashboardState>(
        'handles rapid refresh requests',
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
      );

      blocTest<DashboardBloc, DashboardState>(
        'handles mixed load and refresh requests',
        setUp: () {
          when(() => mockDataService.getDashboardForUser('1'))
              .thenReturn(testDashboardData);
          when(() => mockDataService.getDashboardForUser('user2'))
              .thenReturn(testDashboardData);
        },
        build: () => dashboardBloc,
        act: (bloc) async {
          bloc.add(const DashboardLoaded());
          bloc.add(const DashboardRefreshed());
          bloc.add(const DashboardLoaded(userId: 'user2'));
        },
        expect: () => [
          DashboardLoading(),
          DashboardLoadSuccess(testDashboardData),
          DashboardLoading(),
          DashboardLoadSuccess(testDashboardData),
          DashboardLoading(),
          DashboardLoadSuccess(testDashboardData),
        ],
      );
    });

    group('Edge Case: Error Scenarios', () {
      blocTest<DashboardBloc, DashboardState>(
        'handles type error',
        setUp: () {
          when(() => mockDataService.getDashboardForUser('1'))
              .thenThrow(TypeError());
        },
        build: () => dashboardBloc,
        act: (bloc) => bloc.add(const DashboardLoaded()),
        expect: () => [
          DashboardLoading(),
          isA<DashboardError>()
              .having((s) => s.message, 'message', contains('TypeError')),
        ],
      );

      blocTest<DashboardBloc, DashboardState>(
        'handles argument error',
        setUp: () {
          when(() => mockDataService.getDashboardForUser('1'))
              .thenThrow(ArgumentError('Invalid argument'));
        },
        build: () => dashboardBloc,
        act: (bloc) => bloc.add(const DashboardLoaded()),
        expect: () => [
          DashboardLoading(),
          isA<DashboardError>().having(
              (s) => s.message, 'message', contains('Invalid argument')),
        ],
      );

      blocTest<DashboardBloc, DashboardState>(
        'handles state error',
        setUp: () {
          when(() => mockDataService.getDashboardForUser('1'))
              .thenThrow(StateError('Bad state'));
        },
        build: () => dashboardBloc,
        act: (bloc) => bloc.add(const DashboardLoaded()),
        expect: () => [
          DashboardLoading(),
          isA<DashboardError>()
              .having((s) => s.message, 'message', contains('Bad state')),
        ],
      );
    });

    group('Edge Case: State Transitions', () {
      blocTest<DashboardBloc, DashboardState>(
        'can recover from error state with successful load',
        setUp: () {
          when(() => mockDataService.getDashboardForUser('1'))
              .thenReturn(testDashboardData);
        },
        build: () => dashboardBloc,
        seed: () => const DashboardError('Previous error'),
        act: (bloc) => bloc.add(const DashboardLoaded()),
        expect: () => [
          DashboardLoading(),
          DashboardLoadSuccess(testDashboardData),
        ],
      );

      blocTest<DashboardBloc, DashboardState>(
        'can refresh from success state',
        setUp: () {
          when(() => mockDataService.getDashboardForUser('1'))
              .thenReturn(testDashboardData);
        },
        build: () => dashboardBloc,
        seed: () => DashboardLoadSuccess(testDashboardData),
        act: (bloc) => bloc.add(const DashboardRefreshed()),
        expect: () => [
          DashboardLoading(),
          DashboardLoadSuccess(testDashboardData),
        ],
      );
    });

    group('Edge Case: State Properties', () {
      test('DashboardInitial is equatable', () {
        expect(DashboardInitial(), equals(DashboardInitial()));
      });

      test('DashboardLoading is equatable', () {
        expect(DashboardLoading(), equals(DashboardLoading()));
      });

      test('DashboardLoadSuccess with same data is equatable', () {
        final state1 = DashboardLoadSuccess(testDashboardData);
        final state2 = DashboardLoadSuccess(testDashboardData);
        expect(state1, equals(state2));
      });

      test('DashboardLoadSuccess with different data is not equatable', () {
        final state1 = DashboardLoadSuccess(testDashboardData);
        final differentData = DashboardData(
          totalMeals: 999,
          monthlyGoal: 50,
          monthlyGoalProgress: 19.98,
          moneySaved: MoneySaved(
            thisMonth: 999.99,
            lastMonth: 999.99,
            trend: 9.99,
            breakdown: {},
          ),
          monthlyAverage: 99.9,
          percentile: 99,
          currentStreak: 99,
          socialImpact: SocialImpact(
            studentsHelped: 999,
            avgMoneySavedPerStudent: 99.9,
          ),
        );
        final state2 = DashboardLoadSuccess(differentData);
        expect(state1, isNot(equals(state2)));
      });

      test('DashboardError with same message is equatable', () {
        const state1 = DashboardError('Error message');
        const state2 = DashboardError('Error message');
        expect(state1, equals(state2));
      });

      test('DashboardError with different messages is not equatable', () {
        const state1 = DashboardError('Error 1');
        const state2 = DashboardError('Error 2');
        expect(state1, isNot(equals(state2)));
      });
    });

    group('Edge Case: Event Properties', () {
      test('DashboardLoaded with null userId uses default', () {
        const event = DashboardLoaded();
        expect(event.userId, isNull); // Default value is null
      });

      test('DashboardLoaded props includes userId', () {
        const event1 = DashboardLoaded(userId: 'user1');
        const event2 = DashboardLoaded(userId: 'user1');
        const event3 = DashboardLoaded(userId: 'user2');

        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });

      test('DashboardRefreshed is equatable', () {
        expect(const DashboardRefreshed(), equals(const DashboardRefreshed()));
      });
    });

    group('Edge Case: MoneySaved Calculations', () {
      test('difference calculates correctly for positive difference', () {
        final moneySaved = MoneySaved(
          thisMonth: 100.0,
          lastMonth: 80.0,
          trend: 0.25,
          breakdown: {},
        );
        expect(moneySaved.difference, equals(20.0));
      });

      test('difference calculates correctly for negative difference', () {
        final moneySaved = MoneySaved(
          thisMonth: 60.0,
          lastMonth: 80.0,
          trend: -0.25,
          breakdown: {},
        );
        expect(moneySaved.difference, equals(-20.0));
      });

      test('difference calculates correctly for zero difference', () {
        final moneySaved = MoneySaved(
          thisMonth: 80.0,
          lastMonth: 80.0,
          trend: 0.0,
          breakdown: {},
        );
        expect(moneySaved.difference, equals(0.0));
      });
    });

    group('Edge Case: NextPickup Time Formatting', () {
      test('formattedTime shows days for future date', () {
        final nextPickup = NextPickup(
          location: 'Test Location',
          time: DateTime.now().add(const Duration(days: 2, hours: 5)),
        );
        expect(nextPickup.formattedTime, contains('d'));
      });

      test('formattedTime shows hours for near future', () {
        final nextPickup = NextPickup(
          location: 'Test Location',
          time: DateTime.now().add(const Duration(hours: 5)),
        );
        expect(nextPickup.formattedTime, contains('h'));
      });

      test('formattedTime shows minutes for very near future', () {
        final nextPickup = NextPickup(
          location: 'Test Location',
          time: DateTime.now().add(const Duration(minutes: 30)),
        );
        expect(nextPickup.formattedTime, contains('m'));
      });

      test('formattedTime handles past date', () {
        final nextPickup = NextPickup(
          location: 'Test Location',
          time: DateTime.now().subtract(const Duration(minutes: 5)),
        );
        // Should show negative minutes
        expect(nextPickup.formattedTime, contains('m'));
      });
    });
  });
}
