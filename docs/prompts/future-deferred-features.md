# Future Deferred Features

> This document tracks features that were intentionally removed or deferred from the current development phase. These features will be implemented when the application is ready to upgrade from local SQLite to Firebase/cloud and when AI capabilities are added.

**Date deferred**: 2026-09-25
**Reason**: Focus on building a working local-database application first. Cloud migration and AI features are planned for later phases.

---

## 1. AI / ML Features (Removed from all prompts P11–P17)

The following AI-related references were removed from prompts. None of these were implemented — they were guard-rail clauses preventing accidental AI additions.

| Original Prompt | Removed Content | Notes |
|---|---|---|
| P11–P17 (all) | `"Do not add product AI, OCR, chatbots, model APIs, embeddings or forecasting models. AI is only the coding assistant."` | Replaced with simplified `"No AI/ML features are in scope for this application."` |
| P16, Task 4 | `"No AI diagnosis or OCR."` | Redundant with general AI exclusion clause |
| P17, Task 1 | `"Search dependencies/UI/config for accidentally introduced AI features and remove them from scope."` | Unnecessary since AI was never implemented |
| P17, Task 1 | `"non-AI supplied features"` | Changed to `"supplied features"` |
| P17, Exit gate | `"Complete non-AI ERP delivery"` | Changed to `"Complete ERP delivery"` |

### Future AI Features to Consider
When AI is added to the application, consider:
- **OCR** — Invoice/document scanning and data extraction
- **Chatbots** — Customer support automation
- **Forecasting models** — Demand prediction, sales forecasting
- **Embeddings** — Product similarity search, smart recommendations
- **AI diagnosis** — Equipment fault diagnosis for service/AMC workflows

---

## 2. Database Encryption (Removed from P11)

Encryption features were removed from the backup/restore workflow since the current focus is on getting a working application with plain local SQLite.

| Original Prompt | Removed Content | Replacement |
|---|---|---|
| P11, Task 1 | `"automatic/manual encrypted backups"` | `"automatic/manual backups"` |
| P11, Task 2 | `"schema/integrity/hash validation"` | `"schema/integrity validation"` |
| P11, Task 2 | `"Rehearse replacement-machine recovery with portable keys."` | `"Rehearse replacement-machine recovery."` |

### Future Encryption Features to Implement
When upgrading to production/Firebase:
- **Encrypted backups** — AES-256 encryption for backup files at rest
- **Portable encryption keys** — Key management for backup recovery across machines
- **Hash validation** — SHA-256 hash verification of backup file integrity
- **Database encryption** — SQLCipher or equivalent for encrypting the local SQLite database
- **TLS for sync** — Transport encryption for data synchronization

---

## 3. Cloud Platform — P13 (Entire Phase Deferred)

**Original prompt**: [P13-cloud-platform.md](P13-cloud-platform.md)
**Status**: Deferred — original content preserved in a collapsed `<details>` block within the prompt file.

### Features Deferred

| Feature | Description |
|---|---|
| **PostgreSQL cloud schema** | Dart API/worker modular service with PostgreSQL |
| **OIDC/device enrollment** | Branch-scoped authorization with OIDC |
| **Firebase Auth/Storage** | Authentication and file storage via Firebase (behind ports) |
| **FlutterFire Windows** | Windows sign-in through production-supported adapter |
| **Event ingestion** | Transactional ordered event ingestion with deduplication |
| **Cloud backup manifest** | Cloud-side backup manifest handling |
| **Tenant isolation** | Multi-tenant isolation checks and limits |
| **Staging deployment** | Cloud staging environment |
| **OpenAPI contracts** | API contracts and CI |

### When to Revisit
- After V1.5 (P12) is working and tested on local database
- When Firebase project credentials are available
- When cloud infrastructure budget is confirmed

---

## 4. Multi-Branch Synchronization — P14 (Entire Phase Deferred)

**Original prompt**: [P14-sync-branches.md](P14-sync-branches.md)
**Status**: Deferred — original content preserved in a collapsed `<details>` block within the prompt file.

### Features Deferred

| Feature | Description |
|---|---|
| **Branch agent** | LAN command/query API with authenticated TLS |
| **Durable outbox transport** | Ordered retry/dedup for event transport |
| **Master proposals/conflict resolution** | Multi-branch conflict handling |
| **Branch locations/permissions** | Multi-location branch management |
| **Global credit budgets** | Cross-branch credit limit management |
| **Transfer workflows** | Dispatch/transit/partial receipt between branches |
| **Paired-device recovery** | Device recovery and authority fencing |
| **WAN/LAN resilience** | Continued operation during network outages |

### When to Revisit
- After P13 (cloud platform) is implemented
- When multi-branch operation is actually needed
- When WAN/LAN infrastructure is set up

---

## 5. Prerequisite Chain Changes

The prompt prerequisite chain was updated to skip deferred cloud phases:

```
Original: P11 → P12 → P13 → P14 → P15 → P16 → P17
Updated:  P11 → P12 → P15 → P16 → P17
                  ↓
            P13 → P14 (deferred, to be done when cloud is ready)
```

P15 prerequisite changed from P14 to P12, with a note that P13/P14 are deferred.

---

## 6. Local Database Notes Added

All active prompts (P11, P12, P15, P16, P17) now include:
```
Use local SQLite database; cloud/Firebase migration is deferred.
```

This ensures the coding assistant uses SQLite for all database operations and does not introduce Firebase/cloud dependencies prematurely.
