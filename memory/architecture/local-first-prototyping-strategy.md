# FoodBeGood Local-First Prototyping Strategy

> **Document Type:** Architecture Strategy & Sprint Planning  
> **Project:** FoodBeGood - Food Waste Reduction App  
> **Framework:** Flutter 3.16+ with Local-First Architecture  
> **Last Updated:** February 5, 2025  
> **Status:** Planning Phase

---

## Executive Summary

This document presents a **local-first prototyping strategy** for the FoodBeGood mobile application. Instead of building the complex backend infrastructure first, we will:

1. **Prototype with local storage only** (Weeks 1-6)
2. **Validate UX and core features** with real data
3. **Iterate quickly** without API dependencies
4. **Add backend incrementally** after validation (Weeks 7-14)

### Why Local-First Prototyping?

| Benefit | Description |
|---------|-------------|
| **Faster Iteration** | No backend setup delays, immediate feedback |
| **Offline-Ready** | Architecture supports offline from day one |
| **UX Validation** | Test with real user data quickly |
| **Risk Reduction** | Validate features before investing in backend |
| **Better Architecture** | Clean separation of concerns enables easy backend addition |

---

## 🏗️ Architecture Overview

### Two-Phase Development Approach

```
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 1: LOCAL-FIRST PROTOTYPE               │
│                         (Weeks 1-6)                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐      │
│   │   UI Layer  │────▶│   BLoC      │────▶│  Repository │      │
│   │   (Flutter) │◀────│ (State Mgmt)│◀────│   Pattern   │      │
│   └─────────────┘     └─────────────┘     └──────┬──────┘      │
│                                                  │              │
│                                          ┌───────▼───────┐      │
│                                          │ Local Storage │      │
│                                          │  • Hive       │      │
│                                          │  • SQLite     │      │
│                                          └───────────────┘      │
│                                                                 │
│   Features:                                                     │
│   ✅ Role Selection        ✅ Meal Selection                   │
│   ✅ Student Dashboard     ✅ Container Animations             │
│   ✅ QR Code Display       ✅ Profile & Settings               │
│   ✅ Dark Mode             ✅ Local Data Persistence           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    PHASE 2: BACKEND INTEGRATION                 │
│                         (Weeks 7-14)                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐      │
│   │   UI Layer  │────▶│   BLoC      │────▶│  Repository │      │
│   │   (Flutter) │◀────│ (State Mgmt)│◀────│   Pattern   │      │
│   └─────────────┘     └─────────────┘     └──────┬──────┘      │
│                                                  │              │
│                              ┌───────────────────┼──────────┐  │
│                              │                   │          │  │
│                    ┌─────────▼────────┐  ┌───────▼───────┐  │  │
│                    │  Local Storage   │  │  Remote API   │  │  │
│                    │  (Offline Cache) │  │  (Node.js)    │  │  │
│                    └──────────────────┘  └───────────────┘  │  │
│                                                           │  │
│                    ┌──────────────────────────────────────┘  │
│                    │                                          │
│                    ▼                                          │
│           ┌─────────────────┐                                 │
│           │  Sync Engine    │                                 │
│           │  • Queue        │                                 │
│           │  • Retry        │                                 │
│           │  • Conflict     │                                 │
│           └─────────────────┘                                 │
│                                                                 │
│   New Features:                                                 │
│   ✅ User Authentication   ✅ Real-time Sync                   │
│   ✅ Cloud Backup          ✅ Multi-device Support             │
│   ✅ Push Notifications    ✅ Analytics                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 Technical Architecture

### Local-First Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                        UI LAYER                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐    │
│  │  Screens │  │  Widgets │  │  Forms   │  │  Cards   │    │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘    │
└───────┼─────────────┼─────────────┼─────────────┼──────────┘
        │             │             │             │
        └─────────────┴──────┬──────┴─────────────┘
                             │
┌────────────────────────────┼────────────────────────────────┐
│                     PRESENTATION LAYER                       │
│                              │                               │
│  ┌───────────────────────────▼───────────────────────────┐  │
│  │                      BLoC PATTERN                      │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │  │
│  │  │   Events     │──│   BLoC       │──│   States     │  │  │
│  │  │  (Actions)   │  │  (Logic)     │  │  (UI State)  │  │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  │  │
│  └────────────────────────────────────────────────────────┘  │
└────────────────────────────┬────────────────────────────────┘
                             │
┌────────────────────────────┼────────────────────────────────┐
│                      DOMAIN LAYER                            │
│                              │                               │
│  ┌───────────────────────────▼───────────────────────────┐  │
│  │                   REPOSITORY PATTERN                   │  │
│  │                                                        │  │
│  │  ┌──────────────┐         ┌──────────────────────┐   │  │
│  │  │  Abstract    │◀────────│   Repository Impl    │   │  │
│  │  │  Repository  │         │                      │   │  │
│  │  │  Interface   │         │ • LocalDataSource    │   │  │
│  │  └──────────────┘         │ • RemoteDataSource   │   │  │
│  │                           │ • SyncManager        │   │  │
│  │                           └──────────────────────┘   │  │
│  │                                                        │  │
│  │  ┌────────────────────────────────────────────────┐   │  │
│  │  │              USE CASES                          │   │  │
│  │  │  • GetDashboardData                            │   │  │
│  │  │  • CreatePickup                                │   │  │
│  │  │  • UpdateProfile                               │   │  │
│  │  └────────────────────────────────────────────────┘   │  │
│  └────────────────────────────────────────────────────────┘  │
└────────────────────────────┬────────────────────────────────┘
                             │
┌────────────────────────────┼────────────────────────────────┐
│                       DATA LAYER                             │
│                              │                               │
│  ┌───────────────────────────┴───────────────────────────┐  │
│  │                                                        │  │
│  │  ┌─────────────────┐          ┌─────────────────┐     │  │
│  │  │ LOCAL DATA      │          │ REMOTE DATA     │     │  │
│  │  │ (Phase 1)       │          │ (Phase 2)       │     │  │
│  │  │                 │          │                 │     │  │
│  │  │ • Hive (NoSQL)  │          │ • REST API      │     │  │
│  │  │ • SQLite (SQL)  │          │ • GraphQL       │     │  │
│  │  │ • JSON files    │          │ • WebSocket     │     │  │
│  │  │                 │          │                 │     │  │
│  │  │ Advantages:     │          │ Advantages:     │     │  │
│  │  │ ✅ Fast         │          │ ✅ Shared       │     │  │
│  │  │ ✅ Offline      │          │ ✅ Backup       │     │  │
│  │  │ ✅ Simple       │          │ ✅ Multi-device │     │  │
│  │  │                 │          │                 │     │  │
│  │  └─────────────────┘          └─────────────────┘     │  │
│  │                                                        │  │
│  └────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 Local Storage Strategy

### Storage Comparison

| Feature | **Hive** | **SQLite** | **SharedPreferences** |
|---------|----------|------------|----------------------|
| **Structure** | NoSQL (key-value) | SQL (relational) | Simple key-value |
| **Performance** | 🟢 Very Fast | 🟡 Good | 🟢 Very Fast |
| **Query Support** | 🟡 Basic | 🟢 Advanced | 🔴 None |
| **Complex Data** | 🟢 Yes | 🟢 Yes | 🔴 No |
| **Encryption** | 🟢 Built-in | 🟡 Manual | 🔴 No |
| **Use Case** | Settings, Cache | Complex Data | Simple Settings |

### Recommended Hybrid Approach

```dart
// lib/core/storage/storage_manager.dart

