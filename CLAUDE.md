# EasyStock — Claude Code Project Context

> Read this file at the start of every session. This is the single source of truth for the EasyStock project.

---

## Project Overview

**App Name:** EasyStock  
**Tagline:** Stock management made simple  
**Industry:** Paint & Wood Ply B2B distribution — Pakistan market  
**Client:** Paint & Ply business owner (Pakistan)  
**Developer:** Ammar (Rixon Solution)  

### Problem Being Solved
Small shopkeepers in Pakistan don't know how much stock their distributor has available. They need real-time visibility into distributor stock so they can place orders efficiently without calling or visiting physically.

### Core Concept
- Distributors manage their stock (brands, products, colors, sizes, quantities)
- Shopkeepers request access to a distributor
- After approval, shopkeepers can browse live stock and place orders
- **NEW:** Shopkeepers also maintain their own stock (entered via Shopkeeper Web). Once a connection is approved, the distributor can view that shopkeeper's stock too — for restocking visibility.
- Payment is hand-to-hand (offline/cash) — tracked manually
- Admin (client) manages the entire platform and earns subscription revenue

---

## Actors & Roles

| Role | Platform | Description |
|---|---|---|
| Super Admin | Web (React) | Client — manages entire platform, distributors, subscriptions |
| Distributor | Web (React) + Flutter mobile | Manages stock, approves shopkeepers, handles orders, views connected shopkeepers' stock |
| Shopkeeper | Flutter mobile + **Web (React) — NEW** | Mobile: browses distributor stock, places orders, tracks status. Web: manages **own stock** (add/edit inventory) |

> ⚠️ **Architecture change (Jun 2026):** Shopkeeper is no longer mobile-only. A Shopkeeper Web portal is being added, scoped initially to stock management (add/edit own inventory). Confirm later whether shopkeeper web expands beyond stock (e.g. order history, profile) or stays a single-purpose tool.

---

## Tech Stack

### Frontend Web (Admin + Distributor + Shopkeeper Portal)
- **Framework:** React JS (Vite)
- **Styling:** Tailwind CSS
- **UI Components:** shadcn/ui
- **Icons:** Lucide React
- **Charts:** Recharts
- **Routing:** React Router v6
- **State:** React Context + useState (no Redux for now)

### Mobile App (Distributor + Shopkeeper)
- **Framework:** Flutter
- **State:** Provider
- **Navigation:** GoRouter
- **Charts:** fl_chart
- **Font:** Google Fonts — Inter

### Backend
- **Database:** Firebase Firestore
- **Auth:** Firebase Authentication (role-based)
- **Storage:** Firebase Storage (shop photos, business cards)
- **Functions:** Firebase Cloud Functions (business logic, notifications)
- **Real-time:** Firestore onSnapshot listeners for live stock updates

### Payments / Subscriptions
- **Pakistan:** JazzCash / EasyPaisa
- **Cards:** Stripe (optional later)
- **Note:** Order payments are hand-to-hand (offline). Subscriptions are platform payments.

---

## Design System

