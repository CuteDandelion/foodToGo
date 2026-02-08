# Flutter Version Management (FVM)

This project uses [FVM](https://fvm.app/) (Flutter Version Management) to ensure all developers and CI/CD use the **exact same Flutter version**.

## Current Flutter Version

**3.24.0** (stable channel)

## Why FVM?

- **Consistency**: All developers use the same Flutter version
- **CI/CD Alignment**: Local and CI environments match exactly
- **No Conflicts**: Avoid "works on my machine" issues
- **Easy Switching**: Switch between Flutter versions per project

## Installation

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
fvm install

# Use the project Flutter version
fvm use
```

## Daily Usage

### Running Flutter Commands

Always use `fvm flutter` instead of `flutter`:

```bash
# Instead of: flutter pub get
fvm flutter pub get

# Instead of: flutter run
fvm flutter run

# Instead of: flutter analyze
fvm flutter analyze

# Instead of: flutter test
fvm flutter test

# Instead of: flutter build apk
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

The GitHub Actions workflow automatically reads the Flutter version from `.fvmrc`:

```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version-file: pubspec.yaml  # or .fvmrc
    channel: 'stable'
```

This ensures CI uses the **exact same version** as local development.

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

1. **Update `.fvmrc`**:
   ```json
   {
     "flutter": "3.25.0"
   }
   ```

2. **Update `pubspec.yaml` environment**:
   ```yaml
   environment:
     sdk: ">=3.5.0 <4.0.0"  # Match Flutter 3.25.0 Dart SDK
   ```

3. **Update CI workflow** (if not using flutter-version-file):
   ```yaml
   env:
     FLUTTER_VERSION: '3.25.0'
   ```

4. **Notify team**:
   ```bash
   fvm install
   fvm use
   fvm flutter pub get
   ```

## Related Files

- `.fvmrc` - FVM configuration (version specification)
- `.fvm/` - FVM cache directory (gitignored)
- `pubspec.yaml` - Dart SDK constraints
- `.github/workflows/flutter_ci.yml` - CI Flutter version
