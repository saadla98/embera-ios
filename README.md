# EMBERA
```
  ____  __  __  ____  ____   ___
 | __ )|  \/  |/ ___||  _ \ / _ \
 |  _ \| |\/| | |  _ | |_) | | | |
 | |_) | |  | | |_| ||  _ <| |_| |
 |____/|_|  |_|\____||_| \_\\___/
```

EMBERA is a premium iOS coffee experience with 2026-level Apple craft:
dark, warm, cinematic, motion-led, and performance-first.

This README explains the project from A to Z: structure, architecture,
flows, backend, hardest parts, and setup steps.

---

## 1) Vision (Product DNA)
EMBERA is a ritual engine. Not a "shop", but a calm cinematic journey:

- Emotional onboarding with motion.
- Immersive home and ambient depth.
- Cinematic browsing and deep customization.
- Bottom-sheet cart with Apple Pay.
- Live order tracking (Live Activities).
- Rewards, loyalty, and store discovery.

Design language:
dark surfaces, soft highlights, elegant typography, glass layers,
and motion as communication (not decoration).

---

## 2) Tech Stack
- Swift 6+
- SwiftUI
- MVVM + Clean Architecture
- async/await
- SwiftData
- Firebase (Auth + Firestore + Functions)
- Apple Pay
- Passkeys + Face ID
- MapKit
- Live Activities
- Widgets
- Core Haptics
- Full Accessibility
- Dark Mode first

---

## 3) Architecture Overview
Clean Architecture + MVVM:

1) Domain (pure logic)
   - Models, repository protocols, use cases.
2) Data (infrastructure)
   - SwiftData repositories, Firebase repositories, payments.
3) Features (UI + ViewModels)
   - SwiftUI views and their view models.
4) Core (cross-cutting)
   - Design system, motion, components, security, widgets, live activity.
5) App
   - DI container + routing.

This separation keeps UI clean and lets backend change without touching UI.

---

## 4) Project Structure
```
EMBERA/
  App/                     App entry + routing + DI
  Core/                    Design system, motion, security, widgets
  Data/                    Repositories, storage, payments, seeds
  Domain/                  Models, use cases, repository protocols
  Features/                SwiftUI screens + view models
  Extensions/              Widget + Live Activity targets
  Backend/Firebase/        Cloud Functions + Firestore rules
```

---

## 5) App Flow (From A to Z)
1) Onboarding
2) Passkey auth (create or sign-in)
3) Home (hero + featured + browse shortcut)
4) Browse + product detail customization
5) Cart bottom sheet
6) Apple Pay checkout
7) Rewards (tiers + offers)
8) Live order tracking (timeline + Live Activity)
9) Store locator (MapKit)

---

## 6) Data Flow (Local + Remote)
Local-first by design:
- SwiftData stores cart, orders, loyalty.
- Remote Firebase sync is best-effort (never blocks checkout).

Remote is enabled when Firebase SDKs are present:
- `RemoteAuthRepository` (Functions + FirebaseAuth)
- `FirebaseOrderRepository` (per-user orders)
- `FirebaseLoyaltyRepository` (per-user loyalty)

Offline still works because local storage is always used.

---

## 7) Design System (UI that feels "next-year")
Core styles in `EMBERA/Core/DesignSystem/`:
- `EmberaColors`, `EmberaTypography`, `EmberaTheme`, `EmberaSpacing`

Core components in `EMBERA/Core/Components/`:
- GlassCard, EmberaPrimaryButton, chips, steppers, search field, etc.

Motion in `EMBERA/Core/Motion/`:
- `EmberaMotion` (spring + ease curves)
- parallax headers + coverflow

The "sci-fi" feel is in the layering:
glass surfaces + ambient gradient + slow motion + haptics.

---

## 8) The Hard Parts (What + Why)

### A) Passkeys end-to-end (iOS + backend)
Files:
- `EMBERA/Core/Security/PasskeyService.swift`
- `EMBERA/Core/Network/AuthAPIClient.swift`
- `EMBERA/Data/Repositories/RemoteAuthRepository.swift`
- `EMBERA/Backend/Firebase/functions/src/index.ts`

