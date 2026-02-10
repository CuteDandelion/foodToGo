# Unified Login Page Design Specification

## Overview

This document outlines the design for a unified login page that combines student and canteen login into a single, elegant interface. The design is based on the reference screenshot with significant UX improvements.

---

## Design Reference Analysis

### Current Design (from Screenshot)
The reference shows:
- **Background**: Vibrant green (#00E676 or similar) with organic wave/blob shapes
- **Logo**: "FOOD BE GOOD" with distinctive styling - FOOD and GOOD in dark text, BE in a green rounded badge
- **Card**: White rounded card containing the login form
- **Form Elements**:
  - "Welcome!" heading in bold black
  - Underline-style input fields for Username and Password
  - Green rounded "Log in" button
  - "Forgot Password" link below

### Key Design Elements to Preserve
1. Vibrant green background with organic shapes
2. Distinctive logo styling
3. White card container
4. Clean, minimal form layout
5. Green primary action button

---

## Unified Login Design Improvements

### 1. Background Design
```
┌─────────────────────────────────┐
│  ╭──────╮                       │
│ ╱   🌊    ╲    Green background │
││   Wave    │    with organic    │
│ ╲   shape  ╱    blob patterns   │
│  ╰──────╯                       │
│        ╭──────────╮             │
│       ╱   White    ╲            │
│      │  Login Card  │           │
│       ╲              ╱          │
│        ╰──────────╯             │
│                         ╭────╮  │
│                        ╱ Blob ╲ │
└─────────────────────────────────┘
```

**Colors:**
- Primary Green: `#00E676` (or `#10B981` to match brand)
- Secondary Green: `#00C853`
- Background waves: Semi-transparent white overlays

### 2. Logo Section (Top of Card)
```
┌─────────────────────────┐
│                         │
│    ┌─────────────┐      │
│    │   FOOD      │      │
│    │    [BE]     │  ← Green badge
│    │   GOOD      │      │
│    └─────────────┘      │
│                         │
```

**Logo Specifications:**
- Container: White background, 2px green border, 16px border-radius
- FOOD/GOOD: Dark slate (#1E293B), 26px, font-weight 800, letter-spacing 3px
- BE Badge: Green gradient background (#10B981 to #059669), white text, rounded pill shape
- Shadow: Subtle green glow (0 4px 20px rgba(16,185,129,0.3))

### 3. Form Section

#### Header
```
┌─────────────────────────┐
│                         │
│      Welcome!           │  ← 28px, Bold
│                         │
│  Sign in to continue    │  ← 14px, Secondary color
│                         │
```

#### Input Fields (Unified Design)
```
┌─────────────────────────┐
│                         │
│  📧 Email               │  ← Label with icon
│  ┌─────────────────┐    │
│  │ user@email.com  │    │  ← Input field
│  └─────────────────┘    │
│                         │
│  🔒 Password            │
│  ┌─────────────────┐    │
│  │ ••••••••      👁 │    │  ← Show/hide toggle
│  └─────────────────┘    │
│                         │
```

**Input Field Design:**
- Background: White with subtle gray border (#E2E8F0)
- Border-radius: 12px
- Padding: 16px horizontal, 14px vertical
- Focus state: Green border (#10B981) with glow
- Icons: Leading icon (email/lock), trailing icon for password visibility

#### Remember Me & Forgot Password Row
```
┌─────────────────────────┐
│                         │
│  ☑ Remember me     │    │
│                    Forgot│
│                    Password?
│                         │
```

**Design:**
- Checkbox: Custom styled, green when checked
- "Remember me": 14px, secondary color
- "Forgot Password?": 14px, green color, right-aligned

#### Primary Action Button
```
┌─────────────────────────┐
│                         │
│  ┌─────────────────┐    │
│  │    Sign In      │    │  ← Full width, green
│  └─────────────────┘    │
│                         │
```

**Button Design:**
- Background: Green gradient (#10B981 to #059669)
- Border-radius: 14px (or 999px for pill shape)
- Height: 52px
- Text: White, 16px, font-weight 600
- Shadow: 0 4px 16px rgba(16,185,129,0.5)
- Hover: Slight lift effect

#### Role Selection (New - Unified Feature)
```
┌─────────────────────────┐
│                         │
│   ──── or continue as ───  ← Divider with text
│                         │
│  ┌──────┐  ┌──────┐     │
│  │ 👤   │  │ 🍽️   │     │
│  │Student│  │Canteen│    │
│  └──────┘  └──────┘     │
│                         │
```

**Role Toggle Design:**
- Two pill-shaped buttons side by side
- Selected: Green background, white text
- Unselected: White/gray background, dark text
- Icons: Person icon for Student, Restaurant icon for Canteen

#### Create Account Section
```
┌─────────────────────────┐
│                         │
│  Don't have an account? │
│  ┌─────────────────┐    │
│  │  Create Account │    │  ← Secondary button
│  └─────────────────┘    │
│                         │
└─────────────────────────┘
```

**Create Account Button:**
- Background: Transparent or white
- Border: 2px green
- Text: Green color
- Same dimensions as primary button

---

## Complete Layout Structure

```
┌─────────────────────────────────┐
│                                 │
│    [Green Background with       │
│     Organic Wave Shapes]        │
│                                 │
│         ┌─────────────┐         │
│         │    LOGO     │         │
│         │   FOOD      │         │
│         │    [BE]     │         │
│         │   GOOD      │         │
│         └─────────────┘         │
│                                 │
│    ┌─────────────────────┐      │
│    │                     │      │
│    │     Welcome!        │      │
│    │                     │      │
│    │  ┌───────────────┐  │      │
│    │  │ Email         │  │      │
│    │  └───────────────┘  │      │
│    │                     │      │
│    │  ┌───────────────┐  │      │
│    │  │ Password    👁 │  │      │
│    │  └───────────────┘  │      │
│    │                     │      │
│    │  ☑ Remember    │    │      │
│    │     me      Forgot│      │
│    │            Password│      │
│    │                     │      │
│    │  ┌───────────────┐  │      │
│    │  │   Sign In     │  │      │
│    │  └───────────────┘  │      │
│    │                     │      │
│    │  ─── or as ───      │      │
│    │                     │      │
│    │  [Student] [Canteen]│      │
│    │                     │      │
│    │  New here?          │      │
│    │  ┌───────────────┐  │      │
│    │  │Create Account │  │      │
│    │  └───────────────┘  │      │
│    │                     │      │
│    └─────────────────────┘      │
│                                 │
└─────────────────────────────────┘
```

---

## Color Palette

### Background
| Element | Color | Usage |
|---------|-------|-------|
| Primary Green | `#10B981` | Main background |
| Wave Overlay 1 | `rgba(255,255,255,0.1)` | Decorative wave |
| Wave Overlay 2 | `rgba(255,255,255,0.05)` | Secondary wave |

### Card
| Element | Color | Usage |
|---------|-------|-------|
| Card Background | `#FFFFFF` | Login card |
| Card Border | `rgba(255,255,255,0.2)` | Subtle border |
| Card Shadow | `rgba(0,0,0,0.1)` | Elevation |

### Text
| Element | Color | Usage |
|---------|-------|-------|
| Heading | `#1E293B` | Welcome text |
| Body | `#64748B` | Subtitle, labels |
| Primary | `#10B981` | Links, buttons |
| Error | `#EF4444` | Validation errors |

### Interactive Elements
| Element | Color | Usage |
|---------|-------|-------|
| Button Primary | `#10B981` | Sign In button |
| Button Secondary | `transparent` | Create Account |
| Input Border | `#E2E8F0` | Default state |
| Input Focus | `#10B981` | Active state |
| Checkbox Checked | `#10B981` | Remember me |

---

## Typography

| Element | Font | Size | Weight | Color |
|---------|------|------|--------|-------|
| Welcome | Inter | 28px | 700 | #1E293B |
| Subtitle | Inter | 14px | 400 | #64748B |
| Input Label | Inter | 14px | 500 | #64748B |
| Input Text | Inter | 16px | 400 | #1E293B |
| Button | Inter | 16px | 600 | #FFFFFF |
| Link | Inter | 14px | 600 | #10B981 |
| Role Label | Inter | 14px | 500 | varies |

---

## Spacing

| Element | Value |
|---------|-------|
| Card padding | 32px |
| Section gaps | 24px |
| Input gaps | 16px |
| Button height | 52px |
| Input height | 52px |
| Border radius (card) | 24px |
| Border radius (inputs) | 12px |
| Border radius (buttons) | 14px |

---

## Interactions & Animations

### Page Load
1. Background fades in (300ms)
2. Logo scales up with elastic bounce (500ms, delay 100ms)
3. Card slides up and fades in (400ms, delay 200ms)
4. Form elements stagger in (100ms between each)

### Input Focus
- Border color transitions to green (200ms)
- Subtle shadow appears (0 0 0 4px rgba(16,185,129,0.1))
- Label floats up if using floating labels

### Button Hover
- Scale up slightly (1.02)
- Shadow intensifies
- Duration: 200ms

### Button Press
- Scale down (0.98)
- Duration: 100ms

### Role Selection
- Selected role: Green background slides in (200ms)
- Icon and text color transition (200ms)

### Password Visibility Toggle
- Icon morphs (crossfade)
- Text shows/hides with slight delay

---

## Responsive Behavior

### Small Screens (320-375px)
- Card margin: 16px
- Reduced padding: 24px
- Full-width buttons
- Stacked role selection (vertical)

### Medium Screens (376-428px)
- Card margin: 24px
- Standard padding: 32px
- Side-by-side role selection

### Large Screens (429px+)
- Max-width: 400px
- Centered card
- Larger touch targets

---

## Accessibility

### Contrast Ratios
- Green on white: 3.2:1 (AA for large text)
- Dark text on white: 12.6:1 (AAA)
- White on green: 3.2:1 (AA for large text)

### Touch Targets
- Minimum: 44x44px
- Buttons: Full width, 52px height
- Checkboxes: 44x44px tap area

### Focus States
- Visible focus rings on all interactive elements
- 4px offset, green color
- Keyboard navigation support

### Screen Reader
- All inputs properly labeled
- Role selection announced
- Error messages associated with inputs

---

## New Features Added

### 1. Unified Login
- Single login page for both student and canteen
- Role selection toggle within the form
- Backend determines user type from credentials

### 2. Forgot Password
- "Forgot Password?" link below remember me
- Opens modal or navigates to reset page
- Email input for password reset

### 3. Remember Me
- Checkbox with custom styling
- Persists login session
- Secure token storage

### 4. Create Account
- Clear call-to-action for new users
- Separate registration flow
- Email/password registration

### 5. Improved UX
- Better visual hierarchy
- Clearer labels and placeholders
- Inline validation
- Loading states
- Error messaging

---

## Implementation Notes

### Flutter Considerations
1. Use `flutter_screenutil` for responsive sizing
2. Implement custom painter for background waves
3. Use `AnimatedContainer` for role toggle
4. Add form validation with proper error display
5. Implement secure storage for remember me

### State Management
- AuthBloc handles login logic
- Form state managed locally with TextEditingController
- Role selection updates UI but credentials determine actual role

### Security
- Password obscured by default
- Secure storage for tokens
- Input validation before submission
- Rate limiting on login attempts

---

*Design Version: 1.0*
*Date: February 9, 2026*
*Status: Ready for Review*
