# FoodBeGood App Specifications

## Document Information

**Project:** FoodBeGood Mobile Application  
**Version:** 2.0.0  
**Date:** February 4, 2025  
**Platform:** iOS & Android  
**Framework:** Flutter  
**Target Users:** University students, canteen staff  

---

## 1. App Overview

### 1.1 App Name & Brand
- **App Name:** FoodBeGood
- **Tagline:** "Reducing food waste, one meal at a time"
- **Bundle ID:** com.foodbegood.app
- **Package Name:** com.foodbegood.app

### 1.2 App Purpose
FoodBeGood is a mobile application designed to help university students:
- Track their meal selections
- Reduce food waste through better planning
- Access canteen facilities digitally
- Monitor their environmental impact
- Request urgent meal access when needed

### 1.3 Target Audience
- **Primary:** University students (18-30 years)
- **Secondary:** University canteen staff
- **Tertiary:** University administration

### 1.4 App Category
- Food & Drink
- Lifestyle
- Education

---

## 2. Technical Specifications

### 2.1 Platform Requirements

#### iOS
```yaml
Minimum iOS Version: iOS 14.0
Target iOS Version: iOS 17.0+
Devices Supported: iPhone, iPod Touch
iPad Support: Yes (universal app)
Architecture: arm64, x86_64 (simulator)
Xcode Version: 15.0+
Swift Version: 5.9+ (for native plugins)
```

#### Android
```yaml
Minimum SDK: API 24 (Android 7.0)
Target SDK: API 34 (Android 14)
Compile SDK: API 34
Architecture: armeabi-v7a, arm64-v8a, x86, x86_64
Kotlin Version: 1.9.0+ (for native plugins)
Gradle Version: 8.0+
Java Version: 17
```

### 2.2 Flutter Environment

```yaml
Flutter SDK: ">=3.16.0 <4.0.0"
Dart SDK: ">=3.2.0 <4.0.0"

Development Tools:
  - Flutter CLI
  - Dart DevTools
  - Android Studio / VS Code
  - Xcode (for iOS)
  - Android SDK (for Android)
```

### 2.3 Screen Support

#### iOS Screen Sizes
| Device | Screen Size | Resolution | Scale |
|--------|-------------|------------|-------|
| iPhone SE | 4.7" | 1334×750 | @2x |
| iPhone 14 | 6.1" | 2532×1170 | @3x |
| iPhone 14 Pro | 6.1" | 2556×1179 | @3x |
| iPhone 14 Plus | 6.7" | 2778×1284 | @3x |
| iPhone 14 Pro Max | 6.7" | 2796×1290 | @3x |

#### Android Screen Densities
```yaml
supports-screens:
  smallScreens: true
  normalScreens: true
  largeScreens: true
  xlargeScreens: true
  anyDensity: true
```

**Supported DPIs:**
- ldpi (120dpi) - not recommended
- mdpi (160dpi)
- hdpi (240dpi)
- xhdpi (320dpi)
- xxhdpi (480dpi)
- xxxhdpi (640dpi)

### 2.4 App Size

**iOS:**
- Download Size: ~20-30 MB (Flutter optimized)
- Install Size: ~35-50 MB

**Android:**
- APK Size: ~15-25 MB (with app bundle)
- Install Size: ~30-45 MB
- App Bundle: Enabled (AAB format)

**Flutter Optimization:**
- Tree shaking enabled
- Code splitting for deferred components
- Asset compression
- ProGuard/R8 enabled for Android

---

## 3. Feature Specifications

### 3.1 Authentication & User Management

#### Login System
- **Method:** Username/Password
- **Security:** JWT tokens, refresh tokens
- **Session Duration:** 30 days (configurable)
- **Biometric Auth:** Face ID / Touch ID (iOS), Fingerprint / Face Unlock (Android)
- **Password Requirements:**
  - Minimum 8 characters
  - At least 1 uppercase letter
  - At least 1 number
  - At least 1 special character

**Flutter Implementation:**
```yaml
dependencies:
  flutter_secure_storage: ^9.0.0    # Secure token storage
  local_auth: ^2.1.8                 # Biometric authentication
  dio: ^5.4.0                        # HTTP client with interceptors
```

#### User Profile
- **QR Code:** Unique student identification
- **Student ID:** University ID integration
- **Profile Picture:** Optional (JPEG/PNG, max 5MB)
- **University:** Mykolo Romerio Universitetas (MRU)