Why hard:
- Passkeys need server-generated challenges and verification.
Solution:
- Functions generate challenges and verify with `@simplewebauthn/server`.
- iOS performs the ceremony via `AuthenticationServices`.
- Server returns Firebase custom token for auth session.

### B) Live Activities + Widgets bridge
Files:
- `EMBERA/Core/LiveActivity/OrderLiveActivityManager.swift`
- `EMBERA/Core/Widgets/WidgetDataStore.swift`
- `EMBERA/Extensions/EmberaWidgets/`

Why hard:
- Widgets/Live Activities run in separate processes and targets.
Solution:
- App Group storage `group.com.embera` shares snapshots.

### C) Order tracking timeline
Files:
- `EMBERA/Features/Orders/OrderStatusTimeline.swift`
- `EMBERA/Features/Orders/OrdersViewModel.swift`

Why hard:
- Needs realistic progress without server updates.
Solution:
- Deterministic timeline based on createdAt + ETA.

### D) Local-first + remote sync
Files:
- `EMBERA/Data/Repositories/CompositeOrderRepository.swift`

Why hard:
- Network failures should never block checkout.
Solution:
- Save locally first; remote save best-effort.

---

## 9) Backend (Firebase) Overview
Backend lives in `EMBERA/Backend/Firebase`.
It provides:
- Passkey registration + sign-in with WebAuthn verification.
- Firebase Auth custom token generation.
- Firestore data for loyalty and orders.

Files:
- `functions/src/index.ts` (Cloud Functions)
- `firestore.rules` (security rules)
- `firestore.indexes.json` (indexes)

Full backend setup steps are in:
`EMBERA/Backend/Firebase/README.md`

---

## 10) Setup From A to Z (Mac + Xcode)

### 10.1 Prerequisites
- Xcode 15+ (Swift 6)
- iOS 17+ device
- Firebase project
- Associated Domain (for passkeys)
- Apple Pay merchant ID

### 10.2 Add Firebase SDKs (SPM)
Add via Swift Package Manager:
- FirebaseAuth
- FirebaseFirestore
- FirebaseFunctions
- FirebaseCore

Add `GoogleService-Info.plist` to app target.

### 10.3 Configure Firebase backend
From `EMBERA/Backend/Firebase`:
```
firebase login
firebase use <project-id>
firebase functions:config:set embera.rp_id="embera.coffee" embera.origin="https://embera.coffee" embera.rp_name="EMBERA"
firebase deploy --only functions,firestore:rules,firestore:indexes
```

### 10.4 Capabilities (Xcode)
Add to app target:
- Associated Domains: `webcredentials:embera.coffee`
- Apple Pay: `merchant.com.embera.coffee`
- App Groups: `group.com.embera`
- Live Activities

### 10.5 AASA file (Passkeys requirement)
Host `/.well-known/apple-app-site-association` at your domain,
and include your Team ID + bundle ID in `webcredentials.apps`.

### 10.6 Widget + Live Activity Targets
Make sure widget files in `EMBERA/Extensions/EmberaWidgets/`
are assigned to a Widget Extension target in Xcode.

### 10.7 Run
Build on device (not simulator) to test:
- Passkeys
- Apple Pay
- Live Activities

---

## 11) Key IDs and Places to Update
- Apple Pay merchant ID:
  `EMBERA/App/AppContainer.swift`
  default = `merchant.com.embera.coffee`
- App Group:
  `EMBERA/Core/Widgets/WidgetDataStore.swift`
  default = `group.com.embera`
- Relying Party ID (passkeys):
  `EMBERA/Data/Repositories/LocalAuthRepository.swift`
  default = `embera.coffee`
- Firebase config:
  `GoogleService-Info.plist`

---

