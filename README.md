# Pondy Connect Matrimony (பாண்டி கனெக்ட் மேட்ரிமோனி)

A premier, offline-first mobile matrimony application built with **Flutter (Dart latest stable)**, tailored specifically for the **Puducherry & surrounding Tamil Nadu regions** (Puducherry, Karaikal, Mahe, Yanam, Villupuram, Cuddalore, Chennai).

Designed with the vibrant aesthetics, animations, and smoothness of premier Tamil matrimonial apps: vivid orange (`#E2670A`) call-to-actions, emerald progress headers, bottom-sheet pickers, dynamic match teasers with real-time candidate counts, instant English/Tamil localization, 10-Porutham astrology matching engine, and direct messaging with simulated offline responses.

---

## 🌟 Key Features

### 1. Offline-First CSV Database Architecture
- **Zero Remote Backend Dependencies**: Entire database operates locally inside `<documents>/pondy_db/` using structured CSV files with atomic writes (`File.rename`) and in-memory read-caching.
- **Thread-Safe & Re-entrant Mutex**: Zone-based synchronization lock (`CsvLock`) guarantees integrity across concurrent reads and writes.
- **Seamless Repository Swappability**: Full clean architecture repository pattern (`AuthRepository`, `ProfileRepository`, `InterestRepository`, `ChatRepository`, `ShortlistRepository`, `PlanRepository`, `NotificationRepository`, `StoryRepository`, `ReportRepository`, `MasterDataRepository`). The CSV persistence layer can be swapped for Supabase/Firebase/REST with **zero UI changes**.
- **Realistic Seed Engine**: Pre-seeded with **620 synthetic profiles** reflecting authentic Puducherry demographics (religions, denominations, native Tamil castes, Nakshatras, professions, and landmarks).

### 2. 5-Step Registration Funnel & Onboarding
- **Step 0**: Profile creator selection ("Myself", "Son", "Daughter", "Brother", "Sister", "Friend", "Relative") with dynamic field label prefixes (`Son's Date of Birth`), mobile entry & OTP simulation.
- **Step 1 — Personal Details**: Strict legal marriage age validation (21+ for males, 18+ for females), formatted date picker, height picker, physical and marital status.
- **Step 2 — Religion & Astrology**: Progressive cascading pickers for Religion, Christian/Muslim denominations, Tamil castes ("Don't wish to specify" option), 27 Nakshatras, 12 Rasis, and Doshams (Sevvai Dosham, Rahu-Ketu, etc.).
- **Step 3 — Location**: Country, State, District, City, and active `TeaserStrip` computing **real live candidate matches** from the local CSV database.
- **Step 4 — Education & Career**: Highest education level, employment sector (Private, Govt, Business, Defence), occupation, annual income brackets.
- **Step 5 — Family & Lifestyle**: Family status/values/type, parents' occupation, sibling counts, dietary preferences (Veg, Non-Veg, Eggetarian).
- **Review & Smart Moderation**: Draft summary card with automated bio generator and smart content moderation rejecting embedded phone numbers, emails, URLs, and social handles.
- **Photo Upload & Privacy**: Primary photo selection with privacy controls (Public, Registered Members Only, Blurred on-request).
- **Completion Screen**: Celebration animation with Confetti blast, assigned Profile ID (`PC000123`), and completion gauge.

### 3. Home Dashboard & Dynamic Carousels
- **Welcome Header**: Greeting in English / Tamil ("வணக்கம்!"), user avatar with verification badge, instant `EN`/`தமிழ்` language switch, notifications bell with unread badge.
- **Profile Completeness Ring**: Visual percentage indicator with one-tap nudges to complete missing attributes.
- **Activity Stats Strip**: Real counts for Total Matches, Interests Received, Shortlisted, and 10-Porutham.
- **Membership Callout**: Gradient card promoting VIP contact access and direct chat.
- **Horizontal Carousels**:
  - *Daily Recommendations* (Scored by compatibility engine)
  - *New Matches Today* (Recent registrations)
  - *Nearby Puducherry* (Candidates within Puducherry, Karaikal, Villupuram, Cuddalore)
  - *Success Stories* (Testimonials from couples married via Pondy Connect)

### 4. Matching Engine & Scored Profile Cards
- **Multi-Factor Scoring (0–100%)**: Evaluates age proximity, height range, district/state matching, community compatibility (supporting "Caste no bar"), mother tongue, higher education alignment, and lifestyle.
- **"Why this match" Chips**: Contextual badges (e.g. `Same District`, `Age Match`, `Professional Degree`, `Matching Diet`).
- **Matches Screen**: Tabbed filtering (`All`, `New Today`, `Nearby Pondy`, `Mutual 70%+`) and sorting by Relevance, Newest, or Age.

### 5. Search Engine
- **Basic Search**: Range sliders for age & height, single-select pills for religion, district, and marital status.
- **Advanced Search**: Education, employment sector, photo-only filter.
- **Profile ID Search**: Instant search for exact or partial IDs (e.g. `PC000100`).

