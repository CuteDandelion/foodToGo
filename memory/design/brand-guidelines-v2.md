# FoodBeGood Brand Guidelines - Professional Edition

## Brand Overview

**FoodBeGood** is a professional mobile application that makes food waste reduction measurable and sustainable for university canteens while helping students save money on meals. The brand balances sustainability messaging with a modern, professional aesthetic that appeals to both students and university administrators.

**Brand Keywords:** Professional, Sustainable, Measurable, Social Impact, Modern, Clean, Data-Driven, Community-Focused

**Core Mission:** Making food waste measurable and sustainable for canteens while enabling students (especially those with limited budgets) to access affordable, nutritious meals.

---

## Primary Brand Colors

### Core Colors (Professional Palette)

The redesigned app uses a refined green color palette that maintains the sustainability theme while appearing more professional and sophisticated.

```css
/* Primary Brand Colors */
--color-primary: #10B981          /* Emerald 500 - Primary Green */
--color-primary-light: #34D399    /* Emerald 400 - Light Green */
--color-primary-dark: #059669     /* Emerald 600 - Dark Green */
--color-primary-accent: #6EE7B7   /* Emerald 300 - Accent Green */

/* Semantic Colors */
--color-success: #10B981          /* Same as primary */
--color-warning: #F59E0B          /* Amber 500 */
--color-error: #EF4444            /* Red 500 */
--color-info: #3B82F6             /* Blue 500 */

/* Neutral Colors (Slate Palette) */
--color-slate-50: #F8FAFC         /* Background primary */
--color-slate-100: #F1F5F9        /* Background secondary */
--color-slate-200: #E2E8F0        /* Borders light */
--color-slate-300: #CBD5E1        /* Disabled states */
--color-slate-400: #94A3B8        /* Muted text */
--color-slate-500: #64748B        /* Secondary text */
--color-slate-600: #475569        /* Tertiary text */
--color-slate-700: #334155        /* Headings */
--color-slate-800: #1E293B        /* Primary text */
--color-slate-900: #0F172A        /* Dark backgrounds */
```

