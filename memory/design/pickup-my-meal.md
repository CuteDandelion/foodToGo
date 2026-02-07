# FoodBeGood - Pickup My Meal Design

## Overview

**Feature Name:** Pickup My Meal  
**Previous Name:** Track My Meal (clarified 2025-02-04)  
**Purpose:** Allow students to select food items they want to collect in their own container and present QR code for canteen verification  
**Target Users:** University students using the canteen

---

## User Flow: Pickup My Meal

```
Student Dashboard
      ↓ (Tap "+ Pickup My Meal")
Food Selection Screen
      ↓ (Select items, watch container fill)
Container Review Screen
      ↓ (Review selections, show QR)
QR Code Presentation
      ↓ (Canteen scans QR)
Confirmation/Success
```

---

## Screen 1: Student Dashboard - Pickup My Meal Button

### Layout
```
┌─────────────────────────┐
│ ☰     [LOGO]     ⚙️ 🔔 │
├─────────────────────────┤
│  Good morning,          │
│  Zain! 👋               │
│                         │
│  [Metrics Grid...]      │
│                         │
│  ┌───────────────────┐  │
│  │ ⏰ Next Pickup    │  │
│  │ Mensa Viadrina    │  │
│  │           2h 45m  │  │
│  └───────────────────┘  │
│                         │
│  ╔═══════════════════╗  │
│  ║  🥡 + Pickup My   ║  │
│  ║      Meal         ║  │
│  ╚═══════════════════╝  │
└─────────────────────────┘
```

