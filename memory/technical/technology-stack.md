# FoodBeGood Technologies Stack

## Overview

This document outlines the recommended technology stack for building the FoodBeGood mobile application. The stack is designed to support both iOS and Android platforms while maintaining code reusability, performance, and developer productivity.

---

## 1. Frontend Mobile Development

### 1.1 Recommended Approach: Flutter

**Why Flutter?**
- Single codebase for iOS and Android (100% code reuse)
- Native performance with compiled code (Dart AOT compilation)
- Beautiful, customizable UI with built-in Material Design and Cupertino widgets
- Hot reload for fast development
- Rich ecosystem of packages and plugins
- Excellent documentation and community support
- Built-in testing framework
- Consistent UI across platforms

**Alternative Options:**
- **React Native**: Good ecosystem but requires JavaScript bridge
- **Native (Swift/Kotlin)**: Maximum performance but 2x development effort
- **Ionic/Cordova**: Web-based, lower performance

### 1.2 Flutter Specifics

```yaml
# Current Flutter version (as of Feb 2026)
flutter: "3.27.3"

dart: ">=3.5.0 <4.0.0"
```

**Key Dependencies:**

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  
  # Navigation
  go_router: ^13.0.0
  
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Networking
  dio: ^5.4.0
  retrofit: ^4.0.3
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  sqflite: ^2.3.0
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  path_provider: ^2.1.2
  path: ^1.8.3
  
  # UI Components
  flutter_screenutil: ^5.9.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  
  # Camera & QR
  camera: ^0.10.5+9
  mobile_scanner: ^3.5.5
  qr_flutter: ^4.1.0
  image_picker: ^1.0.7
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
  firebase_analytics: ^10.8.0
  firebase_crashlytics: ^3.4.9
  
  # Charts & Visualization
  fl_chart: ^0.66.0
  
  # Internationalization
  intl: ^0.19.0
  
  # Security
  flutter_secure_storage: ^9.0.0
  local_auth: ^2.1.8
  
  # Utils
  intl: ^0.19.0
  logger: ^2.0.2
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  uuid: ^4.2.1
  crypto: ^3.0.3
  dartz: ^0.10.1
  
  # Sensors
  sensors_plus: ^4.0.2
  
  # Dependency Injection
  get_it: ^7.6.4
  injectable: ^2.3.2
```

**Navigation:**
- **Library:** Go Router
- **Type:** Declarative routing
- **Deep Linking:** Supported

```yaml
dependencies:
  go_router: ^13.0.0
```

### 1.3 UI Components

**Option 1: Custom Components (Recommended)**
- Build from scratch using Flutter widgets
- Full control over design
- Better performance
- Matches design system exactly
- Use Flutter's built-in Material/Cupertino as base

**Option 2: UI Library**
- **Flutter Material:** Google's Material Design
- **Flutter Cupertino:** iOS-style widgets
- **GetWidget:** Pre-built UI kit

**Recommended:** Custom components with Flutter's widget system

### 1.4 State Management

**Primary:** BLoC Pattern (Business Logic Component)
```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
```

**Alternative:** Riverpod (lighter weight, modern)
```yaml
dependencies:
  flutter_riverpod: ^2.4.9
```

**Alternative:** GetX (all-in-one solution)
```yaml
dependencies:
  get: ^4.6.6
```

**Local State:** Flutter Hooks or StatefulWidget

---

## 2. Backend Technologies

### 2.1 API Development

**Recommended: Node.js + Express**

```javascript
// Core
"express": "^4.18.2"
"node": "^20.10.0"

// Middleware
"cors": "^2.8.5"
"helmet": "^7.1.0"
"compression": "^1.7.4"
"morgan": "^1.10.0"
```

**Alternative Options:**
- **NestJS:** Enterprise-grade, TypeScript-first
- **Fastify:** High performance
- **Django/DRF:** Python ecosystem
- **Spring Boot:** Java ecosystem

### 2.2 Database

**Primary Database: PostgreSQL**
- Relational data structure
- ACID compliance
- JSON support for flexible data
- Excellent performance

```yaml
Version: 15.x
ORM: Prisma or TypeORM
```

**Caching: Redis**
- Session storage
- Rate limiting
- Cache layer

```yaml
Version: 7.x
```

**Alternative Databases:**
- **MongoDB:** If flexible schema needed
- **MySQL:** If team familiar
- **SQLite:** For local/offline storage (Flutter sqflite package)

### 2.3 Authentication

**JWT (JSON Web Tokens)**
```javascript
"jsonwebtoken": "^9.0.0"
"bcryptjs": "^2.4.3"
"passport": "^0.7.0"
"passport-jwt": "^4.0.0"
```

**Features:**
- Access tokens (short-lived: 15 mins)
- Refresh tokens (long-lived: 30 days)
- Token rotation for security
- Secure storage (flutter_secure_storage)

### 2.4 File Storage

**AWS S3 or Cloudflare R2**
- User profile images
- Meal photos
- CSV exports

```javascript
"@aws-sdk/client-s3": "^3.450.0"
"multer": "^1.4.5-lts.1"
"multer-s3": "^3.0.1"
```

---

## 3. Cloud Infrastructure

### 3.1 Hosting Options

**Option 1: AWS (Recommended)**
- EC2 or ECS for API servers
- RDS for PostgreSQL
- ElastiCache for Redis
- S3 for file storage
- CloudFront for CDN

**Option 2: Google Cloud Platform**
- Cloud Run for API
- Cloud SQL for database
- Memorystore for Redis
- Cloud Storage for files

**Option 3: Vercel + Railway**
- Vercel for frontend (if web)
- Railway for backend API
- Simplified deployment

### 3.2 Containerization

**Docker + Docker Compose**

```dockerfile
# API Dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

