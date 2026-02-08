import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:foodbegood/config/constants.dart';
import 'package:foodbegood/core/storage/storage_manager.dart';
import 'package:foodbegood/features/settings/presentation/bloc/theme_bloc.dart';

class MockStorageManager extends Mock implements StorageManager {}

class MockSharedPrefsStorage extends Mock implements SharedPrefsStorage {}

void main() {
  group('ThemeBloc', () {
    late MockStorageManager mockStorage;
    late MockSharedPrefsStorage mockPrefs;

    setUp(() {
      mockStorage = MockStorageManager();
      mockPrefs = MockSharedPrefsStorage();

      // Setup storage mock to return prefs
      when(() => mockStorage.prefs).thenReturn(mockPrefs);
    });

    test('initial state has isDarkMode as false', () {
      // Arrange
      when(() => mockPrefs.getBool(AppConstants.storageKeyTheme))
          .thenAnswer((_) async => false);

      // Act
      final themeBloc = ThemeBloc(storage: mockStorage);

      // Assert
      expect(themeBloc.state.isDarkMode, isFalse);

      // Cleanup
      addTearDown(() => themeBloc.close());
    });

    group('ThemeInitialized', () {
      blocTest<ThemeBloc, ThemeState>(
        'emits ThemeState with isDarkMode false when no theme is saved',
        setUp: () {
          when(() => mockPrefs.getBool(AppConstants.storageKeyTheme))
              .thenAnswer((_) async => false);
        },
        build: () => ThemeBloc(storage: mockStorage),
        expect: () => [const ThemeState(isDarkMode: false)],
        verify: (_) {
          verify(() => mockPrefs.getBool(AppConstants.storageKeyTheme)).called(1);
        },
      );

      blocTest<ThemeBloc, ThemeState>(
        'emits ThemeState with isDarkMode true when dark theme is saved',
        setUp: () {
          when(() => mockPrefs.getBool(AppConstants.storageKeyTheme))
              .thenAnswer((_) async => true);
        },
        build: () => ThemeBloc(storage: mockStorage),
        expect: () => [const ThemeState(isDarkMode: true)],
      );

      blocTest<ThemeBloc, ThemeState>(
        'emits ThemeState with isDarkMode false when null is returned',
        setUp: () {
          when(() => mockPrefs.getBool(AppConstants.storageKeyTheme))
              .thenAnswer((_) async => null);
        },
        build: () => ThemeBloc(storage: mockStorage),
        expect: () => [const ThemeState(isDarkMode: false)],
      );
    });

    group('ThemeToggled', () {
      blocTest<ThemeBloc, ThemeState>(
        'toggles from light to dark mode',
        setUp: () {
          when(() => mockPrefs.getBool(AppConstants.storageKeyTheme))
              .thenAnswer((_) async => false);
          when(() => mockPrefs.setBool(AppConstants.storageKeyTheme, true))
              .thenAnswer((_) async => {});
        },
        build: () => ThemeBloc(storage: mockStorage),
        seed: () => const ThemeState(isDarkMode: false),
        act: (bloc) => bloc.add(ThemeToggled()),
        expect: () => [const ThemeState(isDarkMode: true)],
        verify: (_) {
          verify(() => mockPrefs.setBool(AppConstants.storageKeyTheme, true)).called(1);
        },
      );

      blocTest<ThemeBloc, ThemeState>(
        'toggles from dark to light mode',
        setUp: () {
          when(() => mockPrefs.getBool(AppConstants.storageKeyTheme))
              .thenAnswer((_) async => true);
          when(() => mockPrefs.setBool(AppConstants.storageKeyTheme, false))
              .thenAnswer((_) async => {});
        },
        build: () => ThemeBloc(storage: mockStorage),
        seed: () => const ThemeState(isDarkMode: true),
        act: (bloc) => bloc.add(ThemeToggled()),
        expect: () => [const ThemeState(isDarkMode: false)],
        verify: (_) {
          verify(() => mockPrefs.setBool(AppConstants.storageKeyTheme, false)).called(1);
        },
      );

      blocTest<ThemeBloc, ThemeState>(
        'can toggle multiple times',
        setUp: () {
          when(() => mockPrefs.getBool(AppConstants.storageKeyTheme))
              .thenAnswer((_) async => false);
          when(() => mockPrefs.setBool(any(), any()))
              .thenAnswer((_) async => {});
        },
        build: () => ThemeBloc(storage: mockStorage),
        seed: () => const ThemeState(isDarkMode: false),
        act: (bloc) async {
          bloc.add(ThemeToggled()); // false -> true
          bloc.add(ThemeToggled()); // true -> false
          bloc.add(ThemeToggled()); // false -> true
        },
        expect: () => [
          const ThemeState(isDarkMode: true),
          const ThemeState(isDarkMode: false),
          const ThemeState(isDarkMode: true),
        ],
      );
    });

    group('ThemeChanged', () {
      blocTest<ThemeBloc, ThemeState>(
        'sets dark mode to true when passed true',
        setUp: () {
          when(() => mockPrefs.getBool(AppConstants.storageKeyTheme))
              .thenAnswer((_) async => false);
          when(() => mockPrefs.setBool(AppConstants.storageKeyTheme, true))
              .thenAnswer((_) async => {});
        },
        build: () => ThemeBloc(storage: mockStorage),
        seed: () => const ThemeState(isDarkMode: false),
        act: (bloc) => bloc.add(const ThemeChanged(true)),
        expect: () => [const ThemeState(isDarkMode: true)],
        verify: (_) {
          verify(() => mockPrefs.setBool(AppConstants.storageKeyTheme, true)).called(1);
        },
      );

      blocTest<ThemeBloc, ThemeState>(
        'sets dark mode to false when passed false',
        setUp: () {
          when(() => mockPrefs.getBool(AppConstants.storageKeyTheme))
              .thenAnswer((_) async => true);
          when(() => mockPrefs.setBool(AppConstants.storageKeyTheme, false))
              .thenAnswer((_) async => {});
        },
        build: () => ThemeBloc(storage: mockStorage),
        seed: () => const ThemeState(isDarkMode: true),
        act: (bloc) => bloc.add(const ThemeChanged(false)),
        expect: () => [const ThemeState(isDarkMode: false)],
        verify: (_) {
          verify(() => mockPrefs.setBool(AppConstants.storageKeyTheme, false)).called(1);
        },
      );


    });

    group('State Properties', () {
      test('ThemeState should have correct isDarkMode value', () {
        // Act
        const lightState = ThemeState(isDarkMode: false);
        const darkState = ThemeState(isDarkMode: true);

        // Assert
        expect(lightState.isDarkMode, isFalse);
        expect(darkState.isDarkMode, isTrue);
      });

      test('ThemeState default isDarkMode is false', () {
        // Act
        const defaultState = ThemeState();

        // Assert
        expect(defaultState.isDarkMode, isFalse);
      });

      test('ThemeState props should contain isDarkMode', () {
        // Arrange
        const state1 = ThemeState(isDarkMode: true);
        const state2 = ThemeState(isDarkMode: true);
        const state3 = ThemeState(isDarkMode: false);

        // Assert
        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });
    });

    group('Event Properties', () {
      test('ThemeChanged should contain isDarkMode', () {
        // Act
        const event = ThemeChanged(true);

        // Assert
        expect(event.isDarkMode, isTrue);
      });

      test('ThemeChanged props should contain isDarkMode', () {
        // Arrange
        const event1 = ThemeChanged(true);
        const event2 = ThemeChanged(true);
        const event3 = ThemeChanged(false);

        // Assert
        expect(event1, equals(event2));
        expect(event1, isNot(equals(event3)));
      });

      test('ThemeToggled should be equatable', () {
        // Arrange
        final event1 = ThemeToggled();
        final event2 = ThemeToggled();

        // Assert
        expect(event1, equals(event2));
      });

      test('ThemeInitialized should be equatable', () {
        // Arrange
        final event1 = ThemeInitialized();
        final event2 = ThemeInitialized();

        // Assert
        expect(event1, equals(event2));
      });
    });
  });
}
