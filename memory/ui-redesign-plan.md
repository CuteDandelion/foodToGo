# UI Redesign & Code Quality Plan

Consolidated plan from design review session (2026-02-14).
Reference: `index.html` is the canonical design spec. Branch: `fix/code-quality-and-design-issues`.

---

## Phase 1: Global Code Quality (Low Risk, Mechanical)

These changes are safe, behavior-preserving, and should be done first across all files.

### 1A. Replace Hardcoded Colors with AppTheme Constants

| Raw Value | Replace With | Files Affected |
|---|---|---|
| `Color(0xFF10B981)` | `AppTheme.primary` | student_dashboard_page.dart (~4), canteen_dashboard_page.dart (~3), app_card.dart, app_button.dart, custom_icons.dart |
| `Color(0xFF059669)` | `AppTheme.primaryDark` | student_dashboard_page.dart (FAB), app_card.dart, app_button.dart |
| `Color(0xFFEF4444)` | `AppTheme.error` | settings_page.dart (x2), canteen_dashboard_page.dart (x2) |
| `Color(0xFFF59E0B)` | `AppTheme.warning` | student_dashboard_page.dart, canteen_dashboard_page.dart |
| `Color(0xFF3B82F6)` | `AppTheme.info` | canteen_dashboard_page.dart |
| `Color(0xFFEC4899)` | `AppTheme.social` | canteen_dashboard_page.dart |
| `Colors.green` | `AppTheme.primary` | confirmation_page.dart (x5), meal_history_page.dart (x4) |
| `Colors.orange` | `AppTheme.warning` | profile_page.dart |
| `Colors.red` | `AppTheme.error` | profile_page.dart, pickup_page.dart (x3) |
| `Colors.grey` | `AppTheme.textSecondary` or theme | student_dashboard_page.dart (_ComparisonBar) |

### 1B. Extract Pickup Background Constant

The following appears in 3 files — extract to `AppTheme`:
```dart
// In pickup_page.dart, time_slot_selection_page.dart, confirmation_page.dart:
isDark ? const Color(0xFF1B5E20) : const Color(0xFFE8F5E9)
```
**Decision needed:** The spec doesn't use a custom green background for pickup — it uses the standard app background. Consider dropping this entirely and using the same gradient background as the dashboard. If keeping it, add `AppTheme.pickupBackgroundLight` / `AppTheme.pickupBackgroundDark`.

### 1C. Standardize withAlpha() to withValues(alpha:)

32 instances across 3 files need updating:
- `qr_code_page.dart` — 4 instances
- `profile_page.dart` — 19 instances
- `meal_history_page.dart` — 8 instances (also 1 in shimmer_loading.dart)

Pattern: `withAlpha(26)` → `withValues(alpha: 0.1)`, `withAlpha(153)` → `withValues(alpha: 0.6)`, etc.

### 1D. Fix Deprecated API Usage

- `theme.cardColor` in pickup_page.dart, time_slot_selection_page.dart → `theme.colorScheme.surface`
- `Card(elevation: 8)` in confirmation_page.dart → use `AppCard` or `elevation: 0`

### 1E. Responsive Sizing Migration

Convert all raw pixel values to ScreenUtil units. Files ordered by severity:

| File | ~Raw Values | Priority |
|---|---|---|
| `pickup_page.dart` | 40+ | HIGH |
| `time_slot_selection_page.dart` | 30+ | HIGH |
| `confirmation_page.dart` | 25+ | HIGH |
| `qr_code_page.dart` | 20+ | HIGH |
| `profile_page.dart` | 15+ | MEDIUM |
| `swipeable_dashboard.dart` | 15+ | MEDIUM |
| `meal_history_page.dart` | 10+ | MEDIUM |
| `food_item_card.dart` | 10+ | HIGH (part of pickup) |

Rules: `fontSize` → `.sp`, `width`/`height` → `.w`/`.h`, `borderRadius` → `.r`, `padding`/`margin` → `.r` or `.w`/`.h`.

---

## Phase 2: Student Dashboard Visual Fixes

These changes make the dashboard match the spec's visual hierarchy. The data and layout are already correct — the cards just need proper styling.

### 2A. Money Saved Card — Branded Variant

**Current:** Plain white `AppCard` with flat content.
**Spec:** Special card with `background: linear-gradient(135deg, #ECFDF5, #D1FAE5)`, `border: 2px solid primary`. Dark mode: `linear-gradient(135deg, #064E3B, #065F46)`, `border-color: primaryLight`.

