import 'package:equatable/equatable.dart';

/// Main food categories
enum MainCategory {
  food,
  beverages,
  desserts,
}

/// Extension to get display name for main category
extension MainCategoryExtension on MainCategory {
  String get displayName {
    switch (this) {
      case MainCategory.food:
        return 'Food';
      case MainCategory.beverages:
        return 'Beverages';
      case MainCategory.desserts:
        return 'Desserts';
    }
  }

  String get icon {
    switch (this) {
      case MainCategory.food:
        return '🍽️';
      case MainCategory.beverages:
        return '🥤';
      case MainCategory.desserts:
        return '🍰';
    }
  }
}

/// Food item with image support
class FoodItem extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final String? localImagePath;
  final MainCategory category;
  final String? subCategory;
  final double? price;
  final bool isAvailable;

  const FoodItem({
    required this.id,
    required this.name,
    this.imageUrl,
    this.localImagePath,
    required this.category,
    this.subCategory,
    this.price,
    this.isAvailable = true,
  });

  FoodItem copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? localImagePath,
    MainCategory? category,
    String? subCategory,
    double? price,
    bool? isAvailable,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        imageUrl,
        localImagePath,
        category,
        subCategory,
        price,
        isAvailable,
      ];
}

/// Time slot for pickup
class TimeSlot extends Equatable {
  final String id;
  final DateTime date;
  final String time;
  final bool isAvailable;
  final int? availableSpots;

  const TimeSlot({
    required this.id,
    required this.date,
    required this.time,
    this.isAvailable = true,
    this.availableSpots,
  });

  DateTime get dateTime {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  TimeSlot copyWith({
    String? id,
    DateTime? date,
    String? time,
    bool? isAvailable,
    int? availableSpots,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      isAvailable: isAvailable ?? this.isAvailable,
      availableSpots: availableSpots ?? this.availableSpots,
    );
  }

  @override
  List<Object?> get props => [id, date, time, isAvailable, availableSpots];
}

/// Canteen request response
class CanteenResponse extends Equatable {
  final bool success;
  final String? pickupId;
  final String? message;
  final DateTime? scheduledTime;
  final String? error;

  const CanteenResponse({
    required this.success,
    this.pickupId,
    this.message,
    this.scheduledTime,
    this.error,
  });

  @override
  List<Object?> get props => [success, pickupId, message, scheduledTime, error];
}

/// Pickup order data
class PickupOrder extends Equatable {
  final String id;
  final List<FoodItem> items;
  final TimeSlot timeSlot;
  final DateTime createdAt;
  final String status; // pending, confirmed, completed, cancelled
  final String? canteenMessage;

  const PickupOrder({
    required this.id,
    required this.items,
    required this.timeSlot,
    required this.createdAt,
    this.status = 'pending',
    this.canteenMessage,
  });

  PickupOrder copyWith({
    String? id,
    List<FoodItem>? items,
    TimeSlot? timeSlot,
    DateTime? createdAt,
    String? status,
    String? canteenMessage,
  }) {
    return PickupOrder(
      id: id ?? this.id,
      items: items ?? this.items,
      timeSlot: timeSlot ?? this.timeSlot,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      canteenMessage: canteenMessage ?? this.canteenMessage,
    );
  }

  @override
  List<Object?> get props =>
      [id, items, timeSlot, createdAt, status, canteenMessage];
}
