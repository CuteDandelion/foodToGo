import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodbegood/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:foodbegood/features/dashboard/presentation/widgets/animated_countdown.dart';
import 'package:foodbegood/features/dashboard/presentation/widgets/urgency_color.dart';

void main() {
  group('DashboardHeader', () {
    Widget createWidgetUnderTest({
      required String userName,
      DateTime? testTime,
    }) {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            home: Scaffold(
              body: DashboardHeader(
                userName: userName,
                testTime: testTime,
              ),
            ),
          );
        },
      );
    }

    testWidgets('displays current date and time', (WidgetTester tester) async {
      // Arrange
      final testTime = DateTime(2026, 2, 13, 14, 30);
      
      // Act
      await tester.pumpWidget(createWidgetUnderTest(
        userName: 'Zain',
        testTime: testTime,
      ));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Friday, February 13'), findsOneWidget);
      expect(find.text('14:30'), findsOneWidget);
    });

    testWidgets('displays morning greeting before 12:00', (WidgetTester tester) async {
      // Arrange
      final morningTime = DateTime(2026, 2, 13, 8, 0);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(
        userName: 'Zain',
        testTime: morningTime,
      ));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Good morning, Zain! 👋'), findsOneWidget);
    });

    testWidgets('displays afternoon greeting between 12:00 and 17:00', (WidgetTester tester) async {
      // Arrange
      final afternoonTime = DateTime(2026, 2, 13, 14, 0);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(
        userName: 'Zain',
        testTime: afternoonTime,
      ));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Good afternoon, Zain! 👋'), findsOneWidget);
    });

    testWidgets('displays evening greeting after 17:00', (WidgetTester tester) async {
      // Arrange
      final eveningTime = DateTime(2026, 2, 13, 19, 0);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(
        userName: 'Zain',
        testTime: eveningTime,
      ));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Good evening, Zain! 👋'), findsOneWidget);
    });

    testWidgets('displays evening greeting before 5:00', (WidgetTester tester) async {
      // Arrange
      final lateNightTime = DateTime(2026, 2, 13, 4, 0);

      // Act
      await tester.pumpWidget(createWidgetUnderTest(
        userName: 'Zain',
        testTime: lateNightTime,
      ));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Good evening, Zain! 👋'), findsOneWidget);
    });
  });

  group('AnimatedCountdown', () {
    Widget createWidgetUnderTest({
      required DateTime targetTime,
    }) {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            home: Scaffold(
              body: AnimatedCountdown(
                targetTime: targetTime,
              ),
            ),
          );
        },
      );
    }

    testWidgets('displays days, hours, and minutes when more than 24 hours remaining', (WidgetTester tester) async {
      // Arrange
      final targetTime = DateTime.now().add(const Duration(days: 2, hours: 5, minutes: 30));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(targetTime: targetTime));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('d'), findsOneWidget);
      expect(find.textContaining('h'), findsOneWidget);
      expect(find.textContaining('m'), findsOneWidget);
    });

    testWidgets('displays hours and minutes when less than 24 hours remaining', (WidgetTester tester) async {
      // Arrange
      final targetTime = DateTime.now().add(const Duration(hours: 5, minutes: 30));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(targetTime: targetTime));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('h'), findsOneWidget);
      expect(find.textContaining('m'), findsOneWidget);
    });

    testWidgets('displays minutes and seconds when less than 1 hour remaining', (WidgetTester tester) async {
      // Arrange
      final targetTime = DateTime.now().add(const Duration(minutes: 30, seconds: 45));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(targetTime: targetTime));
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('m'), findsOneWidget);
      expect(find.textContaining('s'), findsOneWidget);
    });

    testWidgets('countdown displays correct format', (WidgetTester tester) async {
      // Arrange
      final targetTime = DateTime.now().add(const Duration(minutes: 30));

      // Act
      await tester.pumpWidget(createWidgetUnderTest(targetTime: targetTime));
      await tester.pumpAndSettle();

      // Assert - verify countdown format contains minutes and seconds
      expect(find.textContaining('m'), findsOneWidget);
      expect(find.textContaining('s'), findsOneWidget);
    });
  });

  group('UrgencyColor', () {
    test('returns green when more than 1 hour remaining', () {
      // Arrange
      const timeRemaining = Duration(hours: 2);

      // Act
      final color = UrgencyColor.getColor(timeRemaining);

      // Assert
      expect(color, equals(const Color(0xFF10B981)));
    });

    test('returns interpolated color between green and yellow at 45 minutes', () {
      // Arrange
      const timeRemaining = Duration(minutes: 45);

      // Act
      final color = UrgencyColor.getColor(timeRemaining);

      // Assert
      expect(color, isNot(equals(const Color(0xFF10B981)))); // Not pure green
      expect(color, isNot(equals(const Color(0xFFF59E0B)))); // Not pure yellow
    });

    test('returns yellow at exactly 30 minutes', () {
      // Arrange
      const timeRemaining = Duration(minutes: 30);

      // Act
      final color = UrgencyColor.getColor(timeRemaining);

      // Assert
      expect(color, equals(const Color(0xFFF59E0B)));
    });

    test('returns interpolated color between yellow and red at 15 minutes', () {
      // Arrange
      const timeRemaining = Duration(minutes: 15);

      // Act
      final color = UrgencyColor.getColor(timeRemaining);

      // Assert
      expect(color, isNot(equals(const Color(0xFFF59E0B)))); // Not pure yellow
      expect(color, isNot(equals(const Color(0xFFEF4444)))); // Not pure red
    });

    test('returns red when less than 30 minutes remaining', () {
      // Arrange
      const timeRemaining = Duration(minutes: 15);

      // Act
      final color = UrgencyColor.getColor(timeRemaining);

      // Assert
      // Should be closer to red
      expect(color.r, greaterThan(color.g));
    });

    test('returns pure red when 0 minutes remaining', () {
      // Arrange
      const timeRemaining = Duration.zero;

      // Act
      final color = UrgencyColor.getColor(timeRemaining);

      // Assert
      expect(color, equals(const Color(0xFFEF4444)));
    });
  });

  group('DynamicGreeting', () {
    test('returns morning greeting between 5:00 and 11:59', () {
      // Arrange
      final morningTime = DateTime(2026, 2, 13, 8, 0);

      // Act
      final greeting = DynamicGreeting.getGreeting('Zain', morningTime);

      // Assert
      expect(greeting, equals('Good morning, Zain! 👋'));
    });

    test('returns afternoon greeting between 12:00 and 16:59', () {
      // Arrange
      final afternoonTime = DateTime(2026, 2, 13, 14, 0);

      // Act
      final greeting = DynamicGreeting.getGreeting('Zain', afternoonTime);

      // Assert
      expect(greeting, equals('Good afternoon, Zain! 👋'));
    });

    test('returns evening greeting between 17:00 and 4:59', () {
      // Arrange
      final eveningTime = DateTime(2026, 2, 13, 19, 0);

      // Act
      final greeting = DynamicGreeting.getGreeting('Zain', eveningTime);

      // Assert
      expect(greeting, equals('Good evening, Zain! 👋'));
    });

    test('returns evening greeting at midnight', () {
      // Arrange
      final midnightTime = DateTime(2026, 2, 13, 0, 0);

      // Act
      final greeting = DynamicGreeting.getGreeting('Zain', midnightTime);

      // Assert
      expect(greeting, equals('Good evening, Zain! 👋'));
    });

    test('returns morning greeting at exactly 5:00', () {
      // Arrange
      final earlyMorningTime = DateTime(2026, 2, 13, 5, 0);

      // Act
      final greeting = DynamicGreeting.getGreeting('Zain', earlyMorningTime);

      // Assert
      expect(greeting, equals('Good morning, Zain! 👋'));
    });

    test('returns afternoon greeting at exactly 12:00', () {
      // Arrange
      final noonTime = DateTime(2026, 2, 13, 12, 0);

      // Act
      final greeting = DynamicGreeting.getGreeting('Zain', noonTime);

      // Assert
      expect(greeting, equals('Good afternoon, Zain! 👋'));
    });

    test('returns evening greeting at exactly 17:00', () {
      // Arrange
      final eveningStartTime = DateTime(2026, 2, 13, 17, 0);

      // Act
      final greeting = DynamicGreeting.getGreeting('Zain', eveningStartTime);

      // Assert
      expect(greeting, equals('Good evening, Zain! 👋'));
    });
  });
}
