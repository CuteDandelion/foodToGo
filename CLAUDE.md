# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

FoodBeGood is a Flutter mobile app for food waste reduction at university canteens (MRU). It connects students picking up surplus food with canteen staff. Currently in Phase 1 (local-first prototype with mock data, no real backend).

Two user roles: **Student** (dashboard, pickup flow, QR code, meal history) and **Canteen Staff** (analytics dashboard, food request management).

## Common Commands

```bash
# Install dependencies
flutter pub get

# Code generation (REQUIRED before build — Freezed, JSON, Retrofit, Hive, Injectable)
flutter pub run build_runner build --delete-conflicting-outputs

# Run
flutter run

# Lint (must pass with zero warnings)
flutter analyze

# Format
dart format lib/ test/

# Run all tests
flutter test

# Run CI-compatible tests only (excludes widget tests needing ScreenUtil init)
flutter test test/features test/core --coverage

# Run widget tests locally only
flutter test test/widgets

# E2E tests
patrol test

# Pre-commit validation sequence
flutter pub run build_runner build --delete-conflicting-outputs && flutter analyze && dart format --output=none --set-exit-if-changed lib/ test/ && flutter test && flutter build apk --debug
```

## Architecture

Clean Architecture with BLoC state management, organized by feature:

```
lib/
├── main.dart / app.dart          # Entry point, MultiBlocProvider, MaterialApp.router
├── injection_container.dart      # Get It + Injectable DI setup
├── config/
│   ├── constants.dart            # App-wide constants (storage keys, timeouts, Hive boxes)
│   ├── routes.dart               # Go Router config, RoutePaths, GoRouterExtension on BuildContext
│   └── theme.dart                # Material 3 light/dark theme, brand colors (AppColors)
├── core/
│   ├── errors/failures.dart      # Failure hierarchy (ServerFailure, AuthFailure, etc.)
│   ├── storage/storage_manager.dart  # Unified 3-tier storage (Hive, SQLite, SharedPrefs)
│   └── usecases/usecase.dart     # Abstract UseCase<Type, Params> base class
├── features/                     # Each feature: domain/ (entities) + presentation/ (bloc, pages, widgets)
│   ├── auth/                     # Login, role selection
│   ├── dashboard/                # Student dashboard with animated widgets
│   ├── canteen/                  # Canteen staff dashboard
│   ├── pickup/                   # Food selection → time slot → confirmation → QR code
│   ├── profile/                  # User profile, meal history
│   └── settings/                 # Theme toggle
└── shared/
    ├── services/mock_data_service.dart  # Singleton providing all mock data (Phase 1)
    └── widgets/                  # Reusable: app_button, app_card, glassmorphism, etc.
```

## Key Patterns

- **Functional error handling**: `dartz` `Either<Failure, T>` — `Left` = failure, `Right` = success
- **BLoC naming**: Events as `<Feature><Action>` (e.g., `AuthLoginRequested`), States as `<Feature><Status>` (e.g., `AuthAuthenticated`)
- **Responsive sizing**: `flutter_screenutil` with base `375x812`. Use `.sp` for fonts, `.w`/`.h` for dimensions, `.r` for radii
- **Navigation**: Go Router with type-safe extensions on `BuildContext` (e.g., `context.goPickup()`, `context.goQRCode(...)`)
- **Three-tier storage**: `StorageManager` singleton — `.prefs` (SharedPreferences), `.cache` (Hive), `.database` (SQLite)
- **Code generation**: Never manually edit `*.g.dart`, `*.freezed.dart`, or `injection_container.config.dart`

## Conventions

- **Imports**: Dart core → Flutter/packages → relative imports
- **Types**: Explicit types for public APIs, `final` over `var`, `const` constructors always
- **Widgets**: Always use `const` constructors with `super.key`
- **Tests**: AAA pattern (arrange/act/assert), `mocktail` for mocking, `bloc_test` for BLoC tests
- **Commits**: `<type>(<scope>): <subject>` — types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- **Branches**: Never commit to `main` directly. Use `feature/`, `bugfix/`, `improvement/`, `refactor/` prefixes
- **Documentation**: All project docs go in `memory/` directory only

## Design Reference

`index.html` in the project root is the canonical UI design spec. All UI must match it. Reference screenshots are in `archived-images/`.

## CI Pipeline

Defined in `.github/workflows/flutter_ci.yml`:
1. `analyze` — lint + format check (always runs)
2. `test` — unit tests excluding widget tests (requires analyze)
3. `build-android-apk` / `build-android-aab` / `build-ios` — only on push to `main`/`release`
4. `security-check` — dependency audit (independent)

Widget tests are excluded from CI (require `flutter_screenutil` init) — run them locally.
