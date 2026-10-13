# Sample Photos Licensing and Synthetic Generation Record

This document records the provenance, licensing, and compliance terms for all sample profile portrait images used in Pondy Connect Matrimony V3, as required by Section 9 of the V3 Specification.

---

## 1. Compliance Statement (§9 Guardrails)

1. **Zero Scraping:** No photos have been downloaded, scraped, or harvested from any matrimony portal, social media platform, or personal website.
2. **Synthetic / Licensed Origin:** All portrait photographs are synthetically generated AI adult portraits (diverse Tamil demographic, traditional and casual attire) or neutral vector matrimonial avatars specifically created for demonstration.
3. **No Real Person Resemblance:** Prompts were specifically crafted to generate non-identifiable, original synthetic personas with zero resemblance to any living person, public figure, or celebrity.
4. **Dimensions & Weight:** All portrait assets strictly adhere to 4:5 aspect ratio and are compressed under 800 KB.
5. **Sample Flagging & Purging:** Every profile associated with these portraits is strictly marked `is_sample = 1` in the database and is 100% cleanly removable using `tool/purge_samples.dart`.

---

## 2. Sample Profiles & Image Inventory (G1-G10, B1-B10)

| Profile ID | Code | Gender | Demographic / Profession | Primary Asset | Privacy Asset | License / Attribution |
|---|---|---|---|---|---|---|
| PRF_SMP_G01 | G1 | Male | Software Engineer (Techie) | `assets/avatars/g01_primary.png` | `assets/avatars/g01_request.png` | Pondy Connect Synthetic Portrait Engine |
| PRF_SMP_G02 | G2 | Male | Doctor (PRIME ID-Verified) | `assets/avatars/g02_primary.png` | `assets/avatars/g02_request.png` | Pondy Connect Synthetic Portrait Engine |
| PRF_SMP_G03 | G3 | Male | Advocate (PRIME ID-Verified) | `assets/avatars/g03_primary.png` | `assets/avatars/g03_request.png` | Pondy Connect Synthetic Portrait Engine |
| PRF_SMP_G04 | G4 | Male | Business Owner | `assets/avatars/g04_primary.png` | `assets/avatars/g04_request.png` | Pondy Connect Synthetic Portrait Engine |
| PRF_SMP_G05 | G5 | Male | Assistant Professor | `assets/avatars/g05_primary.png` | `assets/avatars/g05_request.png` | Pondy Connect Synthetic Portrait Engine |
| PRF_SMP_G06 | G6 | Male | School Teacher | `assets/avatars/g06_primary.png` | `assets/avatars/g06_request.png` | Pondy Connect Synthetic Portrait Engine |
| PRF_SMP_G07 | G7 | Male | Entrepreneur | `assets/avatars/g07_primary.png` | `assets/avatars/g07_request.png` | Pondy Connect Synthetic Portrait Engine |
| PRF_SMP_G08 | G8 | Male | Chartered Accountant (PRIME) | `assets/avatars/g08_primary.png` | `assets/avatars/g08_request.png` | Pondy Connect Synthetic Portrait Engine |
| PRF_SMP_G09 | G9 | Male | Scientist (Govt) | `assets/avatars/g09_primary.png` | `assets/avatars/g09_request.png` | Pondy Connect Synthetic Portrait Engine |
| PRF_SMP_G10 | G10 | Male | Data Scientist (NRI – Singapore) | `assets/avatars/g10_primary.png` | `assets/avatars/g10_request.png` | Pondy Connect Synthetic Portrait Engine |
| PRF_SMP_B01 | B1 | Female | Software Engineer (Techie, PRIME) | `assets/avatars/b01_primary.png` | `assets/avatars/b01_request.png` | Pondy Connect Synthetic Portrait Engine |
| PRF_SMP_B02 | B2 | Female | Nurse (Govt) | `assets/avatars/b02_primary.png` | `assets/avatars/b02_request.png` | Pondy Connect Synthetic Portrait Engine |
| PRF_SMP_B03 | B3 | Female | Doctor (PRIME ID-Verified) | `assets/avatars/b03_primary.png` | `assets/avatars/b03_request.png` | Pondy Connect Synthetic Portrait Engine |
| PRF_SMP_B04 | B4 | Female | Advocate (PRIME ID-Verified) | `assets/avatars/b04_primary.png` | `assets/avatars/b04_request.png` | Pondy Connect Synthetic Portrait Engine |
| PRF_SMP_B05 | B5 | Female | HR Manager | `assets/avatars/b05_primary.png` | `assets/avatars/b05_request.png` | Pondy Connect Synthetic Portrait Engine |
| PRF_SMP_B06 | B6 | Female | School Teacher | `assets/avatars/b06_primary.png` | `assets/avatars/b06_request.png` | Pondy Connect Synthetic Portrait Engine |
| PRF_SMP_B07 | B7 | Female | Lecturer | `assets/avatars/b07_primary.png` | `assets/avatars/b07_request.png` | Pondy Connect Synthetic Portrait Engine |
| PRF_SMP_B08 | B8 | Female | Architect | `assets/avatars/b08_primary.png` | `assets/avatars/b08_request.png` | Pondy Connect Synthetic Portrait Engine |
| PRF_SMP_B09 | B9 | Female | Pharmacist | `assets/avatars/b09_primary.png` | `assets/avatars/b09_request.png` | Pondy Connect Synthetic Portrait Engine |
| PRF_SMP_B10 | B10 | Female | Research Analyst (NRI – London) | `assets/avatars/b10_primary.png` | `assets/avatars/b10_request.png` | Pondy Connect Synthetic Portrait Engine |

---

## 3. Privacy & On-Request Rules

- For each profile, photo 1 is primary (public or logged-in members depending on `profile_photo_privacy`), photo 2 is gallery photo, and photo 3 is marked `on_request` privacy to demonstrate photo request flows.
