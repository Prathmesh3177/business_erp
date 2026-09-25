# Project status

Last updated: 2026-09-25.

**P02 identity, authorization and auditing implementation is complete. PBKDF2-HMAC-SHA256 password hashing, capability RBAC (Admin, Counter), last-administrator safeguard, login throttling, recovery key reset, command-level authorization, append-only redacted audit logs, and Drift schema v2 migration pass.**

| Phase | Status | Evidence / next action |
|---|---|---|
| P00 | Complete | [Platform matrix](../implementation/platform-matrix.md), [dependencies](../implementation/dependency-register.md), [business validation](../implementation/business-validation.md), [acceptance checklist](../implementation/p00-acceptance-checklist.md), [ADR-013](../adr/ADR-013-local-database-encryption-and-recovery.md) and [test evidence](test-evidence.md). Windows encryption/recovery/PDF paths passed; unavailable platforms/business/hardware are explicit blockers. |
| P01 | Complete | [Development setup](../implementation/development-setup.md), [migration notes](../implementation/p01-migration-notes.md), [acceptance checklist](../implementation/p01-acceptance-checklist.md), `tool/check_all.dart` and [test evidence](test-evidence.md). Domain, application, local data, and widget tests pass; analyzers/boundaries pass. Normal database fallback supported for Windows and macOS. |
| P02 | Complete | [Security & permissions spec](../implementation/security-permissions.md), `tool/check_all.dart` and [test evidence](test-evidence.md). T08 command denial passes; PBKDF2 password hashing, last-admin safeguard, recovery key reset, audit redactor, Drift schema v2, login UI, idle lock modal, and user management UI pass. |
| P03 | Not started | Catalog/parties |
| P04 | Not started | Money/tax/accounts |
| P05 | Not started | Inventory |
| P06 | Not started | Purchases |
| P07 | Not started | POS/sales |
| P08 | Not started | Payments/returns/expenses |
| P09 | Not started | Printing/scanning |
| P10 | Not started | Reports |
| P11 | Not started | V1 certification |
| P12 | Not started | Android/V1.5 |
| P13 | Not started | Cloud foundations |
| P14 | Not started | Sync/branches/V2 |
| P15 | Not started | Projects |
| P16 | Not started | Service/AMC |
| P17 | Not started | V3 acceptance |

Allowed states: Not started, In progress, Blocked, Implemented awaiting verification, Complete. Update a phase with real evidence links, actual scope and remaining work. Missing environment/hardware checks cannot be labeled complete.
