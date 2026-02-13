# FoodBeGood Feature Implementation Plan

> **Document Type:** Implementation Plan  
> **Based on:** PROMPT.md Requirements  
> **Date:** February 13, 2026  
> **Status:** Ready for Implementation

---

## 📋 Executive Summary

This document outlines the complete implementation plan for the new features requested in PROMPT.md. The implementation is divided into 4 feature branches with a total of 23 tasks.

**Key Clarifications from User:**
1. ✅ Use placeholder images (German delicacies)
2. ✅ Canteen hours: Every 30 minutes, time slot selection AFTER food selection
3. ✅ Notification: 1 hour before pickup
4. ✅ Color coding: Green → Yellow → Red as pickup approaches
5. ✅ Replace existing 6-category system with Food/Beverages/Desserts horizontal scrolling
6. ✅ Swipe left on dashboard → seamless QR code access

---

## 🎯 Feature Breakdown

### **Feature 1: Dashboard Enhancements** (`feature/dashboard-enhancements`)

#### 1.1 Global Theme Updates
- **Logo Usage**: Update all screens to use `assets\icons\Screenshot 2026-02-10 161900.png`
- **Double-click Protection**: Ensure all screens have back button protection
- **Background Colors**:
  - Light Mode: Split of lighter green (#E8F5E9) and white (#FFFFFF)
  - Dark Mode: Split of darker green (#1B5E20) and slightly darker green (#0D3318)

#### 1.2 Dashboard Header
```dart
// New widget: DashboardHeader
- Current date (e.g., "Monday, February 13")
- Current time (e.g., "14:30")
- Dynamic greeting based on time:
  - 5:00 - 11:59: "Good morning, Zain! 👋"
  - 12:00 - 16:59: "Good afternoon, Zain! 👋"
  - 17:00 - 4:59: "Good evening, Zain! 👋"
```

#### 1.3 Enhanced Card Animations
- **Pop-up Effect**: Cards scale up from 0.9 to 1.0 with spring physics
- **Vibrant Gradients**: 
  - Light mode: Green gradients with higher saturation
  - Dark mode: Deep emerald gradients
- **Bold Text**: FontWeight.w700 for all card titles
- **Darker Tones**: Text color #1A1A1A (light), #FFFFFF (dark)

#### 1.4 Animated Elements
- **Countdown Timer**: 
  - Color transitions: Green (> 1 hour) → Yellow (30-60 min) → Red (< 30 min)
  - Format: "2h 45m" or "45m 30s"
- **Flame Streaks**: Animated gradient flames using CustomPainter
- **Beating Heart**: Scale animation 1.0 → 1.2 → 1.0, duration 1s

#### 1.5 Swipe to QR Code
```dart
// Implementation: PageView with 2 pages
PageView(
  controller: _pageController,
  children: [
    DashboardContent(), // Main dashboard
    QRCodePreview(),    // Quick QR access
  ],
)
```
- Swipe hint: "Swipe left for QR code" with arrow animation
- Smooth page transition with parallax effect

---

### **Feature 2: Pickup Flow Redesign** (`feature/pickup-flow-redesign`)

#### 2.1 Remove Redundant Bar
- Remove the summary bar above "Confirm Pickup" button
- Keep only the container visualization

#### 2.2 Horizontal Category Scrolling
**New Category Structure:**
```dart
enum MainCategory { food, beverages, desserts }

final categories = {
  MainCategory.food: [
    FoodItem(name: 'Schnitzel', image: 'schnitzel.jpg', type: 'main'),
    FoodItem(name: 'Bratwurst', image: 'bratwurst.jpg', type: 'main'),
    FoodItem(name: 'Spätzle', image: 'spaetzle.jpg', type: 'side'),
    FoodItem(name: 'Kartoffelsalat', image: 'potato_salad.jpg', type: 'side'),
    FoodItem(name: 'Sauerkraut', image: 'sauerkraut.jpg', type: 'side'),
  ],
  MainCategory.beverages: [
    FoodItem(name: 'Apfelschorle', image: 'apfelschorle.jpg', type: 'drink'),
    FoodItem(name: 'Spezi', image: 'spezi.jpg', type: 'drink'),
    FoodItem(name: 'Mineralwasser', image: 'water.jpg', type: 'drink'),
  ],
  MainCategory.desserts: [
    FoodItem(name: 'Apfelstrudel', image: 'apfelstrudel.jpg', type: 'dessert'),
    FoodItem(name: 'Schwarzwälder Kirschtorte', image: 'black_forest.jpg', type: 'dessert'),
    FoodItem(name: 'Lebkuchen', image: 'lebkuchen.jpg', type: 'dessert'),
  ],
};
```

**UI Layout:**
```
┌─────────────────────────┐
│ ←    Pickup My Meal     │
├─────────────────────────┤
│ [Food][Beverages][Dess] │ ← Tab bar (horizontal scroll)
├─────────────────────────┤
│ ┌────┐ ┌────┐ ┌────┐   │
│ │🍖  │ │🌭  │ │🍜  │   │ ← Food items (horizontal scroll)
│ │Schn│ │Brat│ │Spät│   │
│ └────┘ └────┘ └────┘   │
├─────────────────────────┤
│    [Container View]     │
├─────────────────────────┤
│    [Confirm Pickup]     │
└─────────────────────────┘
```

#### 2.3 Food Images (German Delicacies Placeholders)
**Images to Source:**
1. **Schnitzel** - Breaded pork cutlet
2. **Bratwurst** - German sausage
3. **Spätzle** - Egg noodles
4. **Kartoffelsalat** - Potato salad
5. **Sauerkraut** - Fermented cabbage
6. **Apfelschorle** - Apple spritzer
7. **Spezi** - Orange cola mix
8. **Apfelstrudel** - Apple strudel
9. **Schwarzwälder Kirschtorte** - Black Forest cake
10. **Lebkuchen** - Gingerbread cookies

**Image Loading:**
```yaml
# pubspec.yaml
dependencies:
  cached_network_image: ^3.3.0
```

Use placeholder images from `assets/images/food/` or network images with fallback.

#### 2.4 Touch to Unselect
- Tap selected item in container to remove it
- Animate item sliding out
- Update container fill level

#### 2.5 Back Button Warning
```dart
Future<bool> _onWillPop() async {
  if (selectedItems.isNotEmpty) {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Discard Selection?'),
        content: Text('Your food selection will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), 
                     child: Text('CANCEL')),
          FilledButton(onPressed: () => Navigator.pop(context, true), 
                       child: Text('DISCARD')),
        ],
      ),
    );
  }
  return true;
}
```

---

### **Feature 3: Calendar Time Slot Selection** (`feature/calendar-time-slot`)

#### 3.1 New Flow
```
Student Dashboard
       ↓ (Tap "Pickup My Meal")
Food Selection Screen
       ↓ (Select food items)
Time Slot Selection Screen ← NEW
       ↓ (Select date + time)
QR Code Generation
       ↓
Dashboard Updated with Next Pickup
```

#### 3.2 Time Slot Selection Screen
```dart
class TimeSlotSelectionPage extends StatelessWidget {
  // Calendar view with available dates
  // Time slots every 30 minutes during canteen hours
  // Canteen hours: 11:00 - 14:00 (typical German canteen)
}
```

**UI Layout:**
```
┌─────────────────────────┐
│ ←   Select Pickup Time  │
├─────────────────────────┤
│                         │
│   [Calendar Widget]     │
│                         │
├─────────────────────────┤
│   Available Times       │
│   ┌────┐ ┌────┐ ┌────┐ │
│   │11:00│ │11:30│ │12:00│ │
│   └────┘ └────┘ └────┘ │
│   ┌────┐ ┌────┐ ┌────┐ │
│   │12:30│ │13:00│ │13:30│ │
│   └────┘ └────┘ └────┘ │
│                         │
│   [Confirm Time Slot]   │
└─────────────────────────┘
```

#### 3.3 Canteen Request Simulation
```dart
class CanteenRequestService {
  Future<CanteenResponse> submitPickupRequest({
    required List<FoodItem> items,
    required DateTime pickupTime,
    required String userId,
  }) async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));
    
    return CanteenResponse(
      success: true,
      pickupId: 'PK${DateTime.now().millisecondsSinceEpoch}',
      qrCodeData: generateQRCode(),
      expiresAt: pickupTime.add(Duration(minutes: 5)),
    );
  }
}
```

#### 3.4 Dashboard Next Pickup Updates
```dart
class NextPickup {
  final String location;
  final DateTime scheduledTime;
  final String pickupId;
  final List<FoodItem> items;
  
  String get countdownText {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h ${difference.inMinutes % 60}m';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      return '${difference.inMinutes}m ${difference.inSeconds % 60}s';
    }
  }
  
  Color get urgencyColor {
    final now = DateTime.now();
    final difference = scheduledTime.difference(now);
    
    if (difference.inHours > 1) return Colors.green;
    if (difference.inMinutes > 30) return Colors.yellow;
    return Colors.red;
  }
}
```

---

### **Feature 4: Notification System** (`feature/notification-system`)

#### 4.1 Local Notification Setup
```yaml
# pubspec.yaml
dependencies:
  flutter_local_notifications: ^16.3.0
  timezone: ^0.9.2
```

#### 4.2 Notification Service
```dart
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
  }

  Future<void> schedulePickupReminder({
    required String pickupId,
    required DateTime pickupTime,
  }) async {
    final reminderTime = pickupTime.subtract(Duration(hours: 1));
    
    await _notifications.zonedSchedule(
      pickupId.hashCode,
      'Pickup Reminder',
      'Your meal pickup is in 1 hour at Mensa Viadrina',
      tz.TZDateTime.from(reminderTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pickup_reminders',
          'Pickup Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
```

#### 4.3 Bell Icon Integration
```dart
class NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications_outlined),
          onPressed: () => _showNotifications(context),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$unreadCount',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }
}
```

---

## 📁 File Structure Changes

### New Files
```
lib/
├── features/
│   ├── dashboard/
│   │   └── presentation/
│   │       └── widgets/
│   │           ├── dashboard_header.dart       # Date/time + greeting
│   │           ├── animated_countdown.dart     # Color-coded countdown
│   │           ├── swipeable_dashboard.dart    # PageView wrapper
│   │           └── flame_animation.dart        # Custom painter
│   ├── pickup/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── time_slot_selection_page.dart  # Calendar + time slots
│   │       └── widgets/
│   │           ├── horizontal_category_tabs.dart
│   │           ├── food_item_card.dart
│   │           └── food_image_widget.dart
│   └── notifications/
│       └── notification_service.dart
├── shared/
│   └── widgets/
│       └── calendar/
│           └── time_slot_picker.dart
└── config/
    └── theme_extensions.dart                    # Background gradients
```

### Modified Files
```
lib/
├── features/
│   ├── dashboard/
│   │   └── presentation/
│   │       └── pages/
│   │           └── student_dashboard_page.dart  # Major updates
│   ├── pickup/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── pickup_page.dart            # Complete redesign
│   │       └── bloc/
│   │           └── pickup_bloc.dart            # Add time slot logic
│   └── auth/
│       └── presentation/
│           └── pages/
│               └── unified_login_page.dart     # Update logo
├── config/
│   ├── theme.dart                              # Background colors
│   └── routes.dart                             # Add time slot route
└── shared/
    └── services/
        └── mock_data_service.dart              # Add German food data
```

---

## 🎨 Design Specifications

### Color Transitions for Pickup Urgency
```dart
class UrgencyColors {
  static Color getColor(Duration timeRemaining) {
    final minutes = timeRemaining.inMinutes;
    
    if (minutes > 60) {
      return Color(0xFF10B981); // Green
    } else if (minutes > 30) {
      // Interpolate green → yellow
      return Color.lerp(
        Color(0xFF10B981),
        Color(0xFFF59E0B),
        (60 - minutes) / 30,
      )!;
    } else {
      // Interpolate yellow → red
      return Color.lerp(
        Color(0xFFF59E0B),
        Color(0xFFEF4444),
        (30 - minutes) / 30,
      )!;
    }
  }
}
```

### Background Gradients
```dart
class BackgroundGradients {
  static LinearGradient get lightMode => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8F5E9), // Light green
      Color(0xFFFFFFFF), // White
    ],
    stops: [0.0, 0.6],
  );
  
  static LinearGradient get darkMode => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1B5E20), // Dark green
      Color(0xFF0D3318), // Darker green
    ],
    stops: [0.0, 1.0],
  );
}
```

---

## 🧪 Testing Strategy

### Unit Tests
- DashboardBloc: Time-based greeting logic
- PickupBloc: Category selection and time slot logic
- NotificationService: Scheduling and cancellation

### Widget Tests
- DashboardHeader: Date/time display
- AnimatedCountdown: Color transitions
- TimeSlotPicker: Selection and validation

### Integration Tests
- Complete pickup flow: Food → Time → QR
- Notification scheduling on pickup creation
- Swipe gesture navigation

---

## 📅 Implementation Timeline

| Week | Feature Branch | Tasks |
|------|----------------|-------|
| Week 1 | feature/dashboard-enhancements | Global theme, header, animations, swipe |
| Week 2 | feature/pickup-flow-redesign | Horizontal categories, images, unselect, back warning |
| Week 3 | feature/calendar-time-slot | Calendar, time slots, canteen request, countdown |
| Week 4 | feature/notification-system | Notifications, bell icon, integration testing |

---

## ✅ Definition of Done

### Each Feature Branch Must:
- [ ] All code written and tested
- [ ] Unit tests passing (> 75% coverage)
- [ ] Widget tests for new UI components
- [ ] Flutter analyze passes with no errors
- [ ] Flutter build apk --debug succeeds
- [ ] Code reviewed (via PR)
- [ ] Documentation updated in /memory/

### Final Validation:
- [ ] All 4 feature branches merged to main
- [ ] Full app integration test passing
- [ ] E2E tests updated and passing
- [ ] development-log.md updated with all changes

---

## 🚀 Ready to Start

This plan is ready for implementation. Shall I proceed with creating the first feature branch and begin implementation?

**Recommended Start:** `feature/dashboard-enhancements`
