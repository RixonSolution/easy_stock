# EasyStock — Shopkeeper Mobile: Flutter Implementation Spec

> Last updated: June 2026  
> Status key: ✅ Built & working · 🔄 Partially built · ⏳ Pending

---

## Changelog

| Date | What changed |
|---|---|
| Jun 2026 | User lifecycle gate fully implemented — `AuthProvider` made stateful, splash routing wired, pending screen auto-approves after 5 s, bottom nav gating added |

---

## Project overview

**Stack:** Flutter 3.9.x · Dart SDK ^3.9.2 · UI-only (no Firebase — all mock/static data)  
**Design language:** Navy/Orange, Inter font, rounded cards — see `lib/constants/theme.dart`  
**Navigation:** `go_router ^14.0.0` with `context.push / context.pop(value)` for data return  
**Android:** `compileSdk = 36` required (url_launcher_android, sqflite_android need it)

---

## 1. Packages

```yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^14.0.0
  provider: ^6.1.0
  google_fonts: ^6.2.0
  file_picker: ^8.1.2        # image picking — use FileType.custom NOT FileType.image
  path_provider: ^2.1.3      # write picked images to cache dir
  url_launcher: ^6.3.0       # WhatsApp wa.me links, tel:, mailto:
  sqflite: ^2.3.3+1
  intl: ^0.19.0
```

**Critical Android notes:**
- `android/app/build.gradle.kts` → `compileSdk = 36`
- `AndroidManifest.xml` needs `<queries>` block for WhatsApp URL scheme visibility
- Use `pickImageToCache()` helper (`lib/utils/image_picker_helper.dart`) for all image picking — uses `FileType.custom` with `allowedExtensions` to bypass `compressImage()` crash on Android 10+

---

## 2. Architecture

### Constants & theme — `lib/constants/theme.dart` ✅
All colors, radii, and typography as `const` values. Never redefine hex inline.

```
primaryNavy = #1B2B4B · accentOrange = #F97316 · lightNavy = #243A63
bgColor = #F4F6FA · surfaceWhite = #FFFFFF · borderColor = #E8EDF3
textPrimary = #1B2B4B · textSecondary = #888888 · textMuted = #AAAAAA

successText/Bg · warningText/Bg · dangerText/Bg · infoText/Bg · purpleText/Bg

cardRadius=12 · innerCardRadius=10 · buttonRadius=8 · pillRadius=6
```

### Shared widgets ✅
| Widget | File | Used in |
|---|---|---|
| `StatusPill(status)` | `widgets/status_pill.dart` | Home, Orders, Distributors, Subscription |
| `ColorSwatch` | `widgets/color_swatch.dart` | Browse Stock, Product Detail |
| `QtyStepper` | `widgets/qty_stepper.dart` | Browse Stock, Product Detail, Cart |
| `AppBottomNav` | `widgets/app_bottom_nav.dart` | All tab-root screens |
| `UploadTile` | `widgets/upload_tile.dart` | Registration |
| `DistributorAvatar` | `widgets/distributor_avatar.dart` | Home, Distributors |
| `ProfileSubHeader` | `screens/profile/profile_widgets.dart` | All profile sub-screens |
| `ProfileSaveBar` | `screens/profile/profile_widgets.dart` | Profile form screens |
| `ProfileFormCard / ProfileField` | `screens/profile/profile_widgets.dart` | Profile form screens |

### Image picker helper — `lib/utils/image_picker_helper.dart` ✅
```dart
Future<File?> pickImageToCache()
// Uses FileType.custom + allowedExtensions + withData:true
// Writes bytes to getTemporaryDirectory() — always writable on Android
```
Use this everywhere instead of calling `FilePicker.platform.pickFiles` directly.

### Routing — `lib/router/app_router.dart` ✅
```
/splash
/onboarding
/register
/register/pending
/home
/stock/:distributorId
/stock/:distributorId/product/:productId
/cart
/orders
/orders/:orderId/tracking
/payment/:orderId            ← PaymentArg via extra
/distributors
/distributors/:id
/profile
/profile/edit
/profile/shop
/profile/personal
/profile/password
/profile/subscription
/subscription/payment        ← SubscriptionPaymentArg via extra
/profile/language
/profile/faq
/profile/support
/profile/terms
```

