part of 'pickup_bloc.dart';

/// Status of pickup flow
enum PickupStatus {
  initial,
  ready,
  creating,
  created,
  error,
}

/// State for PickupBloc
class PickupState extends Equatable {
  final List<FoodCategory> categories;
  final List<FoodCategory> selectedItems;
  final PickupStatus status;
  final String? pickupId;
  final String? qrCodeData;
  final DateTime? expiresAt;
  final String? errorMessage;

  const PickupState({
    this.categories = const [],
    this.selectedItems = const [],
    this.status = PickupStatus.initial,
    this.pickupId,
    this.qrCodeData,
    this.expiresAt,
    this.errorMessage,
  });

  PickupState copyWith({
    List<FoodCategory>? categories,
    List<FoodCategory>? selectedItems,
    PickupStatus? status,
    String? pickupId,
    String? qrCodeData,
    DateTime? expiresAt,
    String? errorMessage,
  }) {
    return PickupState(
      categories: categories ?? this.categories,
      selectedItems: selectedItems ?? this.selectedItems,
      status: status ?? this.status,
      pickupId: pickupId ?? this.pickupId,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      expiresAt: expiresAt ?? this.expiresAt,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        selectedItems,
        status,
        pickupId,
        qrCodeData,
        expiresAt,
        errorMessage,
      ];
}
