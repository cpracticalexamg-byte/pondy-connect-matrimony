# Pondy Connect Matrimony — Database Architecture

This directory houses the offline-first relational CSV database and Azure cloud migration specifications.

```
db/
  README.md                 # This guide
  schema/
    tables.manifest.json    # Complete schema manifest (columns, PKs, FKs, types)
    schema.sql              # Azure SQL Database compatible DDL
    data_dictionary.md      # Human-readable column specifications
  master/                   # 48 Read-only reference tables (bundled with app)
  data/                     # Production transactional tables (Headers only in release)
  azure/
    IMPORT_GUIDE.md         # Step-by-step Azure migration manual
    import_order.txt        # FK-respecting load order
    blob_manifest.csv       # Asset path mappings for Azure Blob Storage
```
