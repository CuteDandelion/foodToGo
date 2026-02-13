part of 'pickup_bloc.dart';

/// Events for PickupBloc
abstract class PickupEvent extends Equatable {
  const PickupEvent();

  @override
  List<Object?> get props => [];
}

/// Load food items
class PickupLoadItems extends PickupEvent {
  const PickupLoadItems();
}

/// Select a food item
class PickupItemSelected extends PickupEvent {
  final FoodItem item;

  const PickupItemSelected(this.item);

  @override
  List<Object?> get props => [item];
}

/// Deselect a food item
class PickupItemDeselected extends PickupEvent {
  final FoodItem item;

  const PickupItemDeselected(this.item);

  @override
  List<Object?> get props => [item];
}

/// Clear all selections
class PickupClearSelection extends PickupEvent {
  const PickupClearSelection();
}

/// Change main category
class PickupCategoryChanged extends PickupEvent {
  final MainCategory category;

  const PickupCategoryChanged(this.category);

  @override
  List<Object?> get props => [category];
}

/// Load available time slots
class PickupLoadTimeSlots extends PickupEvent {
  final DateTime date;

  const PickupLoadTimeSlots(this.date);

  @override
  List<Object?> get props => [date];
}

/// Select a time slot
class PickupTimeSlotSelected extends PickupEvent {
  final TimeSlot timeSlot;

  const PickupTimeSlotSelected(this.timeSlot);

  @override
  List<Object?> get props => [timeSlot];
}

/// Submit order to canteen
class PickupSubmitToCanteen extends PickupEvent {
  const PickupSubmitToCanteen();
}

/// Reset pickup state
class PickupReset extends PickupEvent {
  const PickupReset();
}

/// Navigate to time slot selection
class PickupNavigateToTimeSlot extends PickupEvent {
  const PickupNavigateToTimeSlot();
}
