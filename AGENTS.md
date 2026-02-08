# FoodBeGood - Agent Guidelines

> Guidelines for AI agents working on the FoodBeGood Flutter mobile application.

## Project Overview

**FoodBeGood** is a food waste reduction mobile app for university canteens (targeting Mykolo Romerio Universitetas - MRU). Built with Flutter for iOS/Android, using BLoC pattern, Go Router, and Clean Architecture.

**Agent Role:** You are a professional UI/UX designer and software engineer. You must apply professional design principles, visual hierarchy, typography, color theory, and user experience best practices in all UI/UX work. Design decisions should be intentional, accessible, and aligned with modern mobile app standards.

## Environment

**Git Repository**  
https://github.com/CuteDandelion/foodToGo.git

**Platform:** Windows
- All file paths should use Windows-style backslashes (`\`)
- Commands assume Windows Command Prompt or PowerShell
- Working directory: `C:\Users\justi\OneDrive\Desktop\FoodBeGood`

## Project Paths

### Critical Project Directories

```
C:\Users\justi\OneDrive\Desktop\FoodBeGood\
├── lib\                          # Main Flutter source code
│   ├── features\                 # Feature modules (Clean Architecture)
│   ├── core\                     # Core utilities, errors, storage
│   └── shared\                   # Shared widgets and services
├── test\                         # Unit and widget tests
├── integration_test\             # E2E tests (Patrol)
├── android\                      # Android platform code
├── ios\                          # iOS platform code
├── assets\                       # Static assets
│   ├── images\                   # Image assets
│   ├── icons\                    # Icon assets
│   └── fonts\                    # Font files (Inter family)
├── memory\                       # Project documentation (CRITICAL)
│   ├── architecture\             # Architecture docs
│   ├── design\                   # UI/UX specifications
│   ├── technical\                # Technical documentation
│   └── development-log.md        # Project history
├── .github\workflows\            # CI/CD configurations
└── pubspec.yaml                  # Flutter dependencies
```

### Flutter SDK Path

**Actual Flutter Installation (This Machine):**
```bash
# Windows - User-local installation
C:\Users\justi\flutter\bin        # Add to PATH
```

**Standard Flutter Installation Paths:**
```bash
# Windows (typical)
C:\flutter\bin                    # System-wide installation
C:\Users\<username>\flutter\bin   # User-local installation

# Verify Flutter installation
flutter doctor
flutter --version
```

**Environment Variables Required:**
```bash
# Add to system PATH
C:\Users\justi\flutter\bin

# Android SDK (for Android builds)
C:\Users\justi\AppData\Local\Android\Sdk

# Java (for Android builds)
C:\Program Files\Eclipse Adoptium\jdk-<version>-hotspot\bin
```

### Build Output Paths

```bash
# Android APK output
build\app\outputs\flutter-apk\app-release.apk

# Android App Bundle output
build\app\outputs\bundle\release\app-release.aab

# iOS output (macOS only)
build\ios\iphoneos\Runner.app

# Web output
build\web\

# Test coverage output
coverage\lcov.info
```

### Tool-Specific Paths

**Patrol (E2E Testing):**
```bash
# Patrol configuration
android\app\src\main\AndroidManifest.xml    # Android test config
ios\Runner\Info.plist                        # iOS test config
```

**Firebase (if configured):**
```bash
# Firebase config files (DO NOT COMMIT)
android\app\google-services.json              # Android
ios\Runner\GoogleService-Info.plist          # iOS
lib\firebase_options.dart                    # Generated config
```

**Code Generation:**
```bash
# Generated files (do not edit manually)
lib\*.g.dart                                 # JSON serializable
lib\*.freezed.dart                           # Freezed models
lib\injection_container.config.dart          # Injectable config
```

## Rules

### Rule 1: Quality Over Quantity
**Prioritize depth over speed.** Every deliverable must meet high quality standards:
- **One excellent solution** is better than three mediocre ones
- **Take time to think** before implementing - rushed code creates technical debt
- **Refactor ruthlessly** - if code feels wrong, it probably is
- **Prefer fewer, well-tested features** over many buggy ones
- **Review your own work critically** before marking complete
- **Ask: "Would I be proud to show this to a senior engineer?"**

### Rule 2: Question Everything - Never Assume
**When in doubt, ALWAYS ask. Assumptions are the root of bugs:**
- **If requirements are unclear** → Ask for clarification before proceeding
- **If context is missing** → Request more information
- **If a pattern seems wrong** → Question it, don't blindly follow
- **If you're unsure about a dependency** → Research and verify
- **If the user says "just do X"** → Understand WHY before implementing
- **Better to over-communicate than to guess wrong**

### Rule 3: Invoke Software-Engineer Sub-Agent for Critical Decisions
**For non-trivial decisions, invoke a software-engineer sub-agent to challenge your thinking:**
- **Use the Task tool** with `subagent_type: "general"` to spawn a critical reviewer
- **Ask the sub-agent to:**
  - Review your proposed approach
  - Identify potential flaws or better alternatives
  - Question your assumptions
  - Suggest different perspectives or patterns
- **When to invoke:**
  - Architecture decisions
  - Non-obvious design patterns
  - Security-sensitive code
  - Performance-critical paths
  - Any time you feel uncertain
- **Example prompt:** *"Review my approach to [problem]. Challenge my assumptions. What am I missing? What could go wrong?"*

### Rule 4: Code Security Priority
Always prioritize code security. When reviewing or writing code:
- **Flag all security issues** and unsafe patterns immediately
- **Suggest secure alternatives** with specific code examples
- **Never ignore** potential security vulnerabilities (OWASP Top 10, injection attacks, XSS, CSRF, etc.)
- **Question** any use of: unsafe eval(), hardcoded secrets, weak encryption, improper input validation, or insecure dependencies

### Rule 5: Best Pattern Selection
Always review and choose the best pattern for the task:
- **Analyze multiple approaches** before implementing
- **Consider trade-offs**: performance vs. readability, complexity vs. maintainability
- **Prefer industry-standard patterns** over custom solutions
- **Document your reasoning** when selecting non-obvious patterns
- **Consider future maintainers**: Will this pattern be clear to other developers?

### Rule 6: Always Document in Memory
All project documentation MUST be stored in the `\memory\` directory:
- **CRITICAL**: Never store documentation in the project root or other directories
- Create documentation in appropriate subdirectories: `\memory\architecture\`, `\memory\design\`, `\memory\technical\`, `\memory\notes\`, `\memory\decisions\`
- After every task, update `\memory\development-log.md` with changes made, files created/modified, and design decisions
- Create interactive HTML diagrams for system architecture in `\memory\diagrams\`
- Document architectural decisions as ADRs in `\memory\decisions\`

### Rule 7: Design Must Reflect index.html and archived-images
When implementing UI/UX design for the app:
- **MUST reflect** the design specifications found in `index.html` and `archived-images` unless explicitly specified otherwise
- **Reference first**: Always check `index.html` and `archived-images` before proposing or implementing any design changes
- **Consistency required**: Maintain visual consistency with the established design system, color schemes, layouts, and components
- **If impossible**: If implementing the exact design from `index.html` and `archived-images` is not feasible:
  - Document the technical constraints or limitations
  - Suggest better alternative designs that maintain the core user experience
  - Provide specific recommendations with visual references or detailed descriptions
  - Get approval before proceeding with alternative designs

### Rule 8: Complete Testing Before Completion
Before considering any task complete, you MUST run the full validation suite in a single session:
- **Build**: Ensure the code compiles without errors
- **Lint**: Run linting and fix all issues
- **Unit Tests**: Execute all unit tests and ensure they pass
- **E2E Tests**: Run Appium MCP tools to execute end-to-end tests
  - Run E2E tests with head/visible mode when possible so interactions can be observed
  - Verify critical user flows work as expected
  - Document any test failures and fix before marking complete
- **Never skip**: All tests must pass before the task is considered done

### Rule 9: Visual Comparison for Design Integrity
**ALWAYS compare the design reference with the actual implementation to eliminate AI slop, poor design choices, and visual bugs:**
- **Reference Screenshot**: Use Playwright MCP to capture a screenshot of `./index.html` (the design specification)
- **Implementation Screenshot**: Use ADB/emulator tools to capture a screenshot of the built APK running on an Android emulator
- **Comparison Process**:
  1. Load `./index.html` in a browser using Playwright MCP and capture a screenshot
  2. Build the APK and install it on an Android emulator
  3. Navigate to the corresponding screen in the app
  4. Capture a screenshot of the APK using ADB/emulator tools
  5. Visually compare both screenshots side-by-side
  6. Identify discrepancies in: layout, colors, typography, spacing, alignment, component styling, and overall visual hierarchy
- **Fix Discrepancies**: Any visual differences between the design reference and implementation must be corrected before marking the task complete
- **Document Deviations**: If technical constraints prevent exact implementation, document the reasons and get approval for the deviation
- **Goal**: Ensure pixel-perfect implementation that matches the approved design specification

## Build Commands

### Flutter Development

```bash
# Install dependencies
flutter pub get

# Run code generation (for JSON serializable, freezed, retrofit)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for code generation changes
flutter pub run build_runner watch --delete-conflicting-outputs

# Run development server
flutter run

# Run on specific device
flutter run -d ios        # iOS simulator (macOS only)
flutter run -d android    # Android emulator

# Build production APK
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release

# Build iOS release (macOS only)
flutter build ios --release
```

### Backend (Node.js)

```bash
cd backend
npm install
npm run dev        # Development with hot reload
npm run build      # Build for production
npm run start      # Production server
```

## Test Commands

### Flutter Tests

```bash
# Run all tests
flutter test

# Run a single test file
flutter test test/features/auth/domain/usecases/login_test.dart

# Run tests matching a pattern
flutter test --name "Login"

# Run with coverage
flutter test --coverage

# Generate golden files (for widget tests)
flutter test --update-goldens

# Run integration tests
flutter test integration_test/app_test.dart
```

### Backend Tests

```bash
npm test                    # Run all tests
npm test -- auth.test.js    # Run single test file
npm test -- --coverage      # With coverage
npm test -- --watch         # Watch mode
```

### E2E Tests (Patrol)

```bash
# Run E2E tests
patrol test

# Run on specific device
patrol test --device-id emulator-5554
```

## Lint & Format Commands

### Flutter

```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/

# Format with specific line length
flutter format lib/ --line-length 100

# Fix auto-fixable issues
dart fix --apply
```

### Backend

```bash
npm run lint            # ESLint
npm run lint:fix        # Auto-fix ESLint issues
npm run format          # Prettier format
```

## Code Style Guidelines

### Dart/Flutter Conventions

**Naming:**
- `PascalCase` for classes, enums, typedefs, type parameters
- `camelCase` for variables, functions, methods
- `snake_case` for file names and imports
- `SCREAMING_SNAKE_CASE` for constants

**Imports:**
```dart
// Order: Dart/Flutter → Packages → Relative
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/failures.dart';
import '../models/user_model.dart';
```

**Types:**
- Always use explicit types for public APIs
- Use `final` over `var` when value doesn't change
- Use `const` constructors when possible
- Prefer `async/await` over raw `Future`

**Error Handling:**
```dart
// Use Either type from dartz for functional error handling
Either<Failure, Success> result = await useCase(params);

result.fold(
  (failure) => emit(ErrorState(failure.message)),
  (success) => emit(SuccessState(success)),
);
```

### Architecture Pattern

**Clean Architecture with BLoC:**
```
lib/
├── features/
│   └── feature_name/
│       ├── data/
│       │   ├── datasources/     # Remote/Local data sources
│       │   ├── models/          # Data models
│       │   └── repositories/    # Repository implementations
│       ├── domain/
│       │   ├── entities/        # Domain entities
│       │   ├── repositories/    # Repository interfaces
│       │   └── usecases/        # Use cases
│       └── presentation/
│           ├── bloc/            # BLoC files (bloc, event, state)
│           ├── pages/           # Screen widgets
│           └── widgets/         # Feature-specific widgets
```

### State Management (BLoC)

```dart
// Event naming
abstract class AuthEvent {}
class AuthLoginRequested extends AuthEvent {}

// State naming
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
```

### Widget Guidelines

```dart
// Prefer const constructors
const MyWidget({super.key});

// Use super parameters for key
class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: const [
            // Use const for static widgets
            HeaderWidget(),
          ],
        ),
      ),
    );
  }
}
```

### Testing Standards

```dart
// Unit test naming
group('LoginUseCase', () {
  test('should return User when credentials are valid', () async {
    // arrange
    // act  
    // assert
  });
});