**Primary Green (#10B981):**
- Primary buttons
- Logo BE badge
- Success states
- Progress indicators
- Charts and data visualizations
- Environmental impact metrics

**Neutral Slate:**
- Text and headings
- Card backgrounds
- Borders
- Disabled states

---

## Dark Mode Colors

```css
/* Dark Mode Variables */
--bg-primary: #0F172A             /* Slate 900 */
--bg-secondary: #1E293B           /* Slate 800 */
--bg-card: #1E293B                /* Card background */
--text-primary: #F8FAFC           /* Slate 50 */
--text-secondary: #94A3B8         /* Slate 400 */
--text-muted: #64748B             /* Slate 500 */
--border-color: #334155           /* Slate 700 */
```

**Dark Mode Implementation:**
- Toggle in Settings screen
- CSS custom properties for theme switching
- Smooth transitions between themes
- All components support both modes

---

## Logo Specifications

### Logo Structure (Approved Design - From logo.html)

```
┌─────────────────────────┐
│ ╭───────            │
│       FOOD              │  ← Dark grey text, bold, tight line height
│         BE              │  ← Green badge, black text, centered
│       GOOD              │  ← Dark grey text, bold, touching FOOD
│             ───────╯    │
└─────────────────────────┘
     Thick border (3px solid dark grey)
     Very rounded corners (40px radius)
     Longer/wider proportions
```

### Logo Dimensions (Exact from logo.html)

- **Container**: Wide rounded rectangle
- **Border**: 3px solid #242a24 (dark grey)
- **Border Radius**: 40px (very rounded, pill-like)
- **Padding**: 30px vertical, 45px horizontal (scaled for mobile: 20px 30px)
- **Background**: Pure white (#ffffff)
- **Shadow**: 0 10px 0px rgba(0, 0, 0, 0.05)

### Logo Colors (Exact from logo.html)

```css
:root {
    --bg-green: #29f094;        /* Bright green for BE badge */
    --dark-grey: #242a24;       /* Dark grey for borders and text */
    --white: #ffffff;           /* White background */
}

.logo-card {
    background-color: #ffffff;
    padding: 30px 45px;         /* Use 20px 30px for mobile */
    border-radius: 40px;
    border: 3px solid #242a24;
    box-shadow: 0 10px 0px rgba(0, 0, 0, 0.05);
}

.text-row {
    color: #242a24;
    font-size: 52px;            /* Use 36px for mobile */
    line-height: 0.85;          /* Tight spacing so FOOD/GOOD touch */
    letter-spacing: -2px;
    font-weight: 900;
    text-transform: uppercase;
}

.be-badge {
    background-color: #29f094;  /* Bright green */
    color: #242a24;             /* Dark grey text (NOT white) */
    font-size: 16px;            /* Use 14px for mobile */
    padding: 2px 8px;
    border-radius: 4px;
    font-weight: bold;
}
```

### Inner Decorative Brackets (L-Shapes)

Two corner brackets that create an incomplete inner border:

```css
.bracket {
    position: absolute;
    width: 50px;                /* Use 35px for mobile */
    height: 50px;               /* Use 35px for mobile */
    border: 4px solid #242a24;
}

/* Top-left corner bracket */
.bracket.top-left {
    top: 16px;                  /* Use 12px for mobile */
    left: 16px;                 /* Use 12px for mobile */
    border-right: none;
    border-bottom: none;
    border-top-left-radius: 16px;    /* Use 12px for mobile */
}

/* Bottom-right corner bracket */
.bracket.bottom-right {
    bottom: 16px;               /* Use 12px for mobile */
    right: 16px;                /* Use 12px for mobile */
    border-left: none;
    border-top: none;
    border-bottom-right-radius: 16px; /* Use 12px for mobile */
}
```

### Logo HTML Structure (Reference)

```html
<div class="logo-card">
    <div class="bracket top-left"></div>
    
    <h1 class="text-row">FOOD</h1>
    <div class="be-badge">BE</div>
    <h1 class="text-row">GOOD</h1>
    
    <div class="bracket bottom-right"></div>
</div>
```

### Logo Usage Guidelines

**DO:**
- Use the exact colors: #29f094 (green), #242a24 (dark grey), #ffffff (white)
- Maintain the tight line-height (0.85) so FOOD and GOOD appear touching
- Keep the BE badge with dark text on green background
- Use the decorative corner brackets in opposite corners
- Maintain the wide, rounded proportions

**DON'T:**
- Change the BE badge text to white
- Remove the corner brackets
- Make the corners less rounded
- Change the proportions to be more square
- Use different colors for the badge or text

### Source File

**Reference Implementation:** `C:\Users\justi\OneDrive\Desktop\FoodBeGood\logo.html`
**Approved:** 2026-02-10
**Approved By:** User

---

## Typography

### Font Family

**Primary Font:** Inter (Google Fonts)
- Weights: 300 (Light), 400 (Regular), 500 (Medium), 600 (Semi-bold), 700 (Bold), 800 (Extra-bold)

```html
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
```

```css
* {
    font-family: 'Inter', sans-serif;
}
```

### Typography Scale

| Style | Size | Weight | Line Height | Usage |
|-------|------|--------|-------------|-------|
| Display | 36px | 800 | 1.1 | Large stats |
| H1 | 24px | 700 | 1.2 | Screen titles |
| H2 | 20px | 600 | 1.3 | Section headers |
| H3 | 18px | 600 | 1.4 | Card titles |
| Body Large | 16px | 400 | 1.5 | Primary content |
| Body | 14px | 400 | 1.5 | Paragraphs |
| Body Small | 13px | 400 | 1.5 | Descriptions |
| Caption | 12px | 500 | 1.4 | Labels, timestamps |
| Overline | 11px | 600 | 1 | Tags, badges |

---

## UI Components

### Buttons

**Primary Button (Gradient)**
```css
.btn-primary {
    background: linear-gradient(135deg, #10B981 0%, #059669 100%);
    color: white;
    border: none;
    border-radius: 14px;
    padding: 16px 32px;
    font-weight: 600;
    font-size: 16px;
    box-shadow: 0 4px 16px -4px rgba(16, 185, 129, 0.5);
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 24px -4px rgba(16, 185, 129, 0.6);
}
```

**Secondary Button**
```css
.btn-secondary {
    background: var(--bg-secondary);
    color: var(--text-primary);
    border: 2px solid var(--border-color);
    border-radius: 14px;
    padding: 16px 32px;
    font-weight: 600;
    font-size: 16px;
    transition: all 0.3s ease;
}

.btn-secondary:hover {
    border-color: #10B981;
    color: #10B981;
}
```

### Cards

**Standard Card**
```css
.card {
    background: var(--bg-card);
    border-radius: 20px;
    padding: 24px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.06);
    border: 1px solid var(--border-color);
    transition: all 0.3s ease;
}

.card:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1);
}
```

**Highlight Card (Gradient)**
```css
.metric-card.highlight {
    background: linear-gradient(135deg, #10B981 0%, #059669 100%);
    color: white;
    border: none;
}
```

**Dark Card (For Profile/ID)**
```css
.card-dark {
    background: linear-gradient(135deg, #1E293B 0%, #0F172A 100%);
    border-radius: 20px;
    padding: 24px;
    color: white;
    position: relative;
    overflow: hidden;
}
```

### Input Fields

**Text Input (Modern)**
```css
.input-field {
    background: var(--bg-secondary);
    border: 2px solid var(--border-color);
    border-radius: 12px;
    padding: 16px;
    font-size: 16px;
    width: 100%;
    outline: none;
    color: var(--text-primary);
    transition: all 0.3s ease;
}

.input-field:focus {
    border-color: #10B981;
    box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.1);
}
```

### Icon Buttons

**Meal Selection Button**
```css
.icon-btn {
    background: var(--bg-card);
    border: 2px solid var(--border-color);
    border-radius: 16px;
    aspect-ratio: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    padding: 16px;
}

.icon-btn:hover {
    border-color: #10B981;
    transform: translateY(-2px);
}

.icon-btn.selected {
    background: linear-gradient(135deg, #10B981 0%, #059669 100%);
    border-color: #10B981;
    color: white;
    box-shadow: 0 8px 24px -4px rgba(16, 185, 129, 0.4);
}
```

### Dark Mode Toggle

```css
.dark-mode-toggle {
    width: 52px;
    height: 28px;
    background: #CBD5E1;
    border-radius: 14px;
    position: relative;
    cursor: pointer;
    transition: background 0.3s ease;
}

.dark-mode-toggle.active {
    background: #10B981;
}

.dark-mode-toggle::after {
    content: '';
    position: absolute;
    width: 24px;
    height: 24px;
    background: white;
    border-radius: 50%;
    top: 2px;
    left: 2px;
    transition: transform 0.3s ease;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
}

.dark-mode-toggle.active::after {
    transform: translateX(24px);
}
```

---

## Layout Guidelines

### Screen Structure

1. **Top Navigation Bar** (60px height)
   - Hamburger menu
   - Page title or logo
   - Settings and notifications

2. **Main Content Area**
   - Padding: 20px horizontal
   - Cards with 16px gap
   - Scrollable content

3. **No Bottom Navigation**
   - Navigation is at the TOP only
   - Consistent with modern app patterns

### Spacing System (4px base)

| Token | Value | Usage |
|-------|-------|-------|
| space-1 | 4px | Icon gaps |
| space-2 | 8px | Small gaps |
| space-3 | 12px | Compact spacing |
| space-4 | 16px | Standard spacing |
| space-5 | 20px | Component padding |
| space-6 | 24px | Card padding |
| space-8 | 32px | Section gaps |
| space-10 | 40px | Large sections |

---

## Navigation Icons

### Top Nav Icons

Using Font Awesome 6.5.1:

1. **Hamburger Menu**: `fas fa-bars`
2. **Settings**: `fas fa-cog`
3. **Notifications**: `fas fa-bell`
4. **Back Arrow**: `fas fa-arrow-left`

### Category Icons

- **Salad Bar**: `fas fa-seedling`
- **Dessert**: `fas fa-ice-cream`
- **Side Dish**: `fas fa-drumstick-bite`
- **Main Dish**: `fas fa-utensils`

### Metric Icons

- **Meals Saved**: `fas fa-leaf`
- **Money**: `fas fa-euro-sign` / `fas fa-dollar-sign`
- **CO2**: `fas fa-cloud`
- **Streak**: `fas fa-fire`
- **Calendar**: `fas fa-calendar-alt`
- **Clock**: `fas fa-clock`
- **Users**: `fas fa-users`
- **Heart**: `fas fa-heart`

---

## Metrics and Data Visualization

### Student Metrics Display

**Primary Metrics:**
- Total Meals Saved (with progress bar to monthly goal)
- Money Saved (€) with trend indicator
- CO2 Prevented (kg) with trend indicator
- Monthly Average
- Current Streak

**Display Format:**
```
┌─────────────────────────┐
│  €85.67                 │  ← Large value (36px, bold)
│  Money Saved            │  ← Label (13px, uppercase)
│  ↑ +12% vs last month   │  ← Trend with arrow
└─────────────────────────┘
```

### Canteen Metrics Display

**Sustainability KPIs:**
- Total Meals Saved (all students)
- Food Waste Prevented (kg)
- Cost Savings (€)
- Students Helped
- Student Savings Total (€)

**Progress Indicators:**
- Horizontal progress bars
- Color-coded by category (Green, Blue, Pink)
- Percentage labels

---

## QR Code Specifications

**Location:** Student Profile Screen

**Design:**
- White background container
- Border radius: 16px
- Padding: 20px
- Shadow: subtle drop shadow
- Scannable pattern in dark slate

**Size:** 112x112px (28mm physical)

**Content:** Encoded student ID

---

## Accessibility

### Contrast Ratios

| Combination | Ratio | WCAG Level |
|-------------|-------|------------|
| Green (#10B981) on White | 3.2:1 | AA (Large text) |
| Slate-800 (#1E293B) on White | 12.6:1 | AAA |
| White on Green (#10B981) | 3.2:1 | AA (Large text) |
| White on Slate-900 (#0F172A) | 17.5:1 | AAA |

### Touch Targets

- Minimum: 44×44px
- Icon buttons: 64×64px
- Navigation icons: 44×44px
- Buttons: Full width with 16px padding

### Focus States

- Visible focus rings on all interactive elements
- 4px offset, primary green color
- Keyboard navigation support

---

## Animations and Interactions

### Page Transitions

```css
.screen {
    transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.screen.hidden {
    transform: translateX(100%);
    opacity: 0;
}
```

### Button Interactions

```css
/* Hover */
transform: translateY(-2px);
box-shadow: 0 8px 24px -4px rgba(16, 185, 129, 0.5);

/* Active */
transform: scale(0.98);
```

### Card Hover

```css
transform: translateY(-2px);
box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1);
```

---

## Design Tokens (JSON)

```json
{
  "colors": {
    "brand": {
      "50": "#ECFDF5",
      "100": "#D1FAE5",
      "400": "#34D399",
      "500": "#10B981",
      "600": "#059669",
      "gradient": "linear-gradient(135deg, #10B981 0%, #059669 100%)"
    },
    "slate": {
      "50": "#F8FAFC",
      "100": "#F1F5F9",
      "200": "#E2E8F0",
      "400": "#94A3B8",
      "500": "#64748B",
      "700": "#334155",
      "800": "#1E293B",
      "900": "#0F172A"
    },
    "semantic": {
      "success": "#10B981",
      "warning": "#F59E0B",
      "error": "#EF4444",
      "info": "#3B82F6"
    }
  },
  "spacing": {
    "1": "4px",
    "2": "8px",
    "3": "12px",
    "4": "16px",
    "5": "20px",
    "6": "24px",
    "8": "32px",
    "10": "40px"
  },
  "borderRadius": {
    "sm": "8px",
    "DEFAULT": "12px",
    "lg": "16px",
    "xl": "20px",
    "full": "9999px"
  },
  "shadows": {
    "sm": "0 1px 2px 0 rgba(0,0,0,0.05)",
    "DEFAULT": "0 1px 3px 0 rgba(0,0,0,0.1)",
    "md": "0 4px 6px -1px rgba(0,0,0,0.1)",
    "lg": "0 10px 15px -3px rgba(0,0,0,0.1)",
    "brand": "0 4px 16px -4px rgba(16,185,129,0.5)"
  },
  "typography": {
    "fontFamily": ["Inter", "system-ui", "sans-serif"],
    "sizes": {
      "display": "36px",
      "h1": "24px",
      "h2": "20px",
      "h3": "18px",
      "bodyLarge": "16px",
      "body": "14px",
      "bodySmall": "13px",
      "caption": "12px",
      "overline": "11px"
    }
  }
}
```

---

## Implementation Notes

### CSS Framework

Use **Tailwind CSS** with custom configuration:

```javascript
// tailwind.config.js
module.exports = {
    theme: {
        extend: {
            colors: {
                brand: {
                    50: '#ECFDF5',
                    100: '#D1FAE5',
                    400: '#34D399',
                    500: '#10B981',
                    600: '#059669',
                },
            },
            fontFamily: {
                'inter': ['Inter', 'sans-serif'],
            },
            boxShadow: {
                'brand': '0 4px 16px -4px rgba(16, 185, 129, 0.5)',
            }
        }
    }
}
```

### Dark Mode Implementation

```javascript
// Toggle dark mode
function toggleDarkMode() {
    const html = document.documentElement;
    const isDark = html.getAttribute('data-theme') === 'dark';
    html.setAttribute('data-theme', isDark ? 'light' : 'dark');
    localStorage.setItem('theme', isDark ? 'light' : 'dark');
}

// Initialize theme
const savedTheme = localStorage.getItem('theme') || 'light';
document.documentElement.setAttribute('data-theme', savedTheme);
```

### Icon Strategy

Use **Font Awesome 6.5.1** for all icons:

```html
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
```

---

## File References

- **Interactive Mockup V2**: `/memory/diagrams/interactive-mockup-v2.html`
- **Original Brand Guidelines**: `/memory/design/brand-guidelines.md`
- **Logo Reference Implementation**: `/logo.html`
- **Unified Login Design**: `/memory/design/unified-login-mockup-v2.html`
- **Unified Login Specification**: `/memory/design/unified-login-design.md`

---

*Updated: 2026-02-10*
*Version: 4.0 (Approved Logo Design from logo.html)*
