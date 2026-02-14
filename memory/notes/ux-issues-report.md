# FoodBeGood UX/UI Issues Report

## Date: 2026-02-14

## Issues Found During Emulator Exploration

### 1. Login Screen Issues

#### Issue 1.1: Thin Green Line Artifact
- **Location**: Login page - top of the white login card
- **Observation**: A thin green horizontal line is visible cutting through the card
- **Cause**: Likely due to the ClipRRect or container overflow in the logo area
- **Severity**: Medium - Visual artifact that degrades the professional look

#### Issue 1.2: Logo Image Clipping
- **Location**: Login page - FOODBE logo
- **Observation**: The logo appears slightly clipped at the top in the screenshot
- **Cause**: The logo container height might be too small or image not properly fitted
- **Severity**: Medium - Logo is a key brand element

#### Issue 1.3: Duplicate "Sign in" Text
- **Location**: Login page - welcome header
- **Observation**: The login form has "Sign in to continue" as a subtitle, but the design could be clearer
- **Cause**: Text hierarchy needs improvement
- **Severity**: Low - Minor UX issue

### 2. General UX Observations

#### Issue 2.1: Missing Role Selection Screen
- **Location**: App flow
- **Observation**: The app goes directly to login, but the design reference shows a role selection screen first
- **Status**: Already addressed - unified login was implemented

#### Issue 2.2: "Menu Coming Soon" Placeholder
- **Location**: Dashboard - hamburger menu
- **Observation**: Tapping the menu icon shows "Menu is coming soon" snackbar
- **Severity**: Low - Expected for MVP

#### Issue 2.3: Notifications Show Generic Message
- **Location**: Dashboard - notification bell
- **Observation**: Shows "No new notifications" regardless of state
- **Severity**: Low - Placeholder behavior

### 3. Design Reference Comparison

The app implementation generally follows the index.html design reference well:
- Color scheme matches (emerald green primary)
- Card styling follows the design
- Dashboard metrics are properly displayed
- FAB with gradient is implemented

### 4. Recommended Fixes

1. **Fix Login Screen Green Line**: Remove or adjust the ClipRRect that might be causing the artifact
2. **Fix Logo Container**: Ensure proper sizing for the app_logo.png asset
3. **Improve Text Hierarchy**: Review the login welcome text for clarity

### 5. Screenshots Captured
- `screenshot.png` - Login screen showing the green line artifact
- `screen2.png` - Second login screen capture