// Mock naming
class MockAuthRepository extends Mock implements AuthRepository {}

// Test coverage target: 80% minimum
```

### Documentation

- Store all documentation in `\memory\` directory
- Update `development-log.md` after each major change
- Create ADRs for architectural decisions in `\memory\decisions\`
- Use interactive HTML diagrams for system architecture

### Git Workflow

- Never push directly to `main`
- Create feature branches: `feature/description`
- Write descriptive commit messages
- Run `flutter analyze && flutter test` before committing

## Git Worktree Hygiene

### Single Source of Truth Principle
**CRITICAL**: Maintain `main` branch as the single source of truth. All work must flow through PRs to main.

```
┌─────────────────────────────────────────────────────────────┐
│                    SINGLE SOURCE OF TRUTH                    │
│                                                              │
│   main (protected)                                          │
│     ↑                                                        │
│   PR #1 ←── feature/auth-login                              │
│     ↑                                                        │
│   PR #2 ←── feature/dashboard-ui                            │
│     ↑                                                        │
│   PR #3 ←── bugfix/login-validation                         │
│                                                              │
│   NEVER commit directly to main                              │
│   ALWAYS create feature branches                             │
│   ALWAYS use Pull Requests                                   │
└─────────────────────────────────────────────────────────────┘
```

### Branch Naming Conventions

```bash
# Feature branches
feature/<short-description>
feature/user-authentication
feature/dashboard-dark-mode

