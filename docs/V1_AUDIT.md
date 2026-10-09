# Pondy Connect Matrimony — V1 Comprehensive Audit Report

**Date of Audit:** October 7, 2026  
**Auditor:** Senior Flutter Architect, Data Engineer & Release Engineer  
**Baseline Git Commit:** `v1-backup` (tag & branch created)  
**App Target:** Pondy Connect Matrimony V2 (Production-Ready)

---

## 1. Executive Summary

A comprehensive, read-only audit of the **Pondy Connect Matrimony V1** codebase and dataset was conducted. While V1 has a working UI architecture, pleasant visual components, and clean initial test passes, it relies entirely on synthetic/dummy data (620 demo profiles, 620 demo users, and 3 demo success stories with `is_demo=1`), has severely incomplete master data (e.g. only 34 castes, 12 languages, missing panchangam porutham rules and country/state/city hierarchy), contains multiple concurrency/deadlock vulnerabilities in its CSV storage and lock implementation, creates disposable controllers inside widget `build()` methods, swallows exceptions in over 25 locations with empty `catch (_)` blocks, and lacks store-readiness hardening (DPDP Act compliance, account deletion, signing configurations, and adaptive icons).

This document establishes the exhaustive baseline and concrete remediation plan for each phase leading to the V2 production release.

---

## 2. Data Audit (CSV Analysis)

### 2.1 Master Data Files (`assets/csv/master/`)

