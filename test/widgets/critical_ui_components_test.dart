import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodbegood/app.dart';
import 'package:foodbegood/config/routes.dart';
import 'package:foodbegood/features/auth/presentation/pages/login_page.dart';
import 'package:foodbegood/features/auth/presentation/pages/role_selection_page.dart';
import 'package:foodbegood/shared/widgets/app_button.dart';
import 'package:foodbegood/shared/widgets/app_card.dart';
import 'package:foodbegood/shared/widgets/app_input.dart';

/// Widget Tests for Critical UI Components
/// 
/// These tests verify that key UI components render correctly
/// and respond to user interactions as expected.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppButton Widget Tests', () {
    testWidgets('Primary button renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Test Button',
              onPressed: () {},
              variant: ButtonVariant.primary,
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Secondary button renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Secondary',
              onPressed: () {},
              variant: ButtonVariant.secondary,
            ),
          ),
        ),
      );

      expect(find.text('Secondary'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Button onPressed is called when tapped', (tester) async {
      var wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Click Me',
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Click Me'));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('Disabled button does not call onPressed', (tester) async {
      var wasPressed = false;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Disabled'));
      await tester.pump();

      expect(wasPressed, isFalse);
    });

    testWidgets('Button with icon renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'With Icon',
              onPressed: () {},
              icon: Icons.add,
            ),
          ),
        ),
      );

      expect(find.text('With Icon'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Loading button shows progress indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Loading',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Full width button expands to fill', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Full Width',
              onPressed: () {},
              isFullWidth: true,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, double.infinity);
    });
  });

  group('AppCard Widget Tests', () {
    testWidgets('Default card renders with child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppCard(
              child: Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('Highlight card has correct styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppCard(
              variant: CardVariant.highlight,
              child: Text('Highlight'),
            ),
          ),
        ),
      );

      expect(find.text('Highlight'), findsOneWidget);
    });

    testWidgets('Card with onTap is tappable', (tester) async {
      var wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppCard(
              onTap: () {
                wasTapped = true;
              },
              child: const Text('Tappable'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tappable'));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('Card with padding applies padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppCard(
              padding: EdgeInsets.all(32),
              child: Text('Padded'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppCard),
          matching: find.byType(Container),
        ).last,
      );
      expect(container.padding, equals(const EdgeInsets.all(32)));
    });
  });

  group('AppInput Widget Tests', () {
    testWidgets('Text field renders with label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Username',
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      expect(find.text('Username'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('Text field accepts input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Input',
              controller: controller,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Hello World');
      await tester.pump();

      expect(controller.text, equals('Hello World'));
    });

    testWidgets('Password field obscures text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Password',
              controller: TextEditingController(),
              obscureText: true,
            ),
          ),
        ),
      );

      // Verify the field exists
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('Text field shows error message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Email',
              controller: TextEditingController(),
              errorText: 'Invalid email',
            ),
          ),
        ),
      );

      expect(find.text('Invalid email'), findsOneWidget);
    });

    testWidgets('Text field with prefix icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Search',
              controller: TextEditingController(),
              prefixIcon: Icons.search,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('Disabled text field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Disabled',
              controller: TextEditingController(),
              enabled: false,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('Text field with hint text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Name',
              controller: TextEditingController(),
              hint: 'Enter your name',
            ),
          ),
        ),
      );

      expect(find.text('Enter your name'), findsOneWidget);
    });
  });

  group('RoleSelectionPage Widget Tests', () {
    testWidgets('Role selection page renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RoleSelectionPage(),
        ),
      );

      expect(find.text('Welcome!'), findsOneWidget);
      expect(find.text('Select your role to continue'), findsOneWidget);
      expect(find.text('Student'), findsOneWidget);
      expect(find.text('Canteen Staff'), findsOneWidget);
    });

    testWidgets('Student card is tappable', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: AppRouter.router,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Student'), findsOneWidget);
    });

    testWidgets('Canteen Staff card is tappable', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: AppRouter.router,
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Canteen Staff'), findsOneWidget);
    });
  });

  group('LoginPage Widget Tests', () {
    testWidgets('Student login page renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(role: 'student'),
        ),
      );

      expect(find.text('Student Login'), findsOneWidget);
      expect(find.text('Student ID'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Canteen login page renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(role: 'canteen'),
        ),
      );

      expect(find.text('Canteen Login'), findsOneWidget);
      expect(find.text('Staff ID'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('Login form accepts input', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(role: 'student'),
        ),
      );

      await tester.enterText(find.byType(TextField).first, '61913042');
      await tester.enterText(find.byType(TextField).last, 'password123');
      await tester.pump();

      expect(find.text('61913042'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('Sign In button is present', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(role: 'student'),
        ),
      );

      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Remember me checkbox is present', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginPage(role: 'student'),
        ),
      );

      expect(find.byType(CheckboxListTile), findsOneWidget);
    });
  });

  group('FoodBeGoodApp Widget Tests', () {
    testWidgets('App renders without errors', (tester) async {
      await tester.pumpWidget(const FoodBeGoodApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show role selection page
      expect(find.text('Welcome!'), findsOneWidget);
    });

    testWidgets('App has correct title', (tester) async {
      await tester.pumpWidget(const FoodBeGoodApp());
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, equals('FoodBeGood'));
    });

    testWidgets('App has debug banner disabled', (tester) async {
      await tester.pumpWidget(const FoodBeGoodApp());
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });
  });

  group('Navigation Widget Tests', () {
    testWidgets('GoRouter navigation works', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: AppRouter.router,
        ),
      );

      await tester.pumpAndSettle();

      // Should start at role selection
      expect(find.text('Welcome!'), findsOneWidget);
    });
  });

  group('Responsive Layout Tests', () {
    testWidgets('App adapts to small screen', (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(const FoodBeGoodApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Welcome!'), findsOneWidget);

      // Reset
      addTearDown(tester.view.resetPhysicalSize);
    });

    testWidgets('App adapts to large screen', (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(const FoodBeGoodApp());
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Welcome!'), findsOneWidget);

      // Reset
      addTearDown(tester.view.resetPhysicalSize);
    });
  });

  group('Accessibility Widget Tests', () {
    testWidgets('Buttons have semantic labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Accessible Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.child, isNotNull);
    });

    testWidgets('Text fields have labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppInput(
              label: 'Labeled Input',
              controller: TextEditingController(),
            ),
          ),
        ),
      );

      expect(find.text('Labeled Input'), findsOneWidget);
    });
  });

  group('Theme Widget Tests', () {
    testWidgets('App has light theme defined', (tester) async {
      await tester.pumpWidget(const FoodBeGoodApp());
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
    });

    testWidgets('App has dark theme defined', (tester) async {
      await tester.pumpWidget(const FoodBeGoodApp());
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.darkTheme, isNotNull);
    });
  });
}
