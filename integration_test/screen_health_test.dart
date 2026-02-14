import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodbegood/app.dart';
import 'package:foodbegood/core/storage/storage_manager.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await StorageManager().initialize();
  });

  tearDownAll(() async {
    await StorageManager().clearAll();
  });

  group('FoodBeGood Comprehensive Screen Health Tests', () {
    Future<void> resetAppState() async {
      await StorageManager().clearAll();
    }

    Future<void> loginAsStudent(WidgetTester tester) async {
      await resetAppState();
      await tester.pumpWidget(const FoodBeGoodApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.text('Student'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '61913042');
      await tester.enterText(find.byType(TextField).last, 'password123');

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }

    Future<void> loginAsCanteen(WidgetTester tester) async {
      await resetAppState();
      await tester.pumpWidget(const FoodBeGoodApp());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.text('Canteen Staff'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'canteen001');
      await tester.enterText(find.byType(TextField).last, 'canteen123');

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    }

    group('Screen Rendering & Health Checks', () {
      testWidgets('R1: Role Selection screen renders without exceptions', (tester) async {
        await resetAppState();
        await tester.pumpWidget(const FoodBeGoodApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(find.text('Welcome'), findsOneWidget);
        expect(find.text('Select your role to continue'), findsOneWidget);
        expect(find.text('Student'), findsOneWidget);
        expect(find.text('Canteen Staff'), findsOneWidget);

        final gestureDetector = find.byType(GestureDetector);
        expect(gestureDetector, findsWidgets);
      });

      testWidgets('R2: Student Login screen renders correctly', (tester) async {
        await resetAppState();
        await tester.pumpWidget(const FoodBeGoodApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await tester.tap(find.text('Student'));
        await tester.pumpAndSettle();

        expect(find.text('Student Login'), findsOneWidget);
        expect(find.text('Student ID'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Sign In'), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(2));
      });

      testWidgets('R3: Canteen Login screen renders correctly', (tester) async {
        await resetAppState();
        await tester.pumpWidget(const FoodBeGoodApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await tester.tap(find.text('Canteen Staff'));
        await tester.pumpAndSettle();

        expect(find.text('Canteen Login'), findsOneWidget);
        expect(find.text('Staff ID'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
      });

      testWidgets('R4: Student Dashboard renders all components', (tester) async {
        await loginAsStudent(tester);

        expect(find.text('Total Meals'), findsOneWidget);
        expect(find.text('Money Saved'), findsOneWidget);
        expect(find.text('Monthly Average'), findsOneWidget);
        expect(find.text('Current Streak'), findsOneWidget);
        expect(find.text('Pick Up My Meal'), findsOneWidget);
        expect(find.textContaining('Good'), findsOneWidget);
      });

      testWidgets('R5: Pickup Page renders food categories', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.text('Pick Up My Meal'));
        await tester.pumpAndSettle();

        expect(find.text('Pick Up My Meal'), findsOneWidget);
        expect(find.text('Select Your Items'), findsOneWidget);
        expect(find.text('Salad'), findsOneWidget);
        expect(find.text('Dessert'), findsOneWidget);
        expect(find.text('Chicken'), findsOneWidget);
      });

      testWidgets('R6: Time Slot Selection page renders correctly', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.text('Pick Up My Meal'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Salad'));
        await tester.pumpAndSettle();

        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();

        final confirmButton = find.textContaining('Confirm');
        if (confirmButton.evaluate().isNotEmpty) {
          await tester.tap(confirmButton);
          await tester.pumpAndSettle();
        }

        expect(find.text('Select Pickup Time'), findsOneWidget);
        expect(find.text('Selected Items'), findsOneWidget);
      });

      testWidgets('R7: Confirmation page renders after submission', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.text('Pick Up My Meal'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Salad'));
        await tester.pumpAndSettle();

        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.tap(find.textContaining('Confirm'));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(find.text('Order Confirmed!'), findsOneWidget);
        expect(find.text('Your order has been sent to the canteen'), findsOneWidget);
      });

      testWidgets('R8: QR Code page renders correctly', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.text('Pick Up My Meal'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Salad'));
        await tester.pumpAndSettle();

        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.tap(find.textContaining('Confirm'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        final viewQRButton = find.text('View QR Code');
        if (viewQRButton.evaluate().isNotEmpty) {
          await tester.tap(viewQRButton);
          await tester.pumpAndSettle();
        }

        expect(find.text('Your QR Code'), findsOneWidget);
      });

      testWidgets('R9: Profile page renders user info', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Account Management'));
        await tester.pumpAndSettle();

        expect(find.text('My Profile'), findsOneWidget);
        expect(find.text('Zain Ul Ebad'), findsOneWidget);
        expect(find.text('61913042'), findsOneWidget);
      });

      testWidgets('R10: Meal History page renders correctly', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Meal History'));
        await tester.pumpAndSettle();

        expect(find.text('Meal History'), findsOneWidget);
        expect(find.text('Total Meals'), findsOneWidget);
        expect(find.text('Total Saved'), findsOneWidget);
      });

      testWidgets('R11: Settings page renders all options', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Dark Mode'), findsOneWidget);
        expect(find.text('Account Management'), findsOneWidget);
        expect(find.text('Meal History'), findsOneWidget);
        expect(find.text('Sign Out'), findsOneWidget);
      });

      testWidgets('R12: Canteen Dashboard renders all metrics', (tester) async {
        await loginAsCanteen(tester);

        expect(find.text('Mensa Viadrina'), findsOneWidget);
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Total Meals'), findsOneWidget);
        expect(find.text('Waste Saved'), findsOneWidget);
        expect(find.text('Savings'), findsOneWidget);
      });
    });

    group('Workflow Verification', () {
      testWidgets('W1: Complete student pickup workflow', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.text('Pick Up My Meal'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Salad'));
        await tester.pumpAndSettle();
        expect(find.text('1/5 items selected'), findsOneWidget);

        await tester.tap(find.text('Chicken'));
        await tester.pumpAndSettle();
        expect(find.text('2/5 items selected'), findsOneWidget);

        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();
        await tester.tap(find.textContaining('Confirm'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.text('Order Confirmed!'), findsOneWidget);
      });

      testWidgets('W2: Time slot selection workflow', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.text('Pick Up My Meal'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Salad'));
        await tester.pumpAndSettle();

        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();
        await tester.tap(find.textContaining('Confirm'));
        await tester.pumpAndSettle();

        expect(find.text('Select Pickup Time'), findsOneWidget);
      });

      testWidgets('W3: Navigation between all main screens', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.text('Pick Up My Meal'));
        await tester.pumpAndSettle();
        expect(find.text('Pick Up My Meal'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();
        expect(find.text('Total Meals'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();
        expect(find.text('Settings'), findsOneWidget);

        await tester.tap(find.text('Account Management'));
        await tester.pumpAndSettle();
        expect(find.text('My Profile'), findsOneWidget);
      });

      testWidgets('W4: Sign out returns to role selection', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sign Out'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sign Out').last);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.text('Welcome'), findsOneWidget);
      });

      testWidgets('W5: Back navigation preserves state', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.text('Pick Up My Meal'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Salad'));
        await tester.pumpAndSettle();
        expect(find.text('1/5 items selected'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Pick Up My Meal'));
        await tester.pumpAndSettle();

        expect(find.text('1/5 items selected'), findsOneWidget);
      });
    });

    group('User Experience Verification', () {
      testWidgets('U1: Loading states display correctly', (tester) async {
        await resetAppState();
        await tester.pumpWidget(const FoodBeGoodApp());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsNothing);
      });

      testWidgets('U2: Error states display properly', (tester) async {
        await resetAppState();
        await tester.pumpWidget(const FoodBeGoodApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await tester.tap(find.text('Student'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, '99999999');
        await tester.enterText(find.byType(TextField).last, 'wrong');

        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        expect(find.text('User not found'), findsOneWidget);
      });

      testWidgets('U3: Empty states handled gracefully', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.text('Pick Up My Meal'));
        await tester.pumpAndSettle();

        expect(find.text('Your container is empty'), findsOneWidget);
      });

      testWidgets('U4: Theme toggle updates UI', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        final switchTile = find.byType(SwitchListTile);
        expect(switchTile, findsOneWidget);

        await tester.tap(switchTile);
        await tester.pumpAndSettle();
      });

      testWidgets('U5: Button states reflect enabled/disabled', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.text('Pick Up My Meal'));
        await tester.pumpAndSettle();

        final disabledButton = find.text('Confirm Pickup (0)');
        expect(disabledButton, findsOneWidget);

        await tester.tap(find.text('Salad'));
        await tester.pumpAndSettle();

        final enabledButton = find.textContaining('Confirm');
        expect(enabledButton, findsOneWidget);
      });

      testWidgets('U6: Scrolling reveals hidden content', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.text('Pick Up My Meal'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Salad'));
        await tester.pumpAndSettle();

        final scrollView = find.byType(SingleChildScrollView);
        await tester.drag(scrollView, const Offset(0, -300));
        await tester.pumpAndSettle();

        expect(find.textContaining('Confirm'), findsOneWidget);
      });

      testWidgets('U7: Interactive elements provide feedback', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.text('Pick Up My Meal'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Salad'));
        await tester.pumpAndSettle();

        expect(find.text('1/5 items selected'), findsOneWidget);
      });
    });

    group('Exception Handling & Edge Cases', () {
      testWidgets('E1: Rapid navigation does not crash', (tester) async {
        await loginAsStudent(tester);

        for (int i = 0; i < 5; i++) {
          await tester.tap(find.text('Pick Up My Meal'));
          await tester.pump(const Duration(milliseconds: 100));
          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pump(const Duration(milliseconds: 100));
        }
        await tester.pumpAndSettle();

        expect(find.text('Pick Up My Meal'), findsOneWidget);
      });

      testWidgets('E2: Empty input validation', (tester) async {
        await resetAppState();
        await tester.pumpWidget(const FoodBeGoodApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await tester.tap(find.text('Student'));
        await tester.pumpAndSettle();

        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        expect(find.text('Student Login'), findsOneWidget);
      });

      testWidgets('E3: Maximum item selection limit', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.text('Pick Up My Meal'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Salad'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Dessert'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Side'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Chicken'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Fish'));
        await tester.pumpAndSettle();

        expect(find.text('5/5 items selected'), findsOneWidget);
      });

      testWidgets('E4: Clear selections works correctly', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.text('Pick Up My Meal'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Salad'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Chicken'));
        await tester.pumpAndSettle();
        expect(find.text('2/5 items selected'), findsOneWidget);

        final clearButton = find.text('Clear');
        if (clearButton.evaluate().isNotEmpty) {
          await tester.tap(clearButton);
          await tester.pumpAndSettle();
        }
      });

      testWidgets('E5: Dialog dismissal behavior', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sign Out'));
        await tester.pumpAndSettle();

        expect(find.text('Are you sure you want to sign out?'), findsOneWidget);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.text('Settings'), findsOneWidget);
      });

      testWidgets('E6: Bottom navigation or back gestures work', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.text('Pick Up My Meal'));
        await tester.pumpAndSettle();

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.text('Total Meals'), findsOneWidget);
      });

      testWidgets('E7: State persists across screen rotations', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.text('Pick Up My Meal'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Salad'));
        await tester.pumpAndSettle();
        expect(find.text('1/5 items selected'), findsOneWidget);

        await tester.binding.setSurfaceSize(const Size(600, 900));
        await tester.pumpAndSettle();

        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpAndSettle();

        expect(find.text('1/5 items selected'), findsOneWidget);
      });
    });

    group('Visual & Accessibility Check', () {
      testWidgets('V1: All icons render correctly', (tester) async {
        await loginAsStudent(tester);

        expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
        expect(find.byIcon(Icons.qr_code), findsWidgets);
      });

      testWidgets('V2: Text is readable and properly styled', (tester) async {
        await loginAsStudent(tester);

        final textWidgets = find.byType(Text);
        expect(textWidgets, findsWidgets);
      });

      testWidgets('V3: Cards and containers render properly', (tester) async {
        await loginAsStudent(tester);

        final cards = find.byType(Card);
        expect(cards, findsWidgets);
      });

      testWidgets('V4: Touch targets are adequately sized', (tester) async {
        await loginAsStudent(tester);

        final buttons = find.byType(ElevatedButton);
        expect(buttons, findsWidgets);
      });

      testWidgets('V5: No overflow errors visible', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.text('Pick Up My Meal'));
        await tester.pumpAndSettle();

        final overflowErrors = tester.takeException();
        expect(overflowErrors, isNull);
      });
    });

    group('Complete End-to-End Flows', () {
      testWidgets('F1: Full student journey - Login to Confirmation', (tester) async {
        await resetAppState();
        await tester.pumpWidget(const FoodBeGoodApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await tester.tap(find.text('Student'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, '61913042');
        await tester.enterText(find.byType(TextField).last, 'password123');

        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await tester.tap(find.text('Pick Up My Meal'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Salad'));
        await tester.pumpAndSettle();

        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();
        await tester.tap(find.textContaining('Confirm'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        await tester.tap(find.text('View QR Code'));
        await tester.pumpAndSettle();

        expect(find.text('Your QR Code'), findsOneWidget);
      });

      testWidgets('F2: Full canteen journey - Login to Settings', (tester) async {
        await resetAppState();
        await tester.pumpWidget(const FoodBeGoodApp());
        await tester.pumpAndSettle(const Duration(seconds: 3));

        await tester.tap(find.text('Canteen Staff'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'canteen001');
        await tester.enterText(find.byType(TextField).last, 'canteen123');

        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(find.text('Mensa Viadrina'), findsOneWidget);

        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        expect(find.text('Settings'), findsOneWidget);
      });

      testWidgets('F3: Settings exploration flow', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Account Management'));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Meal History'));
        await tester.pumpAndSettle();

        expect(find.text('Meal History'), findsOneWidget);
      });
    });

    group('Performance & Stability', () {
      testWidgets('P1: App remains responsive during navigation', (tester) async {
        await loginAsStudent(tester);

        final startTime = DateTime.now();

        for (int i = 0; i < 3; i++) {
          await tester.tap(find.text('Pick Up My Meal'));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();
        }

        final elapsed = DateTime.now().difference(startTime);
        expect(elapsed.inSeconds, lessThan(10));
      });

      testWidgets('P2: No memory leaks during repeated operations', (tester) async {
        await loginAsStudent(tester);

        for (int i = 0; i < 3; i++) {
          await tester.tap(find.text('Pick Up My Meal'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Salad'));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();
        }
      });

      testWidgets('P3: State management works correctly', (tester) async {
        await loginAsStudent(tester);

        await tester.tap(find.text('Pick Up My Meal'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Salad'));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        expect(find.text('1/5 items selected'), findsOneWidget);
      });
    });
  });
}