### 3.2 Meal Selection

#### Meal Categories
- Salad Bar
- Dessert
- Side Dish
- Main Dish (Dish 1, Dish 2, Dish 3)

#### Selection Flow
1. User taps meal category
2. Visual selection indicator appears
3. Selected items appear in "picked items" bar
4. User confirms selection
5. Selection saved to history

**Flutter Implementation:**
```yaml
dependencies:
  flutter_bloc: ^8.1.3              # State management
  hive: ^2.2.3                       # Local storage
```

#### Data Storage
- **Local:** Hive database (NoSQL, fast)
- **Cloud:** Sync with backend API
- **Offline Support:** Yes (selections queue when offline)

### 3.3 Scan Meal Feature

#### Camera Integration
- **Resolution:** 1080p minimum
- **Format:** JPEG
- **Compression:** 80% quality
- **Max File Size:** 5MB per image

**Flutter Implementation:**
```yaml
dependencies:
  camera: ^0.10.5+9                 # Camera access
  image_picker: ^1.0.7              # Image selection
  image_cropper: ^5.0.1             # Image cropping
```

#### Image Processing
- **ML Model:** TensorFlow Lite (on-device)
- **Processing Time:** < 3 seconds
- **Confidence Threshold:** 75%
- **Fallback:** Manual selection if recognition fails

**Flutter Implementation:**
```yaml
dependencies:
  tflite_flutter: ^0.10.4           # TensorFlow Lite
  google_mlkit_image_labeling: ^0.10.0  # ML Kit fallback
```

#### Permissions Required
**iOS (Info.plist):**
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan meals</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select meal photos</string>
```

**Android (AndroidManifest.xml):**
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### 3.4 Dashboard & Statistics

#### Metrics Displayed
- Total meals saved
- Average meals per month
- Current streak
- Environmental impact (CO2 saved)

**Flutter Implementation:**
```yaml
dependencies:
  fl_chart: ^0.66.0                 # Charts and graphs
  shimmer: ^3.0.0                   # Loading skeletons
```

#### Real-time Updates
- **Update Frequency:** Every 5 minutes when app is active
- **Background Sync:** Hourly
- **Push Notifications:** Enabled for urgent access requests

### 3.5 Urgent Access

#### Request System
- **Trigger:** Student facing tough time
- **Approval:** Admin dashboard
- **Notification:** Push + In-app
- **Response Time:** Real-time

#### Request Queue
- **Max Pending:** 3 requests per student
- **Cooldown Period:** 24 hours between requests
- **Priority System:** Yes (emergency flag)

### 3.6 Announcements

#### Types
- System announcements
- Canteen status updates
- Special events
- Policy changes

#### Display
- **Location:** Dashboard card
- **Format:** Text + optional image
- **History:** 30 days retention

### 3.7 Settings

#### Available Options
- Language selection
- Profile management
- Meal history
- Regulations/Policies
- Dark mode toggle
- Social media links
- Notifications preferences

**Flutter Implementation:**
```yaml
dependencies:
  shared_preferences: ^2.2.2        # Settings persistence
  flutter_localizations:            # i18n support
    sdk: flutter
```

#### Data Export
- **Format:** CSV
- **Content:** Meal history, statistics
- **Privacy:** GDPR compliant
- **Download:** Local file system (path_provider)

**Flutter Implementation:**
```yaml
dependencies:
  path_provider: ^2.1.2             # File system access
  csv: ^5.1.1                       # CSV generation
  share_plus: ^7.2.2                # File sharing
```

---

## 4. API Specifications

### 4.1 Backend API

```yaml
Base URL: https://api.foodbegood.app/v1
Protocol: HTTPS only
Authentication: Bearer Token (JWT)
Content-Type: application/json
Timeout: 30 seconds
Retry Policy: 3 attempts with exponential backoff
```

### 4.2 Endpoints

#### Authentication
```http
POST /auth/login
POST /auth/refresh
POST /auth/logout
POST /auth/forgot-password
```

#### User
```http
GET /user/profile
PUT /user/profile
GET /user/qr-code
GET /user/stats
GET /user/history
```

#### Meals
```http
GET /meals/categories
POST /meals/select
GET /meals/selections
POST /meals/scan
```

#### Canteen
```http
GET /canteen/status
GET /canteen/announcements
POST /canteen/urgent-access
GET /canteen/urgent-access/status
```

### 4.3 Rate Limiting

- **General:** 100 requests per minute per user
- **Scan:** 10 requests per minute
- **Login:** 5 attempts per minute

**Flutter Implementation:**
```yaml
dependencies:
  dio: ^5.4.0                       # HTTP client with interceptors
  retry: ^3.1.2                     # Retry logic