**Implementation:**
- Add `CardVariant.branded` to `AppCard` in `app_card.dart`
- Light: gradient `#ECFDF5 → #D1FAE5` + `2px solid AppTheme.primary` border
- Dark: gradient `#064E3B → #065F46` + `2px solid AppTheme.primaryLight` border
- Use in `student_dashboard_page.dart` for the Money Saved card

### 2B. Social Impact Card — Dark Variant

**Current:** Plain white `AppCard` with green text.
**Spec:** `background: linear-gradient(135deg, slate-800 (#1E293B), slate-900 (#0F172A))` with white text, stat values in `primaryLight` (#34D399).

**Implementation:**
- Add `CardVariant.dark` to `AppCard` in `app_card.dart`
- Background: `LinearGradient(AppTheme.darkSurface, AppTheme.darkBackground)`
- All text inside must be white/white-alpha
- Stat values use `AppTheme.primaryLight`
- Divider: `white.withValues(alpha: 0.1)`
- Use in `student_dashboard_page.dart` for the Social Impact card

### 2C. Metric Icon Gradient Backgrounds

**Current:** `primary.withValues(alpha: 0.1)` (flat wash).
**Spec:** `linear-gradient(135deg, #ECFDF5, #D1FAE5)` light / `linear-gradient(135deg, #064E3B, #065F46)` dark.

**Implementation:** Replace the flat `Container` decoration in all non-highlight metric icon containers (Money Saved icon, Next Pickup icon) with gradient. Consider creating a helper `AppTheme.iconBackgroundGradient(isDark)`.

### 2D. Metric Labels — Uppercase + Letter Spacing

**Spec:** `.metric-label { text-transform: uppercase; letter-spacing: 0.5px; }`

**Implementation:** Add to metric label `TextStyle` wherever "Meals Saved", "Avg/Month", "Day Streak", etc. appear:
```dart
style: TextStyle(
  fontSize: 12.sp,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.5,
  // And use .toUpperCase() on the string
)
```

### 2E. FAB Bounce Animation

**Current:** Pulsing shadow only.
**Spec:** `translateY` bounce: `0% → translateY(0)`, `50% → translateY(-5px)`, `100% → translateY(0)`.

**Implementation:** Add a `Transform.translate` driven by the existing `_controller` animation:
```dart
offset: Offset(0, -5 * sin(_controller.value * pi))
```

### 2F. Deduplicate PopUp Animation Wrappers

**Current:** `_PopUpCard`, `_PopUpMetricCard`, `_PopUpStatCard` share identical `TweenAnimationBuilder` logic.

**Implementation:** Extract a single `PopUpAnimation` widget:
```dart
class PopUpAnimation extends StatelessWidget {
  final int index;
  final Widget child;
  // Same TweenAnimationBuilder logic
}
```
Then `_PopUpMetricCard` and `_PopUpStatCard` only contain their card content, wrapped by `PopUpAnimation`.

---

## Phase 3: Canteen Dashboard Rebuild

The canteen dashboard is significantly under-designed vs. the spec. Needs near-rewrite.

### 3A. Add CanteenBloc

**Current:** `MockDataService()` called directly in `build()`. No loading/error states.

**Implementation:**
- Create `canteen_bloc.dart`, `canteen_event.dart`, `canteen_state.dart` in `features/canteen/presentation/bloc/`
- Events: `CanteenDashboardLoaded`, `CanteenDashboardRefreshed`, `CanteenRequestApproved(String id)`, `CanteenRequestRejected(String id)`
- States: `CanteenInitial`, `CanteenLoading`, `CanteenLoadSuccess(data)`, `CanteenError(message)`
- Wrap page in `BlocProvider<CanteenBloc>`

### 3B. Add Mission Card

**Spec has but Flutter doesn't:** Gradient hero card at top:
```
background: linear-gradient(135deg, primary, primaryDark)
"Our Mission" (uppercase, letter-spacing: 1px)
"Don't Waste Food" (20px, bold)
"Sustainability & Anti-Pollution" (13px, 0.9 opacity)
```
Use `AppCard(variant: CardVariant.highlight)` with centered text content.

### 3C. Replace Loose Stat Cards with Sustainability Section

**Current:** 4 separate `_StatCard` widgets floating loose.
**Spec:** Single bordered card titled "Sustainability Impact" containing a 2x2 grid of items on `bg-primary` background tiles.

**Implementation:**
```dart
AppCard(
  child: Column(
    children: [
      Row(icon, "Sustainability Impact" title),
      GridView.count(
        crossAxisCount: 2,
        children: [
          _SustainabilityItem(value: "428kg", label: "Food Saved"),
          _SustainabilityItem(value: "€3,142", label: "Cost Savings"),
          _SustainabilityItem(value: "287", label: "Students Helped"),
          _SustainabilityItem(value: "€4,235", label: "Student Savings"),
        ],
      ),
    ],
  ),
)
```
Each item: centered, on `colorScheme.surface` rounded tile, value in `primary` + `24sp/800w`, label in `secondary` + `12sp`.

### 3D. Rebuild Urgent Requests Section

**Current:** Single row with "X requests pending" and a "Review" button.
**Spec:** Rich card with red gradient background, header with count badge, and a list of individual request items (avatar, name, timestamp, approve/reject buttons).

**Implementation:**
- Card background: `linear-gradient(135deg, #FEF2F2, #FEE2E2)` + `2px solid error` border. Dark: `linear-gradient(135deg, #450A0A, #7F1D1D)`.
- Header row: warning icon + "Urgent Access Requests" + red circle count badge
- List of `_RequestItem` widgets, each with:
  - Colored circle avatar with initials
  - Name + "X minutes ago" timestamp
  - Approve (green circle, check icon) + Reject (red circle, X icon) buttons
- Mock data already has request objects — wire them through the new CanteenBloc

### 3E. Add Gradient Background + Entrance Animations

- Use `AppTheme.lightBackgroundGradient` / `darkBackgroundGradient` (same as student dashboard)
- Wrap cards in `PopUpAnimation` (from Phase 2F) for staggered entrance

### 3F. Add Loading/Error States

- Loading: Use `DashboardShimmer` or create a canteen-specific shimmer
- Error: Use existing `ErrorRetryWidget` from `error_widgets.dart`

---

## Phase 4: Pickup Flow Redesign

### 4A. Food Container Visualization (Major Feature)

**Current:** Plain white "Your Container" card with a `ListView`.
**Spec:** Animated SVG container with lid that opens, food items that drop in with bounce animation, and a fill progress bar.

**Implementation options:**
1. **Full spec match:** Custom `CustomPainter` or Rive/Lottie animation of a container with food drop physics. High effort, high visual impact.
2. **Simplified version:** A `Stack` with a container illustration (static image or simple CustomPaint), overlaid food emoji circles that animate in with `SlideTransition` + `ScaleTransition`, plus a `LinearProgressIndicator` fill bar. Medium effort, good visual impact.
3. **Skip for now:** Keep the list approach but restyle it. Low effort.

**Recommendation:** Option 2. Build a `FoodContainerWidget` that:
- Shows a stylized container shape (rounded rectangle with a "lid" line)
- Food items appear as emoji circles that animate in from above
- Fill bar at the bottom shows capacity (X/5)
- Tapping an item in the container removes it

### 4B. Food Category Grid (Replace Horizontal Scroll)

**Current:** `HorizontalCategoryTabs` (horizontal chip scroll) + horizontal `FoodItemCard` list.
**Spec:** 3-column grid of category tiles with gradient icon backgrounds.

**Implementation:**
- Replace `HorizontalCategoryTabs` with a `GridView.count(crossAxisCount: 3)` of category tiles
- Each tile: bordered card (`16px radius`), selected state uses gradient `primary → primaryDark` background
- Icon container: `48x48`, gradient `#ECFDF5 → #D1FAE5` (light) / `#064E3B → #065F46` (dark)
- When a category is selected, show its food items below as tappable cards

### 4C. Selected Items as Pill Tags

**Current:** `ListView` with `ListTile` + `Dismissible`.
**Spec:** `Wrap` of pill-shaped tags with emoji + name + red remove button.

**Implementation:**
```dart
Wrap(
  spacing: 8, runSpacing: 8,
  children: state.selectedItems.map((item) => _SelectedItemTag(
    emoji: item.category.icon,
    name: item.name,
    onRemove: () => bloc.add(PickupItemDeselected(item)),
  )).toList(),
)
```
Each tag: `borderRadius: 20`, `padding: 8/14`, border, emoji + name + small red circle X button.

### 4D. Drop Custom Green Background

Replace `Color(0xFFE8F5E9)` / `Color(0xFF1B5E20)` in all 3 pickup files with the standard app gradient background (`AppTheme.lightBackgroundGradient` / `darkBackgroundGradient`), matching the dashboard.

---

## Phase 5: QR Code Page Improvements

### 5A. Fix QR Code Seed (Bug)

**Current:** `DateTime.now().millisecond` produces different patterns on rebuild.
**Fix:** Use `widget.pickupId.hashCode` as the seed:
```dart
final random = widget.pickupId.hashCode;
// In paint(): (row + col + random) % 3 == 0
```
Pass `pickupId` into the painter constructor.

### 5B. Add Order Summary Card

**Spec has:** An `order-summary` card below the QR showing items + pickup time.
**Implementation:** Add a card after the instructions box:
```dart
AppCard(
  child: Column(
    children: [
      Row(icon, "Order Summary"),
      ...order.items.map((item) => _OrderItemRow(item)),
      Divider(),
      _PickupTimeRow(order.timeSlot),
    ],
  ),
)
```
This requires passing the order data to the QR page (currently it only receives `pickupId`).

### 5C. Timer Warning State

**Current:** Binary expired/not-expired.
**Spec:** Red pulsing text when time is low.

**Implementation:**
```dart
bool get _isWarning => _remaining.inSeconds > 0 && _remaining.inSeconds <= 60;
```
When `_isWarning`: timer text turns `colorScheme.error`, add an `AnimatedOpacity` pulse (opacity oscillating 0.5 → 1.0).

### 5D. Add Student Name Display

**Spec shows:** Student ID (monospace) + student name under the QR code.
**Implementation:** Pass user name to QR page, display between QR and pickup ID.

---

## Phase 6: Confirmation Page Fixes

### 6A. Replace Card with AppCard
Remove `Card(elevation: 8)` → use `AppCard` for consistent zero-elevation styling.

### 6B. Fix "View QR Code" Button
**Current bug:** Both buttons call `context.goStudentDashboard()`.
**Fix:** "View QR Code" should navigate to `context.goQRCode(pickupId: order.id)` with the order data.

### 6C. Replace Colors.green with AppTheme
5 instances of `Colors.green` → `AppTheme.primary` (for the success circle, confirmed badge, etc.).

---

## Phase 7: Polish & Cleanup

### 7A. Add Inter Font Family
Add `google_fonts` package or bundle Inter as an asset. Set in `theme.dart`:
```dart
textTheme: GoogleFonts.interTextTheme(base)
```

### 7B. Wire meal_history_page.dart into ProfileBloc
**Current:** Uses `setState()` + direct `MockDataService` call.
**Fix:** Add meal history events/states to `ProfileBloc`, fetch data via bloc.

### 7C. Remove Dead Code
- `login_page.dart` — verify unused, delete
- `role_selection_page.dart` — verify unused, delete
- Resolve or remove 3 `TODO` comments in dashboard

### 7D. Hardcoded Strings
- `settings_page.dart`: "Zain Ul Ebad" and "Student at MRU" should come from auth state/bloc
- `student_dashboard_page.dart`: `DashboardHeader(userName: 'Zain')` should come from auth state

---

## Implementation Order (Recommended)

```
Session 1: Phase 1 (code quality — mechanical, safe)
Session 2: Phase 2 (student dashboard visuals)
Session 3: Phase 3 (canteen dashboard rebuild)
Session 4: Phase 4 (pickup flow redesign)
Session 5: Phase 5 + 6 (QR + confirmation fixes)
Session 6: Phase 7 (polish & cleanup)
```

Each phase should end with:
```bash
flutter analyze  # zero warnings
dart format --output=none --set-exit-if-changed lib/ test/
flutter test test/features test/core
```

---

## Open Design Decisions (Need Your Input)

1. **Pickup background:** Drop the green and match dashboard, or keep it as a distinct "pickup mode" feel?
2. **Food container animation:** Full animated container (high effort) vs. simplified version vs. skip?
3. **Time slot page:** Keep as separate page, or convert to bottom sheet on pickup page?
4. **Inter font:** Bundle via google_fonts (network dependency) or as local asset?
5. **Login page:** Keep the neon green brand treatment (differs from spec) or align with spec's neutral forms?