### Button Specifications
- **Label:** "+ Pickup My Meal" with lunchbox/container icon (🥡)
- **Style:** Prominent floating action button or full-width button
- **Color:** Primary green (#10B981) with white text
- **Icon:** Food container/lunchbox icon
- **Position:** Fixed at bottom or prominent in dashboard

---

## Screen 2: Food Selection with Container Animation

### Layout
```
┌─────────────────────────┐
│ ←    Pickup My Meal     │
├─────────────────────────┤
│                         │
│  ┌───────────────────┐  │
│  │   🥡              │  │
│  │  ┌─────────────┐  │  │
│  │  │             │  │  │
│  │  │  CONTAINER  │  │  │
│  │  │   VISUAL    │  │  │
│  │  │             │  │  │
│  │  │  🍗 🥗 🍰   │  │  │  ← Food items appear here
│  │  │             │  │  │
│  │  └─────────────┘  │  │
│  │                   │  │
│  │  3 items selected │  │
│  │  Space: 60% full  │  │
│  └───────────────────┘  │
│                         │
│  Available Food         │
│  ┌────┐ ┌────┐ ┌────┐  │
│  │ 🥗 │ │ 🍰 │ │ 🍗 │  │
│  │Sald│ │Dess│ │Side│  │
│  └────┘ └────┘ └────┘  │
│                         │
│  ┌────┐ ┌────┐ ┌────┐  │
│  │ 🍽️ │ │ 🍽️ │ │ 🍽️ │  │
│  │Main│ │Main│ │Main│  │
│  │ 1  │ │ 2  │ │ 3  │  │
│  └────┘ └────┘ └────┘  │
│                         │
│  [Continue to QR →]     │
└─────────────────────────┘
```

### Container Visualization

#### Container Design
```
┌─────────────────────────┐
│      Container Lid      │  ← Opens when adding food
│    ╔═══════════════╗    │
│    ║  ╭─────────╮  ║    │
│    ║  │         │  ║    │
│    ║  │  FOOD   │  ║    │  ← Food items stack here
│    ║  │  ITEMS  │  ║    │
│    ║  │         │  ║    │
│    ║  ╰─────────╯  ║    │
│    ╚═══════════════╝    │
│         [====60%===]    │  ← Fill level indicator
│         3/5 items       │
└─────────────────────────┘
```

#### Container States
1. **Empty State:** Container shown with lid closed, "Tap food to add"
2. **Filling State:** Lid opens, food items animate dropping in
3. **Full State:** Container at capacity, lid stays open, "Ready!"
4. **Overflow Warning:** Red warning if trying to add too much

### Food Categories

| Category | Icon | Color | Items Available |
|----------|------|-------|-----------------|
| Salad Bar | 🥗 | Green (#22C55E) | Mixed greens, tomatoes, cucumbers, dressing |
| Dessert | 🍰 | Pink (#EC4899) | Cake, fruit cup, yogurt, pudding |
| Side Dish | 🍟 | Yellow (#EAB308) | Fries, rice, bread, vegetables |
| Main 1 | 🍽️ | Orange (#F97316) | Protein option A (chicken, fish, vegetarian) |
| Main 2 | 🍽️ | Blue (#3B82F6) | Protein option B |
| Main 3 | 🍽️ | Purple (#8B5CF6) | Protein option C |

### Animation Specifications

#### Food Drop Animation
```css
@keyframes foodDrop {
  0% {
    transform: translateY(-100px) scale(0.8);
    opacity: 0;
  }
  30% {
    opacity: 1;
  }
  60% {
    transform: translateY(10px) scale(1.05);
  }
  80% {
    transform: translateY(-5px) scale(0.95);
  }
  100% {
    transform: translateY(0) scale(1);
    opacity: 1;
  }
}

.food-item-adding {
  animation: foodDrop 0.6s cubic-bezier(0.34, 1.56, 0.64, 1);
}
```

#### Container Lid Animation
```css
@keyframes lidOpen {
  0% {
    transform: rotateX(0deg);
  }
  100% {
    transform: rotateX(-110deg);
  }
}

.container-lid {
  transform-origin: top;
  transition: transform 0.4s ease;
}

.container-lid.open {
  animation: lidOpen 0.4s ease forwards;
}
```

#### Bounce Effect When Food Lands
```css
@keyframes containerBounce {
  0%, 100% {
    transform: translateY(0);
  }
  25% {
    transform: translateY(3px);
  }
  50% {
    transform: translateY(-2px);
  }
  75% {
    transform: translateY(1px);
  }
}

.container-bounce {
  animation: containerBounce 0.4s ease;
}
```

### Interaction Flow

1. **Student taps food category** (e.g., "Main 1")
2. **Sub-menu appears** with specific food items
3. **Student selects specific item**
4. **Container lid opens** (0.4s animation)
5. **Food item icon drops** from top into container (0.6s animation with bounce)
6. **Container bounces** slightly on impact (0.4s)
7. **Lid closes** (0.4s delay after food lands)
8. **Fill level updates** (progress bar animates)
9. **Counter updates** ("3 items selected")

### Selection Details

#### Food Item Card (Selected State)
```
┌─────────────────────┐
│ 🍗                  │
│ Chicken Rice        │
│ ┌─────────────────┐ │
│ │ Remove      [X] │ │
│ └─────────────────┘ │
└─────────────────────┘
```

#### Selected Items List (Below Container)
```
Selected Items (3):
┌────────┬────────┬────────┐
│ 🥗     │ 🍗     │ 🍰     │
│ Salad  │Main 1  │Dessert │
│[×]     │[×]     │[×]     │
└────────┴────────┴────────┘
```

---

## Screen 3: QR Code Presentation

### Layout
```
┌─────────────────────────┐
│ ←   Show to Canteen     │
├─────────────────────────┤
│                         │
│  ┌───────────────────┐  │
│  │  Present this QR  │  │
│  │  code to canteen  │  │
│  │  staff            │  │
│  │                   │  │
│  │  ┌─────────────┐  │  │
│  │  │ ▄▄▄ ▄▄▄ ▄▄▄ │  │  │
│  │  │ █ █ ▀▀▀ █ █ │  │  │
│  │  │ ▀▀▀ ▄▄▄ ▀▀▀ │  │  │
│  │  │ ▄▄▄ █ █ ▄▄▄ │  │  │
│  │  │ █ █ ▀▀▀ █ █ │  │  │
│  │  │ ▀▀▀ ▄▄▄ ▀▀▀ │  │  │
│  │  └─────────────┘  │  │
│  │                   │  │
│  │  ID: #61913042    │  │
│  │  Zain Ul Ebad     │  │
│  │                   │  │
│  │  [3 items]        │  │
│  │  [View Items ▼]   │  │
│  └───────────────────┘  │
│                         │
│  ⏱️ Valid for: 5:00     │
│                         │
│  ┌───────────────────┐  │
│  │ 📋 Order Summary  │  │
│  │ Salad Bar         │  │
│  │ Main: Chicken     │  │
│  │ Dessert: Cake     │  │
│  │                   │  │
│  │ Total: €6.50      │  │
│  └───────────────────┘  │
└─────────────────────────┘
```

### QR Code Specifications
- **Size:** 200x200px (large for easy scanning)
- **Data:** Encoded student ID + selected items + timestamp
- **Expiration:** 5 minutes (countdown timer displayed)
- **Auto-refresh:** QR code regenerates every 4:30 minutes
- **Visual:** High contrast black/white pattern

### Expiration Timer
```css
@keyframes pulse-warning {
  0%, 100% {
    opacity: 1;
    color: #EF4444;
  }
  50% {
    opacity: 0.6;
    color: #F87171;
  }
}

.timer-warning {
  animation: pulse-warning 1s ease infinite;
}
```

---

## Screen 4: Canteen Verification View (Staff Side)

### Layout
```
┌─────────────────────────┐
│ ⚙️  Canteen Portal  🔔 │
├─────────────────────────┤
│  Scan Student QR Code   │
│                         │
│  ┌───────────────────┐  │
│  │                   │  │
│  │   [Camera View]   │  │
│  │                   │  │
│  │  ┌─────────────┐  │  │
│  │  │  SCAN FRAME │  │  │
│  │  └─────────────┘  │  │
│  │                   │  │
│  │  Align QR code    │  │
│  │  within frame     │  │
│  │                   │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ 🥡 Container Pickup│  │
│  │                   │  │
│  │ Student: Zain     │  │
│  │ Items: 3          │  │
│  │                   │  │
│  │ [View Details]    │  │
│  │ [✓ Confirm Pickup]│  │
│  └───────────────────┘  │
└─────────────────────────┘
```

### Staff Actions
1. **Scan QR Code** - Camera scans student's QR
2. **View Order Details** - Shows selected items
3. **Confirm Pickup** - Marks items as collected
4. **Cancel/Modify** - If student changes mind

---

## Container Animation Technical Specifications

### Container SVG Structure
```svg
<svg viewBox="0 0 200 240" class="food-container">
  <!-- Container Body -->
  <path d="M20,60 L180,60 L170,220 L30,220 Z" 
        fill="#F3F4F6" 
        stroke="#9CA3AF" 
        stroke-width="2"/>
  
  <!-- Container Lid (animated) -->
  <g class="container-lid">
    <path d="M15,60 L185,60 L175,40 L25,40 Z" 
          fill="#E5E7EB" 
          stroke="#9CA3AF" 
          stroke-width="2"/>
    <rect x="85" y="25" width="30" height="15" rx="3" fill="#9CA3AF"/>
  </g>
  
  <!-- Food Items Container -->
  <g class="food-stack">
    <!-- Food items added dynamically -->
  </g>
  
  <!-- Fill Level Indicator -->
  <rect x="30" y="200" width="140" height="8" rx="4" fill="#E5E7EB"/>
  <rect x="30" y="200" width="84" height="8" rx="4" fill="#10B981" class="fill-bar"/>
</svg>
```

### Food Item Icons (SVG)

#### Salad (🥗)
```svg
<svg viewBox="0 0 40 40" class="food-icon salad">
  <circle cx="20" cy="20" r="16" fill="#DCFCE7"/>
  <path d="M20,8 Q28,8 28,20 Q28,32 20,32 Q12,32 12,20 Q12,8 20,8" fill="#22C55E"/>
  <circle cx="16" cy="16" r="3" fill="#16A34A"/>
  <circle cx="24" cy="20" r="2" fill="#16A34A"/>
  <circle cx="18" cy="24" r="2.5" fill="#16A34A"/>
</svg>
```

#### Main Course (🍽️)
```svg
<svg viewBox="0 0 40 40" class="food-icon main">
  <circle cx="20" cy="20" r="16" fill="#FFF7ED"/>
  <ellipse cx="20" cy="24" rx="10" ry="6" fill="#F97316"/>
  <ellipse cx="20" cy="20" rx="8" ry="4" fill="#FB923C"/>
  <circle cx="14" cy="22" r="2" fill="#FDBA74"/>
</svg>
```

#### Dessert (🍰)
```svg
<svg viewBox="0 0 40 40" class="food-icon dessert">
  <circle cx="20" cy="20" r="16" fill="#FDF2F8"/>
  <path d="M12,28 L12,18 L20,12 L28,18 L28,28 Z" fill="#F9A8D4"/>
  <path d="M12,18 L28,18" stroke="#F472B6" stroke-width="2"/>
  <circle cx="20" cy="16" r="3" fill="#EC4899"/>
</svg>
```

### Animation Sequencing (JavaScript)
```javascript
class ContainerAnimation {
  constructor(containerElement) {
    this.container = containerElement;
    this.lid = containerElement.querySelector('.container-lid');
    this.foodStack = containerElement.querySelector('.food-stack');
    this.fillBar = containerElement.querySelector('.fill-bar');
    this.items = [];
  }

  async addFood(foodType) {
    // 1. Open lid
    await this.openLid();
    
    // 2. Create food element
    const food = this.createFoodElement(foodType);
    this.foodStack.appendChild(food);
    
    // 3. Animate drop
    await this.animateDrop(food);
    
    // 4. Bounce container
    this.bounceContainer();
    
    // 5. Update fill level
    this.updateFillLevel();
    
    // 6. Close lid after delay
    setTimeout(() => this.closeLid(), 600);
    
    this.items.push(foodType);
  }

  openLid() {
    return new Promise(resolve => {
      this.lid.classList.add('open');
      setTimeout(resolve, 400);
    });
  }

  closeLid() {
    this.lid.classList.remove('open');
  }

  createFoodElement(type) {
    const food = document.createElement('div');
    food.className = `food-item ${type}`;
    food.innerHTML = this.getFoodSVG(type);
    // Start position: above container
    food.style.transform = 'translateY(-100px)';
    food.style.opacity = '0';
    return food;
  }

  animateDrop(food) {
    return new Promise(resolve => {
      food.classList.add('food-item-adding');
      setTimeout(resolve, 600);
    });
  }

  bounceContainer() {
    this.container.classList.add('container-bounce');
    setTimeout(() => {
      this.container.classList.remove('container-bounce');
    }, 400);
  }

  updateFillLevel() {
    const percentage = Math.min((this.items.length / 5) * 100, 100);
    this.fillBar.style.width = `${percentage}%`;
  }
}
```

---

## Design Tokens

### Colors
| Purpose | Hex | Usage |
|---------|-----|-------|
| Container Body | #F3F4F6 | Container background |
| Container Lid | #E5E7EB | Lid color |
| Container Border | #9CA3AF | Container outline |
| Fill Progress | #10B981 | Fill level bar |
| Salad | #22C55E | Salad category |
| Dessert | #EC4899 | Dessert category |
| Side | #EAB308 | Side dish category |
| Main 1 | #F97316 | Main protein A |
| Main 2 | #3B82F6 | Main protein B |
| Main 3 | #8B5CF6 | Main protein C |

### Spacing
| Element | Value |
|---------|-------|
| Container padding | 20px |
| Food item gap | 8px |
| Category grid gap | 12px |
| Animation duration | 400-600ms |

### Typography
| Element | Size | Weight |
|---------|------|--------|
| Screen title | 20px | 700 |
| Category label | 12px | 600 |
| Item count | 14px | 500 |
| Fill percentage | 16px | 700 |

---

## Accessibility Considerations

1. **Animation**
   - Respect `prefers-reduced-motion` media query
   - Provide static alternative for reduced motion
   - Ensure animations don't cause vestibular issues

2. **QR Code**
   - Large size for easy scanning
   - High contrast (black on white)
   - Alternative text description
   - Screen reader announcement on generate

3. **Container Visualization**
   - Color not the only indicator (patterns/icons)
   - Text labels for all food items
   - Clear fill level text ("3 of 5 items")

4. **Touch Targets**
   - Food category buttons: 60×60px minimum
   - Remove buttons: 44×44px minimum
   - Continue button: Full width, 56px height

---

## Responsive Behavior

### Small Screens (< 375px)
- Container scales to 80% width
- Food categories in 2-column grid
- Simplified container visualization

### Large Screens (> 428px)
- Container max-width: 280px
- Food categories in 3-column grid
- Expanded order summary view

---

## Success Metrics

Track these metrics to measure feature success:

1. **Pickup Completion Rate** - % of started pickups completed
2. **Average Items per Pickup** - Target: 2.5+ items
3. **QR Scan Success Rate** - Should be > 95%
4. **Time to Complete** - Target: < 90 seconds
5. **Container Animation Engagement** - Time spent watching animations

---

*Design Documentation Updated: 2025-02-04*  
*Feature: Pickup My Meal v1.0*  
*Replaces: Track My Meal*