## 12) Important UI Files (Where the magic is)
- Home: `EMBERA/Features/Home/HomeView.swift`
- Browse: `EMBERA/Features/Catalog/CatalogView.swift`
- Detail: `EMBERA/Features/ProductDetail/ProductDetailView.swift`
- Cart: `EMBERA/Features/Cart/CartView.swift`
- Rewards: `EMBERA/Features/Rewards/RewardsView.swift`
- Tracking: `EMBERA/Features/Orders/OrderTrackingView.swift`
- Stores: `EMBERA/Features/Stores/StoresView.swift`
- Onboarding: `EMBERA/Features/Onboarding/OnboardingView.swift`

---

## 13) Testing Notes
Because the app is UI-heavy:
- Test onboarding and auth flow on device.
- Verify Apple Pay in Sandbox.
- Trigger order tracking to confirm Live Activity.
- Validate widgets after an order is placed.
- Check rewards updates after checkout.

---

## 14) Troubleshooting
- Passkeys not showing:
  - Check Associated Domains + AASA file.
  - Make sure rp_id and origin are correct in Functions config.
- Apple Pay not available:
  - Check merchant ID + entitlements.
  - Use a real device.
- Widgets not updating:
  - Confirm App Group ID matches.
  - Ensure widget target is set.
- Firebase errors:
  - Confirm SDKs are added via SPM and
    `GoogleService-Info.plist` is in target.

---

## 15) Why These Choices Matter
EMBERA is designed to feel premium and effortless:
local-first persistence avoids friction,
passkeys remove password pain,
motion leads the eye,
and Live Activities keep the ritual alive beyond the app.

---

If you want a specific deep dive (code walkthrough or UI refinement),
tell me which section and I will expand it further.

---

## 16) App State and Routing (How the app decides what to show)
Core routing lives in `EMBERA/App/RootView.swift`:

Order of gates:
1) Onboarding (first launch)
2) Passkey auth (no session)
3) Biometric lock (session locked)
4) Main app tabs

State lives in:
- `EMBERA/App/AppState.swift`
  - `hasCompletedOnboarding`
  - `selectedTab`
  - `isCartPresented`
  - `userDisplayName`

This keeps flows deterministic and avoids navigation bugs.

---

## 17) Dependency Injection (Why AppContainer exists)
`EMBERA/App/AppContainer.swift` constructs all repositories and view models:

- Local repositories use SwiftData.
- Remote repositories use Firebase when SDKs are available.
- Feature view models are created once and reused.

This avoids hidden dependencies and makes the app predictable.

---

## 18) Domain Models (Data Schemas)
Key models and where they live:

- `Product` (name, price, tone, tasting notes)
  `EMBERA/Domain/Models/Product.swift`
- `CartItem` (product + grind + bag + brew + quantity)
  `EMBERA/Domain/Models/CartItem.swift`
- `CartSummary` (subtotal, shipping, tax)
  `EMBERA/Domain/Models/CartSummary.swift`
- `Order` (items, summary, status, createdAt, ETA)
  `EMBERA/Domain/Models/Order.swift`
- `LoyaltyAccount` (points, tier, visits, memberSince)
  `EMBERA/Domain/Models/LoyaltyAccount.swift`
- `RewardOffer` (title, pointsCost, highlight)
  `EMBERA/Domain/Models/RewardOffer.swift`
- `StoreLocation` (address, coordinates, hours)
  `EMBERA/Domain/Models/StoreLocation.swift`

---

## 19) Checkout Pipeline (Step by Step)
Flow (files in parentheses):

1) Cart summary built (`PaymentSummaryBuilder`)
2) Apple Pay authorization (`ApplePayService`)
3) Order created (`Order`)
4) Persist order locally (`LocalOrderRepository`)
5) Remote order sync (best-effort)
6) Loyalty update (`ApplyOrderLoyaltyUseCase`)
7) Live Activity started (`OrderLiveActivityManager`)
8) Widgets snapshot saved (`WidgetDataStore`)

This flow guarantees checkout success even if network is down.

---

## 20) Rewards Logic (Points and Tiers)
Points engine:
- `LoyaltyEngine.points(for:)` = `subtotal * 10`

