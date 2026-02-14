# FoodBeGood App Design Documentation - Professional Edition

## 1. Design System Overview

### 1.1 Design Philosophy
- **Professional:** Polished, modern interface suitable for university deployment
- **Measurable:** Data visualization and metrics are prominently featured
- **Impact-Focused:** Highlight social and environmental impact
- **Clean:** Minimal visual clutter with thoughtful whitespace
- **Accessible:** High contrast, readable typography, WCAG compliant
- **Sustainable:** Green brand color reinforces environmental mission

### 1.2 Core Features

**Student Features:**
- Track meals saved with detailed metrics
- Monitor money saved (helping budget-conscious students)
- View environmental impact (CO2 prevented, food saved)
- QR code for canteen verification
- Meal selection and history
- Achievement tracking

**Canteen Features:**
- Dashboard with sustainability KPIs
- Waste reduction tracking
- Student impact metrics
- Urgent access request management
- Food status updates
- Social impact reporting

---

## 2. Screen Specifications

### 2.1 Unified Login Screen (REPLACES Role Selection + Separate Logins)

**Note:** The Role Selection screen has been removed. Users now authenticate through a unified login page that handles both Student and Canteen roles automatically based on their credentials.

**Layout:**
```
┌─────────────────────────┐
│                         │
│      [LOGO]             │  ← FOOD + BE + GOOD with corner brackets
│                         │
│  ┌───────────────────┐  │
│  │ Student / Canteen │  │  ← Role toggle buttons
│  │                   │  │
│  │ Email             │  │
│  │ ┌───────────────┐ │  │
│  │ │ student@...   │ │  │
│  │ └───────────────┘ │  │
│  │                   │  │
│  │ Password          │  │
│  │ ┌───────────────┐ │  │
│  │ │ ••••••••      │ │  │
│  │ └───────────────┘ │  │
│  │                   │  │
│  │ ☑ Remember me     │  │
│  │ [Forgot Password] │  │
│  │                   │  │
│  │ ┌───────────────┐ │  │
│  │ │  Sign In      │ │  │
│  │ └───────────────┘ │  │
│  │                   │  │
│  │ Don't have...     │  │
│  └───────────────────┘  │
└─────────────────────────┘
```

**Features:**
- Single login form for all users
- Email-based authentication (not Student ID)
- Role is determined automatically from user credentials
- Clean input fields with focus states
- Remember me checkbox
- Forgot password link (placeholder)
- Create account option (placeholder)
- Animated bubble background with gyroscope sensitivity
- Logo popup animation on page load
- Haptic feedback throughout

**Test Credentials:**
- Student: student@example.com / password123
- Canteen: canteen@example.com / canteen123

