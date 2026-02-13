import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/food_item.dart';

part 'pickup_event.dart';
part 'pickup_state.dart';

/// BLoC for managing pickup flow
class PickupBloc extends Bloc<PickupEvent, PickupState> {
  PickupBloc() : super(const PickupState()) {
    on<PickupLoadItems>(_onLoadItems);
    on<PickupItemSelected>(_onItemSelected);
    on<PickupItemDeselected>(_onItemDeselected);
    on<PickupClearSelection>(_onClearSelection);
    on<PickupCategoryChanged>(_onCategoryChanged);
    on<PickupLoadTimeSlots>(_onLoadTimeSlots);
    on<PickupTimeSlotSelected>(_onTimeSlotSelected);
    on<PickupSubmitToCanteen>(_onSubmitToCanteen);
    on<PickupReset>(_onReset);
    on<PickupNavigateToTimeSlot>(_onNavigateToTimeSlot);
  }

  void _onLoadItems(
    PickupLoadItems event,
    Emitter<PickupState> emit,
  ) {
    // Load German food items
    final foodItems = _getGermanFoodItems();
    emit(state.copyWith(
      foodItems: foodItems,
      status: PickupStatus.ready,
    ));
  }

  void _onItemSelected(
    PickupItemSelected event,
    Emitter<PickupState> emit,
  ) {
    final item = event.item;
    
    // Check if already at max for this item type (max 2 per item)
    final currentCount = state.selectedItems.where((i) => i.id == item.id).length;
    if (currentCount >= 2) {
      emit(state.copyWith(
        errorMessage: 'Maximum 2 ${item.name} per pickup',
      ));
      return;
    }

    // Check total items limit (max 5)
    if (state.selectedItems.length >= 5) {
      emit(state.copyWith(
        errorMessage: 'Maximum 5 items per pickup',
      ));
      return;
    }

    final updatedItems = [...state.selectedItems, item];
    emit(state.copyWith(
      selectedItems: updatedItems,
      errorMessage: null,
    ));
  }

  void _onItemDeselected(
    PickupItemDeselected event,
    Emitter<PickupState> emit,
  ) {
    final updatedItems = [...state.selectedItems];
    final index = updatedItems.indexWhere((i) => i.id == event.item.id);
    if (index != -1) {
      updatedItems.removeAt(index);
    }
    emit(state.copyWith(
      selectedItems: updatedItems,
      errorMessage: null,
    ));
  }

  void _onClearSelection(
    PickupClearSelection event,
    Emitter<PickupState> emit,
  ) {
    emit(state.copyWith(
      selectedItems: [],
      errorMessage: null,
    ));
  }

  void _onCategoryChanged(
    PickupCategoryChanged event,
    Emitter<PickupState> emit,
  ) {
    emit(state.copyWith(
      selectedCategory: event.category,
      errorMessage: null,
    ));
  }

  Future<void> _onLoadTimeSlots(
    PickupLoadTimeSlots event,
    Emitter<PickupState> emit,
  ) async {
    emit(state.copyWith(status: PickupStatus.loading));
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    final timeSlots = _generateTimeSlots(event.date);
    emit(state.copyWith(
      availableTimeSlots: timeSlots,
      status: PickupStatus.selectingTimeSlot,
    ));
  }

  void _onTimeSlotSelected(
    PickupTimeSlotSelected event,
    Emitter<PickupState> emit,
  ) {
    emit(state.copyWith(
      selectedTimeSlot: event.timeSlot,
      errorMessage: null,
    ));
  }