---

## 3. User lifecycle & access gates ✅ (IMPLEMENTED)

```
[Register] → pending approval → [Admin approves] → buy subscription → [Full access]
              ↑ BLOCKED STATE                        ↑ BLOCKED STATE
```

### 3.1 States

| State | `verificationStatus` | `subscriptionStatus` | What's accessible |
|---|---|---|---|
| **Just registered** | `pending` | `none` | Profile, FAQ, Support, Terms only |
| **Approved, no plan** | `approved` | `none` | Profile + Subscription purchase screen only |
| **Active subscriber** | `approved` | `active` | Everything unlocked |
| **Subscription expired** | `approved` | `expired` | Profile + Subscription renewal only |

### 3.2 AuthProvider — `providers/auth_provider.dart` ✅

Stateful `ChangeNotifier` driving the entire lifecycle:

```dart
enum VerificationStatus { none, pending, approved, rejected }
enum SubscriptionStatus { none, active, expiring, expired }

bool get canAccess       => verificationStatus == approved && subscriptionStatus == active;
bool get isPending       => verificationStatus == pending;
bool get isApprovedNoSub => verificationStatus == approved && subscriptionStatus != active;

void setRegistered(String ref)         // called on registration submit
void simulateAdminApproval()           // demo helper — fires automatically after 5 s
void simulateSubscriptionActivated()   // demo helper — fires automatically after 7 s
```

### 3.3 Pending approval screen — `screens/register/register_pending_screen.dart` ✅

Persistent home while `verificationStatus == pending`. Key behaviours:

- **5-second auto-approve timer** starts as soon as the screen is mounted
- Shows "Reviewing your application •••" animated dot indicator during the wait
- After 5 s: `simulateAdminApproval()` fires → screen animates to "Account Approved!" via `AnimatedSwitcher`
- After 2 more seconds: `simulateSubscriptionActivated()` + `context.go('/home')`
- Contact Support button always visible
- `AppBottomNav(currentIndex: -1)` shown — Profile tab is the only unlocked tab while pending

> **Backend wiring:** remove the two `Timer` calls and drive state from real Firestore/FCM updates. All gate logic stays identical.

### 3.4 Splash routing — `screens/splash/splash_screen.dart` ✅

```dart
// After 2 s:
if (!auth.isLoggedIn)                          → /onboarding
if (auth.verificationStatus == pending)        → /register/pending  (passes referenceNumber)
if (auth.subscriptionStatus != active)         → /profile/subscription
else                                           → /home
```

### 3.5 Bottom nav gate — `widgets/app_bottom_nav.dart` ✅

- Reads `AuthProvider` via `context.watch`
- When `!auth.canAccess`: tabs 0 (Home), 1 (Orders), 2 (Distributors) are dimmed + show a small lock badge
- Tapping a locked tab opens `_LockedSheet` bottom sheet:
  - Pending state → "Account Under Review" + Contact Support CTA
  - Approved/no-sub state → "Subscription Required" + "Choose a Plan" CTA (routes to `/profile/subscription`)
- Profile tab (index 3) is always unlocked

### 3.6 Subscription screen — `screens/profile/subscription_screen.dart` ✅

- Listens to `AuthProvider` via `addListener` — when `subscriptionStatus` flips to `active`, auto-navigates to `/home`
- **Approval banner**: shown when `verificationStatus == approved && subscriptionStatus != active`
- **No Active Plan card**: shown instead of the gradient "Active Plan" banner when `_selected == null`
- Plan card buttons say **"Get Started"** (not "Upgrade/Downgrade") when no plan is active
- Billing history section hidden when no plan is active
- Payment-pending banner includes **"Demo: Admin Confirms Payment"** tile → calls `simulateSubscriptionActivated()`

### 3.7 Subscription → unlock flow ✅

```
User approved → /profile/subscription (shows "Account Approved!" banner)
→ taps plan card → /subscription/payment (account numbers + copy buttons)
→ pays via EasyPaisa/JazzCash/Bank, takes screenshot
→ taps WhatsApp card → sends screenshot to EasyStock Billing
→ taps "I've Paid" → subscription screen shows orange "Payment Pending" banner
→ Admin confirms → subscriptionStatus flips to 'active'
→ app auto-navigates to /home — full access unlocked
```

