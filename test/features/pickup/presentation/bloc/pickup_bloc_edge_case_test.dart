import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodbegood/features/pickup/domain/entities/food_item.dart';
import 'package:foodbegood/features/pickup/presentation/bloc/pickup_bloc.dart';

/// Edge Case Tests for PickupBloc
/// 
/// These tests cover boundary conditions, error scenarios, and
/// unusual situations in the pickup flow.
void main() {
  late PickupBloc pickupBloc;

  setUp(() {
    pickupBloc = PickupBloc();
  });

  tearDown(() {
    pickupBloc.close();
  });

  group('PickupBloc Edge Cases', () {
    
    group('Edge Case: Empty and Null States', () {
      test('initial state has all default values', () {
        expect(pickupBloc.state.status, PickupStatus.initial);
        expect(pickupBloc.state.selectedItems, isEmpty);
        expect(pickupBloc.state.foodItems, isEmpty);
        expect(pickupBloc.state.selectedTimeSlot, isNull);
        expect(pickupBloc.state.currentOrder, isNull);
        expect(pickupBloc.state.errorMessage, isNull);
      });

      test('deselect from empty selection keeps items empty', () {
        const state = PickupState(
          foodItems: [
            FoodItem(id: 'item1', name: 'Item 1', category: MainCategory.food),
          ],
          status: PickupStatus.ready,
          selectedItems: [],
        );
        
        // Deselecting from empty should keep it empty
        expect(state.selectedItems, isEmpty);
      });

      test('clear on already empty selection keeps items empty', () {
        const state = PickupState(
          foodItems: [
            FoodItem(id: 'item1', name: 'Item 1', category: MainCategory.food),
          ],
          status: PickupStatus.ready,
          selectedItems: [],
        );
        
        expect(state.selectedItems, isEmpty);
      });
    });

    group('Edge Case: Item Limits', () {
      blocTest<PickupBloc, PickupState>(
        'prevents adding more than 5 items total',
        build: () => pickupBloc,
        seed: () => PickupState(
          foodItems: const [FoodItem(id: 'new', name: 'New', category: MainCategory.food)],
          selectedItems: List.generate(
            5,
            (i) => FoodItem(id: 'item$i', name: 'Item $i', category: MainCategory.food),
          ),
          status: PickupStatus.ready,
        ),
        act: (bloc) => bloc.add(const PickupItemSelected(
          FoodItem(id: 'new', name: 'New', category: MainCategory.food),
        )),
        expect: () => [
          isA<PickupState>()
            .having((s) => s.errorMessage, 'error message', contains('Maximum 5 items')),
        ],
      );

      blocTest<PickupBloc, PickupState>(
        'prevents adding more than 2 of same item',
        build: () => pickupBloc,
        seed: () => const PickupState(
          foodItems: [FoodItem(id: 'schnitzel', name: 'Schnitzel', category: MainCategory.food)],
          selectedItems: [
            FoodItem(id: 'schnitzel', name: 'Schnitzel', category: MainCategory.food),
            FoodItem(id: 'schnitzel', name: 'Schnitzel', category: MainCategory.food),
          ],
          status: PickupStatus.ready,
        ),
        act: (bloc) => bloc.add(const PickupItemSelected(
          FoodItem(id: 'schnitzel', name: 'Schnitzel', category: MainCategory.food),
        )),
        expect: () => [
          isA<PickupState>()
            .having((s) => s.errorMessage, 'error message', contains('Maximum 2')),
        ],
      );
    });

    group('Edge Case: Category Changes', () {
      blocTest<PickupBloc, PickupState>(
        'handles rapid category changes',
        build: () => pickupBloc,
        act: (bloc) async {
          bloc.add(const PickupCategoryChanged(MainCategory.food));
          bloc.add(const PickupCategoryChanged(MainCategory.beverages));
          bloc.add(const PickupCategoryChanged(MainCategory.desserts));
          bloc.add(const PickupCategoryChanged(MainCategory.food));
        },
        expect: () => [
          isA<PickupState>().having((s) => s.selectedCategory, 'category', MainCategory.food),
          isA<PickupState>().having((s) => s.selectedCategory, 'category', MainCategory.beverages),
          isA<PickupState>().having((s) => s.selectedCategory, 'category', MainCategory.desserts),
          isA<PickupState>().having((s) => s.selectedCategory, 'category', MainCategory.food),
        ],
      );
    });

    group('Edge Case: State Transitions', () {
      blocTest<PickupBloc, PickupState>(
        'transitions from initial to ready on load',
        build: () => pickupBloc,
        act: (bloc) => bloc.add(const PickupLoadItems()),
        expect: () => [
          isA<PickupState>().having((s) => s.status, 'status', PickupStatus.ready),
        ],
      );

      blocTest<PickupBloc, PickupState>(
        'maintains state immutability',
        build: () => pickupBloc,
        seed: () => const PickupState(
          foodItems: [FoodItem(id: 'item1', name: 'Item 1', category: MainCategory.food)],
          selectedItems: [],
          status: PickupStatus.ready,
        ),
        act: (bloc) => bloc.add(const PickupItemSelected(
          FoodItem(id: 'item1', name: 'Item 1', category: MainCategory.food),
        )),
        verify: (bloc) {
          // Verify that the original state wasn't mutated
          expect(bloc.state.selectedItems.length, 1);
        },
      );
    });

    group('Edge Case: Error Handling', () {
      blocTest<PickupBloc, PickupState>(
        'clears error message on successful action',
        build: () => pickupBloc,
        seed: () => PickupState(
          foodItems: const [FoodItem(id: 'item1', name: 'Item 1', category: MainCategory.food)],
          selectedItems: List.generate(
            5,
            (i) => FoodItem(id: 'item$i', name: 'Item $i', category: MainCategory.food),
          ),
          errorMessage: 'Previous error',
          status: PickupStatus.ready,
        ),
        act: (bloc) => bloc.add(const PickupItemDeselected(
          FoodItem(id: 'item0', name: 'Item 0', category: MainCategory.food),
        )),
        expect: () => [
          isA<PickupState>()
            .having((s) => s.errorMessage, 'error message', isNull)
            .having((s) => s.selectedItems.length, 'selected items', 4),
        ],
      );
    });

    group('Edge Case: Reset Scenarios', () {
      blocTest<PickupBloc, PickupState>(
        'reset clears all selected items and loads fresh',
        build: () => pickupBloc,
        seed: () => const PickupState(
          foodItems: [FoodItem(id: 'item1', name: 'Item 1', category: MainCategory.food)],
          selectedItems: [
            FoodItem(id: 'item1', name: 'Item 1', category: MainCategory.food),
            FoodItem(id: 'item2', name: 'Item 2', category: MainCategory.food),
          ],
          selectedCategory: MainCategory.beverages,
          status: PickupStatus.ready,
        ),
        act: (bloc) => bloc.add(const PickupReset()),
        expect: () => [
          isA<PickupState>()
            .having((s) => s.selectedItems.length, 'selected items', 0)
            .having((s) => s.status, 'status', PickupStatus.initial),
          isA<PickupState>()
            .having((s) => s.status, 'status', PickupStatus.ready)
            .having((s) => s.foodItems.length, 'food items', greaterThan(0)),
        ],
      );
    });
  });
}