# Bug fix branches
bugfix/<issue-description>
bugfix/login-crash-on-ios
bugfix/memory-leak-in-bloc

# Hotfix branches (production issues)
hotfix/<critical-issue>
hotfix/security-vulnerability
hotfix/payment-gateway-error

# Release branches
release/<version>
release/v1.2.0
release/v2.0.0-beta
```

### Branch Lifecycle Management

**1. Create Feature Branch (Always from latest main)**
```bash
# Ensure you're on main and it's up to date
git checkout main
git pull origin main

# Create and switch to feature branch
git checkout -b feature/your-feature-name

# Push branch to remote
git push -u origin feature/your-feature-name
```

**2. Keep Branch Updated**
```bash
# While working on feature, regularly sync with main
git checkout main
git pull origin main
git checkout feature/your-feature-name
git rebase main

# Or merge main into feature
git merge main
```

**3. Clean Up After Merge**
```bash
# Delete local branch after PR is merged
git checkout main
git pull origin main
git branch -d feature/your-feature-name

# Delete remote branch
git push origin --delete feature/your-feature-name
```

### Remote Branch Pruning (Prevent Branch Pollution)

**Automatic Pruning Configuration**
```bash
# Enable automatic pruning on fetch
git config --global fetch.prune true

# Or manually prune remote-tracking branches
git fetch --prune
```

**Regular Branch Cleanup Commands**
```bash
# List all remote branches
git branch -r