Tier thresholds:
- Ember: 0
- Aura: 500
- Halo: 1200

Files:
- `EMBERA/Domain/Services/LoyaltyEngine.swift`
- `EMBERA/Domain/Models/RewardTier.swift`

---

## 21) Order Tracking Logic (Timeline)
Orders are tracked using a deterministic timeline:
- Processing: 15 min
- Roasting: 45 min
- Shipping: rest of ETA window

File: `EMBERA/Features/Orders/OrderStatusTimeline.swift`

This gives a realistic Live Activity without backend events.

---

## 22) Passkey Backend Contract (Firebase Functions)
Functions are callable endpoints:

- `registerBegin`
  - request: `displayName`
  - response: `uid`, `challenge`, `userID`, `rpID`, `rpName`
- `registerFinish`
  - request: `uid`, `credential`
  - response: `uid`, `displayName`, `memberSince`, `customToken`
- `signInBegin`
  - request: none
  - response: `challengeID`, `challenge`, `rpID`
- `signInFinish`
  - request: `challengeID`, `credential`
  - response: `uid`, `displayName`, `memberSince`, `customToken`

Functions live in `EMBERA/Backend/Firebase/functions/src/index.ts`.

---

## 23) Firestore Data Model (Server Side)
Collections:

- `users/{uid}`
  - `displayName`
  - `webauthnUserID`
  - `points`, `visits`, `tier`
  - `memberSince`, `lastUpdated`
  - `currentChallenge` (temporary)

- `users/{uid}/credentials/{credentialID}`
  - `credentialID`
  - `publicKey`
  - `counter`
  - `createdAt`, `lastUsedAt`

- `orders/{orderId}`
  - `id`, `orderData`, `createdAt`, `status`, `userID`

- `webauthnChallenges/{challengeId}`
  - `challenge`, `createdAt`

Rules live in `EMBERA/Backend/Firebase/firestore.rules`.

---

## 24) Security and Privacy (Critical Notes)
- Passkeys require a trusted domain + AASA file.
- Firestore rules restrict access by `request.auth.uid`.
- Custom tokens are generated server-side only.
- Keychain stores session locally.

Never ship without:
- Associated Domains configured
- AASA file live
- Firestore rules deployed

---

## 25) Performance and Smoothness
Performance tactics used:
- `LazyVStack` for long lists.
- `TimelineView` updates only when needed.
- Lightweight models with `Codable`.
- Local-first data access to avoid blocking UI.

If performance dips:
- Reduce heavy gradients inside scrolling views.
- Avoid nested scrolls unless necessary.

---

## 26) Accessibility Checklist
Current coverage:
- Labels and hints on key controls.
- VoiceOver-friendly card groupings.

Before release:
- Audit contrast on glass surfaces.
- Test with Larger Text and Reduce Motion.
- Add accessibility values to sliders and toggles.

---

## 27) Motion and Haptics Spec
Motion:
- Spring response: `EmberaMotion.spring`
- Shared transitions: `matchedGeometryEffect` in onboarding

Haptics:
- Selection changes on key taps.
- Soft transient feedback for rewards.

Files:
- `EMBERA/Core/Motion/EmberaMotion.swift`
- `EMBERA/Core/Motion/HapticEngine.swift`

---

## 28) Build Variants (Local vs Remote)
The app adapts based on SDK availability:

- If FirebaseAuth + Functions exist -> remote passkey auth.
- If FirebaseFirestore exists -> remote orders + loyalty.
- Otherwise -> local-only data.

This keeps the app usable in all environments.

---

## 29) Seed Data (Demo Mode)
Seed data is defined in:
- `EMBERA/Data/Seed/SeedProducts.swift`
- `EMBERA/Data/Seed/SeedStores.swift`

These give the app rich content without a backend.

---

## 30) Release Checklist (Do not skip)
- Firebase SDKs added and configured
- Functions deployed + rules + indexes
- AASA file live
- Apple Pay merchant ID verified
- Widget target configured
- App Group ID matches code
- Real device testing completed

---