```

---

## 5. Security Requirements

### 5.1 Data Protection
- **Encryption at Rest:** AES-256
- **Encryption in Transit:** TLS 1.3
- **Sensitive Data:** Passwords hashed with bcrypt (cost factor 12)
- **Local Storage:** flutter_secure_storage for tokens

**Flutter Implementation:**
```yaml
dependencies:
  flutter_secure_storage: ^9.0.0    # Encrypted storage
  encrypt: ^5.0.1                   # Additional encryption
```

### 5.2 Compliance
- **GDPR:** Full compliance for EU users
- **COPPA:** Not for children under 13
- **Privacy Policy:** Required before account creation
- **Data Retention:** 2 years after last activity

### 5.3 Security Features
- Certificate pinning (ssl_pinning_plugin)
- Root/jailbreak detection (jailbreak_root_detection)
- Code obfuscation (ProGuard/R8 for Android, code obfuscation for iOS)
- Anti-tampering measures

**Flutter Implementation:**
```yaml
dependencies:
  ssl_pinning_plugin: ^2.0.0
  jailbreak_root_detection: ^1.0.0
```

---

## 6. Performance Requirements

### 6.1 Response Times

| Action | Target | Maximum |
|--------|--------|---------|
| App Launch | < 2s | < 4s |
| Screen Transition | < 300ms | < 500ms |
| API Response | < 1s | < 3s |
| Image Upload | < 5s | < 10s |
| QR Code Scan | < 1s | < 2s |

### 6.2 Battery & Resources

- **Background Activity:** Minimal
- **Location Services:** Not required
- **Battery Optimization:** Respect system settings
- **Memory Usage:** < 150MB average

**Flutter Optimization:**
- Use `const` constructors where possible
- Implement lazy loading for lists
- Optimize images with cached_network_image
- Use isolates for heavy computations

### 6.3 Offline Capability

- **Critical Features:** Meal selection, history viewing
- **Data Sync:** Automatic when connection restored
- **Conflict Resolution:** Server wins strategy

**Flutter Implementation:**
```yaml
dependencies:
  connectivity_plus: ^5.0.2         # Network state
  hive: ^2.2.3                       # Offline storage
  workmanager: ^0.5.2               # Background sync
```

---

## 7. Push Notifications

### 7.1 Firebase Cloud Messaging (Android)

**Flutter Implementation:**
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
```

**Android Configuration:**
```xml
<service android:name=".fcm.FCMService">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```

### 7.2 Apple Push Notification Service (iOS)
- **Certificate:** APNs Auth Key (.p8)
- **Environment:** Production
- **Payload Size:** Max 4KB

### 7.3 Notification Types

| Type | Priority | Sound | Badge |
|------|----------|-------|-------|
| Urgent Access | High | Yes | Yes |
| Announcement | Normal | No | Yes |
| System Alert | High | Yes | Yes |
| Weekly Summary | Low | No | No |

---

## 8. Third-Party Integrations

### 8.1 Required Services

| Service | Purpose | Platform | Flutter Package |
|---------|---------|----------|-----------------|
| Firebase | Analytics, Crashlytics, FCM | Both | firebase_core |
| Google ML Kit | Image recognition | Android | google_mlkit_* |
| Core ML | Image recognition | iOS | tflite_flutter |
| QR Scanner | QR scanning | Both | mobile_scanner |

### 8.2 Optional Services

| Service | Purpose | Platform | Flutter Package |
|---------|---------|----------|-----------------|
| Sentry | Error tracking | Both | sentry_flutter |
| Amplitude | Analytics | Both | amplitude_flutter |
| OneSignal | Push notifications | Both | onesignal_flutter |

---

## 9. Accessibility Requirements

### 9.1 iOS (VoiceOver)
- All interactive elements labeled
- Dynamic type support
- Reduced motion support
- Color contrast compliance (WCAG AA)

**Flutter Implementation:**
```dart
// Semantics for accessibility
Semantics(
  label: 'Login button',
  child: ElevatedButton(
    onPressed: () {},
    child: Text('Login'),
  ),
)
```