| File | Rows | Header Columns | Audit Findings & Gaps |
|---|---|---|---|
| `religions.csv` | 13 | `id, name_en, name_ta` | Covers primary religions, but missing division hierarchy FK. |
| `divisions.csv` | 39 | `id, religion_id, name_en, name_ta` | Incomplete Christian denominations (missing Catholic/Protestant rite granularity like Latin Catholic, Malankara, Syro-Malabar) and Muslim schools. |
| `castes.csv` | 34 | `id, religion_id, division_id, name_en, name_ta` | **Critical Deficit:** Only 34 entries. Fails to cover official TN BC, MBC, DNC, SC, SCA, ST lists (~300+ communities) and lacks reservation category metadata. |
| `districts.csv` | 43 | `id, state, district_en, district_ta` | Only contains 38 TN districts + 4 Puducherry regions + 1 external. Missing all other 27 Indian states and Union Territories per India LGD. |
| `mother_tongues.csv` | 12 | `id, name_en, name_ta` | Only 12 languages. Missing scheduled languages (Assamese, Bodo, Dogri, Kashmiri, Konkani, Maithili, Manipuri, Nepali, Odia, Sanskrit, Santali, Sindhi) and regional Puducherry languages (French, Sourashtra, Badaga). |
| `education_levels.csv` | 22 | `id, category, name_en, name_ta` | Flattens levels and degrees into one file without normalized degree grouping (B.E., MBBS, MBA, CA, etc.). |
| `occupations.csv` | 27 | `id, category, name_en, name_ta` | Limited list; missing modern IT specializations, healthcare branches, civil service cadres. |
| `income_ranges.csv` | 11 | `id, min_inr, max_inr, label_en, label_ta` | Only covers INR. Missing foreign currencies (USD, AED, SGD, GBP, etc.) for NRI profiles. |
| `heights.csv` | 37 | `cm, formatted_en, formatted_ta` | Formatted cleanly from 140 cm to 213 cm (4'7" to 7'0"). Valid. |
| `stars.csv` | 27 | `id, star_name_en, star_name_ta, rasi_ids` | Valid 27 stars, but uses semicolon-delimited `rasi_ids` (denormalized). Missing star-to-padam-rasi mapping. |
| `rasis.csv` | 12 | `id, rasi_name_en, rasi_name_ta, lord_en` | Valid 12 signs with planetary lords. |
| `doshams.csv` | 7 | `id, name_en, name_ta` | Basic doshams present. |
| `diet.csv` | 4 | `id, name_en, name_ta` | Valid (Veg, Non-Veg, Eggetarian, Jain). |
| `employment_types.csv` | 6 | `id, name_en, name_ta` | Valid categories. |
| `family_status.csv` | 3 | `id, name_en, name_ta` | Valid (Middle, Upper Middle, Rich/Affluent). |
| `family_type.csv` | 2 | `id, name_en, name_ta` | Valid (Nuclear, Joint). |
| `family_values.csv` | 3 | `id, name_en, name_ta` | Valid (Traditional, Moderate, Liberal). |
| `marital_statuses.csv` | 5 | `id, name_en, name_ta` | Valid. |
| `plans.csv` | 4 | `plan_id, name, price_inr, duration_months...` | Valid mock plans. |

#### Master Data Missing Entirely:
1. `nakshatra_padam_rasi.csv` (108 padams to exact rasi mapping).
2. `porutham_rules.csv` (10 Porutham calculation matrices: Dina, Gana, Mahendra, Stree Deergha, Yoni, Rasi, Rasi Adhipathi, Vasya, Rajju, Vedha).
3. `country.csv` (ISO country codes, dial codes, priority countries).
4. `state.csv` (All 28 Indian states + 8 UTs + NRI provinces).
5. `city.csv` (Full city/commune list for Puducherry and Tamil Nadu).
6. `gothram.csv` (Authoritative list of Vedic and community gothrams).
7. `sub_caste.csv` (Sub-castes mapped to parent caste).
8. `body_type.csv`, `complexion.csv`, `blood_group.csv`.
9. `citizenship.csv`, `residency_status.csv`.
10. `hobby_interest.csv` (Grouped tags).
11. `profile_created_for.csv`, `physical_status.csv`, `disability_type.csv`.

### 2.2 Seed Data Files (`assets/csv/seed/`)

| File | Total Rows | `is_demo=1` Rows | Real Data Rows | Findings |
|---|---|---|---|---|
| `users.csv` | 620 | 620 (100%) | 0 | All rows are generated synthetic test accounts. Passwords use basic sha256. |
| `profiles.csv` | 620 | 620 (100%) | 0 | All rows generated by `tool/seed_generator.dart`. No real human profiles exist. |
| `partner_prefs.csv` | 620 | 0 (derived) | 0 | 620 synthetic partner preference rows paired to the demo profiles. |
| `photos.csv` | 620 | 0 (derived) | 0 | All point to placeholder asset paths `assets/avatars/avatar_m_1.png` etc. No real images. |
| `success_stories.csv` | 3 | 3 (100%) | 0 | 3 hard-coded demo stories with `is_demo=true`. |

### 2.3 Data Integrity & Quality Analysis
- **Exact Duplicates:** 0 duplicate rows found in current seed CSVs.
- **Orphan Foreign Keys:** 0 orphan keys currently in seed data (all `user_id` and `profile_id` references match).
- **Date Formats:** DOB formats in `profiles.csv` consistently follow `YYYY-MM-DD`.
- **Encoding Issues:** All files are valid UTF-8. Tamil characters render properly without corruption or mojibake.
- **Denormalization:** `stars.csv` uses semicolon-delimited `rasi_ids` (`mesha;vrishabha`) instead of a relational link table.
- **V2 Action Requirement:** All 620 synthetic rows in `seed/` must be eliminated. In V2, the production shipment starts with **clean, empty tables** (headers only). 10 men + 10 women sample profiles will be added in Phase 9 strictly flagged as `is_sample=1` and `profile_source='sample'`.

---

## 3. Code & Architecture Audit (Loop, Error & Concurrency Risks)

### 3.1 Concurrency & Mutex Deadlock Risks
- **File:** [csv_lock.dart](file:///d:/Pondy-Connect/Matrimony/lib/data/csv/csv_lock.dart#L13-L28)
  - **Issue 1 (Race Condition on Release):** In `CsvLock.synchronized`, when `_locks[tableName]` finishes and `finally` runs `_locks[tableName] = null`, all waiting callers awaiting `_locks[tableName]!.future` wake up concurrently in the same microtask loop. There is no FIFO ordering, causing a race condition where multiple callers can contend or clear another caller's active lock.
  - **Issue 2 (No Timeout):** If any file I/O hangs, deadlocks, or throws an unhandled error inside `runZoned`, the table lock remains acquired indefinitely, freezing that table for all subsequent operations.
  - **Fix Plan (Phase 4):** Replace with an asynchronous FIFO queue mutex with a strict 5-second timeout, owner tracking, and dead-lock recovery.

- **File:** [csv_store.dart](file:///d:/Pondy-Connect/Matrimony/lib/data/csv/csv_store.dart#L23-L75)
  - **Issue 1 (Synchronous Startup Blocking):** `CsvStore.instance.initialize()` is awaited in `main()` before `runApp()`. Any delay in reading 20 CSV files stalls native app startup.
  - **Issue 2 (Non-Atomic Writes):** Write operations write directly to the target file. If an app crash or power loss occurs mid-write, the CSV file is corrupted.
  - **Issue 3 (Missing Rollback & Transactions):** Operations like multi-table inserts (e.g. user + profile + preferences) do not support atomic rollback on partial failure.
  - **Fix Plan (Phase 4):** Implement atomic write using temporary files (`table.csv.tmp` -> flush -> rename), automated `.bak` snapshot recovery on corruption detection, and multi-table transaction rollback via `runInTransaction()`.

### 3.2 Memory Leaks & Undisposed Controllers
- **File:** [step2_religion_screen.dart](file:///d:/Pondy-Connect/Matrimony/lib/features/registration/screens/step2_religion_screen.dart#L320)
  - **Issue:** `controller: TextEditingController(text: reg.gothram)` instantiated inside `build()`. A new controller is created on every rebuild and never disposed.
  - **Fix Plan (Phase 7):** Manage text controllers in screen state `initState`/`dispose` or sync directly via Riverpod notifier.
- **File:** [step3_location_screen.dart](file:///d:/Pondy-Connect/Matrimony/lib/features/registration/screens/step3_location_screen.dart#L164-L177)
  - **Issue:** `TextEditingController(text: reg.city)` and `TextEditingController(text: reg.citizenship)` created inside `build()`.
  - **Fix Plan (Phase 7):** Refactor to stateful controllers with proper disposal.
- **File:** [step4_professional_screen.dart](file:///d:/Pondy-Connect/Matrimony/lib/features/registration/screens/step4_professional_screen.dart#L158-L205)
  - **Issue:** `TextEditingController(text: reg.educationDetail)` and `TextEditingController(text: reg.employer)` created inside `build()`.
  - **Fix Plan (Phase 7):** Refactor to stateful controllers with proper disposal.
- **File:** [step5_additional_screen.dart](file:///d:/Pondy-Connect/Matrimony/lib/features/registration/screens/step5_additional_screen.dart#L161-L173)
  - **Issue:** `TextEditingController(text: reg.fatherOccupation)` and `TextEditingController(text: reg.motherOccupation)` created inside `build()`.
  - **Fix Plan (Phase 7):** Refactor to stateful controllers with proper disposal.
- **File:** [chat_conversation_screen.dart](file:///d:/Pondy-Connect/Matrimony/lib/features/chat/screens/chat_conversation_screen.dart#L35-L42)
  - **Issue:** Polling timer runs every 1500 ms. If network/storage lag exceeds 1500 ms, multiple concurrent reads overlap.
  - **Fix Plan (Phase 5):** Use asynchronous sequential polling or stream-based updates.

### 3.3 Swallowed Exceptions & Unhandled Failures
- **Count:** 26 instances across `lib/` where `catch (_) {}` or `catch (e) {}` suppresses errors without logging or typed error wrapping.
- **Notable Locations:**
  - [master_data_repository.dart#L51](file:///d:/Pondy-Connect/Matrimony/lib/data/repositories/master_data_repository.dart#L51): `catch (_) { return []; }` hides missing or malformed CSV files.
  - [photo_screen.dart#L38](file:///d:/Pondy-Connect/Matrimony/lib/features/registration/screens/photo_screen.dart#L38): `catch (_) {}` hides image picker crashes.
  - [registration_provider.dart#L301](file:///d:/Pondy-Connect/Matrimony/lib/features/registration/providers/registration_provider.dart#L301): `catch (_) {}` hides profile creation failures.
  - [plan_repository.dart#L38](file:///d:/Pondy-Connect/Matrimony/lib/data/repositories/plan_repository.dart#L38): `catch (_) {}` hides subscription errors.
  - [search_provider.dart#L185](file:///d:/Pondy-Connect/Matrimony/lib/features/search/providers/search_provider.dart#L185): `catch (_) {}` hides filter calculation crashes.
- **Fix Plan (Phase 5):** Introduce `Result<T, AppError>` functional pattern with typed domain errors (`ValidationError`, `StorageError`, `RateLimitError`). Replace all empty catch blocks with structured logging and user-facing recovery states.

### 3.4 Navigation & Routing Loop Risks
- **File:** [app_router.dart](file:///d:/Pondy-Connect/Matrimony/lib/core/router/app_router.dart#L69-L330)
  - **Issue:** No centralized `redirect` callback on `GoRouter`. Navigation transitions (e.g. from splash, registration steps, or auth guards) are performed imperatively with `context.go()` scattered across UI callbacks.
  - **File:** [splash_screen.dart#L43-L48](file:///d:/Pondy-Connect/Matrimony/lib/features/splash/splash_screen.dart#L43-L48)
  - **Issue:** Blindly invokes `context.go('/onboarding')` after 2200 ms regardless of whether the user is already authenticated or partially registered.
  - **Fix Plan (Phase 2 & Phase 5):** Unify all authentication and onboarding route guards into a single deterministic redirect function in `GoRouter`. Add unit tests asserting termination within <= 2 redirects.

### 3.5 Fabricated UI Data & Fallbacks
- **File:** [teaser_strip.dart#L44-L80](file:///d:/Pondy-Connect/Matrimony/lib/core/widgets/teaser_strip.dart#L44-L80)
  - **Issue:** Contains hardcoded `_defaultSampleProfiles` list with mock ages, religions, and occupations shown when data is empty.
  - **File:** [home_provider.dart#L89](file:///d:/Pondy-Connect/Matrimony/lib/features/home/providers/home_provider.dart#L89)
  - **Issue:** Defaults `myProfile` to `allProfiles.first` (the first demo profile) if the logged-in user has no profile, polluting the dashboard with fake demo data.
  - **Fix Plan (Phase 4 & Phase 7):** Remove all hardcoded fallback data. If counts or matches are 0, display authentic empty states ("0 Matches in Puducherry yet").

---

## 4. Remediation Matrix & Action Plan

| Phase | Core Objective | Key Deliverables & Changes |
|---|---|---|
| **Phase 2** | Branding & Splash | Use existing logo for `flutter_launcher_icons` (adaptive Android, iOS 1024x1024, no alpha). Implement 2.5s synchronized animated splash with `Future.wait` on DB init + single GoRouter redirect. |
| **Phase 3** | Complete Master Data | Expand `db/master/*.csv` to include all TN BC/MBC/DNC/SC/ST communities, ISO countries, India LGD states & districts, Puducherry communes/cities, 108 star-padams, and Porutham calculation rules. Document sources in `db/master/SOURCES.md`. |
| **Phase 4** | CSV Database Rebuild | Restructure to Azure-ready layout (`db/schema/`, `db/master/`, `db/data/`, `db/azure/`). Re-engineer `CsvStore` with atomic file swapping, snapshot backup, FIFO mutex with 5s timeout, transactions, and migration tools (`migrate_v1_to_v2.dart`, `db_audit.dart`). |
| **Phase 5** | Backend Reorganization | Clean Architecture layering (`core/`, `data/`, `domain/`, `application/`, `features/`). Introduce `Result<T, AppError>`, remove all swallowed exceptions, eliminate widget memory leaks, add comprehensive test suite. |
| **Phase 6** | Isolated Fake OTP | Create `OtpService` interface with `FakeOtpService` (fixed code `123456`, rate limiting, lockout, expiry) and stubbed `SmsOtpService`. |
| **Phase 7** | Master Data Binding | Bind all form pickers and search filters dynamically to master CSVs. Implement 10-Porutham compatibility and horoscope chart editor. |
| **Phase 8** | Production Hardening | DPDP Act 2023 consent flows, account deletion, secure token storage, obfuscated release build configuration, ProGuard/R8 rules, and store listing assets. |
| **Phase 9** | Sample Profiles | Add exactly 10 men + 10 women realistic sample profiles with commercial/AI portraits, clear "Sample Profile" badges, and `purge_samples.dart` tool. |

---
*End of V1 Audit Report. Ready to proceed with Phase 2 implementation.*