class StorageManager {
  // Hive for simple data and cache
  late final Box<Settings> _settingsBox;
  late final Box<UserProfile> _profileBox;
  late final Box<DashboardCache> _dashboardBox;
  
  // SQLite for complex relational data
  late final Database _mainDatabase;
  
  // SharedPreferences for app state
  late final SharedPreferences _prefs;
  
  Future<void> initialize() async {
    // Initialize Hive
    await Hive.initFlutter();
    Hive.registerAdapter(SettingsAdapter());
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(DashboardCacheAdapter());
    
    _settingsBox = await Hive.openBox<Settings>('settings');
    _profileBox = await Hive.openBox<UserProfile>('profile');
    _dashboardBox = await Hive.openBox<DashboardCache>('dashboard');
    
    // Initialize SQLite
    _mainDatabase = await openDatabase(
      'foodbegood.db',
      version: 1,
      onCreate: _createDatabase,
    );
    
    // Initialize SharedPreferences
    _prefs = await SharedPreferences.getInstance();
  }
}
```

### Data Organization

```
Storage Strategy:

1. HIVE BOXES (NoSQL - Fast Access)
   ├── settings        → Theme, language, preferences
   ├── profile         → User profile data
   ├── dashboard_cache → Cached dashboard metrics
   └── auth_tokens     → JWT tokens (Phase 2)

