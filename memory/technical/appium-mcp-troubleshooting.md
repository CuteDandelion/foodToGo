# Appium MCP Troubleshooting Guide

**Date:** 2026-02-06  
**Issue:** Local Appium MCP not working in OpenCode  
**Status:** ✅ RESOLVED

---

## 🔍 Root Cause Analysis

### Issue 1: Module Resolution Error with `npx`
**Error:**
```
Error: Cannot find package 'uri-templates' imported from fastmcp
```

**Cause:** The `npx -y appium-mcp@latest` command has dependency resolution issues with the `uri-templates` package, which is a transitive dependency of `fastmcp`. This is a known issue when using npx with certain ESM (ES Module) packages.

**Solution:** Install `appium-mcp` locally and run it directly with Node.js instead of using npx.

### Issue 2: ADB Not in PATH
**Error:**
```
adb: command not found
```

**Cause:** The Android Debug Bridge (ADB) is installed at `C:/Users/justi/AppData/Local/Android/Sdk/platform-tools/` but it's not in the system PATH environment variable.

**Solution:** Add the platform-tools directory to the PATH in the MCP environment configuration.

### Issue 3: Missing App Builds
**Cause:** The `capabilities.json` referenced APK/IPA files in `./apps/` directory that don't exist. The Flutter app needs to be built first.

**Solution:** Updated capabilities to reference the standard Flutter build output paths and added instructions for building the app.

---

## 🛠️ Fixes Applied

### 1. Updated `opencode.json`

Changed from:
```json
{
  "mcp": {
    "appium-mcp": {
      "type": "local",
      "command": ["npx", "-y", "appium-mcp@latest"],
      "enabled": true,
      "timeout": 10000,
      "environment": {
        "ANDROID_HOME": "C:/Users/justi/AppData/Local/Android/Sdk",
        "CAPABILITIES_CONFIG": "./capabilities.json",
        "SCREENSHOTS_DIR": "./screenshots"
      }
    }
  }
}
```

To:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "appium-mcp": {
      "type": "local",
      "command": ["node", "./node_modules/appium-mcp/dist/index.js"],
      "enabled": true,
      "timeout": 60000,
      "environment": {
        "PATH": "C:/Users/justi/AppData/Local/Android/Sdk/platform-tools;C:/Windows/System32;C:/Windows",
        "ANDROID_HOME": "C:/Users/justi/AppData/Local/Android/Sdk",
        "CAPABILITIES_CONFIG": "./capabilities.json",
        "SCREENSHOTS_DIR": "./screenshots"
      }
    }
  }
}
```

**Key Changes:**
- ✅ Changed command from `npx` to direct `node` execution
- ✅ Increased timeout from 10s to 60s (Appium needs more time)
- ✅ Added PATH environment variable with ADB location
- ✅ Used forward slashes for cross-platform compatibility

### 2. Updated `capabilities.json`

Updated to use Flutter's default build output paths:
- Android: `./build/app/outputs/flutter-apk/app-debug.apk`
- iOS: `./build/ios/iphonesimulator/Runner.app`

Added additional capabilities for better automation:
- `noReset`: false (fresh app state for each test)
- `autoGrantPermissions`: true (automatically grant Android permissions)
- `autoAcceptAlerts`: true (automatically accept iOS alerts)

### 3. Installed appium-mcp Locally

```bash
npm install appium-mcp@latest --save
```

This avoids the npx module resolution issues.

---

## ✅ Verification Steps

### Step 1: Verify Local Installation
```bash
node node_modules/appium-mcp/dist/index.js --help
```

Expected output: Server starts and shows connection info

### Step 2: Verify ADB Connection
```bash
# With PATH set
export PATH="$PATH:/c/Users/justi/AppData/Local/Android/Sdk/platform-tools"
adb devices
```

Expected output:
```
List of devices attached
emulator-5554   device
```

### Step 3: Build Flutter App
```bash
# For Android
flutter build apk --debug

# For iOS (macOS only)
flutter build ios --simulator
```

### Step 4: Start Emulator (if no physical device)
```bash
# List available emulators
emulator -list-avds

# Start an emulator
emulator -avd <emulator_name>
```

---

## 📋 Prerequisites Checklist

Before using Appium MCP, ensure:

- [ ] **Android SDK installed** at `C:/Users/justi/AppData/Local/Android/Sdk`
- [ ] **Platform-tools installed** (contains adb.exe)
- [ ] **Node.js installed** (v18+ recommended, currently v24.11.1)
- [ ] **appium-mcp installed locally** (`npm install`)
- [ ] **Flutter app built** (`flutter build apk --debug`)
- [ ] **Android emulator running OR physical device connected**
- [ ] **Device visible in `adb devices`**

---

## 🚀 Usage

### Testing with Android Emulator

1. **Start the emulator:**
   ```bash
   emulator -avd Pixel_7_API_33
   ```

2. **Build the Flutter app:**
   ```bash
   flutter build apk --debug
   ```

3. **Use in OpenCode:**
   The Appium MCP tools should now be available. Common tools include:
   - `appium_start_session` - Start a new Appium session
   - `appium_find_element` - Find UI elements
   - `appium_click` - Click on elements
   - `appium_send_keys` - Send text input
   - `appium_take_screenshot` - Capture screenshots

---

## 🐛 Common Issues & Solutions

### Issue: "Cannot find module 'uri-templates'"
**Solution:** Don't use npx. Use the locally installed version as configured in opencode.json.

### Issue: "adb: command not found"
**Solution:** Ensure PATH is set in opencode.json environment variables with the full path to platform-tools.

### Issue: "App path does not exist"
**Solution:** Build the Flutter app first with `flutter build apk --debug`. The APK will be at `./build/app/outputs/flutter-apk/app-debug.apk`.

### Issue: "No device connected"
**Solution:** 
- Check `adb devices` shows a device
- Start an emulator: `emulator -avd <name>`
- Or connect a physical device with USB debugging enabled

### Issue: "Session timeout"
**Solution:** Increase the timeout in opencode.json (currently set to 60000ms = 60 seconds).

---

## 📚 References

- [Appium MCP GitHub](https://github.com/appium/appium-mcp)
- [Appium Documentation](http://appium.io/docs/en/2.0/)
- [Flutter Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [OpenCode MCP Configuration](https://opencode.ai/docs)

---

## 📝 Notes

- The current configuration assumes Windows paths. For macOS/Linux, adjust paths accordingly.
- Screenshots will be saved to `./screenshots/` directory (created automatically)
- Physical devices require the actual UDID from `adb devices` or Xcode devices list
- iOS testing requires macOS and Xcode

---

**Last Updated:** 2026-02-06  
**Author:** OpenCode Agent