---

## 4. Screen status

### 4.1 Auth & onboarding
| Screen | File | Status |
|---|---|---|
| Splash | `screens/splash/splash_screen.dart` | ✅ Built — lifecycle routing wired |
| Onboarding | `screens/onboarding/onboarding_screen.dart` | ✅ Built |
| Registration (4 steps) | `screens/register/register_screen.dart` | ✅ Built — calls `auth.setRegistered()` on submit |
| Register pending | `screens/register/register_pending_screen.dart` | ✅ Built — persistent home, 5 s auto-approve timer |

### 4.2 Core app screens
| Screen | File | Status |
|---|---|---|
| Home dashboard | `screens/home/home_screen.dart` | ✅ Built |
| Browse stock | `screens/stock/stock_browse_screen.dart` | ✅ Built |
| Product detail | `screens/stock/product_detail_screen.dart` | ✅ Built |
| Cart / order summary | `screens/cart/` | ✅ Built |
| Order history | `screens/orders/order_history_screen.dart` | ✅ Built (5 tabs) |
| Order tracking | `screens/orders/order_tracking_screen.dart` | ✅ Built — dynamic status timeline |
| Order payment | `screens/orders/payment_details_screen.dart` | ✅ Built — real WhatsApp integration |

### 4.3 Distributors
| Screen | File | Status |
|---|---|---|
| Distributor connections | `screens/distributors/distributor_connections_screen.dart` | ✅ Built (Discover + My tabs) |
| Distributor detail | `screens/distributors/distributor_detail_screen.dart` | ✅ Built — dynamic connect request with bottom sheet |

### 4.4 Profile & settings
| Screen | File | Status |
|---|---|---|
| Profile (main) | `screens/profile/profile_screen.dart` | ✅ Built — all tiles wired |
| Edit Profile | `screens/profile/edit_profile_screen.dart` | ✅ Built — real image picker |
| Shop Details | `screens/profile/shop_details_screen.dart` | ✅ Built |
| Personal Info | `screens/profile/personal_info_screen.dart` | ✅ Built |
| Change Password | `screens/profile/change_password_screen.dart` | ✅ Built — live strength indicator |
| Subscription & Plans | `screens/profile/subscription_screen.dart` | ✅ Built — approval banner, no-plan state, auto-navigates home on activation |
| Subscription Payment | `screens/profile/subscription_payment_screen.dart` | ✅ Built — WhatsApp proof flow |
| Language | `screens/profile/language_screen.dart` | ✅ Built |
| Help & FAQ | `screens/profile/faq_screen.dart` | ✅ Built — searchable, grouped, expandable |
| Contact Support | `screens/profile/support_screen.dart` | ✅ Built — real WhatsApp + email |
| Terms & Privacy | `screens/profile/terms_screen.dart` | ✅ Built |

---

## 5. Key flows (built)

### Order payment flow ✅
```
Order status: requested → approved (distributor calls to approve)
→ [Payment Required banner on tracking screen]
→ User taps → /payment/:orderId (PaymentArg via extra)
→ Screen shows EasyPaisa/JazzCash/Bank accounts with copy buttons
→ User copies number, pays, takes screenshot
→ Taps WhatsApp card → opens wa.me URL with pre-filled message
→ Taps "I've Sent It" → context.pop(true)
→ Tracking screen: status → 'payment_submitted'
→ Distributor confirms → 'payment_confirmed' → 'out_for_delivery' → 'completed'
```

### Subscription payment flow ✅
```
User on /profile/subscription → taps a plan card
→ /subscription/payment (SubscriptionPaymentArg via extra)
→ Same payment screen layout — EasyStock bank accounts
→ WhatsApp card opens EasyStock Billing chat
→ "I've Paid" → context.pop(true)
→ Subscription screen: shows orange "Payment Pending" banner + plan card badge
→ Admin confirms → subscriptionStatus flips to 'active'
```

### Distributor connect flow ✅
```
Discover tab → tap distributor → detail screen
→ "Send Connect Request" button → _ConnectSheet bottom sheet
→ Shows distributor info + "What happens next" checklist
→ Confirm → optimistic setState(_linkStatus = 'requested') + SnackBar
→ Header status pill animates to 'Requested'
```