## 31) Architecture Diagram (ASCII)
```
   [SwiftUI Views]
          |
      [ViewModels]  <---- AppState, EnvironmentObjects
          |
      [Use Cases]   (Domain)
          |
    [Repositories]  (Protocols)
        /   \
  [SwiftData] [Firebase]
   (Local)     (Remote)
        \       /
      [Composite Repos]
          |
   [Core Services]
 (Apple Pay / Passkeys / Haptics / Widgets / Live Activity)
```

---

## 32) Full File Map (Every File)
```
EMBERA/README.md
EMBERA/App/EMBERAApp.swift
EMBERA/App/AppContainer.swift
EMBERA/App/AppState.swift
EMBERA/App/MainTabView.swift
EMBERA/App/RootView.swift

EMBERA/Core/Components/AmbientBackground.swift
EMBERA/Core/Components/ApplePayButton.swift
EMBERA/Core/Components/CartFloatingButton.swift
EMBERA/Core/Components/EmberaButton.swift
EMBERA/Core/Components/EmberaSearchField.swift
EMBERA/Core/Components/GlassCard.swift
EMBERA/Core/Components/OptionCard.swift
EMBERA/Core/Components/OptionChip.swift
EMBERA/Core/Components/QuantityStepper.swift
EMBERA/Core/Components/TastingNoteChip.swift

EMBERA/Core/DesignSystem/EmberaColors.swift
EMBERA/Core/DesignSystem/EmberaSpacing.swift
EMBERA/Core/DesignSystem/EmberaTheme.swift
EMBERA/Core/DesignSystem/EmberaTypography.swift
EMBERA/Core/DesignSystem/ProductTone+Palette.swift

EMBERA/Core/LiveActivity/OrderActivityAttributes.swift
EMBERA/Core/LiveActivity/OrderLiveActivityManager.swift

EMBERA/Core/Motion/CoverflowCarousel.swift
EMBERA/Core/Motion/EmberaMotion.swift
EMBERA/Core/Motion/HapticEngine.swift
EMBERA/Core/Motion/ParallaxHeader.swift

EMBERA/Core/Network/AuthAPIClient.swift
EMBERA/Core/Network/Base64URL.swift
EMBERA/Core/Network/FirebaseAuthService.swift

EMBERA/Core/Security/BiometricService.swift
EMBERA/Core/Security/KeychainStore.swift
EMBERA/Core/Security/PasskeyService.swift

EMBERA/Core/Utilities/EmberaCoders.swift
EMBERA/Core/Utilities/EmberaCurrency.swift

EMBERA/Core/Widgets/WidgetDataStore.swift

EMBERA/Data/Payments/ApplePayService.swift
EMBERA/Data/Remote/FirebaseBootstrap.swift
EMBERA/Data/Seed/SeedProducts.swift
EMBERA/Data/Seed/SeedStores.swift
EMBERA/Data/Storage/AppModelContainer.swift
EMBERA/Data/Storage/CartItemRecord+Domain.swift
EMBERA/Data/Storage/CartItemRecord.swift
EMBERA/Data/Storage/LoyaltyAccountRecord+Domain.swift
EMBERA/Data/Storage/LoyaltyAccountRecord.swift
EMBERA/Data/Storage/OrderRecord+Domain.swift
EMBERA/Data/Storage/OrderRecord.swift
EMBERA/Data/Storage/ProductRecord.swift

EMBERA/Data/Repositories/CartRepositoryError.swift
EMBERA/Data/Repositories/CompositeOrderRepository.swift
EMBERA/Data/Repositories/FirebaseLoyaltyRepository.swift
EMBERA/Data/Repositories/FirebaseOrderRepository.swift
EMBERA/Data/Repositories/LocalAuthRepository.swift
EMBERA/Data/Repositories/LocalCartRepository.swift
EMBERA/Data/Repositories/LocalLoyaltyRepository.swift
EMBERA/Data/Repositories/LocalOrderRepository.swift
EMBERA/Data/Repositories/LocalProductRepository.swift
EMBERA/Data/Repositories/LocalStoreRepository.swift
EMBERA/Data/Repositories/LoyaltyRepositoryError.swift
EMBERA/Data/Repositories/OrderRepositoryError.swift
EMBERA/Data/Repositories/RemoteAuthRepository.swift

EMBERA/Domain/Models/BagSize.swift
EMBERA/Domain/Models/BiometricType.swift
EMBERA/Domain/Models/BrewStyle.swift
EMBERA/Domain/Models/CartItem.swift
EMBERA/Domain/Models/CartSummary.swift
EMBERA/Domain/Models/Category.swift
EMBERA/Domain/Models/GrindSize.swift
EMBERA/Domain/Models/LoyaltyAccount.swift
EMBERA/Domain/Models/Order.swift
EMBERA/Domain/Models/OrderStatus.swift
EMBERA/Domain/Models/Product.swift
EMBERA/Domain/Models/ProductTone.swift
EMBERA/Domain/Models/RewardOffer.swift
EMBERA/Domain/Models/RewardTier.swift
EMBERA/Domain/Models/RoastLevel.swift
EMBERA/Domain/Models/StoreLocation.swift
EMBERA/Domain/Models/SubscriptionInterval.swift
EMBERA/Domain/Models/UserSession.swift

EMBERA/Domain/Repositories/AuthRepository.swift
EMBERA/Domain/Repositories/CartRepository.swift
EMBERA/Domain/Repositories/LoyaltyRepository.swift
EMBERA/Domain/Repositories/OrderRepository.swift
EMBERA/Domain/Repositories/ProductRepository.swift
EMBERA/Domain/Repositories/StoreRepository.swift

EMBERA/Domain/Services/LoyaltyEngine.swift

EMBERA/Domain/UseCases/AddToCartUseCase.swift
EMBERA/Domain/UseCases/ApplyOrderLoyaltyUseCase.swift
EMBERA/Domain/UseCases/ClearCartUseCase.swift
EMBERA/Domain/UseCases/GetBiometricLockStateUseCase.swift
EMBERA/Domain/UseCases/GetBiometricTypeUseCase.swift
EMBERA/Domain/UseCases/LoadAllProductsUseCase.swift
EMBERA/Domain/UseCases/LoadCartUseCase.swift
EMBERA/Domain/UseCases/LoadFeaturedProductsUseCase.swift
EMBERA/Domain/UseCases/LoadLoyaltyAccountUseCase.swift
EMBERA/Domain/UseCases/LoadRecentOrdersUseCase.swift
EMBERA/Domain/UseCases/LoadSessionUseCase.swift
EMBERA/Domain/UseCases/LoadStoresUseCase.swift
EMBERA/Domain/UseCases/PlaceOrderUseCase.swift
EMBERA/Domain/UseCases/RedeemRewardUseCase.swift
EMBERA/Domain/UseCases/RegisterPasskeyUseCase.swift
EMBERA/Domain/UseCases/RemoveCartItemUseCase.swift
EMBERA/Domain/UseCases/SetBiometricLockUseCase.swift
EMBERA/Domain/UseCases/SignInUseCase.swift
EMBERA/Domain/UseCases/SignOutUseCase.swift
EMBERA/Domain/UseCases/UnlockWithBiometricsUseCase.swift
EMBERA/Domain/UseCases/UpdateCartItemUseCase.swift

EMBERA/Extensions/EmberaWidgets/EmberaWidgets.swift
EMBERA/Extensions/EmberaWidgets/OrderLiveActivityWidget.swift
EMBERA/Extensions/EmberaWidgets/RewardsWidget.swift

EMBERA/Features/Auth/AuthViewModel.swift
EMBERA/Features/Auth/AuthenticationView.swift
EMBERA/Features/Auth/BiometricLockView.swift
EMBERA/Features/Cart/CartView.swift
EMBERA/Features/Cart/CartViewModel.swift
EMBERA/Features/Catalog/CatalogHeaderView.swift
EMBERA/Features/Catalog/CatalogView.swift
EMBERA/Features/Catalog/CatalogViewModel.swift
EMBERA/Features/Checkout/CheckoutViewModel.swift
EMBERA/Features/Checkout/PaymentSummaryBuilder.swift
EMBERA/Features/Home/CategoryChipsView.swift
EMBERA/Features/Home/FeaturedCarouselView.swift
EMBERA/Features/Home/HomeHeaderView.swift
EMBERA/Features/Home/HomeHeroView.swift
EMBERA/Features/Home/HomeView.swift
EMBERA/Features/Home/HomeViewModel.swift
EMBERA/Features/Home/ProductCardView.swift
EMBERA/Features/Onboarding/OnboardingView.swift
EMBERA/Features/Onboarding/OnboardingViewModel.swift
EMBERA/Features/Orders/OrderStatusTimeline.swift
EMBERA/Features/Orders/OrderTrackingView.swift
EMBERA/Features/Orders/OrdersViewModel.swift
EMBERA/Features/ProductDetail/ProductDetailView.swift
EMBERA/Features/ProductDetail/ProductDetailViewModel.swift
EMBERA/Features/Rewards/RewardsView.swift
EMBERA/Features/Rewards/RewardsViewModel.swift
EMBERA/Features/Stores/StoresView.swift
EMBERA/Features/Stores/StoresViewModel.swift

EMBERA/Backend/Firebase/README.md
EMBERA/Backend/Firebase/firebase.json
EMBERA/Backend/Firebase/firestore.indexes.json
EMBERA/Backend/Firebase/firestore.rules
EMBERA/Backend/Firebase/functions/package.json
EMBERA/Backend/Firebase/functions/tsconfig.json
EMBERA/Backend/Firebase/functions/src/index.ts
```

