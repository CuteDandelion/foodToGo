# Flutter Version Management

This project ensures all developers and CI/CD use the **exact same Flutter version** through configuration in `pubspec.yaml`.

## Current Flutter Version

**3.24.0** (stable channel)

The Flutter version is specified in `pubspec.yaml`:

```yaml
environment:
  sdk: ">=3.5.0 <4.0.0"
  flutter: "3.24.0"
```

## Why Version Locking?

- **Consistency**: All developers use the same Flutter version
- **CI/CD Alignment**: Local and CI environments match exactly
- **No Conflicts**: Avoid "works on my machine" issues
- **Reproducible Builds**: Same Flutter version = same build output

## Optional: Using FVM (Flutter Version Management)

While not required (since the version is locked in `pubspec.yaml`), you can use FVM for easier version management locally.

### 1. Install FVM

```bash
# Using pub
dart pub global activate fvm

# Or download from https://fvm.app/docs/getting_started/installation
```

### 2. Add FVM to PATH

Add to your shell profile (`.bashrc`, `.zshrc`, or PowerShell profile):

```bash
# macOS/Linux
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Windows (PowerShell)
$env:PATH += ";$env:LOCALAPPDATA\Pub\Cache\bin"
```

### 3. Install Project Flutter Version

```bash
# Navigate to project root
cd C:\Users\justi\OneDrive\Desktop\FoodBeGood

# Install the Flutter version specified in .fvmrc
fvm install 3.24.0

# Use the project Flutter version
fvm use 3.24.0
```

## Daily Usage

### Running Flutter Commands

**Without FVM** (using system Flutter):
```bash
# Ensure you're using Flutter 3.24.0
flutter --version

# Standard Flutter commands
flutter pub get
flutter run
flutter analyze
flutter test
flutter build apk --release
```

**With FVM** (optional):
```bash
# Use fvm prefix for all commands
fvm flutter pub get
fvm flutter run
fvm flutter analyze
fvm flutter test
fvm flutter build apk --release
```

### IDE Configuration

#### VS Code

Install the [Flutter Version Management](https://marketplace.visualstudio.com/items?itemName=leoafarias.fvm) extension.

Or configure manually in `.vscode/settings.json`:

```json
{
  "dart.flutterSdkPath": ".fvm/flutter_sdk",
  "search.exclude": {
    "**/.fvm": true
  }
}
```

#### Android Studio / IntelliJ

1. Open Settings → Languages & Frameworks → Flutter
2. Set "Flutter SDK path" to: `C:\Users\justi\OneDrive\Desktop\FoodBeGood\.fvm\flutter_sdk`

### Useful FVM Commands

```bash
# Check current Flutter version
fvm flutter --version

# List installed Flutter versions
fvm list

# Install a specific version
fvm install 3.24.0

# Use a specific version globally
fvm global 3.24.0

# Remove a version
fvm remove 3.24.0

# Update FVM
fvm update
```

## CI/CD Integration

The GitHub Actions workflow automatically reads the Flutter version from `pubspec.yaml`:

```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version-file: pubspec.yaml
    channel: 'stable'
```

This ensures CI uses the **exact same version** as local development.

**Note:** The `subosito/flutter-action` only supports reading the Flutter version from `pubspec.yaml` (specifically the `environment.flutter` field), not from `.fvmrc` files.

## Troubleshooting

### "fvm: command not found"

1. Ensure FVM is in your PATH
2. Restart your terminal/IDE
3. Try: `dart pub global activate fvm`

### Flutter SDK not found

```bash
# Reinstall the Flutter version
fvm install 3.24.0
fvm use 3.24.0
```

### IDE not recognizing FVM Flutter

1. Restart IDE after `fvm use`
2. Check SDK path points to `.fvm/flutter_sdk`
3. Run `fvm doctor` to diagnose issues

## Version Updates

When updating the Flutter version:

1. **Update `pubspec.yaml` environment** (Primary source of truth):
   ```yaml
   environment:
     sdk: ">=3.6.0 <4.0.0"  # Match new Flutter version's Dart SDK
     flutter: "3.25.0"      # New Flutter version
   ```

2. **Update FVM config** (Optional, for local FVM users):
   ```json
   {
     "flutter": "3.25.0"
   }
   ```

3. **Notify team**:
   ```bash
   # Without FVM
   flutter upgrade 3.25.0
   flutter pub get
   
   # With FVM
   fvm install 3.25.0
   fvm use 3.25.0
   fvm flutter pub get
   ```

## Related Files

- `pubspec.yaml` - **Primary** Flutter version specification (in `environment` section)
- `.fvmrc` - Optional FVM configuration for local development
- `.fvm/` - FVM cache directory (gitignored)
- `.github/workflows/flutter_ci.yml` - CI reads version from `pubspec.yaml`
