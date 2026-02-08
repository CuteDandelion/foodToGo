import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodbegood/features/pickup/presentation/bloc/pickup_bloc.dart';
import 'package:foodbegood/shared/services/mock_data_service.dart';

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

  group('PickupBloc', () {
    test('initial state is correct', () {
      expect(pickupBloc.state.status, PickupStatus.initial);
      expect(pickupBloc.state.selectedItems, isEmpty);
      expect(pickupBloc.state.categories, isEmpty);
    });

    group('PickupLoadCategories', () {
      blocTest<PickupBloc, PickupState>(
        'emits [ready] with categories when loaded',
        build: () => pickupBloc,
        act: (bloc) => bloc.add(const PickupLoadCategories()),
        expect: () => [
          isA<PickupState>()
            .having((s) => s.status, 'status', PickupStatus.ready)
            .having((s) => s.categories.length, 'categories length', 6),
        ],
      );
    });

    group('PickupCategorySelected', () {
      blocTest<PickupBloc, PickupState>(
        'adds category to selected items',
        build: () => pickupBloc,
        seed: () => PickupState(
          categories: mockDataService.getFoodCategories(),
          status: PickupStatus.ready,
        ),
        act: (bloc) {
          final categories = mockDataService.getFoodCategories();
          bloc.add(PickupCategorySelected(categories[0]));
        },
        expect: () => [
          isA<PickupState>()
            .having((s) => s.selectedItems.length, 'selected items', 1),
        ],
      );

      blocTest<PickupBloc, PickupState>(
        'does not exceed max per pickup',
        build: () => pickupBloc,
        seed: () => PickupState(
          categories: mockDataService.getFoodCategories(),
          status: PickupStatus.ready,
          selectedItems: [mockDataService.getFoodCategories()[0]],
        ),
        act: (bloc) {
          final categories = mockDataService.getFoodCategories();
          // Salad has maxPerPickup of 1
          bloc.add(PickupCategorySelected(categories[0]));
        },
        expect: () => [
          isA<PickupState>()
            .having((s) => s.errorMessage, 'error message', isNotNull),
        ],
      );

      blocTest<PickupBloc, PickupState>(
        'does not exceed total limit of 5 items',
        build: () => pickupBloc,
        seed: () {
          final categories = mockDataService.getFoodCategories();
          // Use different categories to avoid max per pickup limit
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
            .having((s) => s.errorMessage, 'error message', 'Maximum 5 items per pickup'),
        ],
      );
    });

    group('PickupCategoryDeselected', () {
      blocTest<PickupBloc, PickupState>(
        'removes category from selected items',
        build: () => pickupBloc,
        seed: () {
          final categories = mockDataService.getFoodCategories();
          return PickupState(
            categories: categories,
            status: PickupStatus.ready,
            selectedItems: [categories[0], categories[1]],
          );
        },
        act: (bloc) {
          final categories = mockDataService.getFoodCategories();
          bloc.add(PickupCategoryDeselected(categories[0]));
        },
        expect: () => [
          isA<PickupState>()
            .having((s) => s.selectedItems.length, 'selected items', 1),
        ],
      );
    });

    group('PickupClearSelection', () {
      blocTest<PickupBloc, PickupState>(
        'clears all selected items',
        build: () => pickupBloc,
        seed: () {
          final categories = mockDataService.getFoodCategories();
          return PickupState(
            categories: categories,
            status: PickupStatus.ready,
            selectedItems: [categories[0], categories[1]],
          );
        },
        act: (bloc) => bloc.add(const PickupClearSelection()),
        expect: () => [
          isA<PickupState>()
            .having((s) => s.selectedItems, 'selected items', isEmpty),
        ],
      );
    });

    group('PickupCreate', () {
      blocTest<PickupBloc, PickupState>(
        'emits [creating, created] with QR code data',
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
            .having((s) => s.qrCodeData, 'qr code data', isNotNull)
            .having((s) => s.expiresAt, 'expires at', isNotNull),
        ],
      );

      blocTest<PickupBloc, PickupState>(
        'shows error when no items selected',
        build: () => pickupBloc,
        seed: () => PickupState(
          categories: mockDataService.getFoodCategories(),
          status: PickupStatus.ready,
          selectedItems: const [],
        ),
        act: (bloc) => bloc.add(const PickupCreate()),
        expect: () => [
          isA<PickupState>()
            .having((s) => s.errorMessage, 'error message', 'Please select at least one item'),
        ],
      );
    });

    group('PickupReset', () {
      blocTest<PickupBloc, PickupState>(
        'resets to initial state and reloads categories',
        build: () => pickupBloc,
        seed: () {
          final categories = mockDataService.getFoodCategories();
          return PickupState(
            categories: categories,
            status: PickupStatus.created,
            selectedItems: [categories[0]],
            pickupId: '123',
            qrCodeData: 'data',
          );
        },
        act: (bloc) => bloc.add(const PickupReset()),
        expect: () => [
          isA<PickupState>()
            .having((s) => s.status, 'status', PickupStatus.initial)
            .having((s) => s.selectedItems, 'selected items', isEmpty),
          isA<PickupState>()
            .having((s) => s.status, 'status', PickupStatus.ready)
            .having((s) => s.categories.length, 'categories', 6),
        ],
      );
    });
  });
}
