part of 'pickup_bloc.dart';

/// Status of pickup flow
enum PickupStatus {
  initial,
  loading,
  ready,
  selectingTimeSlot,
  confirming,
  submitted,
  error,
}

/// State for PickupBloc
class PickupState extends Equatable {
  final List<FoodItem> foodItems;
  final List<FoodItem> selectedItems;
  final MainCategory selectedCategory;
  final List<TimeSlot> availableTimeSlots;
  final TimeSlot? selectedTimeSlot;
  final PickupStatus status;
  final PickupOrder? currentOrder;
  final String? errorMessage;

  const PickupState({
    this.foodItems = const [],
    this.selectedItems = const [],
    this.selectedCategory = MainCategory.food,
    this.availableTimeSlots = const [],
    this.selectedTimeSlot,
    this.status = PickupStatus.initial,
    this.currentOrder,
    this.errorMessage,
  });

  PickupState copyWith({
    List<FoodItem>? foodItems,
    List<FoodItem>? selectedItems,
    MainCategory? selectedCategory,
    List<TimeSlot>? availableTimeSlots,
    TimeSlot? selectedTimeSlot,
    PickupStatus? status,
    PickupOrder? currentOrder,
    String? errorMessage,
  }) {
    return PickupState(
      foodItems: foodItems ?? this.foodItems,
      selectedItems: selectedItems ?? this.selectedItems,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      status: status ?? this.status,
      currentOrder: currentOrder ?? this.currentOrder,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        foodItems,
        selectedItems,
        selectedCategory,
        availableTimeSlots,
        selectedTimeSlot,
        status,
        currentOrder,
        errorMessage,
      ];
}
