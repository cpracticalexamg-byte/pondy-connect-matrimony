# Pondy Connect Matrimony — Tamil Localization & Review Guide

This document records the localization mappings, standard Tamil matrimonial terminology, and items flagged for native speaker review for Pondy Connect Matrimony V3.

---

## 1. Verbatim Core Terminology (Reviewed & Standardized)

| English Term | Tamil Translation | Usage / Context |
|---|---|---|
| Home | முகப்பு | Bottom navigation tab 1, Header |
| Matches | வரன்கள் | Bottom navigation tab 2, Count headlines |
| Interests | விருப்பங்கள் | Bottom navigation tab 3 |
| Messages | மெசேஜ்கள் | Bottom navigation tab 4 |
| Upgrade | அப்கிரேடு | Bottom navigation tab 5, Buttons, Chips |
| Regular | ரெகுலர் | Segmented header toggle (All matches) |
| PRIME | ப்ரைம் | Segmented header toggle (Verified matches) |
| Free Member | இலவச சேவை உறுப்பினர் | Header membership badge |
| Gold Member | தங்க உறுப்பினர் | Header membership badge |
| Prime Gold Member | ப்ரைம் தங்க உறுப்பினர் | Header membership badge |
| Prime – Till U Marry | ப்ரைம் – திருமணம் வரை | Header membership badge |
| All matches | அனைத்து வரன்கள் | Matches list header, filter tabs |
| View all | அனைவரையும் பார்க்கவும் | Carousel header CTA buttons |
| yrs (Age) | வயது | Profile card demographic chip (e.g., 29 வயது) |
| Matches based on your preferences | உங்கள் விருப்பங்களுடன் பொருந்தும் வரன்கள் | Home headline & Matches screen |
| Newly joined | புதிதாக சேர்ந்தவர்கள் | Filter chips, sort option, Home carousel |
| Nearby matches | அருகிலுள்ள வரன்கள் | Filter chips, sort option, Home carousel |
| Verified | சரிபார்க்கப்பட்டவை | ID verified badge and filter chip |
| Shortlisted | பட்டியலிடப்பட்டது | Card toggle action |
| Send Interest | விருப்பம் அனுப்பு | Card CTA action button |
| Daily Recommendation | தினசரி பரிந்துரை | Card stack modal title |
| Become a paid member now! | கட்டண உறுப்பினராகுங்கள்! | Upgrade screen banner |
| Regular Packs | வழக்கமான திட்டங்கள் | Upgrade screen tab |
| Exclusives | பிரத்தியேக சலுகைகள் | Upgrade screen tab |

---

## 2. Items Flagged for Native Review

The following translations are syntactically accurate and grammatically sound, but native matrimonial copywriters may suggest stylistic preferences for the local Puducherry / Tamil Nadu dialect:

1. **"Same profession as me"**
   - Current translation: `என் தொழில் போன்ற வரன்கள்` (Matches of my profession)
   - Alternative: `என் அதே தொழில் உள்ளவர்கள்`
   - Recommendation: `என் தொழில் போன்ற வரன்கள்` is concise and fits well inside a horizontal chip without text clipping.

2. **"Profile created by parents / self"**
   - Current translation: `சுயவிவரம் உருவாக்கியது: பெற்றோர் / நான்`
   - Alternative: `சுயவிவரப் பதிவு: பெற்றோர்`
   - Status: Clear and unambiguous.

3. **"Prime – Till U Marry"**
   - Current translation: `ப்ரைம் – திருமணம் வரை`
   - Note: The brand name "Prime" is transliterated as `ப்ரைம்` consistent with leading South Indian matrimonial platforms.

4. **"Shortlisted you" / "Viewed you"**
   - Current translation: `உங்களை தேர்வு செய்தவர்கள்` / `உங்களைப் பார்த்தவர்கள்`
   - Status: Natural and widely accepted.

5. **"10-Porutham Matching"**
   - Current translation: `10-பொருத்தம் பொருத்தம்`
   - Status: Standard traditional Tamil astrological terminology.

---

## 3. Typography & Accessibility Standards

- **Font Family:** `Noto Sans Tamil` loaded via Google Fonts (with graceful local fallback in test/offline environments).
- **Line Height:** Enforced minimum `1.35` (set to `1.35` - `1.4` across all text styles in `AppTypography`) to prevent Tamil vowel modifier clipping (மேல் விலங்கு / கீழ் விலங்கு).
- **Text Scaling:** Verified safe at `1.3x` text scale without container overflow or ellipsis truncation on critical actions.
- **Numbers & Currency:** Retains Indian numerical format and rupee symbol (e.g. `₹1,999`) for familiar financial comprehension.
