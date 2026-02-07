# Appium MCP Troubleshooting Report

**Date:** 2026-02-06  
**Status:** ⚠️ ISSUES FOUND - Action Required  

## 🔍 Diagnostic Summary

I ran comprehensive diagnostics on your Appium MCP configuration and found several issues that need to be addressed:

---

## ✅ What's Working

1. **✅ Appium MCP Server** - Installed locally (v1.11.0) and starts successfully
2. **✅ ADB (Android Debug Bridge)** - Installed at correct location:
   - `C:/Users/justi/AppData/Local/Android/Sdk/platform-tools/adb.exe`
3. **✅ Configuration Files** - Both `opencode.json` and `capabilities.json` are correctly configured
4. **✅ Android SDK** - Present at `C:/Users/justi/AppData/Local/Android/Sdk`

---

## ❌ Issues Found

### Issue #1: Flutter App Not Built
**Severity:** HIGH  
**Status:** ❌ MISSING

**Problem:** The Flutter APK file referenced in `capabilities.json` does not exist:
- Expected: `./build/app/outputs/flutter-apk/app-debug.apk`
- Status: Directory does not exist

**Impact:** Appium cannot install and run tests on the app because there's no APK to test.

**Solution:**
```bash
# Build the Flutter debug APK
flutter build apk --debug

# Verify the APK was created
ls -la build/app/outputs/flutter-apk/app-debug.apk
```

---

### Issue #2: No Android Device/Emulator Connected
**Severity:** HIGH  
**Status:** ❌ NOT CONNECTED

**Problem:** No Android devices or emulators are currently connected.

**Verification:**
```bash
# With ADB in PATH
export PATH="/c/Users/justi/AppData/Local/Android/Sdk/platform-tools:$PATH"
adb devices
```

**Output:**
```
* daemon not running; starting now at tcp:5037
* daemon started successfully
List of devices attached
# (EMPTY - No devices listed)
```

**Solution - Option A: Start an Android Emulator**
```bash
# List available emulators
emulator -list-avds

# Start an emulator (replace with your AVD name)
emulator -avd Pixel_7_API_33

# Verify it's connected
adb devices
```

**Solution - Option B: Use Physical Device**
1. Enable Developer Options on your Android device
2. Enable USB Debugging
3. Connect device via USB
4. Accept the RSA fingerprint prompt on device
5. Verify connection: `adb devices`

---

### Issue #3: Flutter Not in PATH (Shell Environment)
**Severity:** MEDIUM  
**Status:** ⚠️ WARNING

**Problem:** The Flutter CLI is not accessible in the current shell environment. While this won't prevent OpenCode from using Appium MCP (which uses the compiled APK), it means you can't build the app from this terminal.

**Verification:**
```bash
which flutter
# Output: Flutter not in PATH
```

**Solution:**
Add Flutter to your system PATH or use the Flutter installation from its location:
```bash
# Typical Flutter location on Windows (adjust if different)
export PATH="$PATH:/c/src/flutter/bin"
# OR
export PATH="$PATH:/c/Users/justi/flutter/bin"

# Verify
flutter doctor
```

---

## 🧪 Test Results

### Test 1: Appium MCP Server Startup
```bash
node node_modules/appium-mcp/dist/index.js --help
```

**Result:** ✅ PASSED
- Server starts successfully
- All resources registered
- All tools registered
- Client connects successfully
- Warning: "could not infer client capabilities after 10 attempts" (non-critical)

### Test 2: ADB Accessibility
```bash
ls -la "C:/Users/justi/AppData/Local/Android/Sdk/platform-tools/adb.exe"
```

**Result:** ✅ PASSED
- ADB executable exists (7.7MB)
- All required DLLs present (AdbWinApi.dll, AdbWinUsbApi.dll)

### Test 3: ADB with PATH
```bash
export PATH="/c/Users/justi/AppData/Local/Android/Sdk/platform-tools:$PATH"
adb devices
```