**Orchestration:**
- Docker Compose (development)
- Kubernetes (production scale)
- AWS ECS/Fargate (managed)

### 3.3 CI/CD Pipeline

**GitHub Actions (Recommended)**

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [ main ]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - name: Deploy to production
        run: |
          # Deployment commands
```

**Pipeline Steps:**
1. Lint and test (Flutter analyze, test)
2. Build Flutter apps (iOS/Android)
3. Run security scans
4. Deploy to staging
5. Integration tests
6. Deploy to production

---

## 4. Push Notifications

### 4.1 Firebase Cloud Messaging (FCM)

**Android:**
- Native FCM integration
- Firebase Admin SDK for backend

**iOS:**
- FCM + APNS integration
- Same backend endpoint

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
```

```javascript
"firebase-admin": "^12.0.0"
```

### 4.2 Notification Types

- **Urgent Access:** High priority, sound + badge
- **Announcements:** Normal priority, badge only
- **Weekly Summary:** Low priority, silent

---

## 5. Image Processing

### 5.1 ML-Based Food Recognition

**Option 1: TensorFlow Lite (On-device)**
- Better privacy
- Works offline
- Lower latency

```yaml
dependencies:
  tflite_flutter: ^0.10.4
  tflite_flutter_helper: ^0.3.1
```

**Option 2: Cloud Vision API**
- Higher accuracy
- More food categories
- Requires internet

```yaml
dependencies:
  google_mlkit_image_labeling: ^0.10.0
```

**Recommended:** Hybrid approach
- On-device model for common foods
- Cloud API fallback for unknown items

### 5.2 Image Upload

```yaml
dependencies:
  image_picker: ^1.0.7
  image_cropper: ^5.0.1
```

**Processing Pipeline:**
1. Capture/select image (image_picker)
2. Resize/compress (flutter_image_compress)
3. Upload to S3
4. Return URL for ML processing

---

## 6. QR Code Generation

### 6.1 Generation (Backend)

```javascript
"qrcode": "^1.5.3"
"@types/qrcode": "^1.5.5"
```

**QR Code Data:**
```json
{
  "userId": "61913042",
  "type": "student-id",
  "expires": "2025-12-31T23:59:59Z"
}
```

### 6.2 Display & Scanning (Mobile)

```yaml
dependencies:
  qr_flutter: ^4.1.0        # Generate QR codes
  mobile_scanner: ^3.5.5    # Scan QR codes
```

---

## 7. Monitoring & Analytics

### 7.1 Error Tracking

**Firebase Crashlytics (Recommended for Flutter)**
```yaml
dependencies:
  firebase_crashlytics: ^3.4.9
```

**Sentry (Alternative)**
```yaml
dependencies:
  sentry_flutter: ^7.14.0
```

Features:
- Real-time error tracking
- Performance monitoring
- Release tracking
- Source maps

### 7.2 Analytics

**Firebase Analytics (Free)**
```yaml
dependencies:
  firebase_analytics: ^10.8.0
```

**Amplitude (Advanced)**
```yaml
dependencies:
  amplitude_flutter: ^3.16.0
```

### 7.3 Logging

**Backend:**
```javascript
"winston": "^3.11.0"
"winston-daily-rotate-file": "^4.7.1"
```

**Mobile:**
```yaml
dependencies:
  logger: ^2.0.2
```

---

## 8. Testing

### 8.1 Unit Testing

**Flutter:**
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.1
  bloc_test: ^9.1.5
```

**Backend:**
```javascript
"jest": "^29.7.0"
"supertest": "^6.3.3"
```

### 8.2 Widget Testing (Flutter)

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  golden_toolkit: ^0.15.0
```

### 8.3 Integration Testing (Flutter)

```yaml
dev_dependencies:
  integration_test:
    sdk: flutter
```

### 8.4 E2E Testing