### 6. Profile Detail View
- **Hero Image Carousel**: Stylized photo showcase with privacy blur indicator.
- **Section Cards**: Horoscope details, Career, Family background, Lifestyle habits, Personal Bio.
- **Partner Preferences Checklist**: Side-by-side comparison ("You match 6 of 7 criteria") with green checkmarks.
- **Actions Bar**: One-tap "Send Interest", "Shortlist", "Chat", and report/block dialogue.

### 7. Interests & Shortlist
- **Interests Hub**: Received (Pending), Accepted, and Sent tabs with Accept/Decline action flows.
- **Shortlist Screen**: Bookmarked profiles with fast connect actions.

### 8. Chat & Instant Simulated Responses
- **Direct Messaging**: Clean message bubbles with timestamps and read receipts.
- **Interactive Demo Mode**: When messaging any demo profile (`is_demo == true`), the app automatically schedules and delivers a realistic contextual reply after 2–4 seconds!

### 9. Membership & Mock Payments
- **Plan Tiers**: Free, Gold (₹2,499), Diamond (₹4,499), Platinum (₹7,999).
- **Mock Checkout**: Seamless payment modal supporting simulated UPI, Credit/Debit Cards, and Net Banking with immediate plan upgrade.

### 10. 10-Porutham Astrological Compatibility Engine
- Authentic South Indian Tamil horoscope matching calculation for:
  1. **Dina Porutham** (Health & longevity)
  2. **Gana Porutham** (Temperament & mental compatibility)
  3. **Mahendra Porutham** (Progeny & wealth)
  4. **Stree Deergha Porutham** (Bride's longevity & fortune)
  5. **Yoni Porutham** (Mutual attraction & harmony)
  6. **Rasi Porutham** (Family lineage & cordiality)
  7. **Rasi Adhipathi Porutham** (Planetary lord friendship)
  8. **Vasya Porutham** (Magnetic affection)
  9. **Rajju Porutham** (Mangalya longevity — strict avoidance of same Rajju)
  10. **Vedha Porutham** (Affliction avoidance)
  + **Sevvai Dosham (Kuja Dosham)** compatibility check.

### 11. Security, Settings & Admin Console
- **Biometric App Lock**: Fingerprint or Face unlock powered by `local_auth`.
- **Photo Privacy**: Control who can see your photos (Public, Members only, Blurred).
- **Hidden Admin Console**: Tap the Pondy Connect logo **7 times** from the login screen or navigate via Profile menu to inspect live CSV row counts, export database zip archive, and reset sample data.

---

## 🏗️ Architecture & Project Structure

```
lib/
├── core/
│   ├── l10n/                 # Localization & Locale notifier (en, ta)
│   ├── router/               # GoRouter configuration with custom slide/fade transitions
│   ├── theme/                # AppColors, AppTypography, AppTheme
│   └── widgets/              # Reusable UI widgets (PondyLogo, AppButton, ProfileAvatar, etc.)
├── data/
│   ├── csv/                  # CsvStore, CsvLock, CsvSchema (18 tables)
│   └── repositories/         # Concrete offline CSV repositories & Riverpod providers
├── domain/
│   ├── horoscope/            # 10-Porutham HoroscopeEngine & Astro algorithms
│   ├── matching/             # MatchingEngine (0-100 compatibility calculator)
│   └── models/               # Domain entities (User, Profile, Message, Plan, Interest, etc.)
└── features/
    ├── admin/                # 7-tap Hidden Admin Console & CSV inspector
    ├── auth/                 # Login, Mobile Registration, OTP simulation
    ├── chat/                 # ChatList & ChatConversation with demo reply generator
    ├── home/                 # Main navigation shell, Home dashboard, Carousels
    ├── horoscope/            # 10-Porutham horoscope calculator screen
    ├── interests/            # Received, Accepted & Sent interests manager
    ├── matches/              # Scored profile cards, tabbed match views
    ├── membership/           # Plans comparison & mock payment checkout
    ├── notifications/        # In-app notifications screen
    ├── onboarding/           # Welcome slides & intro
    ├── profile/              # Profile detail, editor & account screen
    ├── registration/         # 5-step registration funnel, review & photo screens
    ├── search/               # Basic, Advanced & ID search filters
    ├── settings/             # Biometrics, Privacy, Language preferences
    └── splash/               # Splash screen with auto-login check
```

---

## 🧪 Quality Gates & Verification

- **Static Analysis**:
  ```bash
  flutter analyze
  ```
  *Result*: **0 issues found** (100% clean).

- **Unit & Integration Test Suite**:
  ```bash
  flutter test
  ```
  *Result*: **19/19 tests passed** (100% green across matching engine, horoscope porutham, registration validation, auth, CSV storage concurrency, chat and notifications).

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.24+ / 3.38+ compatible)
- Java 17 or 21 (Eclipse Adoptium OpenJDK recommended)
- Android SDK (API 34+)

### Run Locally
```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run analysis
flutter analyze

# 3. Run all tests
flutter test

# 4. Launch app in debug mode
flutter run
```

### Build APK
```bash
flutter build apk --debug
```
The compiled APK will be located at `build/app/outputs/flutter-apk/app-debug.apk`.

---

© 2026 Pondy Connect Matrimony. Crafted with pride for Puducherry & Tamil Nadu.