**Background:**
- Light green gradient (#00E676 → #00C853 → #00B248)
- 12 animated bubbles with parallax effect

---

### 2.3 Student Home/Dashboard Screen

**Layout:**
```
┌─────────────────────────┐
│ ☰     [LOGO]     ⚙️ 🔔 │
├─────────────────────────┤
│  Good morning,          │
│  Zain! 👋               │
│                         │
│  ┌───────────────────┐  │
│  │ 🌱 Total Meals    │  │
│  │                   │  │
│  │ 34                │  │
│  │ Meals Saved       │  │
│  │ [Progress: 68%]   │  │
│  └───────────────────┘  │
│                         │
│  ┌─────────────────────┐│
│  │ 💶 Money Saved      ││
│  │ vs Last Month       ││
│  │                     ││
│  │ This Month: €82.50  ││
│  │ [████████░░] 85%    ││
│  │ Last Month: €70.00  ││
│  │ [██████░░░░] 70%    ││
│  │                     ││
│  │ ↑ +18% (€12.50)    ││
│  │                     ││
│  │ Breakdown:          ││
│  │ €45 | €22.50 | €15 ││
│  │ Meals Drinks Snacks ││
│  └─────────────────────┘│
│                         │
│  ┌────────┐ ┌────────┐  │
│  │ 12.3   │ │   5    │  │
│  │ Avg/Mo │ │ Streak │  │
│  └────────┘ └────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ ⏰ Next Pickup    │  │
│  │ Mensa Viadrina    │  │
│  │           2h 45m  │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ 💚 Social Impact  │  │
│  │ 156 students      │  │
│  │ helped save money │  │
│  └───────────────────┘  │
│                         │
│  [+ Pick Up My Meal]    │
└─────────────────────────┘
```

**Metrics Displayed:**

1. **Total Meals Saved**
   - Large number: 34
   - Progress bar to monthly goal (68%)
   - Green gradient card

2. **Money Saved vs Last Month**
   - This Month: €82.50 (85% progress bar)
   - Last Month: €70.00 (70% progress bar)
   - Trend: ↑ +18% (€12.50 more)
   - Green comparison card with gradient background
   - **Savings Breakdown:**
     - Meals: €45.00
     - Drinks: €22.50
     - Snacks: €15.00
   - Motivational message: "You're on track to save €1,000+ this year!"

3. **Monthly Average**
   - Value: 12.3 meals/month
   - Context: Top 15% of students
   - Amber indicator

4. **Day Streak**
   - Value: 5 days
   - Motivation: "Keep it going!"
   - Pink indicator

5. **Next Pickup**
   - Location: Mensa Viadrina
   - Countdown: 2h 45m
   - Visual clock icon

6. **Social Impact**
   - Students helped: 156
   - Money saved per student: €12.50
   - Dark gradient card

**Interactions:**
- Tap metrics for detailed view
- Track My Meal button navigates to selection
- Pull down to refresh

---

### 2.4 Canteen Dashboard Screen

**Layout:**
```
┌─────────────────────────┐
│ ☰     [LOGO]     ⚙️ 🔔 │
├─────────────────────────┤
│  Mensa Viadrina         │
│  Dashboard              │
│                         │
│  ┌───────────────────┐  │
│  │ 📊 Total Meals    │  │
│  │ 1,247             │  │
│  │ Daily: 89 ↑ +23%  │  │
│  │ Weekly: 342       │  │
│  └───────────────────┘  │
│                         │
│  ┌────────┐ ┌────────┐  │
│  │ 428kg  │ │ €3,142 │  │
│  │ Waste  │ │ Savings│  │
│  │ ↓ -15% │ │        │  │
│  └────────┘ └────────┘  │
│                         │
│  ┌────────┐ ┌────────┐  │
│  │  287   │ │ €4,235 │  │
│  │Students│ │Student │  │
│  │ Helped │ │Savings │  │
│  └────────┘ └────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ ⚠️ Urgent Access  │  │
│  │ 3 requests        │  │
│  │ [Review Button]   │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ ℹ️ Current Status │  │
│  │ Everything normal │  │
│  └───────────────────┘  │
│                         │
│  [Update Food Status]   │
└─────────────────────────┘
```

**Canteen Metrics:**

1. **Total Meals Saved**
   - Value: 1,247 meals
   - Daily average: 89
   - Week total: 342
   - Month trend: ↑ +23%

2. **Food Waste Prevented**
   - Value: 428kg
   - Trend: ↓ -15% (improvement)
   - Amber indicator

3. **Canteen Cost Savings**
   - Value: €3,142
   - Operational savings
   - Blue indicator

4. **Students Helped**
   - Value: 287 students
   - Trend: ↑ +8% this week
   - Green indicator

5. **Student Savings Total**
   - Value: €4,235
   - Total money saved by students
   - Pink indicator

6. **Urgent Access Requests**
   - Count: 3 students
   - Review button
   - Red border accent

7. **Current Status**
   - "Everything is running smoothly"
   - Last updated timestamp
   - Green status indicator

---

### 2.5 Pickup Flow - Food Selection (REVISED)

**Layout:**
```
┌─────────────────────────┐
│ ←       Select Meal     │
├─────────────────────────┤
│  Choose your items      │
│                         │
│  [Food] [Beverages]    │  ← Horizontal category tabs
│  [Desserts]             │
│                         │
│  ┌──┐ ┌──┐ ┌──┐        │
│  │🍖│ │🍖│ │🍖│        │  ← Horizontal scrolling
│  │ ✓ │ │   │ │   │        │     within category
│  └──┘ └──┘ └──┘        │
│  Schnitzel Bratwurst  │
│  €4.50  €3.80          │
│                        │
│  ┌──┐ ┌──┐ ┌──┐        │
│  │🍰│ │🍰│ │🍰│        │
│  │   │ │ ✓ │ │   │        │
│  └──┘ └──┘ └──┘        │
│  Strudel  Kuchen  ...  │
│                        │
│  ┌─────────────────────┐
│  │ Your Selection (3/5)│
│  │ [Schnitzel ×1  ✕]  │
│  │ [Kuchen ×1     ✕]  │
│  │ [Cola ×1       ✕]  │
│  │ ████████░░ 60%     │
│  └─────────────────────┘
│                        │
│  [Continue to Time Slot]│
└────────────────────────┘
```

**Features:**
- 3 main categories: Food, Beverages, Desserts (horizontal tabs)
- Horizontal scrolling food items within each category
- Food images with shimmer loading
- Selection limit: 5 items max
- Touch to unselect items
- Visual feedback for selection
- Animated container showing selected items

---

### 2.6 Time Slot Selection Screen (NEW)

**Layout:**
```
┌─────────────────────────┐
│ ←     Select Time      │
├─────────────────────────┤
│  Pickup: Schnitzel x1  │
│         Kuchen x1       │
│                         │
│  Today    Tomorrow      │
│  ┌─────────────────────┐│
│  │ Mon 16  │ Tue 17   ││
│  └─────────────────────┘│
│                         │
│  11:00 ░░░░░░░░░ 14:00 │
│  ┌────┐ ┌────┐ ┌────┐  │
│  │11:00│ │11:30│ │12:00│  ← Time slot buttons
│  │ ■   │ │ ■   │ │ ■   │     ■ Available
│  └────┘ └────┘ └────┘     □ Unavailable
│                         │
│  ┌────┐ ┌────┐ ┌────┐  │
│  │12:30│ │13:00│ │13:30│  │
│  │ ■   │ │ □   │ │ ■   │  │
│  └────┘ └────┘ └────┘  │
│                         │
│  [Confirm Pickup]      │
└────────────────────────┘
```

**Features:**
- Calendar view with 7-day selection
- Time slots every 30 minutes (11:00-14:00)
- Availability indicators
- Selected items summary at top

---

### 2.7 Confirmation Screen (NEW)

**Layout:**
```
┌─────────────────────────┐
│                         │
│         ✓               │
│    Order Confirmed!     │
│                         │
│  ┌───────────────────┐  │
│  │ Order #ABC123      │  │
│  │ Schnitzel x1      │  │
│  │ Kuchen x1          │  │
│  │ Cola x1            │  │
│  │                     │  │
│  │ Pickup: 12:30 Today │  │
│  │ Location: Mensa     │  │
│  └───────────────────┘  │
│                         │
│  [View QR Code]         │
│  [Back to Dashboard]    │
└─────────────────────────┘
```

**Features:**
- Success animation with checkmark
- Receipt card with order details
- Order ID, items, pickup time, location
- Navigation to QR code or dashboard

---

### 2.8 QR Code Screen (UPDATED)

**Layout:**
```
┌─────────────────────────┐
│ ←                       │
│                         │
│     █████████████       │
│     █████████████       │
│     ██        ██       │
│     ██ ██  ██ ██       │
│     ██ ██  ██ ██       │
│     ██        ██       │
│     █████████████       │
│     █████████████       │
│                         │
│  Pickup ID: #ABC123     │
│  Student: Zain          │
│                         │
│  ┌───────────────────┐  │
│  │ ⏱ Expires in     │  │
│  │    04:59          │  │  ← Countdown timer
│  └───────────────────┘  │     (warning at <60s)
│                         │
│  [Back to Dashboard]    │
└─────────────────────────┘
```

**Features:**
- Custom QR code with deterministic pattern
- Pickup ID display
- Student name display
- Countdown timer (5-minute expiration)
- Warning state when <60 seconds remain
- Order summary when data provided

---

### 2.9 Student Profile Screen with QR Code

**Layout:**
```
┌─────────────────────────┐
│ ←   My Profile      ⚙️  │
├─────────────────────────┤
│                         │
│  ┌───────────────────┐  │
│  │ MRU           🛡️  │  │
│  │                   │  │
│  │ ┌────┐ ┌────┐    │  │
│  │ │ QR │ │ 📷 │    │  │
│  │ │Code│ │Photo│    │  │
│  │ └────┘ └────┘    │  │
│  │                   │  │
│  │ ID: #61913042     │  │
│  │ Zain Ul Ebad      │  │
│  │ Computer Science  │  │
│  └───────────────────┘  │
│                         │
│  ┌────────┬────────┬───┐│
│  │   34   │   12   │ 5 ││
│  │ Meals  │ Avg/Mo │Str││
│  └────────┴────────┴───┘│
│                         │
│  ┌───────────────────┐  │
│  │ 📱 Show QR Code  ▸│  │
│  ├───────────────────┤  │
│  │ 🕐 Meal History  ▸│  │
│  ├───────────────────┤  │
│  │ 🏆 Achievements  ▸│  │
│  └───────────────────┘  │
└─────────────────────────┘
```

**QR Code Specifications:**
- Size: 112x112px
- Scannable pattern
- White background container
- "Scan for verification" label
- Student photo beside QR code
- University badge (MRU)
- Student ID and name
- Program/Year info

---

### 2.7 Settings Screen

**Layout:**
```
┌─────────────────────────┐
│ ←   Settings            │
├─────────────────────────┤
│                         │
│  ┌───────────────────┐  │
│  │       [Photo]     │  │
│  │   Zain Ul Ebad    │  │
│  │   Student at MRU  │  │
│  │   [Edit Profile]  │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ 🌐 Language     ▸ │  │
│  │    English        │  │
│  ├───────────────────┤  │
│  │ 👤 Account      ▸ │  │
│  ├───────────────────┤  │
│  │ 🕐 Meal History ▸ │  │
│  ├───────────────────┤  │
│  │ 📋 Regulations  ▸ │  │
│  ├───────────────────┤  │
│  │ 🌙 Dark Mode   [○]│  │
│  ├───────────────────┤  │
│  │ 📷 Social Media ▸ │  │
│  └───────────────────┘  │
│                         │
│  [Sign Out]             │
│                         │
│  FoodBeGood v2.0.0      │
└─────────────────────────┘
```

**Dark Mode Toggle:**
- Toggle switch in settings list
- Animated switch (52x28px)
- Green when active
- Smooth transition
- Persists preference

---

### 2.8 Food Status Screen (Canteen)

**Layout:**
```
┌─────────────────────────┐
│ ←   Food Status         │
├─────────────────────────┤
│                         │
│  [📍 Mensa Viadrina]    │
│                         │
│  ┌───────────────────┐  │
│  │      ❤️            │  │
│  │  Thank you for    │  │
│  │  reducing         │  │
│  │  food waste!      │  │
│  │                   │  │
│  │  See you soon     │  │
│  └───────────────────┘  │
│                         │
│  Today's Impact         │
│  ┌─────────┐┌─────────┐ │
│  │ 42.5kg  ││  127    │ │
│  │ Saved   ││  Meals  │ │
│  └─────────┘└─────────┘ │
│                         │
│  Sustainability Impact  │
│  ┌───────────────────┐  │
│  │ CO2: 18.5kg [75%] │  │
│  │ Water: 2,450L[68%]│  │
│  │ Students: 89 [82%]│  │
│  └───────────────────┘  │
│                         │
│  Quick Actions          │
│  [+ Add Food]           │
│  [⚠️ Report Low Stock]  │
└─────────────────────────┘
```

**Sustainability Metrics:**
- CO2 Emissions Prevented: 18.5kg (75%)
- Water Saved: 2,450L (68%)
- Students Helped: 89 (82%)
- Progress bars for each metric

---

## 3. Metrics System

### 3.1 Student Metrics

| Metric | Unit | Display | Trend |
|--------|------|---------|-------|
| Total Meals Saved | count | 34 | Progress bar |
| Money Saved (This Month) | € | €82.50 | ↑ +18% vs last month |
| Money Saved (Last Month) | € | €70.00 | Baseline |
| Monthly Average | meals | 12.3 | Top 15% |
| Current Streak | days | 5 | Fire icon |
| Social Impact | students | 156 helped | — |

**Savings Breakdown:**
| Category | Amount | Percentage |
|----------|--------|------------|
| Meals | €45.00 | 54.5% |
| Drinks | €22.50 | 27.3% |
| Snacks | €15.00 | 18.2% |
| **Total** | **€82.50** | **100%** |

### 3.2 Canteen Metrics

| Metric | Unit | Display | Trend |
|--------|------|---------|-------|
| Total Meals Saved | count | 1,247 | Daily: 89 |
| Food Waste Prevented | kg | 428kg | ↓ -15% |
| Canteen Savings | € | €3,142 | — |
| Students Helped | count | 287 | ↑ +8% |
| Student Savings | € | €4,235 | — |
| Urgent Requests | count | 3 | Red alert |

### 3.3 Environmental Impact Metrics

| Metric | Calculation | Display |
|--------|-------------|---------|
| CO2 Prevented | 0.5kg per meal | kg with trend |
| Water Saved | 20L per meal | Liters with progress |
| Food Waste | kg measured | kg with reduction % |
| Cost per Meal | Avg €2.50 | € saved total |

---

## 4. Component Library

### 4.1 Metric Card

```css
.metric-card {
    background: var(--bg-card);
    border-radius: 16px;
    padding: 20px;
    border: 1px solid var(--border-color);
    transition: all 0.3s ease;
}

.metric-card.highlight {
    background: linear-gradient(135deg, #10B981 0%, #059669 100%);
    color: white;
    border: none;
}

.stat-value {
    font-size: 36px;
    font-weight: 800;
    color: #10B981;
    line-height: 1;
}

.stat-label {
    font-size: 13px;
    color: #64748B;
    font-weight: 500;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.trend-indicator {
    display: flex;
    align-items: center;
    gap: 4px;
    font-size: 12px;
}

.trend-up { color: #10B981; }
.trend-down { color: #EF4444; }
```

### 4.2 Progress Bar

```css
.progress-container {
    height: 8px;
    background: var(--bg-secondary);
    border-radius: 4px;
    overflow: hidden;
}

.progress-bar {
    height: 100%;
    border-radius: 4px;
    transition: width 0.5s ease;
}

.progress-bar.green {
    background: linear-gradient(90deg, #10B981, #34D399);
}

.progress-bar.blue {
    background: #3B82F6;
}

.progress-bar.pink {
    background: #EC4899;
}
```

### 4.3 QR Code Component

```css
.qr-container {
    background: white;
    padding: 20px;
    border-radius: 16px;
    box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
    text-align: center;
}

.qr-code {
    width: 112px;
    height: 112px;
}

.qr-label {
    font-size: 12px;
    color: #64748B;
    font-family: monospace;
    margin-top: 8px;
}
```

### 4.4 Dark Mode Toggle

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

## 5. Color System

### 5.1 Light Mode

| Element | Color |
|---------|-------|
| Background Primary | #F8FAFC |
| Background Secondary | #FFFFFF |
| Card Background | #FFFFFF |
| Text Primary | #1E293B |
| Text Secondary | #64748B |
| Text Muted | #94A3B8 |
| Border | #E2E8F0 |

### 5.2 Dark Mode

| Element | Color |
|---------|-------|
| Background Primary | #0F172A |
| Background Secondary | #1E293B |
| Card Background | #1E293B |
| Text Primary | #F8FAFC |
| Text Secondary | #94A3B8 |
| Text Muted | #64748B |
| Border | #334155 |

### 5.3 Semantic Colors

| Purpose | Color | Usage |
|---------|-------|-------|
| Success | #10B981 | Meals saved, trends up |
| Warning | #F59E0B | Averages, alerts |
| Error | #EF4444 | Urgent requests, down trends |
| Info | #3B82F6 | Water, general info |
| Social | #EC4899 | Students helped |

---

## 6. Spacing and Layout

### 6.1 Spacing Scale

```
4px  - space-1 (icon gaps)
8px  - space-2 (small gaps)
12px - space-3 (compact)
16px - space-4 (standard)
20px - space-5 (component padding)
24px - space-6 (card padding)
32px - space-8 (section gaps)
```

### 6.2 Border Radius

```
8px  - rounded-sm (small elements)
12px - rounded (buttons, inputs)
16px - rounded-lg (cards, containers)
20px - rounded-xl (large cards)
9999px - rounded-full (pills, avatars)
```

### 6.3 Shadows

```
sm: 0 1px 2px 0 rgba(0,0,0,0.05)
DEFAULT: 0 1px 3px 0 rgba(0,0,0,0.1)
md: 0 4px 6px -1px rgba(0,0,0,0.1)
lg: 0 10px 15px -3px rgba(0,0,0,0.1)
brand: 0 4px 16px -4px rgba(16,185,129,0.5)
```

---

## 7. Dark Mode Implementation

### 7.1 CSS Custom Properties

```css
:root {
    --bg-primary: #F8FAFC;
    --bg-secondary: #FFFFFF;
    --bg-card: #FFFFFF;
    --text-primary: #1E293B;
    --text-secondary: #64748B;
    --text-muted: #94A3B8;
    --border-color: #E2E8F0;
}

[data-theme="dark"] {
    --bg-primary: #0F172A;
    --bg-secondary: #1E293B;
    --bg-card: #1E293B;
    --text-primary: #F8FAFC;
    --text-secondary: #94A3B8;
    --text-muted: #64748B;
    --border-color: #334155;
}
```

### 7.2 Theme Toggle JavaScript

```javascript
function toggleDarkMode() {
    const html = document.documentElement;
    const currentTheme = html.getAttribute('data-theme');
    const newTheme = currentTheme === 'light' ? 'dark' : 'light';
    
    html.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
}

// Initialize on load
document.addEventListener('DOMContentLoaded', () => {
    const savedTheme = localStorage.getItem('theme') || 'light';
    document.documentElement.setAttribute('data-theme', savedTheme);
});
```

### 7.3 Transition Effects

```css
* {
    transition: background-color 0.3s ease, color 0.3s ease;
}
```

---

## 8. Animations

### 8.1 Page Transitions

```css
@keyframes slideUp {
    from {
        opacity: 0;
        transform: translateY(20px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.animate-slide-up {
    animation: slideUp 0.5s ease-out forwards;
}
```

### 8.2 Button Interactions

```css
.btn-primary {
    transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 24px -4px rgba(16, 185, 129, 0.5);
}

.btn-primary:active {
    transform: scale(0.98);
}
```

### 8.3 Card Hover

```css
.card {
    transition: all 0.3s ease;
}

.card:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1);
}
```

---

## 9. Accessibility

### 9.1 Contrast Requirements

| Element | Minimum Ratio |
|---------|--------------|
| Normal text | 4.5:1 |
| Large text (18px+) | 3:1 |
| UI components | 3:1 |

### 9.2 Touch Targets

- Minimum size: 44×44px
- Spacing between targets: 8px minimum

### 9.3 Focus Indicators

- Visible focus rings on all interactive elements
- 4px offset from element
- Primary green color

---

## 10. Responsive Design

### 10.1 Breakpoints

| Name | Width | Target |
|------|-------|--------|
| Small | 320-375px | iPhone SE, small phones |
| Medium | 376-428px | Standard phones |
| Large | 429-768px | Large phones, small tablets |

### 10.2 Responsive Patterns

**Small Screens:**
- Reduce card padding to 16px
- Smaller icon buttons (56px)
- Compact metric displays

**Large Screens:**
- Max-width container (430px)
- Centered layout
- Larger touch targets

---

## 11. Assets

### 11.1 Icons

**Library:** Font Awesome 6.5.1

**Required Icons:**
- Navigation: bars, cog, bell, arrow-left
- Actions: plus, check, times, filter, search
- Categories: seedling, ice-cream, drumstick-bite, utensils
- Metrics: leaf, euro-sign, cloud, fire, calendar, clock, users, heart
- Status: exclamation-circle, info-circle, shield-alt

### 11.2 Images

**User Photos:**
- Format: JPG/WebP
- Size: 200x200px minimum
- Aspect: 1:1 (square)
- Border-radius: 16px or 50%

### 11.3 QR Codes

- Generated programmatically
- Error correction: Medium (M)
- Size: 200x200px render
- Colors: Dark (#1E293B) on white

---

## 12. Quality Checklist

### 12.1 Visual Quality
- [x] Consistent color palette
- [x] Professional typography
- [x] Subtle shadows and depth
- [x] Smooth animations
- [x] Clear visual hierarchy

### 12.2 Metrics Quality
- [x] All key metrics visible
- [x] Trends clearly indicated
- [x] Progress bars for goals
- [x] Social impact highlighted
- [x] Environmental metrics prominent

### 12.3 Accessibility
- [x] High contrast ratios
- [x] Adequate touch targets
- [x] Clear focus states
- [x] Screen reader support
- [x] Dark mode support

### 12.4 Dark Mode
- [x] All screens support dark mode
- [x] Toggle in settings
- [x] Smooth transitions
- [x] Preference persistence
- [x] Proper contrast in both modes

---

*Design documentation updated for Professional Edition - February 2026*
*Version: 3.1 with Unified Login, Pickup Flow Redesign, and Time Slot Selection*

**Key Changes from V3.0:**
- Removed Role Selection screen (replaced with unified login)
- Updated login to use email-based authentication
- Redesigned pickup flow with horizontal category tabs
- Added time slot selection screen
- Added confirmation screen
- Updated QR code page with countdown timer and warning state