**Patrol (Flutter)**
```yaml
dev_dependencies:
  patrol: ^3.0.0
```

**Maestro (Alternative)**
- YAML-based
- Cross-platform
- Easy to write

### 8.5 Test Coverage Targets

- Unit Tests: 80% minimum
- Widget Tests: Key components covered
- Integration Tests: Critical user journeys

---

## 9. Security

### 9.1 Mobile Security

```yaml
dependencies:
  flutter_secure_storage: ^9.0.0    # Secure storage
  local_auth: ^2.1.8                 # Biometric auth
  jailbreak_root_detection: ^1.0.0   # Root/jailbreak detection
```

### 9.2 Backend Security

```javascript
"rate-limiter-flexible": "^4.0.0"        // Rate limiting
"express-rate-limit": "^7.1.0"
"express-slow-down": "^2.0.0"
"express-validator": "^7.0.0"            // Input validation
"xss-clean": "^0.1.4"                    // XSS protection
"hpp": "^0.2.3"                          // HTTP Parameter Pollution
```

### 9.3 Environment Variables

```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

---

## 10. Development Tools

### 10.1 IDE & Extensions

**VS Code Extensions:**
- Flutter
- Dart
- Dart Data Class Generator
- Flutter Tree
- Awesome Flutter Snippets
- Bracket Pair Colorizer

**Android Studio/IntelliJ:**
- Flutter Plugin
- Dart Plugin

### 10.2 Code Quality

**Flutter:**
```yaml
dev_dependencies:
  flutter_lints: ^3.0.1
  very_good_analysis: ^5.1.0
```

**Linting:**
```yaml
analysis_options.yaml:
  include: package:very_good_analysis/analysis_options.yaml
```

**Pre-commit Hooks:**
```yaml
dev_dependencies:
  husky: ^0.6.0
  lint_staged: ^0.5.0
```

### 10.3 API Development

**Postman / Insomnia** for API testing
**Swagger/OpenAPI** for documentation

```javascript
"swagger-jsdoc": "^6.2.8"
"swagger-ui-express": "^5.0.0"
```

---

## 11. pubspec.yaml Example

### Mobile (Flutter)

```yaml
name: foodbegood
version: 1.0.0+1
publish_to: 'none'

environment:
  sdk: ">=3.5.0 <4.0.0"
  flutter: "3.27.3"

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  
  # Navigation
  go_router: ^13.0.0
  
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Networking
  dio: ^5.4.0
  retrofit: ^4.0.3
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  sqflite: ^2.3.0
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  path_provider: ^2.1.2
  path: ^1.8.3
  
  # UI
  flutter_screenutil: ^5.9.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  
  # Camera & QR
  camera: ^0.10.5+9
  mobile_scanner: ^3.5.5
  qr_flutter: ^4.1.0
  image_picker: ^1.0.7
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
  firebase_analytics: ^10.8.0
  firebase_crashlytics: ^3.4.9
  
  # Charts
  fl_chart: ^0.66.0
  
  # Utils
  intl: ^0.19.0
  logger: ^2.0.2
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  uuid: ^4.2.1
  crypto: ^3.0.3
  dartz: ^0.10.1
  
  # Sensors
  sensors_plus: ^4.0.2
  
  # Dependency Injection
  get_it: ^7.6.4
  injectable: ^2.3.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  very_good_analysis: ^5.1.0
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  retrofit_generator: ^8.0.6
  hive_generator: ^2.0.1
  mocktail: ^1.0.1
  bloc_test: ^9.1.5
  injectable_generator: ^2.4.1
  patrol: ^3.0.0

flutter:
  uses-material-design: true
  generate: true
  
  assets:
    - assets/images/
    - assets/icons/
  
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

### Backend (Node.js)

```json
{
  "name": "foodbegood-api",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "compression": "^1.7.4",
    "prisma": "^5.6.0",
    "@prisma/client": "^5.6.0",
    "jsonwebtoken": "^9.0.0",
    "bcryptjs": "^2.4.3",
    "passport": "^0.7.0",
    "passport-jwt": "^4.0.0",
    "redis": "^4.6.0",
    "@aws-sdk/client-s3": "^3.450.0",
    "multer": "^1.4.5-lts.1",
    "firebase-admin": "^12.0.0",
    "qrcode": "^1.5.3",
    "winston": "^3.11.0",
    "express-rate-limit": "^7.1.0",
    "express-validator": "^7.0.0"
  },
  "devDependencies": {
    "@types/express": "^4.17.0",
    "@types/node": "^20.0.0",
    "jest": "^29.7.0",
    "supertest": "^6.3.3",
    "typescript": "^5.3.0",
    "ts-node": "^10.9.0",
    "nodemon": "^3.0.0",
    "eslint": "^8.55.0"
  }
}
```

