# Pondy Connect Matrimony — Master Data Sources & Provenance

This document records the authoritative public registries, government Gazettes, and standard panchangam references used to compile the master tables in `db/master/`.

**Retrieval & Harmonization Date:** October 7, 2026  
**Compiler:** Pondy Connect Matrimony Data Engineering Team

---

## 1. Castes & Communities (Tamil Nadu & Puducherry)

- **Official Source 1:** Government of Tamil Nadu, Backward Classes, Most Backward Classes and Minorities Welfare Department.
  - *URL / Gazette Reference:* [https://www.bcmbcmw.tn.gov.in/bclist.htm](https://www.bcmbcmw.tn.gov.in/bclist.htm)
  - *List of Backward Classes (BC), Most Backward Classes (MBC), and Denotified Communities (DNC).*
- **Official Source 2:** Government of Tamil Nadu, Adi Dravidar and Tribal Welfare Department.
  - *URL:* [https://adtw.tn.gov.in/](https://adtw.tn.gov.in/)
  - *Official Annexure of Scheduled Castes (SC), Scheduled Castes Arunthathiyar (SCA), and Scheduled Tribes (ST).*
- **Matrimony Taxonomy Benchmark:** Registration community taxonomies of Tamil Matrimony and Bharat Matrimony networks (harmonized labels: Kongu Vellalar/Gounder, Mudaliar, Vanniyar, Nadar, Thevar/Mukkulathor, Brahmin Iyer/Iyengar, Chettiar, Yadava, Pillai, Vishwakarma, etc.).

## 2. Geography & Administrative Units

- **Official Source 1:** Local Government Directory (LGD), Ministry of Panchayati Raj, Government of India.
  - *URL:* [https://lgdirectory.gov.in/](https://lgdirectory.gov.in/)
  - *Standard administrative code hierarchy for all 28 States, 8 Union Territories, and Indian Districts.*
- **Official Source 2:** Government of Puducherry Directorate of Economics and Statistics.
  - *URL:* [https://statistics.py.gov.in/](https://statistics.py.gov.in/)
  - *Regions, Municipalities, and Communes for Puducherry, Karaikal, Mahe, and Yanam.*
- **Official Source 3:** ISO 3166-1 Alpha-2 and Alpha-3 standard country registry and ITU-T E.164 dial codes.

## 3. Vedic Panchangam & 10-Porutham Astrology

- **Astronomical & Astrological Reference:** Traditional Tamil Panchangam (Vakya and Thiru Kanidha Panchangam standards).
- **Nakshatra-Padam-Rasi System:** 27 Stars x 4 Padams = 108 Charanas mapped across 12 Moon signs (Rasis) at 2.25 stars (9 padams) per sign.
- **10-Porutham Compatibility Matrices:**
  - Dina Porutham (Count method from bride to groom star)
  - Gana Porutham (Deva, Manushya, Rakshasa compatibility)
  - Mahendra Porutham (Star index intervals 4, 7, 10, 13, 16, 19, 22, 25)
  - Stree Deergha Porutham (Distance >= 13 nakshatras)
  - Yoni Porutham (Natural friendship and enmity of animal archetypes)
  - Rasi Porutham (6/8 Sashtashtaga exclusion rules)
  - Rasi Adhipathi Porutham (Planetary ruler natural & temporal friendship)
  - Vasya Porutham (Subservient and magnetic rasi pairings)
  - Rajju Porutham (Shiro, Kantha, Udara, Kati, Pada – strict exclusion of identical Rajju)
  - Vedha Porutham (Inimical nakshatra pairs)
