# Pondy Connect Matrimony V2 — Azure Cloud Migration Guide

This step-by-step guide explains how to migrate the local CSV database and photo assets to **Azure SQL Database** and **Azure Blob Storage** when cloud backend deployment is initiated.

---

## Architecture Overview

- **Relational Data:** Migrated to Azure SQL Database using `schema.sql` and Azure Data Factory or `bcp` utility.
- **Master Data:** Pre-loaded from `db/master/` as reference tables.
- **Photos & Horoscope Files:** Uploaded to Azure Blob Storage under private containers with SAS tokens.
- **Authentication:** Azure Communication Services for SMS OTP or Microsoft Entra External ID.

---

## Step 1: Provision Azure Resources

1. **Resource Group:** Create `rg-pondyconnect-prod-southindia` in the South India or Central India region.
2. **Azure SQL Database:**
   - Server: `sql-pondyconnect-prod.database.windows.net`
   - Database: `pondyconnect_db` (General Purpose Serverless or standard tier)
   - Collation: `SQL_Latin1_General_CP1_CI_AS` with UTF-8 support.
3. **Azure Blob Storage:**
   - Account: `stpondyconnectprod`
   - Containers:
     - `profile-photos-public` (Blob anonymous read or SAS)
     - `profile-photos-private` (Private, SAS token with 15-minute expiry)
     - `horoscopes` (Private, strictly SAS with owner/verified check)

---

## Step 2: Deploy Schema

Open Azure Data Studio or SQL Server Management Studio (SSMS) and connect to `sql-pondyconnect-prod`:
```bash
sqlcmd -S sql-pondyconnect-prod.database.windows.net -d pondyconnect_db -U sqladmin -P "YourStrongPassword" -i db/schema/schema.sql
```

---

## Step 3: Bulk Import Transactional CSVs

Execute `bcp` for each table following `db/azure/import_order.txt`:
```bash
# Example bcp command for users table
bcp pondyconnect_db.dbo.users in "db/data/users.csv" -c -t"," -r"\n" -F 2 -S sql-pondyconnect-prod.database.windows.net -U sqladmin -P "YourStrongPassword"
```

---

## Step 4: Sync Blob Assets

Use `AzCopy` to upload photo files matching `db/azure/blob_manifest.csv`:
```bash
azcopy copy "assets/sample_photos/*" "https://stpondyconnectprod.blob.core.windows.net/profile-photos-public/?<SAS_TOKEN>" --recursive
```
