# Project status

Last updated: 2026-09-25.

**P01 foundation implementation is in progress. Boundaries, encrypted schema v1 and English/Marathi widget behavior have real Windows evidence. Flutter doctor passes, but Windows Developer Mode/symlink support blocks the plugin build, app launch and live vault verification. Portable fresh-device recovery is deferred to P11 final hardening and remains mandatory before pilot data.**

| Phase | Status | Evidence / next action |
|---|---|---|
| P00 | Complete | [Platform matrix](../implementation/platform-matrix.md), [dependencies](../implementation/dependency-register.md), [business validation](../implementation/business-validation.md), [acceptance checklist](../implementation/p00-acceptance-checklist.md), [ADR-013](../adr/ADR-013-local-database-encryption-and-recovery.md) and [test evidence](test-evidence.md). Windows encryption/recovery/PDF paths passed; unavailable platforms/business/hardware are explicit blockers. |
| P01 | In progress | [Development setup](../implementation/development-setup.md), [migration notes](../implementation/p01-migration-notes.md), [acceptance checklist](../implementation/p01-acceptance-checklist.md) and [test evidence](test-evidence.md). Five sqlite3mc tests and the English/Marathi widget test pass; analyzers/boundaries pass. Exit blocked by Windows symlink support, app launch and live vault verification. Portable recovery is deferred to P11, before pilot data. |
| P02 | Not started | Identity/security |
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