### Brand Identity
- **App Name:** EasyStock
- **Logo:** Orange "E" square icon + "Easy" (bold) + "Stock" (light) inline wordmark
- **Logo Icon:** Orange (#F97316) rounded square, white bold "E" inside
- **Tagline:** PAINT & PLY DISTRIBUTION (small caps, letterSpaced)

### Color Palette
```
Primary Navy:    #1B2B4B   ← sidebar, headings, primary buttons
Accent Orange:   #F97316   ← CTA buttons, active nav, logo icon, badges
Light Navy:      #243a63   ← hover states on navy
Background:      #F4F6FA   ← page background
Surface:         #FFFFFF   ← cards, panels
Border:          #E8EDF3   ← card borders, dividers
Text Primary:    #1B2B4B
Text Secondary:  #888888
Text Muted:      #AAAAAA

Status Colors:
  Success:       #1a8a5a  bg: #eaf8f2
  Warning:       #d97706  bg: #fff8ed
  Danger:        #d94a3a  bg: #fef0ef
  Info:          #185FA5  bg: #eef2f8
  Purple:        #6c5ce7  bg: #f0eeff
```

### Typography
```
Font Family:     'Helvetica Neue', Arial, sans-serif (web)
                 Inter (Flutter mobile)

Sizes:
  Page title:    16px / 600
  Section title: 13px / 600
  Body:          13px / 400
  Small:         12px / 400
  Label:         11px / 400
  Micro:         10px / 400
  Tiny:          9px  / 400
```

### Spacing & Radius
```
Page padding:    24px
Card padding:    18px inner / 16px compact
Gap between cards: 16px standard / 12px compact
Border radius:   12px cards / 10px inner cards / 8px buttons+inputs / 6px pills
Border width:    0.5px for all borders and dividers
```

### Component Patterns

**Sidebar (Web)**
- Width: 240px, background: #1B2B4B
- Active nav item: #F97316 background, white text
- Inactive nav item: #8fb3d4 text, hover: rgba(white, 0.06) bg
- Section labels: 9px, #4a6a8a, letter-spacing: 1.5px
- Nav badges: orange tinted pill (rgba orange 0.25 bg)
- Bottom: admin profile with avatar, name, role

**Topbar (Web)**
- Height: 60px, white background, 0.5px border-bottom
- Left: page title (16px/600) + subtitle (11px/muted)
- Right: icon buttons (36px square) + primary action button

**Stat Cards**
- White bg, 0.5px border, 12px radius
- Icon: 38-40px colored square (10px radius)
- Value: 24-26px / 700, navy
- Label: 11-12px, muted
- Badge: top-right, green (up) or red (down)

**Status Pills**
```
Active:      bg #eaf8f2  text #1a8a5a  dot #1a8a5a
Pending:     bg #fff8ed  text #d97706  dot #d97706
Suspended:   bg #fef0ef  text #d94a3a  dot #d94a3a
Expiring:    bg #fff8ed  text #d97706  dot #d97706
Expired:     bg #fef0ef  text #d94a3a  dot #d94a3a
Completed:   bg #eaf8f2  text #1a8a5a  dot #1a8a5a
Approved:    bg #eef2f8  text #185FA5  dot #185FA5
Requested:   bg #f0eeff  text #6c5ce7  dot #6c5ce7
Cancelled:   bg #fef0ef  text #d94a3a  dot #d94a3a
```

**Tables**
- Header: #fafbfc bg, 10-11px / 600 / #aaa
- Row: 12-13px, 0.5px bottom border #f5f7fa
- Row hover: #fafbff
- Action buttons: 27-28px square, 6px radius, 0.5px border

**Drawers (Side panels)**
- Width: 340-380px, slides in from right
- Overlay: rgba(0,0,0,0.3)
- Header: 18px padding, 15px/600 title
- Footer: action buttons stacked vertically

---

## Firestore Data Structure

```
/users/{userId}
  name, email, phone, role (admin|distributor|shopkeeper)
  city, createdAt, subscriptionStatus

/distributors/{distributorId}
  userId, businessName, ownerName, email, phone
  cities[], brands[], verified (bool)
  createdAt, subscriptionPlan, subscriptionEnd

/shopkeepers/{shopkeeperId}
  userId, shopName, ownerName, phone, email, city
  shopPhotoUrl, businessCardUrl
  verificationStatus (pending|approved|rejected)
  verificationNote, verifiedAt, createdAt

/distributor_shopkeeper/{linkId}
  distributorId, shopkeeperId
  status (pending|approved|blocked)
  requestedAt, approvedAt
  ← Gate for ALL cross-visibility: distributor stock view (shopkeeper side),
    shopkeeper stock view (distributor side), and ordering — all require status == approved

/brands/{brandId}  ← Master data, seeded by admin
  name, description, initials, color (hex), active

/categories/{categoryId}
  brandId, name, icon, active

/products/{productId}
  brandId, categoryId, name, active

/colors/{colorId}
  productId, brandId
  code (e.g. "2056"), name (e.g. "Royal Blue")
  hex (#1a3fc4), active

/sizes/{sizeId}
  label (1L, 4L, 16L, 20L), sortOrder

/product_sizes/{id}
  productId, sizeId

/stock/{stockId}                          ← DISTRIBUTOR stock
  distributorId, productId, colorId, sizeId
  totalQty, reservedQty
  price, updatedAt
  ← availableQty = totalQty - reservedQty (computed)

/shopkeeper_stock/{stockId}               ← NEW — SHOPKEEPER's own stock
  shopkeeperId, productId, colorId, sizeId
  qty, updatedAt
  ← Entered manually by shopkeeper via Shopkeeper Web
  ← No reservedQty / no price — this is informational inventory for the
    distributor to see (restocking signal), not a sellable listing
  ← Visible to a distributor ONLY where a distributor_shopkeeper link
    exists with status == approved

/orders/{orderId}
  shopkeeperId, distributorId
  status: requested|approved|payment_pending|payment_confirmed|
          out_for_delivery|delivered|completed|cancelled|rejected
  paymentStatus: unpaid|paid
  totalAmount, createdAt, updatedAt
  approvedAt, deliveredAt, completedAt
  ← Direction: shopkeeper orders FROM distributor (confirmed flow).
  ← Reverse direction (distributor ordering from shopkeeper) is NOT yet
    confirmed in scope — flag and confirm with client before building.

/order_items/{itemId}
  orderId, productId, colorId, sizeId
  quantity, unitPrice, totalPrice

/subscriptions/{subscriptionId}
  userId, userType (distributor|shopkeeper)
  plan: dist_monthly|dist_yearly|shop_monthly|shop_yearly
  amount, startDate, endDate
  status: active|expired|cancelled
  paymentHistory[]

/notifications/{notifId}
  userId, type, title, body
  read (bool), createdAt
```

---

## Cross-Visibility Rules (NEW)

```
Trigger: distributor_shopkeeper.status == 'approved'

Shopkeeper side (mobile — already built):
  → Can browse distributor's /stock (live, with price, availableQty)
  → Can place orders against that stock

Distributor side (NEW — web + mobile, pending build):
  → Can view that shopkeeper's /shopkeeper_stock (read-only, qty only — no price)
  → Purpose: lets distributor see what the shopkeeper is low on, proactively
    suggest restock / sales call — NOT a marketplace for distributor to buy
    from shopkeeper
  → If link status flips to 'blocked' or 'pending', visibility revokes both ways

Ordering direction:
  → Confirmed: Shopkeeper → Distributor (existing order lifecycle, unchanged)
  → Unconfirmed: Distributor → Shopkeeper reverse order flow — do NOT build
    until explicitly confirmed by client
```

---

## Business Logic Rules

### Stock Management
```
availableQty = totalQty - reservedQty
- When order APPROVED → reservedQty += ordered quantity
- When order COMPLETED/DELIVERED confirmed → totalQty -= ordered quantity, reservedQty -= ordered quantity
- When order CANCELLED/REJECTED → reservedQty -= ordered quantity (revert)
- Use Firestore transactions for all stock operations (atomic)
- Never allow availableQty to go negative — validate before approving
```

### Order Lifecycle
```
REQUESTED
  → APPROVED (distributor approves) → reservedQty increases
  → REJECTED (distributor rejects) → stock unchanged
APPROVED
  → PAYMENT_CONFIRMED (distributor marks payment received)
  → CANCELLED → stock reverts
PAYMENT_CONFIRMED
  → OUT_FOR_DELIVERY
  → CANCELLED → stock reverts
OUT_FOR_DELIVERY
  → DELIVERED (distributor clicks "Confirm delivery") → stock permanently deducted
  → CANCELLED → stock reverts
DELIVERED
  → COMPLETED (final state)
```

### Shopkeeper–Distributor Link
```
- Shopkeeper sends request → status: pending
- Distributor approves → status: approved → shopkeeper can now see stock
  AND distributor can now see shopkeeper's stock (bidirectional, see above)
- Distributor can also invite shopkeeper directly → status: approved
- Distributor can block → status: blocked → both sides lose stock visibility
- One shopkeeper can be linked to multiple distributors
- One distributor can have unlimited shopkeepers
```

### Verification Flow
```
- Shopkeeper registers → submits shop photo + business card → verificationStatus: pending
- Admin reviews → approves or rejects with reason
- Approved shopkeepers can request to link with distributors
- Rejected shopkeepers notified with reason → can resubmit
```

### Subscription Rules
```
Plans:
  dist_monthly:  Rs. 2,500/month
  dist_yearly:   Rs. 25,000/year (save 17%)
  shop_monthly:  Rs. 500/month
  shop_yearly:   Rs. 5,000/year (save 17%)

- Distributors cannot manage stock without active subscription
- Shopkeepers cannot place orders without active subscription
- Expired subscription → account suspended automatically (Cloud Function)
- Price changes only affect new subscriptions
- Admin can manually extend any subscription
```

---

## Admin Portal — Pages Built

| Page | Route | Status |
|---|---|---|
| Dashboard | /admin | ✅ Designed |
| Distributors | /admin/distributors | ✅ Designed |
| Shopkeepers | /admin/shopkeepers | ✅ Designed |
| Orders | /admin/orders | ✅ Designed |
| Brands & Colors | /admin/brands | ✅ Designed |
| Subscriptions | /admin/subscriptions | ✅ Designed |
| Verifications | /admin/verifications | ✅ Designed |
| Analytics | /admin/analytics | 🔲 Pending |
| Settings | /admin/settings | 🔲 Pending |
| Payments | /admin/payments | 🔲 Pending |

---

## Distributor Portal (Web) — Pages To Build

| Page | Route | Status |
|---|---|---|
| Dashboard | /distributor | ✅ Designed |
| Stock Management | /distributor/stock | ✅ Designed |
| Orders | /distributor/orders | 🔲 Pending |
| Shopkeepers | /distributor/shopkeepers | 🔲 Pending |
| Shopkeeper Stock View — NEW | /distributor/shopkeepers/:id/stock | 🔲 Pending |
| Reports | /distributor/reports | 🔲 Pending |
| Profile / Settings | /distributor/settings | 🔲 Pending |

---

## Shopkeeper Web — Pages To Build (NEW)

| Page | Route | Status |
|---|---|---|
| My Stock (list) | /shop/stock | 🔲 Pending |
| Add/Edit Stock Item | /shop/stock/add | 🔲 Pending |

> Scope confirmed so far: stock management only. Expand this table if shopkeeper web grows beyond that.

---

## Shopkeeper Mobile — Screens Built

See `SHOPKEEPER_FLUTTER_SPEC.md` for full implementation detail. All screens ✅ built (Flutter, mock data, no Firebase wiring yet).

---

## Distributor Mobile — Screens To Build

See `DISTRIBUTOR_FLUTTER_SPEC.md` for implementation spec.

| Screen | Status |
|---|---|
| Dashboard overview | 🔲 Pending |
| Stock management (full CRUD, not just quick-view) | 🔲 Pending |
| Incoming order notifications | 🔲 Pending |
| Order approve/reject | 🔲 Pending |
| Shopkeeper requests (approve/block) | 🔲 Pending |
| Shopkeeper stock view — NEW | 🔲 Pending |
| Profile / Settings | 🔲 Pending |

---

## Folder Structure

```
easystock/
├── CLAUDE.md                     ← This file
├── SHOPKEEPER_FLUTTER_SPEC.md    ← Shopkeeper mobile implementation spec
├── DISTRIBUTOR_FLUTTER_SPEC.md   ← Distributor mobile implementation spec (NEW)
│
├── easystock-web/                ← React JS (Admin + Distributor + Shopkeeper Web)
│   ├── src/
│   │   ├── pages/
│   │   │   ├── admin/
│   │   │   │   ├── Dashboard.jsx
│   │   │   │   ├── Distributors.jsx
│   │   │   │   ├── Shopkeepers.jsx
│   │   │   │   ├── Orders.jsx
│   │   │   │   ├── Brands.jsx
│   │   │   │   ├── Subscriptions.jsx
│   │   │   │   └── Verifications.jsx
│   │   │   ├── distributor/
│   │   │   │   ├── Dashboard.jsx
│   │   │   │   ├── Stock.jsx
│   │   │   │   ├── Orders.jsx
│   │   │   │   ├── Shopkeepers.jsx
│   │   │   │   ├── ShopkeeperStockView.jsx   ← NEW
│   │   │   │   └── Reports.jsx
│   │   │   ├── shopkeeper/                    ← NEW
│   │   │   │   ├── MyStock.jsx
│   │   │   │   └── AddStockItem.jsx
│   │   │   └── auth/
│   │   │       └── Login.jsx
│   │   ├── components/
│   │   │   ├── layout/
│   │   │   │   ├── Sidebar.jsx
│   │   │   │   ├── Topbar.jsx
│   │   │   │   └── AdminLayout.jsx
│   │   │   ├── shared/
│   │   │   │   ├── StatCard.jsx
│   │   │   │   ├── StatusPill.jsx
│   │   │   │   ├── Drawer.jsx
│   │   │   │   ├── DataTable.jsx
│   │   │   │   └── ColorSwatch.jsx
│   │   │   └── charts/
│   │   │       └── BarChart.jsx
│   │   ├── firebase/
│   │   │   ├── config.js
│   │   │   ├── auth.js
│   │   │   ├── firestore.js
│   │   │   └── storage.js
│   │   ├── hooks/
│   │   │   ├── useAuth.js
│   │   │   └── useRole.js
│   │   ├── context/
│   │   │   └── AuthContext.jsx
│   │   ├── utils/
│   │   │   └── stockUtils.js
│   │   ├── constants/
│   │   │   └── design.js          ← Color tokens, spacing
│   │   └── App.jsx
│   ├── tailwind.config.js
│   └── package.json
│
└── easystock-mobile/             ← Flutter (Distributor + Shopkeeper)
    ├── lib/
    │   ├── main.dart
    │   ├── firebase_options.dart
    │   ├── screens/
    │   │   ├── auth/
    │   │   ├── shopkeeper/
    │   │   └── distributor/
    │   ├── widgets/
    │   │   ├── color_swatch.dart
    │   │   ├── order_card.dart
    │   │   └── stock_card.dart
    │   ├── models/
    │   │   ├── order.dart
    │   │   ├── stock.dart
    │   │   └── user.dart
    │   ├── services/
    │   │   ├── auth_service.dart
    │   │   ├── stock_service.dart
    │   │   └── order_service.dart
    │   ├── providers/
    │   └── constants/
    │       └── theme.dart         ← Colors, typography
    └── pubspec.yaml
```

---

## Firebase Security Rules (Key Points)

```
- Admin: read/write all collections
- Distributor: read/write own stock, read own orders, manage own shopkeepers,
  read shopkeeper_stock ONLY for shopkeepers with an approved link
- Shopkeeper: read stock of approved distributors only, create own orders,
  read/write own shopkeeper_stock
- No user can read another user's private data
- Stock writes must go through Cloud Functions (for atomic transactions)
- Verification documents readable only by uploader + admin
```

---

## Key Constraints & Notes

1. **Stock atomicity** — always use Firestore batch writes or transactions for stock changes. Never update stock and order status in separate writes.
2. **Pakistan market** — prices in PKR (Rs.), phone numbers in 03XX-XXXXXXX format, cities: Lahore, Karachi, Islamabad, Faisalabad, Multan, Rawalpindi, Peshawar, Sialkot, Quetta.
3. **Offline payment** — never build payment gateway for orders. Payment is hand-to-hand. Only subscriptions need a payment gateway.
4. **Color codes** — paint colors have brand-defined codes (e.g. Brighto "2056 Royal Blue"). Hex values are approximate swatches for UI display only.
5. **Language** — English only for now. No Urdu support in v1.
6. **Real-time stock** — shopkeepers must see live stock. Use Firestore onSnapshot, not one-time reads.
7. **Role-based routing** — after login, redirect based on role: admin → /admin, distributor → /distributor (or mobile), shopkeeper → Flutter app or /shop (web, stock only).
8. **Subscription gate** — check subscriptionStatus on every protected route. Expired → redirect to renewal page.
9. **shopkeeper_stock is informational, not transactional** — no price, no reservation logic. Don't reuse the full `/stock` schema/business rules for it.
10. **Reverse ordering (distributor buying from shopkeeper) is unconfirmed** — don't build until client confirms.

---

## Pakistan Paint Brands (Pre-seeded Master Data)

```
1. Brighto Paints     — Pakistan's No.1 paint brand
2. Burger Paint       — Premium quality
3. ICI Dulux          — International quality
4. Master Paints      — Trusted since 1954
5. Nippon Paint       — Japanese quality (optional)
6. Berger Paints      — Well known in market
```

### Brighto Product Categories
```
Interior, Exterior, Luxury Coating, Metal Surface,
Surface Preparation, Wood Stains & Varnishes
```

### Common Sizes
```
1 Litre, 4 Litres, 16 Litres, 20 Litres (Drum)
```

---

## Subscription Plans (Pricing)

```
dist_monthly:   Rs. 2,500 / month
dist_yearly:    Rs. 25,000 / year  (save ~17%)
shop_monthly:   Rs. 500 / month
shop_yearly:    Rs. 5,000 / year   (save ~17%)
```

---

## How to Continue in a New Session

Paste this at the start of Claude Code:

```
Read CLAUDE.md and continue building EasyStock.
Current task: [describe what you want to build]
```

Example:
```
Read CLAUDE.md and continue building EasyStock.
Current task: Build the Distributor Mobile Dashboard screen
using DISTRIBUTOR_FLUTTER_SPEC.md and the design system in CLAUDE.md.
```

---

## Current Build Status

- [x] Project planning complete
- [x] Design system defined
- [x] Logo designed (Concept B — Orange E icon)
- [x] Admin portal — all 7 pages designed in Claude Chat
- [ ] Admin portal — React implementation
- [x] Distributor web portal — Dashboard + Stock Management designed
- [ ] Distributor web portal — Orders, Shopkeepers, Shopkeeper Stock View, Reports, Settings
- [ ] Shopkeeper web portal — My Stock, Add/Edit Stock (NEW)
- [ ] Distributor mobile — pending (spec written, screens not designed)
- [x] Shopkeeper mobile — all screens built (Flutter, mock data)
- [ ] Firebase setup
- [ ] Auth + role routing
- [ ] Subscription system
- [ ] Deployment

---

*Last updated: June 2026 | Developer: Ammar (Rixon Solution) | Stack: React + Flutter + Firebase*