---

## 12. Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                          │
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │   iOS App       │  │  Android App    │                   │
│  │    (Flutter)    │  │    (Flutter)    │                   │
│  └────────┬────────┘  └────────┬────────┘                   │
└───────────┼────────────────────┼────────────────────────────┘
            │                    │
            └────────┬───────────┘
                     │ HTTPS/SSL
┌────────────────────┼────────────────────────────────────────┐
│                   API LAYER                                  │
│  ┌─────────────────▼─────────────────┐                       │
│  │    Node.js + Express API          │                       │
│  │  ┌─────────────┐ ┌─────────────┐  │                       │
│  │  │  Auth       │ │  Meals      │  │                       │
│  │  │  Service    │ │  Service    │  │                       │
│  │  └─────────────┘ └─────────────┘  │                       │
│  │  ┌─────────────┐ ┌─────────────┐  │                       │
│  │  │  User       │ │  Canteen    │  │                       │
│  │  │  Service    │ │  Service    │  │                       │
│  │  └─────────────┘ └─────────────┘  │                       │
│  └─────────────────┬─────────────────┘                       │
└────────────────────┼────────────────────────────────────────┘
                     │
         ┌────────────┼────────────┐
         │            │            │
┌───────▼──────┐ ┌──▼───────┐ ┌──▼──────────┐
│  PostgreSQL  │ │  Redis   │ │     S3      │
│  (Primary)   │ │ (Cache)  │ │  (Files)    │
└──────────────┘ └──────────┘ └─────────────┘
```

---

## 13. Technology Selection Criteria

### 13.1 Evaluation Factors

| Factor | Weight | Flutter | React Native | Native |
|--------|--------|---------|--------------|--------|
| Development Speed | 25% | ★★★★★ | ★★★★★ | ★★☆☆☆ |
| Performance | 25% | ★★★★★ | ★★★★☆ | ★★★★★ |
| UI Consistency | 20% | ★★★★★ | ★★★☆☆ | ★★★★★ |
| Ecosystem | 15% | ★★★★☆ | ★★★★★ | ★★★★★ |
| Team Expertise | 10% | ★★★★☆ | ★★★★☆ | ★★★☆☆ |
| Cost | 5% | ★★★★★ | ★★★★★ | ★★★☆☆ |
| **Total** | 100% | **4.75** | **4.35** | **3.75** |

### 13.2 Why Flutter Over React Native

**Flutter Advantages:**
1. **Single Codebase:** 100% code sharing vs 70-80% with React Native
2. **Performance:** Compiled to native ARM code, no JavaScript bridge
3. **UI Consistency:** Pixel-perfect rendering on both platforms
4. **Hot Reload:** Faster development cycle
5. **Built-in Widgets:** Rich set of Material and Cupertino widgets
6. **Testing:** Built-in testing framework
7. **Documentation:** Excellent official documentation
8. **Dart:** Modern language with sound null safety

**When to consider alternatives:**
- **React Native:** If team has strong JavaScript/React expertise
- **Native:** If platform-specific features are critical
- **SwiftUI/Jetpack Compose:** If targeting latest OS versions only

### 13.3 Final Recommendation

**Primary Stack:** Flutter + Node.js + PostgreSQL

**Architecture Pattern:** Clean Architecture with BLoC

**State Management:** BLoC Pattern (flutter_bloc)

**Networking:** Dio + Retrofit

**Local Storage:** Hive + flutter_secure_storage

---

## 14. Learning Resources

### 14.1 Flutter
- Official Docs: https://docs.flutter.dev
- Flutter Widget Catalog: https://docs.flutter.dev/ui/widgets
- BLoC Pattern: https://bloclibrary.dev
- Dart Language: https://dart.dev

### 14.2 Node.js/Backend
- Express.js: https://expressjs.com
- Prisma ORM: https://prisma.io
- JWT.io: https://jwt.io

### 14.3 DevOps
- Docker: https://docs.docker.com
- AWS: https://aws.amazon.com/documentation
- GitHub Actions: https://docs.github.com/actions

### 14.4 Flutter Architecture
- Clean Architecture: https://resocoder.com/flutter-clean-architecture
- BLoC Pattern: https://bloclibrary.dev/#/gettingstarted
- Repository Pattern: https://flutter.dev/docs/development/data-and-backend/state-mgmt

---

## 15. Version History

| Version | Date | Changes |
|---------|------|---------|
| 3.0.0 | 2026-02-14 | Updated to Flutter 3.27.3, added sensors_plus, sqflite, dependency injection |
| 2.0.0 | 2025-02-04 | Migrated from React Native to Flutter as primary mobile framework |
| 1.0.0 | 2025-02-04 | Initial technology stack documentation with React Native |

---

*Technology stack updated to Flutter 3.27.3 - February 2026*