### 9.2 Android (TalkBack)
- Content descriptions for all images
- Focus navigation order
- Minimum touch target: 48dp
- High contrast mode support

### 9.3 Common Requirements
- Screen reader compatibility
- Keyboard navigation support
- Text scaling (up to 200%)
- Color blindness friendly design

**Flutter Support:**
- Built-in `Semantics` widget
- `MediaQuery` for text scaling
- `Theme` for high contrast

---

## 10. App Store Requirements

### 10.1 iOS App Store

**Required Assets:**
- App Icon: 1024×1024px
- Screenshots: iPhone 6.5", iPhone 5.5", iPad 12.9"
- App Preview Video: 15-30 seconds
- Privacy Policy URL
- Support URL

**App Store Information:**
- Primary Category: Food & Drink
- Secondary Category: Lifestyle
- Age Rating: 4+
- Price: Free
- In-App Purchases: No

**Flutter Build:**
```bash
flutter build ios --release
```

### 10.2 Google Play Store

**Required Assets:**
- App Icon: 512×512px
- Feature Graphic: 1024×500px
- Screenshots: Phone, 7-inch tablet, 10-inch tablet
- Privacy Policy URL
- Content Rating: Everyone

**Play Store Information:**
- Category: Food & Drink
- Content Rating: PEGI 3
- Price: Free
- In-App Purchases: No
- Ads: No

**Flutter Build:**
```bash
flutter build appbundle --release
```

---

## 11. Flutter Project Structure

```
foodbegood/
├── android/                    # Android-specific files
├── ios/                        # iOS-specific files
├── lib/
│   ├── main.dart              # Entry point
│   ├── app.dart               # App widget
│   ├── config/                # Configuration files
│   │   ├── routes.dart        # GoRouter configuration
│   │   ├── theme.dart         # AppTheme
│   │   └── constants.dart     # App constants
│   ├── core/                  # Core utilities
│   │   ├── errors/            # Error handling
│   │   ├── usecases/          # Use case base classes
│   │   └── utils/             # Utility functions
│   ├── features/              # Feature modules
│   │   ├── auth/              # Authentication
│   │   │   ├── data/          # Repositories, models
│   │   │   ├── domain/        # Entities, use cases
│   │   │   └── presentation/  # BLoCs, widgets, screens
│   │   ├── meals/             # Meal selection
│   │   ├── dashboard/         # Dashboard & stats
│   │   ├── profile/           # User profile
│   │   └── settings/          # App settings
│   └── shared/                # Shared components
│       ├── widgets/           # Common widgets
│       └── services/          # Shared services
├── test/                      # Unit tests
├── integration_test/          # Integration tests
├── assets/                    # Static assets
│   ├── images/
│   ├── icons/
│   └── fonts/
├── pubspec.yaml              # Dependencies
└── analysis_options.yaml     # Lint rules
```

---

## 12. Development Environment Setup

### 12.1 Prerequisites

```bash
# Install Flutter
https://docs.flutter.dev/get-started/install

# Verify installation
flutter doctor

# Install dependencies
flutter pub get
```

### 12.2 IDE Configuration

**VS Code:**
- Flutter extension
- Dart extension
- Dart Data Class Generator
- Flutter Tree

**Android Studio:**
- Flutter plugin
- Dart plugin

### 12.3 Running the App

```bash
# Run on iOS simulator
flutter run -d ios

# Run on Android emulator
flutter run -d android

# Run with hot reload enabled
flutter run --hot

# Build release version
flutter build ios --release
flutter build appbundle --release
```

---

## 13. Testing Strategy

### 13.1 Unit Tests
```bash
flutter test
```

### 13.2 Widget Tests
```bash
flutter test test/widget
```

### 13.3 Integration Tests
```bash
flutter test integration_test
```

### 13.4 Golden Tests
```bash
flutter test --update-goldens
```

---

## 14. Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.0.0 | 2025-02-04 | Updated to Flutter framework with comprehensive specifications |
| 1.0.0 | 2025-02-04 | Initial release specifications for React Native |

---

## 15. Contact & Support

**Developer:** FoodBeGood Team  
**Support Email:** support@foodbegood.app  
**Website:** https://foodbegood.app  
**Privacy Policy:** https://foodbegood.app/privacy  

---

*Specifications updated for Flutter framework - February 2025*
