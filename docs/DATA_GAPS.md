# Pondy Connect Matrimony — Master Data Gaps & Review Register

This register logs any catalog items where an authoritative public source had ambiguities or where a standardized regional transliteration was adopted.

| Entity | Field / Item | Observation & Adopted Treatment | Verification Status |
|---|---|---|---|
| `caste.csv` | Caste No Bar (`caste_none`) | Included with code `caste_none` as a non-restrictive option for modern progressive candidates. | Validated in registration filters |
| `gothram.csv` | Don't Know | Included as `dont_know` to allow candidates without traditional gothram records to complete the astrology block smoothly. | UI fallback verified |
| `country.csv` | Priority ordering | Priority weighting applied for India and top 17 Tamil diaspora destinations (US, UAE, Singapore, Malaysia, UK, Canada, Australia, France for Puducherry links). | UX-approved |
| `district.csv` | Puducherry regions | Puducherry, Karaikal, Mahe, and Yanam are classified under UT of Puducherry (`state_id: 1`) as independent district administrative units. | Aligns with India LGD |