2. SQLITE TABLES (Relational - Complex Queries)
   ├── users
   ├── pickups
   ├── food_categories
   ├── meal_history
   └── urgent_access_requests

3. SHARED_PREFERENCES (Simple State)
   ├── first_launch    → bool
   ├── last_sync       → DateTime
   └── app_version     → String
```

---

## 📅 Revised Sprint Plan: Local-First Approach

### Phase 1: Local-First Prototype (Weeks 1-6)

#### Week 1: Project Setup & Local Storage Foundation
**Story Points:** 40  
**Goal:** Initialize project with local-first architecture

**Tasks:**
```
Sprint 1.1: Project Initialization
├── Initialize Flutter project (3.16.0+)
├── Configure Clean Architecture folders
├── Set up Hive + SQLite dependencies
├── Configure linting (very_good_analysis)
└── Create Git repository

Sprint 1.2: Storage Layer
├── Create StorageManager singleton
├── Configure Hive adapters
├── Set up SQLite database helper
├── Create base repository interface
└── Write storage unit tests

Sprint 1.3: Theme & Navigation
├── Implement light/dark theme system
├── Set up Go Router
├── Create base widgets (AppButton, AppCard, AppInput)
└── Build theme switcher
```

**Deliverables:**
- ✅ Project structure following Clean Architecture
- ✅ Local storage system operational
- ✅ Theme switching functional
- ✅ Base component library
- ✅ CI/CD pipeline passing

---

#### Week 2: Authentication & User Data (Local)
**Story Points:** 35  
**Goal:** Implement local-only authentication and user management

**Tasks:**
```
Sprint 2.1: Local Authentication
├── Create AuthRepository interface
├── Implement LocalAuthRepository
├── Create AuthBloc
├── Build Role Selection screen
└── Build Login screen (local validation)

Sprint 2.2: User Profile
├── Create UserProfile model
├── Implement ProfileRepository
├── Build Profile screen
├── Add profile photo upload (local)
└── Create ProfileBloc

Sprint 2.3: Mock Data System
├── Create MockDataService
├── Generate sample users
├── Generate sample dashboard data
└── Generate sample meal history
```

**Mock Users:**
```dart
final mockUsers = [
  User(
    studentId: '61913042',
    password: 'password123', // Hashed locally
    role: UserRole.student,
    profile: Profile(
      firstName: 'Zain',
      lastName: 'Ul Ebad',
      department: 'Computer Science',
      yearOfStudy: 3,
    ),
  ),
  // Add more mock users...
];
```

**Deliverables:**
- ✅ Role selection screen functional
- ✅ Local login with validation
- ✅ Profile screen with data persistence
- ✅ Mock data system operational

---

#### Week 3: Student Dashboard (Local Data)
**Story Points:** 45  
**Goal:** Build fully functional dashboard with local metrics

**Tasks:**
```
Sprint 3.1: Dashboard Infrastructure
├── Create DashboardRepository
├── Create DashboardBloc
├── Design metric calculation service
└── Set up dashboard caching

Sprint 3.2: Metric Cards
├── Build TotalMealsCard widget
├── Build MoneyComparisonCard widget
├── Build MonthlyAverageCard widget
├── Build DayStreakCard widget
└── Build NextPickupCard widget

