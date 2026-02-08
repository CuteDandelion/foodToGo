import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodbegood/shared/services/mock_data_service.dart';

part 'pickup_event.dart';
part 'pickup_state.dart';

/// BLoC for managing pickup flow
class PickupBloc extends Bloc<PickupEvent, PickupState> {
  final MockDataService _mockDataService;

  PickupBloc({MockDataService? mockDataService})
      : _mockDataService = mockDataService ?? MockDataService(),
        super(const PickupState()) {
    on<PickupLoadCategories>(_onLoadCategories);
    on<PickupCategorySelected>(_onCategorySelected);
    on<PickupCategoryDeselected>(_onCategoryDeselected);
    on<PickupClearSelection>(_onClearSelection);
    on<PickupCreate>(_onCreatePickup);
    on<PickupReset>(_onReset);
  }

  void _onLoadCategories(
    PickupLoadCategories event,
    Emitter<PickupState> emit,
  ) {
    final categories = _mockDataService.getFoodCategories();
    emit(state.copyWith(
      categories: categories,
      status: PickupStatus.ready,
    ));
  }

  void _onCategorySelected(
    PickupCategorySelected event,
    Emitter<PickupState> emit,
  ) {
    final category = event.category;
    
    // Check if already selected
    final currentCount = state.selectedItems.where((c) => c.id == category.id).length;
    
    // Check max limit
    if (currentCount >= category.maxPerPickup) {
      emit(state.copyWith(
        errorMessage: 'Maximum ${category.maxPerPickup} ${category.name} per pickup',
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

    final updatedItems = [...state.selectedItems, category];
    emit(state.copyWith(
      selectedItems: updatedItems,
      errorMessage: null,
    ));
  }

  void _onCategoryDeselected(
    PickupCategoryDeselected event,
    Emitter<PickupState> emit,
  ) {
    final updatedItems = [...state.selectedItems];
    final index = updatedItems.indexWhere((c) => c.id == event.category.id);
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

  Future<void> _onCreatePickup(
    PickupCreate event,
    Emitter<PickupState> emit,
  ) async {
    if (state.selectedItems.isEmpty) {
      emit(state.copyWith(
        errorMessage: 'Please select at least one item',
      ));
      return;
    }

    emit(state.copyWith(status: PickupStatus.creating));

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    final pickupId = DateTime.now().millisecondsSinceEpoch.toString();
    final qrCodeData = _mockDataService.generateQRCodeData(pickupId);
    final expiresAt = DateTime.now().add(const Duration(minutes: 5));

    emit(state.copyWith(
      status: PickupStatus.created,
      pickupId: pickupId,
      qrCodeData: qrCodeData,
      expiresAt: expiresAt,
    ));
  }

  void _onReset(
    PickupReset event,
    Emitter<PickupState> emit,
  ) {
    emit(const PickupState(
      categories: [],
      selectedItems: [],
      status: PickupStatus.initial,
    ));
    add(const PickupLoadCategories());
  }
}
