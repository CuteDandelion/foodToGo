part of 'pickup_bloc.dart';

/// Events for PickupBloc
abstract class PickupEvent extends Equatable {
  const PickupEvent();

  @override
  List<Object?> get props => [];
}

/// Load food categories
class PickupLoadCategories extends PickupEvent {
  const PickupLoadCategories();
}

/// Select a food category
class PickupCategorySelected extends PickupEvent {
  final FoodCategory category;

  const PickupCategorySelected(this.category);

  @override
  List<Object?> get props => [category];
}

/// Deselect a food category
class PickupCategoryDeselected extends PickupEvent {
  final FoodCategory category;

  const PickupCategoryDeselected(this.category);

  @override
  List<Object?> get props => [category];
}

/// Clear all selections
class PickupClearSelection extends PickupEvent {
  const PickupClearSelection();
}

/// Create pickup with selected items
class PickupCreate extends PickupEvent {
  const PickupCreate();
}

/// Reset pickup state
class PickupReset extends PickupEvent {
  const PickupReset();
}