  Future<void> _onSubmitToCanteen(
    PickupSubmitToCanteen event,
    Emitter<PickupState> emit,
  ) async {
    if (state.selectedItems.isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Please select at least one item',
      ));
      return;
    }

    if (state.selectedTimeSlot == null) {
      emit(state.copyWith(
        errorMessage: 'Please select a pickup time',
      ));
      return;
    }

    emit(state.copyWith(status: PickupStatus.confirming));

    // Simulate API call to canteen
    await Future.delayed(const Duration(milliseconds: 1200));

    final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';
    final order = PickupOrder(
      id: orderId,
      items: state.selectedItems,
      timeSlot: state.selectedTimeSlot!,
      createdAt: DateTime.now(),
      status: 'confirmed',
      canteenMessage: 'Your order has been received and is being prepared!',
    );

    emit(state.copyWith(
      status: PickupStatus.submitted,
      currentOrder: order,
      errorMessage: null,
    ));
  }

  void _onNavigateToTimeSlot(
    PickupNavigateToTimeSlot event,
    Emitter<PickupState> emit,
  ) {
    if (state.selectedItems.isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Please select at least one item first',
      ));
      return;
    }
    
    // Load time slots for today
    add(PickupLoadTimeSlots(DateTime.now()));
  }

  void _onReset(
    PickupReset event,
    Emitter<PickupState> emit,
  ) {
    emit(const PickupState(
      foodItems: [],
      selectedItems: [],
      selectedCategory: MainCategory.food,
      availableTimeSlots: [],
      status: PickupStatus.initial,
    ));
    add(const PickupLoadItems());
  }

  /// Get German food items
  List<FoodItem> _getGermanFoodItems() {
    return [
      // Food items
      const FoodItem(
        id: 'schnitzel',
        name: 'Schnitzel',
        category: MainCategory.food,
        subCategory: 'Main',
        localImagePath: 'assets/images/food/schnitzel.jpg',
      ),
      const FoodItem(
        id: 'bratwurst',
        name: 'Bratwurst',
        category: MainCategory.food,
        subCategory: 'Main',
        localImagePath: 'assets/images/food/bratwurst.jpg',
      ),
      const FoodItem(
        id: 'spaetzle',
        name: 'Spätzle',
        category: MainCategory.food,
        subCategory: 'Side',
        localImagePath: 'assets/images/food/spaetzle.jpg',
      ),
      const FoodItem(
        id: 'potato_salad',
        name: 'Kartoffelsalat',
        category: MainCategory.food,
        subCategory: 'Side',
        localImagePath: 'assets/images/food/potato_salad.jpg',
      ),
      const FoodItem(
        id: 'sauerkraut',
        name: 'Sauerkraut',
        category: MainCategory.food,
        subCategory: 'Side',
        localImagePath: 'assets/images/food/sauerkraut.jpg',
      ),
      // Beverages
      const FoodItem(
        id: 'apfelschorle',
        name: 'Apfelschorle',
        category: MainCategory.beverages,
        subCategory: 'Drink',
        localImagePath: 'assets/images/food/apfelschorle.jpg',
      ),
      const FoodItem(
        id: 'spezi',
        name: 'Spezi',
        category: MainCategory.beverages,
        subCategory: 'Drink',
        localImagePath: 'assets/images/food/spezi.jpg',
      ),
      const FoodItem(
        id: 'mineralwasser',
        name: 'Mineralwasser',
        category: MainCategory.beverages,
        subCategory: 'Drink',
        localImagePath: 'assets/images/food/mineralwasser.jpg',
      ),
      // Desserts
      const FoodItem(
        id: 'apfelstrudel',
        name: 'Apfelstrudel',
        category: MainCategory.desserts,
        subCategory: 'Dessert',
        localImagePath: 'assets/images/food/apfelstrudel.jpg',
      ),
      const FoodItem(
        id: 'black_forest',
        name: 'Schwarzwälder Kirschtorte',
        category: MainCategory.desserts,
        subCategory: 'Dessert',
        localImagePath: 'assets/images/food/black_forest.jpg',
      ),
      const FoodItem(
        id: 'lebkuchen',
        name: 'Lebkuchen',
        category: MainCategory.desserts,
        subCategory: 'Dessert',
        localImagePath: 'assets/images/food/lebkuchen.jpg',
      ),
    ];
  }

  /// Generate time slots for a given date
  List<TimeSlot> _generateTimeSlots(DateTime date) {
    final slots = <TimeSlot>[];
    // Canteen hours: 11:00 - 14:00, every 30 minutes
    const startHour = 11;
    const endHour = 14;
    
    for (int hour = startHour; hour < endHour; hour++) {
      for (int minute in [0, 30]) {
        final timeString = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        final isAvailable = _isTimeSlotAvailable(date, hour, minute);
        
        slots.add(TimeSlot(
          id: '${date.year}${date.month}${date.day}_$timeString',
          date: date,
          time: timeString,
          isAvailable: isAvailable,
          availableSpots: isAvailable ? (5 + (hour * minute) % 10) : 0,
        ));
      }
    }
    
    return slots;
  }

  /// Check if a time slot is available (mock logic)
  bool _isTimeSlotAvailable(DateTime date, int hour, int minute) {
    final now = DateTime.now();
    final slotTime = DateTime(date.year, date.month, date.day, hour, minute);
    
    // Don't show past time slots
    if (slotTime.isBefore(now)) {
      return false;
    }
    
    // Randomly make some slots unavailable for realism
    final hash = (date.day + hour + minute).hashCode;
    return hash % 5 != 0; // 80% availability
  }
}
