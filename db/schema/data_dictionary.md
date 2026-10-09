# Pondy Connect Matrimony V2 — Data Dictionary

**Schema Version:** 2.0.0  
**Target Storage:** Local CSV (App Documents) & Azure SQL Database (Cloud Export)

---

## 1. Identity & Profile Entities

### `users`
- `user_id` (PK, UUID string): Internal immutable user account identifier.
- `mobile` (Unique, string): E.164 phone number used for OTP authentication.
- `email` (Optional, string): Contact email address.
- `password_hash` (string): Salted password digest (PBKDF2/Argon2).
- `salt` (string): Per-user cryptographically random salt.
- `status` (string): 'active', 'hidden', 'deleted'.
- `is_verified` (bit 0/1): Whether identity documents/phone have been verified.
- `is_sample` (bit 0/1): 1 if sample profile; 0 for real organic users.
- `row_version` (int): Optimistic locking concurrency counter.

### `profiles`
- `profile_id` (PK, UUID string): Primary profile identifier.
- `user_id` (FK -> users.user_id): Owning user account.
- `matrimony_id` (Unique, string): Human-readable ID (e.g. `PC000101`). Never reused.
- `name` (string): Full name of the candidate.
- `gender` (string): 'Male' or 'Female'.
- `dob` (date): Date of birth (`YYYY-MM-DD`). Strict legal age: Male >= 21, Female >= 18.
- `age` (int): Calculated age in whole years.
- `height_cm` (int): Height in centimeters (derived from master `height.csv`).
- `marital_status_id` (FK -> marital_status.id): 'Never Married', 'Divorced', etc.
- `mother_tongue_id` (FK -> mother_tongue.id).
- `religion_id` (FK -> religion.id).
- `division_id` (FK -> religion_division.id).
- `caste_id` (FK -> caste.id).
- `sub_caste_id` (FK -> sub_caste.id).
- `willing_other_caste` (bit 0/1): Checkbox indicating willingness to marry across castes.
- `profile_photo_privacy` (string): 'all', 'premium', 'on_request'.
- `profile_source` (string): 'organic' or 'sample'.
- `is_sample` (bit 0/1): Sample profile flag.

### `profile_horoscopes`
- `horoscope_id` (PK, UUID string).
- `profile_id` (FK -> profiles.profile_id).
- `nakshatra_id` (FK -> nakshatra.id).
- `padam` (int 1-4): Nakshatra quarter.
- `rasi_id` (FK -> rasi.id): Auto-suggested from nakshatra + padam.
- `dosham_id` (FK -> dosham.id): Sevvai, Rahu-Kethu, etc.
- `chart_raasi_json` & `chart_amsam_json`: 12-house South Indian planetary grid mappings.

### `profile_location`
- `location_id` (PK, UUID string).
- `country_id`, `state_id`, `district_id`, `city_id`: Hierarchical geographic references.
- `citizenship_id`, `residency_status_id`: NRI / Citizenship tracking.

### `profile_education_career`
- `education_level_id`, `education_degree_id`, `employment_type_id`, `occupation_id`.
- `annual_income_range_id` (FK -> income_range.id).

---

## 2. Interaction & Transaction Entities

### `interests`
- `interest_id` (PK, UUID string).
- `from_profile_id`, `to_profile_id`: Initiator and recipient. Unique edge constraint.
- `status`: 'sent', 'accepted', 'declined', 'withdrawn'.

### `conversations` & `messages`
- Direct messaging thread between candidate pairs with message read tracking.

### `photos`
- `photo_id` (PK, UUID string).
- `profile_id` (FK -> profiles.profile_id).
- `blob_path` (string): Logical path `profiles/{profile_id}/photos/{photo_id}.jpg`.
- `is_primary` (bit 0/1): Exactly one primary photo per profile.
