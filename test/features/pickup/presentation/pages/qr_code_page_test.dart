import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodbegood/config/theme.dart';
import 'package:foodbegood/features/pickup/presentation/pages/qr_code_page.dart';

void main() {
  Widget createWidgetUnderTest({
    required DateTime expiresAt,
    String? studentName,
    List<String> orderItems = const [],
    String? pickupTime,
  }) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          theme: AppTheme.lightTheme,
          home: QRCodePage(
            pickupId: 'ORD123456',
            expiresAt: expiresAt,
            studentName: studentName,
            orderItems: orderItems,
            pickupTime: pickupTime,
          ),
        );
      },
    );
  }

  group('QRCodePage', () {
    testWidgets('shows warning timer color when less than 60 seconds remain',
        (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          expiresAt: DateTime.now().add(const Duration(seconds: 45)),
        ),
      );
      await tester.pump();

      final timerTextFinder = find.textContaining(':');
      expect(timerTextFinder, findsWidgets);

      final timerText = tester.widget<Text>(timerTextFinder.first);
      expect(timerText.style?.color, AppTheme.error);
    });

    testWidgets('renders order summary and student name when provided',
        (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          expiresAt: DateTime.now().add(const Duration(minutes: 5)),
          studentName: 'Test Student',
          orderItems: const ['Schnitzel', 'Kartoffelsalat'],
          pickupTime: 'Friday, Feb 14 at 12:30',
        ),
      );
      // Use pump() instead of pumpAndSettle() because the timer causes infinite updates
      await tester.pump();

      expect(find.text('Test Student'), findsOneWidget);
      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.text('Schnitzel'), findsOneWidget);
      expect(find.text('Kartoffelsalat'), findsOneWidget);
      expect(find.text('Pickup Time: Friday, Feb 14 at 12:30'), findsOneWidget);
    });
  });
}