# List merged branches (safe to delete)
git branch -r --merged main

# Delete specific stale remote branch
git push origin --delete feature/old-feature-name

# Clean up local references to deleted remote branches
git remote prune origin

# List branches not merged (review before deleting)
git branch -r --no-merged main
```

**Branch Cleanup Schedule**
- **Daily**: Remove branches merged via PRs
- **Weekly**: Review and remove stale feature branches (>2 weeks old)
- **Monthly**: Archive or document long-running branches

### Worktree Best Practices

**1. One Worktree Per Task**
```bash
# Create isolated worktree for hotfix while working on feature
git worktree add ../foodbegood-hotfix hotfix/critical-fix
cd ../foodbegood-hotfix
# Work on hotfix independently
```

**2. Clean Worktree Structure**
```
C:\Users\justi\OneDrive\Desktop\
├── FoodBeGood\                    # Main worktree (main branch)
├── FoodBeGood-feature-auth\       # Feature worktree
├── FoodBeGood-hotfix-payment\     # Hotfix worktree
└── FoodBeGood-release-v1.2\       # Release worktree
```

**3. Remove Worktree When Done**
```bash
# Remove worktree
git worktree remove ../foodbegood-hotfix

# Or manually delete and prune
git worktree prune
```

### Pre-Commit Checklist

```bash
# Before every commit, run:
flutter analyze                    # No lint errors
flutter test                       # All tests pass
flutter format --set-exit-if-changed lib/ test/  # Properly formatted

# Check what you're committing
git status
git diff --cached

# Ensure no sensitive files
git diff --cached --name-only | grep -E "(\.env|\.jks|keystore)" && echo "WARNING: Sensitive files detected!"
```

### Commit Message Standards

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting (no code change)
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Build/process changes

**Examples:**
```
feat(auth): add biometric authentication

Implement fingerprint and face ID authentication
using local_auth package. Added secure storage
for credentials.

Closes #123
```

```
fix(dashboard): resolve memory leak in chart widget

Dispose animation controllers properly to prevent
memory accumulation during rapid navigation.

Fixes #456
```

## Key Resources

- **Tech Stack**: `\memory\technical\technology-stack.md`
- **Development Log**: `\memory\development-log.md`
- **App Design**: `\memory\design\app-design-v2.md`
- **Brand Guidelines**: `\memory\design\brand-guidelines-v2.md`
