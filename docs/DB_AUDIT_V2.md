# Pondy Connect Matrimony — Database Audit Report V2

**Audit Date:** 2026-10-13T08:32:31.221493Z  
**Target:** Production-Ready V2 Database Quality Verification  

| Table Name | Expected Columns | Actual Columns | Rows | PK Unique | Integrity Status |
|---|---|---|---|---|---|
| `schema_meta` | 4 | 4 | 2 | Pass | PASSED ✅ |
| `users` | 12 | 12 | 20 | Pass | PASSED ✅ |
| `user_sessions` | 8 | 8 | 0 | Pass | PASSED ✅ |
| `otp_requests` | 8 | 8 | 0 | Pass | PASSED ✅ |
| `profiles` | 33 | 33 | 20 | Pass | PASSED ✅ |
| `profile_horoscopes` | 20 | 20 | 0 | Pass | PASSED ✅ |
| `profile_family` | 18 | 18 | 0 | Pass | PASSED ✅ |
| `profile_lifestyle` | 10 | 10 | 0 | Pass | PASSED ✅ |
| `profile_education_career` | 17 | 17 | 0 | Pass | PASSED ✅ |
| `profile_location` | 14 | 14 | 0 | Pass | PASSED ✅ |
| `profile_languages_known` | 7 | 7 | 0 | Pass | PASSED ✅ |
| `profile_hobbies` | 4 | 4 | 0 | Pass | PASSED ✅ |
| `photos` | 11 | 11 | 0 | Pass | PASSED ✅ |
| `horoscope_files` | 9 | 9 | 0 | Pass | PASSED ✅ |
| `partner_preferences` | 18 | 18 | 0 | Pass | PASSED ✅ |
| `partner_preference_values` | 5 | 5 | 0 | Pass | PASSED ✅ |
| `interests` | 9 | 9 | 0 | Pass | PASSED ✅ |
| `conversations` | 8 | 8 | 0 | Pass | PASSED ✅ |
| `messages` | 11 | 11 | 0 | Pass | PASSED ✅ |
| `shortlists` | 4 | 4 | 0 | Pass | PASSED ✅ |
| `profile_views` | 4 | 4 | 0 | Pass | PASSED ✅ |
| `contact_views` | 5 | 5 | 0 | Pass | PASSED ✅ |
| `blocks` | 4 | 4 | 0 | Pass | PASSED ✅ |
| `reports` | 8 | 8 | 0 | Pass | PASSED ✅ |
| `notifications` | 9 | 9 | 0 | Pass | PASSED ✅ |
| `plans` | 21 | 21 | 6 | Pass | PASSED ✅ |
| `subscriptions` | 9 | 9 | 0 | Pass | PASSED ✅ |
| `payments` | 9 | 9 | 0 | Pass | PASSED ✅ |
| `verification_requests` | 8 | 8 | 0 | Pass | PASSED ✅ |
| `success_stories` | 10 | 10 | 0 | Pass | PASSED ✅ |
| `help_tickets` | 8 | 8 | 0 | Pass | PASSED ✅ |
| `consents` | 7 | 7 | 0 | Pass | PASSED ✅ |
| `app_settings` | 3 | 3 | 0 | Pass | PASSED ✅ |
| `audit_log` | 7 | 7 | 0 | Pass | PASSED ✅ |
| `daily_recommendations` | 7 | 7 | 0 | Pass | PASSED ✅ |
| `hidden_profiles` | 3 | 3 | 0 | Pass | PASSED ✅ |
| `profile_locations` | 7 | 7 | 0 | Pass | PASSED ✅ |
| `user_filter_state` | 6 | 6 | 0 | Pass | PASSED ✅ |
| `user_filter_occupations` | 5 | 5 | 0 | Pass | PASSED ✅ |
| `saved_searches` | 5 | 5 | 0 | Pass | PASSED ✅ |
| `field_visibility` | 5 | 5 | 17 | Pass | PASSED ✅ |
| `exclusive_boosts` | 5 | 5 | 0 | Pass | PASSED ✅ |
| `invoices` | 9 | 9 | 0 | Pass | PASSED ✅ |
| `profile_photo_requests` | 6 | 6 | 0 | Pass | PASSED ✅ |
| `app_open_log` | 4 | 4 | 0 | Pass | PASSED ✅ |
| `notification_settings` | 8 | 8 | 0 | Pass | PASSED ✅ |

## Master Data Reference Integrity

Total Master Tables: **55**  
Master Tables Quality Check: **All Unique Keys & Non-Empty Tamil Text Verified** ✅

## Audit Summary

- **Total Schema Errors:** 0
- **Total Schema Warnings:** 0
- **Certification:** PASSED PRODUCTION QUALITY GATE
