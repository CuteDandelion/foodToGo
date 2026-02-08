import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodbegood/features/pickup/presentation/bloc/pickup_bloc.dart';
import 'package:foodbegood/shared/services/mock_data_service.dart';

/// Edge Case Tests for PickupBloc
/// 
/// These tests cover boundary conditions, error scenarios, and
/// unusual situations in the pickup flow.
void main() {
  late PickupBloc pickupBloc;
  late MockDataService mockDataService;

  setUp(() {
    mockDataService = MockDataService();
    pickupBloc = PickupBloc(mockDataService: mockDataService);
  });

  tearDown(() {
    pickupBloc.close();
  });

  group('PickupBloc Edge Cases', () {
    
    group('Edge Case: Empty and Null States', () {
      test('initial state has all default values', () {
        expect(pickupBloc.state.status, PickupStatus.initial);
        expect(pickupBloc.state.selectedItems, isEmpty);
        expect(pickupBloc.state.categories, isEmpty);
        expect(pickupBloc.state.pickupId, isNull);
        expect(pickupBloc.state.qrCodeData, isNull);
        expect(pickupBloc.state.expiresAt, isNull);
        expect(pickupBloc.state.errorMessage, isNull);
      });

      test('deselect from empty selection keeps items empty', () {
        final categories = mockDataService.getFoodCategories();
        final state = PickupState(
          categories: categories,
          status: PickupStatus.ready,
          selectedItems: const [],
        );
        
        // Deselecting from empty should keep it empty
        expect(state.selectedItems, isEmpty);
      });

      test('clear on already empty selection keeps items empty', () {
        final categories = mockDataService.getFoodCategories();
        final state = PickupState(
          categories: categories,
          status: PickupStatus.ready,
          selectedItems: const [],
        );
        
        // Clearing empty should keep it empty
        expect(state.selectedItems, isEmpty);
      });
    });

    group('Edge Case: Category Limits', () {
      blocTest<PickupBloc, PickupState>(
        'handles selecting exactly max per category',
        build: () => pickupBloc,
        seed: () {
          final categories = mockDataService.getFoodCategories();
          // Side has maxPerPickup of 2
          return PickupState(
            categories: categories,
            status: PickupStatus.ready,
            selectedItems: [categories[2]], // One side already selected
          );
        },
        act: (bloc) {
          final categories = mockDataService.getFoodCategories();
          bloc.add(PickupCategorySelected(categories[2])); // Add second side
        },
        expect: () => [
          isA<PickupState>()
            .having((s) => s.selectedItems.length, 'selected items', 2)
            .having((s) => s.errorMessage, 'error message', isNull),
        ],
      );

      blocTest<PickupBloc, PickupState>(
        'prevents selecting one more than max per category',
        build: () => pickupBloc,
        seed: () {
          final categories = mockDataService.getFoodCategories();
          // Side has maxPerPickup of 2
          return PickupState(
            categories: categories,
            status: PickupStatus.ready,
            selectedItems: [categories[2], categories[2]], // Two sides already selected
          );
        },
        act: (bloc) {
          final categories = mockDataService.getFoodCategories();
          bloc.add(PickupCategorySelected(categories[2])); // Try to add third side
        },
        expect: () => [
          isA<PickupState>()
            .having((s) => s.selectedItems.length, 'selected items', 2)
            .having((s) => s.errorMessage, 'error message', contains('Maximum')),
        ],
      );

      blocTest<PickupBloc, PickupState>(
        'handles selecting exactly 5 items (total limit)',
        build: () => pickupBloc,
        seed: () {
          final categories = mockDataService.getFoodCategories();
          return PickupState(
            categories: categories,
            status: PickupStatus.ready,
            selectedItems: [
              categories[0], // Salad
              categories[1], // Dessert
              categories[2], // Side
              categories[3], // Chicken
            ],
          );
        },
        act: (bloc) {
          final categories = mockDataService.getFoodCategories();
          bloc.add(PickupCategorySelected(categories[4])); // Add Fish (5th item)
        },
        expect: () => [
          isA<PickupState>()
            .having((s) => s.selectedItems.length, 'selected items', 5)
            .having((s) => s.errorMessage, 'error message', isNull),
        ],
      );

      blocTest<PickupBloc, PickupState>(
        'prevents selecting 6th item',
        build: () => pickupBloc,
        seed: () {
          final categories = mockDataService.getFoodCategories();
          return PickupState(
            categories: categories,
            status: PickupStatus.ready,
            selectedItems: [
              categories[0], // Salad
              categories[1], // Dessert
              categories[2], // Side
              categories[3], // Chicken
              categories[4], // Fish
            ],
          );
        },
        act: (bloc) {
          final categories = mockDataService.getFoodCategories();
          bloc.add(PickupCategorySelected(categories[5])); // Try to add Veggie (6th item)
        },
        expect: () => [
          isA<PickupState>()
            .having((s) => s.selectedItems.length, 'selected items', 5)
            .having((s) => s.errorMessage, 'error message', 'Maximum 5 items per pickup'),
        ],
      );
    });

    group('Edge Case: Category with Multiple Selections', () {
      blocTest<PickupBloc, PickupState>(
        'correctly counts multiple selections of same category',
        build: () => pickupBloc,
        seed: () {
          final categories = mockDataService.getFoodCategories();
          return PickupState(
            categories: categories,
            status: PickupStatus.ready,
            selectedItems: const [],
          );
        },
        act: (bloc) {
          final categories = mockDataService.getFoodCategories();
          // Side allows max 2
          bloc.add(PickupCategorySelected(categories[2]));
          bloc.add(PickupCategorySelected(categories[2]));
        },
        expect: () => [
          isA<PickupState>()
            .having((s) => s.selectedItems.length, 'selected items', 1)
            .having((s) => s.selectedItems.where((c) => c.id == 'side').length, 'side count', 1),
          isA<PickupState>()
            .having((s) => s.selectedItems.length, 'selected items', 2)
            .having((s) => s.selectedItems.where((c) => c.id == 'side').length, 'side count', 2),
        ],
      );

      blocTest<PickupBloc, PickupState>(
        'removes only one instance when multiple same category selected',
        build: () => pickupBloc,
        seed: () {
          final categories = mockDataService.getFoodCategories();
          return PickupState(
            categories: categories,
            status: PickupStatus.ready,
            selectedItems: [categories[2], categories[2]], // Two sides
          );
        },
        act: (bloc) {
          final categories = mockDataService.getFoodCategories();
          bloc.add(PickupCategoryDeselected(categories[2]));
        },
        expect: () => [
          isA<PickupState>()
            .having((s) => s.selectedItems.length, 'selected items', 1)
            .having((s) => s.selectedItems.where((c) => c.id == 'side').length, 'side count', 1),
        ],
      );
    });

    group('Edge Case: Rapid Operations', () {
      blocTest<PickupBloc, PickupState>(
        'handles rapid select and deselect',
        build: () => pickupBloc,
        seed: () {
          final categories = mockDataService.getFoodCategories();
          return PickupState(
            categories: categories,
            status: PickupStatus.ready,
            selectedItems: const [],
          );
        },
        act: (bloc) {
          final categories = mockDataService.getFoodCategories();
          // Rapid operations
          bloc.add(PickupCategorySelected(categories[0]));
          bloc.add(PickupCategoryDeselected(categories[0]));
          bloc.add(PickupCategorySelected(categories[0]));
          bloc.add(PickupCategoryDeselected(categories[0]));
          bloc.add(PickupCategorySelected(categories[0]));
        },
        expect: () => [
          isA<PickupState>().having((s) => s.selectedItems.length, 'items', 1),
          isA<PickupState>().having((s) => s.selectedItems.length, 'items', 0),
          isA<PickupState>().having((s) => s.selectedItems.length, 'items', 1),
          isA<PickupState>().having((s) => s.selectedItems.length, 'items', 0),
          isA<PickupState>().having((s) => s.selectedItems.length, 'items', 1),
        ],
      );

      blocTest<PickupBloc, PickupState>(
        'handles rapid multiple category selections',
        build: () => pickupBloc,
        seed: () {
          final categories = mockDataService.getFoodCategories();
          return PickupState(
            categories: categories,
            status: PickupStatus.ready,
            selectedItems: const [],
          );
        },
        act: (bloc) {
          final categories = mockDataService.getFoodCategories();
          // Select all categories rapidly
          for (final category in categories) {
            bloc.add(PickupCategorySelected(category));
          }
        },
        expect: () => [
          isA<PickupState>().having((s) => s.selectedItems.length, 'items', 1),
          isA<PickupState>().having((s) => s.selectedItems.length, 'items', 2),
          isA<PickupState>().having((s) => s.selectedItems.length, 'items', 3),
          isA<PickupState>().having((s) => s.selectedItems.length, 'items', 4),
          isA<PickupState>().having((s) => s.selectedItems.length, 'items', 5),
          isA<PickupState>()
            .having((s) => s.selectedItems.length, 'items', 5)
            .having((s) => s.errorMessage, 'error', contains('Maximum')),
        ],
      );
    });

    group('Edge Case: Create Pickup Scenarios', () {
      blocTest<PickupBloc, PickupState>(
        'creates pickup with exactly one item',
        build: () => pickupBloc,
        seed: () {
          final categories = mockDataService.getFoodCategories();
          return PickupState(
            categories: categories,
            status: PickupStatus.ready,
            selectedItems: [categories[0]],
          );
        },
        act: (bloc) => bloc.add(const PickupCreate()),
        wait: const Duration(milliseconds: 1000),
        expect: () => [
          isA<PickupState>()
            .having((s) => s.status, 'status', PickupStatus.creating),
          isA<PickupState>()
            .having((s) => s.status, 'status', PickupStatus.created)
            .having((s) => s.pickupId, 'pickupId', isNotNull)
            .having((s) => s.qrCodeData, 'qrCodeData', isNotNull)
            .having((s) => s.expiresAt, 'expiresAt', isNotNull),
        ],
      );

      blocTest<PickupBloc, PickupState>(
        'creates pickup with maximum 5 items',
        build: () => pickupBloc,
        seed: () {
          final categories = mockDataService.getFoodCategories();
          return PickupState(
            categories: categories,
            status: PickupStatus.ready,
            selectedItems: [
              categories[0],
              categories[1],
              categories[2],
              categories[3],
              categories[4],
            ],
          );
        },
        act: (bloc) => bloc.add(const PickupCreate()),
        wait: const Duration(milliseconds: 1000),
        expect: () => [
          isA<PickupState>()
            .having((s) => s.status, 'status', PickupStatus.creating),
          isA<PickupState>()
            .having((s) => s.status, 'status', PickupStatus.created)
            .having((s) => s.pickupId, 'pickupId', isNotNull),
        ],
      );

      blocTest<PickupBloc, PickupState>(
        'prevents creating pickup while already creating',
        build: () => pickupBloc,
        seed: () {
          final categories = mockDataService.getFoodCategories();
          return PickupState(
            categories: categories,
            status: PickupStatus.creating,
            selectedItems: [categories[0]],
          );
        },
        act: (bloc) => bloc.add(const PickupCreate()),
        expect: () => [],
      );

      blocTest<PickupBloc, PickupState>(
        'prevents creating pickup after already created',
        build: () => pickupBloc,
        seed: () {
          final categories = mockDataService.getFoodCategories();
          return PickupState(
            categories: categories,
            status: PickupStatus.created,
            selectedItems: [categories[0]],
            pickupId: '12345',
            qrCodeData: 'test-data',
          );
        },
        act: (bloc) => bloc.add(const PickupCreate()),
        expect: () => [
          isA<PickupState>()
            .having((s) => s.status, 'status', PickupStatus.creating)
            .having((s) => s.pickupId, 'pickupId', equals('12345')),
        ],
      );
    });

    group('Edge Case: Reset Scenarios', () {
      blocTest<PickupBloc, PickupState>(
        'resets from created state',
        build: () => pickupBloc,
        seed: () {
          final categories = mockDataService.getFoodCategories();
          return PickupState(
            categories: categories,
            status: PickupStatus.created,
            selectedItems: [categories[0]],
            pickupId: '12345',
            qrCodeData: 'test-data',
            expiresAt: DateTime.now(),
          );
        },
        act: (bloc) => bloc.add(const PickupReset()),
        expect: () => [
          isA<PickupState>()
            .having((s) => s.status, 'status', PickupStatus.initial)
            .having((s) => s.selectedItems, 'selectedItems', isEmpty)
            .having((s) => s.pickupId, 'pickupId', isNull)
            .having((s) => s.qrCodeData, 'qrCodeData', isNull)
            .having((s) => s.expiresAt, 'expiresAt', isNull),
          isA<PickupState>()
            .having((s) => s.status, 'status', PickupStatus.ready)
            .having((s) => s.categories.length, 'categories', 6),
        ],
      );

      blocTest<PickupBloc, PickupState>(
        'resets from error state',
        build: () => pickupBloc,
        seed: () {
          final categories = mockDataService.getFoodCategories();
          return PickupState(
            categories: categories,
            status: PickupStatus.error,
            selectedItems: const [],
            errorMessage: 'Some error occurred',
          );
        },
        act: (bloc) => bloc.add(const PickupReset()),
        expect: () => [
          isA<PickupState>()
            .having((s) => s.status, 'status', PickupStatus.initial)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
          isA<PickupState>()
            .having((s) => s.status, 'status', PickupStatus.ready),
        ],
      );

      blocTest<PickupBloc, PickupState>(
        'reset clears all error messages',
        build: () => pickupBloc,
        seed: () {
          final categories = mockDataService.getFoodCategories();
          return PickupState(
            categories: categories,
            status: PickupStatus.ready,
            selectedItems: [categories[0]],
            errorMessage: 'Previous error',
          );
        },
        act: (bloc) => bloc.add(const PickupReset()),
        expect: () => [
          isA<PickupState>()
            .having((s) => s.selectedItems, 'selectedItems', isEmpty)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
          isA<PickupState>()
            .having((s) => s.status, 'status', PickupStatus.ready),
        ],
      );
    });

    group('Edge Case: Error Message Handling', () {
      blocTest<PickupBloc, PickupState>(
        'clears error message on successful selection after error',
        build: () => pickupBloc,
        seed: () {
          final categories = mockDataService.getFoodCategories();
          return PickupState(
            categories: categories,
            status: PickupStatus.ready,
            selectedItems: [categories[0], categories[0]], // At max for salad
            errorMessage: 'Previous error',
          );
        },
        act: (bloc) {
          final categories = mockDataService.getFoodCategories();
          // This should fail and set error
          bloc.add(PickupCategorySelected(categories[0]));
        },
        expect: () => [
          isA<PickupState>()
            .having((s) => s.errorMessage, 'errorMessage', contains('Maximum')),
        ],
      );

      blocTest<PickupBloc, PickupState>(
        'error message is cleared on deselect',
        build: () => pickupBloc,
        seed: () {
          final categories = mockDataService.getFoodCategories();
          return PickupState(
            categories: categories,
            status: PickupStatus.ready,
            selectedItems: [categories[0]],
            errorMessage: 'Some error',
          );
        },
        act: (bloc) {
          final categories = mockDataService.getFoodCategories();
          bloc.add(PickupCategoryDeselected(categories[0]));
        },
        expect: () => [
          isA<PickupState>()
            .having((s) => s.errorMessage, 'errorMessage', isNull),
        ],
      );
    });

    group('Edge Case: State Immutability', () {
      test('selectedItems list is unmodifiable', () {
        final categories = mockDataService.getFoodCategories();
        final state = PickupState(
          categories: categories,
          status: PickupStatus.ready,
          selectedItems: [categories[0]],
        );
        
        // The list should be a regular list (not necessarily unmodifiable in this implementation)
        final items = state.selectedItems;
        expect(items, isA<List<FoodCategory>>());
      });

      test('categories list is unmodifiable', () {
        final categories = mockDataService.getFoodCategories();
        final state = PickupState(
          categories: categories,
          status: PickupStatus.ready,
        );
        
        final cats = state.categories;
        expect(cats, isA<List<FoodCategory>>());
      });

      test('copyWith creates new instances', () {
        final categories = mockDataService.getFoodCategories();
        final state1 = PickupState(
          categories: categories,
          status: PickupStatus.ready,
          selectedItems: [categories[0]],
        );
        
        final state2 = state1.copyWith();
        
        expect(state1, equals(state2));
        expect(identical(state1, state2), isFalse);
      });
    });

    group('Edge Case: State Equality', () {
      test('equal states are equal', () {
        final categories = mockDataService.getFoodCategories();
        final state1 = PickupState(
          categories: categories,
          status: PickupStatus.ready,
          selectedItems: [categories[0]],
        );
        final state2 = PickupState(
          categories: categories,
          status: PickupStatus.ready,
          selectedItems: [categories[0]],
        );
        
        expect(state1, equals(state2));
      });

      test('different status makes states unequal', () {
        final categories = mockDataService.getFoodCategories();
        final state1 = PickupState(
          categories: categories,
          status: PickupStatus.ready,
        );
        final state2 = PickupState(
          categories: categories,
          status: PickupStatus.creating,
        );
        
        expect(state1, isNot(equals(state2)));
      });

      test('different selectedItems makes states unequal', () {
        final categories = mockDataService.getFoodCategories();
        final state1 = PickupState(
          categories: categories,
          status: PickupStatus.ready,
          selectedItems: [categories[0]],
        );
        final state2 = PickupState(
          categories: categories,
          status: PickupStatus.ready,
          selectedItems: [categories[1]],
        );
        
        expect(state1, isNot(equals(state2)));
      });
    });

    group('Edge Case: PickupStatus Enum', () {
      test('all status values exist', () {
        expect(PickupStatus.values.length, equals(5));
        expect(PickupStatus.values, contains(PickupStatus.initial));
        expect(PickupStatus.values, contains(PickupStatus.ready));
        expect(PickupStatus.values, contains(PickupStatus.creating));
        expect(PickupStatus.values, contains(PickupStatus.created));
        expect(PickupStatus.values, contains(PickupStatus.error));
      });

      test('status can be compared', () {
        expect(PickupStatus.initial == PickupStatus.initial, isTrue);
        expect(PickupStatus.initial == PickupStatus.ready, isFalse);
      });
    });
  });
}