---

## 33) QA Test Plan (Manual + Edge Cases)
Core user journeys:
- Onboarding: swipe flow, skip, final enter.
- Passkey create: new user, cancel, retry, wrong domain.
- Passkey sign-in: existing user, cancel, retry.
- Biometric lock: background/foreground lock, unlock, sign out.
- Browse: search + filter + select product.
- Product detail: grind/bag/brew changes + subscription toggle.
- Cart: quantity edit, remove, empty state.
- Apple Pay: success, cancel, no card, not available.
- Rewards: points update after order, redeem locked/unlocked.
- Orders: new order appears, tracking timeline updates.
- Live Activity: start, update, end.
- Widgets: points snapshot + order snapshot.
- Stores: map selection + directions + call.

Edge cases:
- Offline mode: place order, view rewards, reopen app.
- Firebase auth expired: ensure session is reset.
- Widget target not enabled: app still runs.
- No biometric hardware: app still signs in.
- System time changed: tracking timeline still stable.

---

## 34) Cinematic UI Blueprint (Sci-Fi Premium)
Think "warm spacecraft cockpit":

- Background: multi-layer ambient gradient + soft noise.
- Surfaces: glass cards with subtle borders and low elevation.
- Typography: serif display for emotion, rounded body for clarity.
- Motion: slow spring reveals, parallax headers, coverflow depth.
- Haptics: gentle pulses for reward confirmations.

The UI is designed to feel like a ritual, not a shopping flow.

---

## 35) Developer Playbook (How to Extend)

Add a new screen:
1) Create view in `EMBERA/Features/<FeatureName>/`.
2) Create ViewModel with use cases.
3) Inject ViewModel in `AppContainer`.
4) Route in `MainTabView` or via `NavigationStack`.

Add a new data source:
1) Define repository protocol in `Domain/Repositories`.
2) Implement local and remote repos in `Data/Repositories`.
3) Inject into use cases.

Add a new reward offer:
1) Update `RewardOffer.catalog` in `Domain/Models/RewardOffer.swift`.

---

## 36) Stability Rules (Non-Negotiable)
- Checkout must never fail because of network.
- Passkey auth must work without password fallback.
- UI must stay responsive at 120Hz.
- Live Activity must end when order is delivered.
- Widget updates must be lightweight.