### Profile image picker flow ✅
```
Edit Profile → tap avatar → _SourceSheet bottom sheet (Gallery / Camera tiles)
→ pickImageToCache() — FileType.custom, withData:true, writes to temp dir
→ Avatar updates: Image.file() replacing initials "AS"
→ Camera badge shows spinner during pick, returns to camera icon after
→ Caption: "Photo selected — tap to change" (green)
```

---

## 6. What's left to build

### Priority 1 — Backend wiring (when ready)
Replace the two demo timers in `register_pending_screen.dart` with real push/Firestore listeners:

```dart
// Remove these lines from _RegisterPendingScreenState.initState():
_approvalTimer = Timer(const Duration(seconds: 5), _onAutoApprove);

// Replace with a Firestore/FCM listener that calls:
auth.simulateAdminApproval();           // rename to setApproved()
auth.simulateSubscriptionActivated();   // rename to setSubscriptionActive()
```

Subscription payment confirmation also needs a real Firestore listener in `subscription_screen.dart` (`_onAuthChanged` is already wired — just need the backend to flip the flag).

### Priority 2 — Minor polish ⏳
- Pull-to-refresh on Order History and Distributor list
- Loading skeleton on Home stat cards
- Push notification toggle (currently a static Switch) — wire to local notification settings
- Deep link handling for order status updates
- `_AccessLockedView` widget for gated screens reached via deep link (currently handled by splash routing)

---

## 7. File structure

```
lib/
├── constants/
│   └── theme.dart
├── router/
│   └── app_router.dart
├── utils/
│   └── image_picker_helper.dart        ← use for ALL image picking
├── widgets/                             ← shared widgets
│   ├── app_bottom_nav.dart
│   ├── status_pill.dart
│   ├── color_swatch.dart
│   ├── qty_stepper.dart
│   └── distributor_avatar.dart
└── screens/
    ├── splash/
    ├── onboarding/
    ├── register/
    │   ├── register_screen.dart
    │   └── register_pending_screen.dart
    ├── home/
    ├── stock/
    ├── cart/
    ├── orders/
    │   ├── order_history_screen.dart
    │   ├── order_tracking_screen.dart
    │   └── payment_details_screen.dart  ← PaymentArg class lives here
    ├── distributors/
    │   ├── distributor_connections_screen.dart
    │   └── distributor_detail_screen.dart
    └── profile/
        ├── profile_widgets.dart         ← ProfileSubHeader, ProfileSaveBar, ProfileFormCard, ProfileField
        ├── profile_screen.dart
        ├── edit_profile_screen.dart
        ├── shop_details_screen.dart
        ├── personal_info_screen.dart
        ├── change_password_screen.dart
        ├── subscription_screen.dart
        ├── subscription_payment_screen.dart  ← SubscriptionPaymentArg class lives here
        ├── language_screen.dart
        ├── faq_screen.dart
        ├── support_screen.dart
        └── terms_screen.dart
```

---

## 8. Gotchas & decisions made

| Issue | Decision |
|---|---|
| `FileType.image` crashes Android 10+ | Use `FileType.custom` with `allowedExtensions` via `pickImageToCache()` helper |
| `compileSdk` must be 36 | `url_launcher_android`, `sqflite_android`, `flutter_plugin_android_lifecycle` all require it |
| WhatsApp URL scheme visibility | `<queries>` block in `AndroidManifest.xml` with `wa.me` and `whatsapp://` schemes |
| Private Dart classes (`_Name`) can't be imported across files | Profile shared widgets live in `profile_widgets.dart` as public classes |
| `context` use after `await` | Capture `ScaffoldMessenger.of(context)` before async call; check `mounted` after |
| `DropdownButtonFormField.value` deprecated in Flutter 3.33+ | Use `initialValue` for static defaults; `value` still needed for stateful dropdowns |
| `BuildContext` async gap lint | Capture messenger/navigator before `await`, check `mounted` after, use captured ref |
| WhatsApp phone normalisation | Strip non-digits, replace leading `0` with `92` for Pakistan numbers |