**Result:** ⚠️ PARTIAL
- ADB daemon starts successfully
- No devices connected

### Test 4: Flutter Build Artifacts
```bash
ls -la build/app/outputs/flutter-apk/
```

**Result:** ❌ FAILED
- Build directory does not exist
- App needs to be built first

---

## 📋 Required Actions (In Order)

### Step 1: Build the Flutter App
```bash
# Navigate to project directory
cd C:\Users\justi\OneDrive\Desktop\FoodBeGood

# Get dependencies
flutter pub get

# Build debug APK
flutter build apk --debug
```

**Expected Result:**
```
✓ Built build/app/outputs/flutter-apk/app-debug.apk
```

### Step 2: Start Android Emulator or Connect Device

**Option A - Start Emulator:**
```bash
# Find your emulator name
emulator -list-avds

# Start it
emulator -avd <YOUR_EMULATOR_NAME>
```

**Option B - Connect Physical Device:**
1. Connect Android device via USB
2. Enable USB Debugging in Developer Options
3. Accept the debugging prompt on device

### Step 3: Verify Device Connection
```bash
# In a new terminal with ADB in PATH
export PATH="/c/Users/justi/AppData/Local/Android/Sdk/platform-tools:$PATH"
adb devices
```

**Expected Output:**
```
List of devices attached
emulator-5554   device
# OR
ABC123DEF456    device
```

### Step 4: Test Appium MCP

Once the above steps are complete, try using Appium MCP in OpenCode:

The following tools should now be available:
- `appium_start_session` - Start Appium test session
- `appium_find_element` - Find UI elements
- `appium_click` - Click on elements
- `appium_send_keys` - Send text input
- `appium_take_screenshot` - Capture screenshots

---

## 🔧 Configuration Review

Your current configuration looks correct:

**opencode.json:**
- ✅ Using local node_modules path (avoids npx issues)
- ✅ PATH includes platform-tools
- ✅ ANDROID_HOME set correctly
- ✅ Timeout increased to 60s
- ✅ Capabilities config path correct

**capabilities.json:**
- ✅ Android configuration complete
- ✅ iOS configuration complete (for macOS)
- ✅ Auto-grant permissions enabled
- ✅ APK paths reference Flutter build output

---

## 🚀 Quick Start Commands

Once you've completed the setup:

```bash
# 1. Build the app
flutter build apk --debug

# 2. Start emulator (in separate terminal)
emulator -avd <your_avd_name>

# 3. Verify everything
export PATH="/c/Users/justi/AppData/Local/Android/Sdk/platform-tools:$PATH"
adb devices  # Should show a device

# 4. Test in OpenCode
# Try: "Start an Appium session and take a screenshot"
```

---

## 📝 Additional Notes

1. **Platform Tools Version:** Your ADB is up to date (Feb 2025)
2. **Appium MCP Version:** v1.11.0 (latest stable)
3. **Screenshots:** Will be saved to `./screenshots/` directory
4. **iOS Testing:** Requires macOS and Xcode (not available on Windows)
5. **Physical Device:** If using physical device, update `capabilities.json` with your device's UDID from `adb devices`

---

## 🐛 If Issues Persist

If you encounter issues after following these steps:

1. **Check OpenCode logs:** Look for MCP connection errors
2. **Verify PATH in opencode.json:** Ensure forward slashes are used
3. **Test ADB independently:** Run `adb shell` to verify ADB works
4. **Check emulator logs:** Look for boot errors
5. **Verify APK:** Ensure the APK is not corrupted: `aapt dump badging build/app/outputs/flutter-apk/app-debug.apk`

---

**Next Steps:**
1. ✅ Run `flutter build apk --debug`
2. ✅ Start your Android emulator
3. ✅ Verify device shows in `adb devices`
4. ✅ Test Appium MCP in OpenCode

**Report Generated By:** OpenCode Troubleshooting Agent  
**Last Updated:** 2026-02-06