Sprint 3.3: Dashboard Screen
├── Build dashboard layout
├── Implement pull-to-refresh
├── Add animations
└── Connect to local data
```

**Local Data Generation:**
```dart
class MockDashboardService {
  DashboardData generateForUser(String userId) {
    return DashboardData(
      totalMeals: 34,
      monthlyGoal: 50,
      moneySaved: MoneySaved(
        thisMonth: 82.50,
        lastMonth: 70.00,
        trend: 0.18,
        breakdown: {
          'Meals': 45.00,
          'Drinks': 22.50,
          'Snacks': 15.00,
        },
      ),
      monthlyAverage: 12.3,
      currentStreak: 5,
      nextPickup: NextPickup(
        location: 'Mensa Viadrina',
        time: DateTime.now().add(Duration(hours: 2, minutes: 45)),
      ),
      socialImpact: SocialImpact(
        studentsHelped: 156,
        avgMoneySavedPerStudent: 12.50,
      ),
    );
  }
}
```

**Deliverables:**
- ✅ Complete dashboard with all metric cards
- ✅ Real-time data from local storage
- ✅ Smooth animations and transitions
- ✅ Pull-to-refresh functionality

---

#### Week 4: "Pick Up My Meal" Feature (Local)
**Story Points:** 50  
**Goal:** Implement complete meal pickup flow with local storage

**Tasks:**
```
Sprint 4.1: Food Selection
├── Create FoodCategory model
├── Build FoodCategoryGrid widget
├── Create PickupBloc
├── Implement local selection logic
└── Build selection screen

Sprint 4.2: Container Animation
├── Create FoodContainer widget (SVG)
├── Implement lid animation
├── Add food drop physics
├── Create fill level indicator
└── Add bounce effects

Sprint 4.3: QR Code & Success
├── Generate QR code locally
├── Build QR code screen
├── Implement countdown timer
├── Create success screen
└── Save pickup to local database
```

**Local Pickup Storage:**
```dart
@HiveType(typeId: 1)
class LocalPickup extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final List<FoodItem> items;
  
  @HiveField(2)
  final DateTime createdAt;
  
  @HiveField(3)
  final DateTime expiresAt;
  
  @HiveField(4)
  final String qrCodeData;
  
  @HiveField(5)
  PickupStatus status;
  
  @HiveField(6)
  final String? scannedAt;
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => status == PickupStatus.pending && !isExpired;
}
```

**Deliverables:**
- ✅ Complete "Pick Up My Meal" flow
- ✅ Animated container with smooth physics
- ✅ QR code generation and display
- ✅ Local pickup history storage

---

#### Week 5: Profile, Settings & Canteen View (Local)
**Story Points:** 40  
**Goal:** Complete local-only user features

**Tasks:**
```
Sprint 5.1: Profile & Settings
├── Build Settings screen
├── Implement dark mode persistence
├── Add language selection
├── Create meal history view
└── Build regulations/terms view

Sprint 5.2: Meal History
├── Create MealHistoryRepository
├── Build history list screen
├── Add CSV export (local file)
├── Implement filtering/sorting
└── Connect to local database

Sprint 5.3: Canteen Dashboard (Local)
├── Build CanteenBloc
├── Create canteen metrics service
├── Build canteen dashboard
├── Add urgent access management UI
└── Build food status screen
```

**Canteen Mock Data:**
```dart
class MockCanteenService {
  CanteenDashboard generateDashboard() {
    return CanteenDashboard(
      totalMealsSaved: 1247,
      dailyAverage: 89,
      weeklyTotal: 342,
      monthlyTrend: 0.23,
      foodWastePrevented: 428, // kg
      wasteReduction: -0.15,
      canteenSavings: 3142.00,
      studentsHelped: 287,
      studentsTrend: 0.08,
      studentSavingsTotal: 4235.00,
      urgentRequests: 3,
      status: CanteenStatus.normal,
    );
  }
}
```

**Deliverables:**
- ✅ Complete profile and settings
- ✅ Meal history with export
- ✅ Canteen dashboard
- ✅ All local features functional

---

#### Week 6: Polish, Testing & UX Validation
**Story Points:** 35  
**Goal:** Polish the prototype and validate UX

**Tasks:**
```
Sprint 6.1: Animations & Micro-interactions
├── Add page transition animations
├── Implement button press effects
├── Add card hover animations
├── Create skeleton loading screens
└── Optimize for 60fps

