import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodbegood/features/pickup/domain/entities/food_item.dart';
import 'package:foodbegood/features/pickup/presentation/bloc/pickup_bloc.dart';

void main() {
  late PickupBloc pickupBloc;

  setUp(() {
    pickupBloc = PickupBloc();
  });

  tearDown(() {
    pickupBloc.close();
  });

  group('PickupBloc', () {
    test('initial state is correct', () {
      expect(pickupBloc.state.status, PickupStatus.initial);
      expect(pickupBloc.state.selectedItems, isEmpty);
      expect(pickupBloc.state.foodItems, isEmpty);
      expect(pickupBloc.state.selectedCategory, MainCategory.food);
    });

    group('PickupLoadItems', () {
      blocTest<PickupBloc, PickupState>(
        'emits [ready] with food items when loaded',
        build: () => pickupBloc,
        act: (bloc) => bloc.add(const PickupLoadItems()),
        expect: () => [
          isA<PickupState>()
              .having((s) => s.status, 'status', PickupStatus.ready)
              .having((s) => s.foodItems.length, 'food items length',
                  greaterThan(0)),
        ],
      );
    });

    group('PickupItemSelected', () {
      blocTest<PickupBloc, PickupState>(
        'adds item to selected items',
        build: () => pickupBloc,
        seed: () => const PickupState(
          foodItems: [
            FoodItem(
              id: 'schnitzel',
              name: 'Schnitzel',
              category: MainCategory.food,
            ),
          ],
          status: PickupStatus.ready,
        ),
        act: (bloc) {
          bloc.add(const PickupItemSelected(
            FoodItem(
              id: 'schnitzel',
              name: 'Schnitzel',
              category: MainCategory.food,
            ),
          ));
        },
        expect: () => [
          isA<PickupState>()
              .having((s) => s.selectedItems.length, 'selected items length', 1)
              .having((s) => s.selectedItems[0].id, 'selected item id',
                  'schnitzel'),
        ],
      );

      blocTest<PickupBloc, PickupState>(
        'emits error when max items reached',
        build: () => pickupBloc,
        seed: () => PickupState(
          foodItems: const [
            FoodItem(id: 'item1', name: 'Item 1', category: MainCategory.food),
          ],
          selectedItems: List.generate(
            5,
            (i) => FoodItem(
                id: 'item$i', name: 'Item $i', category: MainCategory.food),
          ),
          status: PickupStatus.ready,
        ),
        act: (bloc) {
          bloc.add(const PickupItemSelected(
            FoodItem(id: 'item1', name: 'Item 1', category: MainCategory.food),
          ));
        },
        expect: () => [
          isA<PickupState>()
              .having((s) => s.errorMessage, 'error message', isNotNull),
        ],
      );
    });

    group('PickupItemDeselected', () {
      blocTest<PickupBloc, PickupState>(
        'removes item from selected items',
        build: () => pickupBloc,
        seed: () => const PickupState(
          foodItems: [
            FoodItem(
                id: 'schnitzel',
                name: 'Schnitzel',
                category: MainCategory.food),
          ],
          selectedItems: [
            FoodItem(
                id: 'schnitzel',
                name: 'Schnitzel',
                category: MainCategory.food),
          ],
          status: PickupStatus.ready,
        ),
        act: (bloc) {
          bloc.add(const PickupItemDeselected(
            FoodItem(
                id: 'schnitzel',
                name: 'Schnitzel',
                category: MainCategory.food),
          ));
        },
        expect: () => [
          isA<PickupState>().having(
              (s) => s.selectedItems.length, 'selected items length', 0),
        ],
      );
    });

    group('PickupCategoryChanged', () {
      blocTest<PickupBloc, PickupState>(
        'changes selected category',
        build: () => pickupBloc,
        act: (bloc) =>
            bloc.add(const PickupCategoryChanged(MainCategory.beverages)),
        expect: () => [
          isA<PickupState>().having((s) => s.selectedCategory,
              'selected category', MainCategory.beverages),
        ],
      );
    });

    group('PickupClearSelection', () {
      blocTest<PickupBloc, PickupState>(
        'clears all selected items',
        build: () => pickupBloc,
        seed: () => const PickupState(
          selectedItems: [
            FoodItem(id: 'item1', name: 'Item 1', category: MainCategory.food),
            FoodItem(id: 'item2', name: 'Item 2', category: MainCategory.food),
          ],
          status: PickupStatus.ready,
        ),
        act: (bloc) => bloc.add(const PickupClearSelection()),
        expect: () => [
          isA<PickupState>().having(
              (s) => s.selectedItems.length, 'selected items length', 0),
        ],
      );
    });

    group('PickupReset', () {
      blocTest<PickupBloc, PickupState>(
        'resets to initial state and loads items',
        build: () => pickupBloc,
        seed: () => const PickupState(
          selectedItems: [
            FoodItem(id: 'item1', name: 'Item 1', category: MainCategory.food),
          ],
          status: PickupStatus.ready,
        ),
        act: (bloc) => bloc.add(const PickupReset()),
        expect: () => [
          isA<PickupState>()
              .having((s) => s.selectedItems.length, 'selected items length', 0)
              .having((s) => s.status, 'status', PickupStatus.initial),
          isA<PickupState>()
              .having((s) => s.status, 'status', PickupStatus.ready)
              .having((s) => s.foodItems.length, 'food items length',
                  greaterThan(0)),
        ],
      );
    });
  });
}
