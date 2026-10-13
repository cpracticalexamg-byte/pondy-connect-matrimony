# Pondy Connect Matrimony — Production Launch & Owner Decision Checklist (V3)

**Application Name:** Pondy Connect Matrimony (பாண்டி கனெக்ட் மேட்ரிமோனி)  
**Version:** 3.0.0 (V3 Feature Upgrade)  
**Application ID:** `com.pondyconnect.matrimony.pondy_connect_matrimony`  
**Target Territory:** Puducherry (UT), Karaikal, Mahe, Yanam, and neighboring Tamil Nadu districts (Cuddalore, Villupuram, Chennai diaspora)  
**Compliance Mandate:** Digital Personal Data Protection Act (DPDP Act 2023), Google Play / App Store Policies  

---

## 1. Status of Mocked vs. Production Services

| Component | Current V3 Status | Action Required for Production Launch | Code Location |
|---|---|---|---|
| **OTP Authentication** | `FakeOtpService` (Code: `123456`) | Configure SMS Gateway provider credentials (e.g. Twilio, MSG91, Kaleyra) and set `AppConfig.useFakeOtp = false`. | `lib/core/config/app_config.dart` |
| **Payment Gateway** | `MockPaymentGateway` (Always succeeds; generates invoices & receipts in test mode) | Integrate Google Play Billing / App Store In-App Purchases, or Razorpay payment gateway depending on store policy. | `lib/domain/payments/` |
| **Government ID Verification** | In-app 2-step mock flow (captures ID type, verifies last-4 masked, sets `is_verified=1`) | Integrate automated DigiLocker API or HyperVerge/IDfy KYC provider. | `lib/domain/repositories/verification_repo.dart` |
| **Cross-Device Nearby Data** | In-memory spatial index & Haversine calculation over local database / sample profiles | Deploy Azure SQL Backend (`db/azure/`) so users across different devices can query actual nearby matches. | `lib/domain/location/location_service.dart` |
| **Sample Profiles** | 20 curated Puducherry/TN profiles (G1-G10, B1-B10) with AI synthetic portraits, flagged `is_sample=1` | Run `dart run tool/purge_samples.dart` before store submission or keep with `AppConfig.demoMode=false` in release builds. | `tool/purge_samples.dart` |

---

## 2. Mandatory Decisions for App Owner / Business Stakeholders

Before publishing to Google Play Store and Apple App Store, the business owner must finalize the following decisions:

### Decision 1: In-App Billing Rail vs External Payment Gateway
- **Policy Context:** Google Play and Apple App Store enforce in-app digital content / subscription billing through Google Play Billing and Apple StoreKit (which incurs store transaction fees of 15% - 30%). In certain jurisdictions (e.g., India user choice billing), alternative billing options may be allowed subject to store requirements.
- **Owner Action:** Confirm whether subscriptions (`gold_3m`, `prime_gold_3m`, `prime_till_marry`) should be registered as in-app products on Google Play Console / App Store Connect, or if external web payment rails (Razorpay/PayU) are permitted.

### Decision 2: Refund Policy Text
- **Guardrail (§0):** V3 strictly forbids fake "100% money-back guarantee" claims.
- **Owner Action:** Provide exact legal refund policy text to be configured in `app_config.refundPolicy`. If no refunds are offered for digital contact unlocks, the refund text must explicitly state: *"Membership fees are non-refundable once contact views have been consumed."*

### Decision 3: Fair-Use Daily Contact Cap for "Unlimited" Tiers
- **Context:** To prevent database harvesting, scrapers, and account sharing, `prime_gold_3m` and `prime_till_marry` feature "unlimited" phone numbers subject to a reasonable daily cap.
- **Default Config:** 50 new contact views per 24-hour rolling window.
- **Owner Action:** Confirm whether 50/day is appropriate or adjust in `plans.csv` (`daily_contact_cap`).

### Decision 4: Profile Highlighter Add-on Pricing
- **Proposed Pricing in V3:**
  - 15 days: ₹199
  - 45 days: ₹499
  - 90 days: ₹899
- **Owner Action:** Confirm or adjust the prices in `plans.csv` / `exclusive_products.csv`.

### Decision 5: "Prime – Till U Marry" Plan Expiration Rule
- **Definition:** The longest validity membership designed to support members until they find a match.
- **Current Logic:** Valid indefinitely until the member marks their status as 'Married', or after 24 months of total account inactivity (no logins).
- **Owner Action:** Confirm or customize the inactivity threshold.

### Decision 6: Legal Terms of Service & Privacy Policy Review
- **Owner Action:** Review generated policies at `docs/store/` with legal counsel for compliance with the DPDP Act 2023 and matrimonial arbitration guidelines.

---

## 3. Sample Data Management & Database Audit

- **Seeding Sample Profiles:**
  ```bash
  dart run tool/seed_samples.dart
  ```
- **Purging Sample Profiles:**
  ```bash
  dart run tool/purge_samples.dart
  ```
- **Auditing Database Integrity (CI/CD Quality Gate):**
  ```bash
  dart run tool/db_audit.dart
  ```
  *Zero errors and zero warnings are required for any deployment.*

---

## 4. Production Release Build Commands

To build the production Android App Bundle:
```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols --android-skip-build-dependency-validation
```
To build release APK:
```bash
flutter build apk --release --android-skip-build-dependency-validation
```