Sprint 6.2: Testing
├── Write unit tests (target: 70%)
├── Create widget tests for all screens
├── Add integration tests
├── Test on multiple devices
└── Performance profiling

Sprint 6.3: UX Validation
├── User testing sessions
├── Gather feedback
├── Create UX improvements backlog
├── Document findings
└── Prepare for Phase 2
```

**Deliverables:**
- ✅ Smooth animations throughout
- ✅ 70%+ test coverage
- ✅ UX validation complete
- ✅ Phase 2 requirements defined

---

### Phase 1 Exit Criteria

Before moving to Phase 2, verify:

- [ ] All 8 screens functional with local data
- [ ] Smooth 60fps animations
- [ ] 70%+ test coverage
- [ ] UX validation positive
- [ ] No critical bugs
- [ ] Phase 2 requirements documented
- [ ] Stakeholder approval for backend integration

---

## Phase 2: Backend Integration (Weeks 7-14)

### Week 7: Backend API Foundation
**Story Points:** 40  
**Goal:** Set up production backend infrastructure

**Tasks:**
- Initialize Node.js project with Express
- Set up PostgreSQL with Prisma
- Create Docker Compose for local development
- Implement health check endpoints
- Create Swagger documentation

**Database Schema:**
```prisma
// Same as existing documentation
// See /memory/architecture/development-phases.md
```

---

### Week 8: Authentication Integration
**Story Points:** 45  
**Goal:** Connect local auth to real backend

**Tasks:**
- Implement JWT authentication
- Create RemoteAuthRepository
- Add token refresh logic
- Implement secure token storage
- Migrate local users to backend
- Add biometric authentication

---

### Week 9-10: API Integration & Sync Engine
**Story Points:** 85  
**Goal:** Connect all features to backend

**Tasks:**
- Create sync queue system
- Implement background sync
- Add conflict resolution
- Migrate local data to cloud
- Add real-time updates (WebSockets)
- Implement offline queue

**Sync Engine Architecture:**
```dart
class SyncEngine {
  final LocalDataSource _local;
  final RemoteDataSource _remote;
  final SyncQueue _queue;
  
  Future<void> sync() async {
    // 1. Process pending operations
    await _processQueue();
    
    // 2. Pull latest from server
    await _pullChanges();
    
    // 3. Push local changes
    await _pushChanges();
    
    // 4. Resolve conflicts
    await _resolveConflicts();
  }
  
  Future<void> _processQueue() async {
    final pending = await _queue.getPending();
    for (final op in pending) {
      try {
        await _remote.execute(op);
        await _queue.markComplete(op.id);
      } catch (e) {
        await _queue.incrementRetry(op.id);
      }
    }
  }
}
```

---

### Week 11-12: Advanced Features
**Story Points:** 80  
**Goal:** Add cloud-only features

**Tasks:**
- Implement push notifications (FCM)
- Add Firebase Analytics
- Set up Crashlytics
- Add social sharing
- Implement multi-device sync
- Create admin dashboard

---

### Week 13-14: Infrastructure & Deployment
**Story Points:** 70  
**Goal:** Deploy to production

**Tasks:**
- Set up AWS infrastructure
- Configure Terraform
- Deploy production API
- Set up monitoring and alerting
- Build release APK/IPA
- Submit to app stores

---

## 📊 Development Timeline Comparison

### Traditional Approach vs Local-First

| Aspect | Traditional | Local-First |
|--------|------------|-------------|
| **Backend Setup** | Week 1-2 | Week 7-8 |
| **First Demo** | Week 4-5 | Week 2-3 |
| **UX Validation** | Week 6-7 | Week 3-4 |
| **User Feedback** | Limited | Extensive |
| **Risk of Rework** | High | Low |
| **Total Duration** | 14 weeks | 14 weeks |
| **Confidence Level** | Medium | High |

### Local-First Advantages

1. **Immediate Feedback:** Demo working features by Week 2
2. **Early Validation:** Test UX with real data from Day 1
3. **Iterative Improvement:** Fix issues before backend investment
4. **Stakeholder Engagement:** Regular demos with tangible progress
5. **Better Architecture:** Clean separation enables easy backend addition
6. **Offline-First:** App works offline from the start

---

## 🛠️ Implementation Guide

### Step 1: Project Setup

```bash
# 1. Create Flutter project
flutter create --org com.foodbegood foodbegood
cd foodbegood

