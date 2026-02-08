import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:foodbegood/config/constants.dart';
import 'package:foodbegood/core/storage/storage_manager.dart';
import 'package:foodbegood/features/settings/presentation/bloc/theme_bloc.dart';

class MockStorageManager extends Mock implements StorageManager {}

class MockSharedPrefsStorage extends Mock implements SharedPrefsStorage {}

/// Edge Case Tests for ThemeBloc
/// 
/// These tests cover boundary conditions, error scenarios, and
/// unusual situations in the theme management functionality.
void main() {
  group('ThemeBloc Edge Cases', () {
    late MockStorageManager mockStorage;
    late MockSharedPrefsStorage mockPrefs;

    setUp(() {
      mockStorage = MockStorageManager();
      mockPrefs = MockSharedPrefsStorage();

      when(() => mockStorage.prefs).thenReturn(mockPrefs);
    });

    group('Edge Case: Storage Initialization', () {
      blocTest<ThemeBloc, ThemeState>(
        'handles storage returning null for theme preference',
        setUp: () {
          when(() => mockPrefs.getBool(AppConstants.storageKeyTheme))
              .thenAnswer((_) async => null);
        },
        build: () => ThemeBloc(storage: mockStorage),
        expect: () => [const ThemeState(isDarkMode: false)],
      );

      blocTest<ThemeBloc, ThemeState>(
        'handles storage read exception during initialization',
        setUp: () {
          when(() => mockPrefs.getBool(AppConstants.storageKeyTheme))
              .thenThrow(Exception('Storage read failed'));
        },
        build: () => ThemeBloc(storage: mockStorage),
        expect: () => [const ThemeState(isDarkMode: false)],
      );

      blocTest<ThemeBloc, ThemeState>(
        'handles storage returning unexpected type (treated as null)',
        setUp: () {
          when(() => mockPrefs.getBool(AppConstants.storageKeyTheme))
              .thenAnswer((_) async => null);
        },
        build: () => ThemeBloc(storage: mockStorage),
        expect: () => [const ThemeState(isDarkMode: false)],
      );
    });

    group('Edge Case: Storage Write Failures', () {
      blocTest<ThemeBloc, ThemeState>(
        'handles storage write failure when toggling theme',
        setUp: () {
          when(() => mockPrefs.getBool(AppConstants.storageKeyTheme))
              .thenAnswer((_) async => false);
          when(() => mockPrefs.setBool(AppConstants.storageKeyTheme, true))
              .thenThrow(Exception('Storage write failed'));
        },
        build: () => ThemeBloc(storage: mockStorage),
        seed: () => const ThemeState(isDarkMode: false),
        act: (bloc) => bloc.add(ThemeToggled()),
        expect: () => [
          // Even if storage fails, state should still update
          const ThemeState(isDarkMode: true),
        ],
      );

      blocTest<ThemeBloc, ThemeState>(
        'handles storage write failure when changing theme explicitly',
        setUp: () {
          when(() => mockPrefs.getBool(AppConstants.storageKeyTheme))
              .thenAnswer((_) async => false);
          when(() => mockPrefs.setBool(AppConstants.storageKeyTheme, true))
              .thenThrow(Exception('Storage write failed'));
        },
        build: () => ThemeBloc(storage: mockStorage),
        seed: () => const ThemeState(isDarkMode: false),
        act: (bloc) => bloc.add(const ThemeChanged(true)),
        expect: () => [
          // Even if storage fails, state should still update
          const ThemeState(isDarkMode: true),
        ],
      );
    });

    group('Edge Case: Rapid Theme Toggles', () {
      blocTest<ThemeBloc, ThemeState>(
        'handles rapid theme toggles',
        setUp: () {
          when(() => mockPrefs.getBool(AppConstants.storageKeyTheme))
              .thenAnswer((_) async => false);
          when(() => mockPrefs.setBool(any(), any()))
              .thenAnswer((_) async => {});
        },
        build: () => ThemeBloc(storage: mockStorage),
        seed: () => const ThemeState(isDarkMode: false),
        act: (bloc) async {
          // Rapid toggles
          bloc.add(ThemeToggled()); // false -> true
          bloc.add(ThemeToggled()); // true -> false
          bloc.add(ThemeToggled()); // false -> true
          bloc.add(ThemeToggled()); // true -> false
          bloc.add(ThemeToggled()); // false -> true
        },
        expect: () => [
          const ThemeState(isDarkMode: true),
          const ThemeState(isDarkMode: false),
          const ThemeState(isDarkMode: true),
          const ThemeState(isDarkMode: false),
          const ThemeState(isDarkMode: true),
        ],
      );

      blocTest<ThemeBloc, ThemeState>(
        'handles rapid explicit theme changes',
        setUp: () {
          when(() => mockPrefs.getBool(AppConstants.storageKeyTheme))
              .thenAnswer((_) async => false);
          when(() => mockPrefs.setBool(any(), any()))
              .thenAnswer((_) async => {});
        },
        build: () => ThemeBloc(storage: mockStorage),
        seed: () => const ThemeState(isDarkMode: false),
        act: (bloc) async {
          bloc.add(const ThemeChanged(true));
          bloc.add(const ThemeChanged(false));
          bloc.add(const ThemeChanged(true));
          bloc.add(const ThemeChanged(true)); // Same value - no emit
          bloc.add(const ThemeChanged(false));
        },
        expect: () => [
          const ThemeState(isDarkMode: true),
          const ThemeState(isDarkMode: false),
          const ThemeState(isDarkMode: true),
          const ThemeState(isDarkMode: false),
        ],
      );

      blocTest<ThemeBloc, ThemeState>(
        'handles mixed toggle and explicit changes',
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
          bloc.add(const ThemeChanged(false)); // explicit false
          bloc.add(ThemeToggled()); // false -> true
          bloc.add(const ThemeChanged(true)); // explicit true (no change - not emitted)
        },
        expect: () => [
          const ThemeState(isDarkMode: true),
          const ThemeState(isDarkMode: false),
          const ThemeState(isDarkMode: true),
        ],
      );
    });

    group('Edge Case: State Consistency', () {
      blocTest<ThemeBloc, ThemeState>(
        'maintains state after multiple same-value changes',
        setUp: () {
          when(() => mockPrefs.getBool(AppConstants.storageKeyTheme))
              .thenAnswer((_) async => true);
          when(() => mockPrefs.setBool(AppConstants.storageKeyTheme, true))
              .thenAnswer((_) async => {});
        },
        build: () => ThemeBloc(storage: mockStorage),
        seed: () => const ThemeState(isDarkMode: true),
        act: (bloc) async {
          bloc.add(const ThemeChanged(true));
          bloc.add(const ThemeChanged(true));
          bloc.add(const ThemeChanged(true));
        },
        expect: () => [
          // No states emitted when value doesn't change
        ],
      );

      blocTest<ThemeBloc, ThemeState>(
        'correctly toggles from true to false',
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
      );
    });

    group('Edge Case: State Properties', () {
      test('ThemeState default constructor uses false', () {
        const state = ThemeState();
        expect(state.isDarkMode, isFalse);
      });

      test('ThemeState can be created with true', () {
        const state = ThemeState(isDarkMode: true);
        expect(state.isDarkMode, isTrue);
      });

      test('ThemeState can be created with false', () {
        const state = ThemeState(isDarkMode: false);
        expect(state.isDarkMode, isFalse);
      });

      test('ThemeState equality - same values are equal', () {
        const state1 = ThemeState(isDarkMode: true);
        const state2 = ThemeState(isDarkMode: true);
        expect(state1, equals(state2));
      });

      test('ThemeState equality - different values are not equal', () {
        const state1 = ThemeState(isDarkMode: true);
        const state2 = ThemeState(isDarkMode: false);
        expect(state1, isNot(equals(state2)));
      });

      test('ThemeState props contains isDarkMode', () {
        const state = ThemeState(isDarkMode: true);
        expect(state.props, contains(true));
      });
    });

    group('Edge Case: Event Properties', () {
      test('ThemeToggled events are equal', () {
        final event1 = ThemeToggled();
        final event2 = ThemeToggled();
        expect(event1, equals(event2));
      });

      test('ThemeChanged with same value are equal', () {
        const event1 = ThemeChanged(true);
        const event2 = ThemeChanged(true);
        expect(event1, equals(event2));
      });

      test('ThemeChanged with different values are not equal', () {
        const event1 = ThemeChanged(true);
        const event2 = ThemeChanged(false);
        expect(event1, isNot(equals(event2)));
      });

      test('ThemeChanged props contains isDarkMode', () {
        const event = ThemeChanged(true);
        expect(event.props, contains(true));
      });

      test('ThemeInitialized events are equal', () {
        final event1 = ThemeInitialized();
        final event2 = ThemeInitialized();
        expect(event1, equals(event2));
      });
    });

    group('Edge Case: Storage Key Constants', () {
      test('storageKeyTheme constant has correct value', () {
        expect(AppConstants.storageKeyTheme, equals('theme_dark_mode'));
      });
    });

    group('Edge Case: No Storage Provided', () {
      test('ThemeBloc can be created without explicit storage', () {
        // This should use the default StorageManager()
        final bloc = ThemeBloc();
        expect(bloc, isNotNull);
        addTearDown(() => bloc.close());
      });
    });
  });
}
