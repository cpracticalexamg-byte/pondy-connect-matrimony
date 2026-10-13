# Pondy Connect Matrimony — V3 Feature Upgrade Changelog

## Overview
**Pondy Connect Matrimony V3** is a comprehensive feature upgrade modelled on leading South Indian matrimony platforms while maintaining 100% original Pondy Connect branding, privacy-first engineering, and zero fake statistics.

---

## Key Features & Architecture Additions

### 1. App Shell & Bottom Navigation (§1)
- **5 Animated Navigation Tabs:** Home, Matches, Interests, Messages, Upgrade (green crown icon when active, dynamic unread badge dots).
- **Sticky Glassy Light-Green Gradient Header:**
  - Row 1: Segmented pill **Regular | PRIME** (red dot indicator for newly verified profiles), compact **அ / A** language toggle button, Search icon.
  - Row 2: Circular avatar with camera upload badge, user name, membership status chip (Free Member / Gold / Prime Gold / Prime – Till U Marry), Upgrade chip, notifications bell with count badge, and hamburger drawer.
- **Shared-Axis Animation:** Smooth horizontal sliding transition between Regular and PRIME modes with preserved scroll state.

### 2. Daily Recommendations Modal & Engine (§2)
- **Engine (`domain/recommendations`):** Up to 8 deterministic profiles per calendar day per member. Enforces hard filters (opposite gender, active, not blocked, not hidden, no recent recommendations in 14 days, partner preference age/religion limits) and diversity cap (max 3 from the same city).
- **Interactive Card Stack (`DailyRecommendationsModal`):**
  - 4:5 portrait photo with edge-blur background fill and diagonal low-opacity "Pondy Connect" watermark.
  - Shortlist pill toggle, live distance chip, and expandable full-detail section.
  - Fixed action bar: **Don't Show** (with 5-second Undo snackbar), **Skip** (card slides left), **Send Interest** (heart animation, respects plan quotas).
  - Clean "You're all caught up" end-state with CTA to browse all matches.

### 3. Matches Tab, 17 Query Systems & Occupation Filter Strip (§3)
- **Matches Tab Shell:** Filter tabs (All matches, Newly joined), live match counter headline, action chips.
- **More Menu (17 Real-Data Queries):**
  - Based on activity: Shortlisted you, Viewed you, Shortlisted by you, Viewed by you.
  - Recently joined & nearby: Newly joined (last 30 days), Nearby matches.
  - Profile details: Photo matches, Matches with horoscope.
  - Astrological compatibility: Star matches, Horoscope matches (10-porutham).
  - Mutual & looking for you: Mutual matches, Looking for you.
  - Preferences: Education preference, Professional preference, City preference, NRI matches.
- **Occupation Quick-Select Strip (§3.5):**
  - Horizontal chip strip: Doctor, Techie (IT & Software), Advocate (Legal), Engineer, Teacher, CA, Business, Govt, Defence, More.
  - One-tap "Same profession as me" filter using the logged-in member's occupation.
  - Removable chip ("Occupation: Doctor ✕") with always-visible reset button.

### 4. Nearby Matches & Distance Engine (§4)
- **Privacy-First Spatial Engine:** Exact GPS coordinates are NEVER stored. On capture, coordinates are snapped to a ~300-500m coarse grid with deterministic jitter and geohash (precision 5).
- **Haversine Distance Calculation:** Computed in-memory; rounded to 0.1 km under 10 km and nearest 1 km above. Distances below 0.3 km display safely as `< 0.5 km` to prevent trilateration.
- **Permission Flow & Settings:** Friendly pre-permission explainer sheet, manual district centroid fallback when location is disabled, and granular privacy controls (Precise-ish / Approximate / Hidden).

### 5. Profile Detail, Field Locks & Contact Paywall (§5)
- **Data-Driven Field Visibility:** Based on `field_visibility.csv`. Free members see caste, education, occupation, and family status. Locked fields (Date of birth, Star, Raasi, Horoscope, Studied at, Works at) display a lock icon with "Upgrade to view >".
- **Deep Routing:** Tapping any locked field deep-links to `/upgrade` with source parameters and returns with revealed fields upon purchase.
- **Contact Paywall Sheet:**
  - Free members see masked phone (`+91 95XXXXXXXX`) and paid membership benefits.
  - Paid members see confirmation with remaining contact views, reveals unmasked contact, logs view to `contact_views`, and launches phone (`tel:`) or WhatsApp (`wa.me`) with prefilled greeting.

### 6. Membership Plans & Payment Layer (§6)
- **Regular Packs:**
  - Gold (3 Months) — ₹999 (~₹333/mo) with 40 contact views.
  - Prime Gold (3 Months) — ₹1,999 (~₹666/mo) with unlimited contact views (fair-use cap).
  - Prime – Till U Marry — ₹4,999 (Best Value) valid until marriage or 24 months inactivity.
- **Exclusives Tab:** Profile Highlighter add-ons (15, 45, 90 days) with verified top-of-matches boost.
- **Entitlements Engine (`domain/entitlements`):** Single source of truth for all plan gating rules, quotas, and field visibilities.
- **Payment Architecture:** Clean `PaymentGateway` abstraction with `MockPaymentGateway` generating tax invoices (18% GST breakdown) and printable payment receipts.

### 7. Tamil Toggle & Complete Localization (§7)
- **Compact Toggle Button (அ / A):** One-tap instant language switch across the entire app without restart.
- **Verbatim Standardized Matrimonial Terminology:**
  - Home: முகப்பு | Matches: வரன்கள் | Interests: விருப்பங்கள் | Messages: மெசேஜ்கள் | Upgrade: அப்கிரேடு
  - Regular: ரெகுலர் | PRIME: ப்ரைம் | Free Member: இலவச சேவை உறுப்பினர்
  - All matches: அனைத்து வரன்கள் | View all: அனைவரையும் பார்க்கவும் | yrs: வயது
  - Matches based on your preferences: உங்கள் விருப்பங்களுடன் பொருந்தும் வரன்கள்
- **Noto Sans Tamil Typography:** Line height strictly enforced ≥ 1.35 to prevent glyph clipping. Verified at 1.3x accessibility text scale.
- **Parity Test:** 100% key parity verified between `app_en.arb` and `app_ta.arb`.

### 8. Authentic Sample Profiles & Purge Tool (§9, §10)
- **20 Real Profiles (G1-G10, B1-B10):** Full data catalogue with real Puducherry/TN locations (Lawspet, Muthialpet, Villianur, White Town, Cuddalore, Chennai, Singapore, London).
- **Synthetic Portraits:** High-resolution realistic Tamil attire adult portraits stored in `assets/avatars/`.
- **Safety Rules:** All contact fields NULL; `is_sample=1`; visible "Sample profile" badge; Send Interest / Call / WhatsApp displays demonstration disclaimer.
- **Purge Tool:** `tool/purge_samples.dart` removes all sample rows across all tables cleanly with 0 database audit errors.

---

## Quality Gate Validation
- `dart analyze lib/ test/ tool/`: **0 issues**
- `flutter test`: **121/121 tests passing (100% green)**
- `dart run tool/db_audit.dart`: **0 errors, 0 warnings**
- `flutter build apk --debug`: **Build Succeeded**
