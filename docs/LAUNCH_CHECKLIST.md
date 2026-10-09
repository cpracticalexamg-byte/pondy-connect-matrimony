# Pondy Connect Matrimony — Production Launch Checklist (V2)

**Target Launch Date:** Q4 2026  
**Application ID:** `com.pondyconnect.matrimony.pondy_connect_matrimony`  
**Target Territory:** Puducherry (UT), Karaikal, Mahe, Yanam, and neighboring Tamil Nadu districts (Cuddalore, Villupuram, Chennai diaspora)  
**Compliance Mandate:** Digital Personal Data Protection Act (DPDP Act 2023), Google Play Policy 2026  

---

## 1. Pre-Launch Configuration & Security Hardening

- [x] **Brand Assets & Vector Icons**
  - Generated native launcher icons across Android densities (`mipmap-mdpi` to `mipmap-xxxhdpi`) from `assets/images/logo.png`.
  - Android 12+ Adaptive Vector Icons with warm saffron background (`#F5E6D3`).
  - Animated cold start splash screen with micro-animations (`flutter_native_splash`).

- [x] **Master Data (48 Tables)**
  - All 48 master CSVs built and validated in `db/master/` and `assets/csv/master/`.
  - Localized bilingual metadata (English and Tamil) for all communes, castes, and nakshatras.
  - Integrity verified by automated test `test/master_data_integrity_test.dart`.

- [x] **OTP Service Switchover**
  - In `lib/core/config/app_config.dart`, change:
    ```dart
    static const bool useFakeOtp = false; // Set to false for live production
    static const bool showOtpTestHint = false;
    ```
  - Configure SMS Gateway provider endpoint and API bearer tokens in production environment variables (`SMS_GATEWAY_URL`, `SMS_GATEWAY_KEY`).
  - Rate limiting active: 3 OTP requests / 10-minute window, 5 invalid attempts triggers 10-minute lockout.

- [x] **DPDP Act 2023 & Privacy Controls**
  - Explicit consent captured on onboarding; stored in `consents` table with timestamp and version.
  - Photo privacy selector: `all`, `members`, or `request` (blurred).
  - Phone number visibility restricted until mutual interest acceptance.
  - Full self-serve Account Deletion flow with reason capture under `SettingsScreen` cascading soft/hard delete to `users`, `profiles`, and `consents`.

---

## 2. Sample Data Management & Purge Procedure

- [x] **Curated Sample Profiles**
  - Exactly 10 authentic men and 10 authentic women seeded in `db/data/profiles.csv` and `db/data/users.csv`.
  - Every sample profile represents real Puducherry institutions (PEC, PTU, JIPMER, Pondicherry Univ), authentic communes (Lawspet, Muthialpet, Oulgaret, Villianur, Bahour, White Town, Karaikal), and real Vedic star/rasi pairings.
  - Every sample row is explicitly marked with `is_sample = '1'`.
- [x] **One-Command Purge Tool**
  - Run the following command at any time to instantly remove all sample data before live launch:
    ```bash
    dart run tool/purge_samples.dart
    ```
  - To re-seed for testing/demo environments:
    ```bash
    dart run tool/seed_curated_samples.dart
    ```

---

## 3. Azure SQL Database Migration Runbook

For cloud scale, the local CSV architecture maps 1:1 with Azure SQL:
1. **Schema Deployment:**
   - Execute `db/schema/schema.sql` against your Azure SQL Database server.
2. **Bulk Ingestion via BCP:**
   - Run the automated loader in `db/azure/load_azure.bat` (or `db/azure/load_azure.sh` on Linux/macOS):
     ```cmd
     cd db\azure
     load_azure.bat <server>.database.windows.net pondy_matrimony_db <user> <password>
     ```
3. **Verify Integrity:**
   - Execute verification query:
     ```sql
     SELECT table_name, count(*) FROM sys.tables;
     ```

---

## 4. Release Build & Android App Bundle (AAB) Generation

1. **Keystore Generation:**
   ```bash
   keytool -genkey -v -keystore android/app/pondy-release-key.jks -alias pondy_key -keyalg RSA -keysize 2048 -validity 10000
   ```
2. **Create `android/key.properties`:**
   ```properties
   storePassword=<your-store-password>
   keyPassword=<your-key-password>
   keyAlias=pondy_key
   storeFile=pondy-release-key.jks
   ```
3. **Generate Obfuscated Production App Bundle:**
   ```bash
   flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
   ```
   *R8/ProGuard configuration in `android/app/proguard-rules.pro` will automatically optimize and preserve Flutter engines and data models.*

---

## 5. Google Play Console Submission Checklist

- [ ] **Store Listing (`docs/store/PLAY_STORE.md`)**
  - App Title: `Pondy Connect Matrimony` (23 chars)
  - Short Description: 75 chars
  - Full Description: High-conversion bilingual copy with regional keywords
- [ ] **Data Safety Questionnaire**
  - Declare Approximate Location, Personal Info (Name, Mobile, DOB), Messages, and Photos.
  - Data encrypted in transit: `Yes` (TLS 1.3).
  - Data deletion URL provided: `https://pondyconnect.com/delete-account`.
- [ ] **Content Rating (IARC)**
  - Matrimonial social app, strictly 18+ age gate, no adult/explicit content.
- [ ] **8 Production Screenshots**
  - Capture 1080x2400 phone and 1200x1920 tablet screenshots per checklist in `docs/store/PLAY_STORE.md`.
- [ ] **App Access Credentials for Play Reviewers**
  - Mobile: `+919840001001`
  - Test OTP: `123456`

---

## 6. Post-Launch Operations Runbook

1. **Daily Database Backups:** Automated nightly snapshot of Azure SQL / local store.
2. **Crash & Anomaly Logging:** Monitor `AppLogger` logs; zero silent exceptions tolerated.
3. **Grievance Redressal SLA:** In compliance with DPDP Act 2023, resolve user profile inquiries and data deletion requests at `grievance@pondyconnect.com` within 72 business hours.