# 2. Add dependencies to pubspec.yaml
cat > dependencies_section.txt << 'EOF'
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Navigation
  go_router: ^13.0.0
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  sqflite: ^2.3.0
  shared_preferences: ^2.2.2
  path_provider: ^2.1.2
  
  # UI
  flutter_screenutil: ^5.9.0
  flutter_svg: ^2.0.9
  shimmer: ^3.0.0
  
  # QR Code
  qr_flutter: ^4.1.0
  
  # Utils
  intl: ^0.18.1
  logger: ^2.0.2
  uuid: ^4.2.1
  crypto: ^3.0.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  very_good_analysis: ^5.1.0
  build_runner: ^2.4.7
  hive_generator: ^2.0.1
  mocktail: ^1.0.1
  bloc_test: ^9.1.5
EOF

# 3. Get dependencies
flutter pub get
```

### Step 2: Folder Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # App widget
├── injection_container.dart     # Dependency injection
│
├── config/                      # Configuration
│   ├── routes.dart             # Go Router
│   ├── theme.dart              # Light/Dark themes
│   └── constants.dart          # App constants
│
├── core/                        # Core utilities
│   ├── errors/                 # Error handling
│   ├── storage/                # Storage manager
│   ├── usecases/               # Base use case
│   └── utils/                  # Helpers
│
├── features/                    # Feature modules
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/    # Local/Remote
│   │   │   ├── models/         # Data models
│   │   │   └── repositories/   # Repository impl
│   │   ├── domain/
│   │   │   ├── entities/       # Domain entities
│   │   │   ├── repositories/   # Abstract repos
│   │   │   └── usecases/       # Use cases
│   │   └── presentation/
│   │       ├── bloc/           # BLoC files
│   │       ├── pages/          # Screens
│   │       └── widgets/        # Widgets
│   │
│   ├── dashboard/
│   ├── pickup/
│   ├── profile/
│   ├── settings/
│   └── canteen/
│
└── shared/                      # Shared components
    ├── widgets/                # Common widgets
    └── services/               # Shared services
```

### Step 3: Base Repository Pattern

```dart
// lib/core/repositories/base_repository.dart

abstract class BaseRepository<T> {
  Future<Result<T>> get(String id);
  Future<Result<List<T>>> getAll();
  Future<Result<T>> create(T item);
  Future<Result<T>> update(T item);
  Future<Result<void>> delete(String id);
}

// lib/features/auth/data/repositories/auth_repository_impl.dart

class AuthRepositoryImpl implements AuthRepository {
  final LocalAuthDataSource _localDataSource;
  final RemoteAuthDataSource? _remoteDataSource; // null in Phase 1
  
  AuthRepositoryImpl({
    required LocalAuthDataSource localDataSource,
    RemoteAuthDataSource? remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;
  
  @override
  Future<Result<User>> login(String studentId, String password) async {
    // Phase 1: Only local validation
    return await _localDataSource.login(studentId, password);
    
    // Phase 2: Add remote validation
    // if (_remoteDataSource != null) {
    //   return await _remoteDataSource.login(studentId, password);
    // }
  }
}
```

---

## 📝 Testing Strategy

### Local-First Testing Approach

```
Test Pyramid:

    /\
   /  \  E2E Tests (10%)
  /____\     - Full user flows
 /      \    - Device testing
/________\
           \  Integration Tests (20%)
            \   - Repository integration
             \  - BLoC integration
              \________________
               Widget Tests (30%)
                    - Screen testing
                    - Component testing
               ___________________
               Unit Tests (40%)
                    - Use cases
                    - Entities
                    - Utilities
```

### Example Test Structure

```dart
// Phase 1: Local-only tests
group('AuthRepository', () {
  late AuthRepository repository;
  late MockLocalAuthDataSource mockLocalDataSource;
  
  setUp(() {
    mockLocalDataSource = MockLocalAuthDataSource();
    repository = AuthRepositoryImpl(
      localDataSource: mockLocalDataSource,
      // remoteDataSource: null (Phase 1)
    );
  });
  
  test('should login with valid credentials locally', () async {
    // Arrange
    when(() => mockLocalDataSource.login(any(), any()))
        .thenAnswer((_) async => Right(mockUser));
    
    // Act
    final result = await repository.login('61913042', 'password123');
    
    // Assert
    expect(result, Right(mockUser));
    verify(() => mockLocalDataSource.login('61913042', 'password123')).called(1);
  });
});

// Phase 2: Add remote tests
group('AuthRepository - With Remote', () {
  late AuthRepository repository;
  late MockLocalAuthDataSource mockLocalDataSource;
  late MockRemoteAuthDataSource mockRemoteDataSource;
  
  setUp(() {
    mockLocalDataSource = MockLocalAuthDataSource();
    mockRemoteDataSource = MockRemoteAuthDataSource();
    repository = AuthRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource, // Phase 2
    );
  });
  
  test('should sync with backend after local login', () async {
    // Test sync logic
  });
});
```

---

## 🎯 Success Metrics

### Phase 1 (Prototyping)

| Metric | Target | Measurement |
|--------|--------|-------------|
| Feature Completeness | 100% | All 8 screens functional |
| Test Coverage | ≥ 70% | Coverage report |
| Performance | 60fps | Profiling |
| App Size | < 30MB | Build artifact |
| UX Satisfaction | > 4.0/5 | User testing |

### Phase 2 (Production)

| Metric | Target | Measurement |
|--------|--------|-------------|
| Test Coverage | ≥ 80% | Coverage report |
| API Response | < 200ms | Monitoring |
| Sync Success Rate | > 99% | Analytics |
| Crash Rate | < 1% | Crashlytics |

---

## 📚 Documentation Requirements

### During Phase 1

- [ ] Architecture Decision Records (ADRs)
- [ ] Local storage schema documentation
- [ ] Component library documentation
- [ ] Setup instructions (README)
- [ ] UX testing results

### During Phase 2

- [ ] API documentation (Swagger)
- [ ] Sync engine documentation
- [ ] Deployment runbooks
- [ ] Monitoring dashboards
- [ ] User guides

---

## 🚨 Risk Management

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Data migration complexity | Medium | High | Design sync engine early |
| Backend delays | Low | Medium | Local-first buys time |
| UX issues discovered late | Low | High | Early validation |
| Performance issues | Medium | Medium | Regular profiling |
| Scope creep | High | Medium | Strict backlog |

---

## 🎓 Lessons from Research

### Best Practices from Industry

1. **Always Read from Local DB** - Never update UI directly from API
2. **Use Exponential Backoff** - Don't hammer server when offline
3. **Encrypt Sensitive Data** - Use encrypted Hive or SQLite
4. **Clean Sync Queue** - Avoid infinite retries
5. **Event-Driven Sync** - Avoid "giant sync function" patterns

### Recommended Libraries

Based on research and existing project docs:

| Purpose | Library | Reason |
|---------|---------|--------|
| **State Management** | flutter_bloc | Clean architecture, testable |
| **Local DB (Simple)** | Hive | Fast, easy, type-safe |
| **Local DB (Complex)** | Drift/SQLite | SQL, relations, complex queries |
| **Navigation** | Go Router | Declarative, deep linking |
| **HTTP Client** | Dio | Interceptors, retry logic |
| **QR Codes** | qr_flutter | Reliable, customizable |
| **Testing** | mocktail + bloc_test | Clean mocking |

---

## ✅ Next Steps

### Immediate Actions (This Week)

1. **Review this document** with stakeholders
2. **Approve Phase 1 scope** and timeline
3. **Set up development environment**
4. **Initialize Flutter project** with local-first structure
5. **Create first sprint backlog**

### Week 1 Goals

- [ ] Project initialized
- [ ] Local storage system operational
- [ ] Theme system functional
- [ ] CI/CD pipeline running

---

*Document Version: 1.0*  
*Created: February 5, 2025*  
*Next Review: End of Week 1*
