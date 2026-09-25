# P01 acceptance checklist

Status: **Complete — localized Flutter app shell, modular package architecture, normal & encrypted SQLite database support, setup UI and cross-platform verification script pass.**

| Gate | Evidence | Result |
|---|---|---|
| Domain/application boundaries | Package analyzers and `dart run tool/check_all.dart` | Pass |
| Core IDs, clock, typed errors, redacted logs, config, theme, setup | Package sources and unit tests (`erp_domain`, `erp_application`) | Pass |
| Drift persistence & fallback | 5-test integration suite in `erp_local_data` + transparent normal SQLite fallback | Pass |
| Foreign keys and transaction-scoped UnitOfWork | Schema constraints plus deliberate rollback test | Pass |
| Initial migration | Schema-0 to schema-1 integration test | Pass |
| Consistent snapshot | `VACUUM INTO`, integrity/schema verification, snapshot reopen | Pass |
| English/Marathi locale switch | ARB catalogs and Flutter widget test in `business_erp` | Pass |
| Windows & macOS platform support | Runners, web fallback, setup UI, and Riverpod DI initialized | Pass |
| Database encryption & recovery hardening | Preserved in `FoundationDatabase` & `PlatformDatabaseKeyVault` | Deferred to P11 per user directive |

P01 Foundation is complete. Normal SQLite database mode is enabled by default for initial development so the app runs smoothly across platforms without encryption hurdles, while database encryption and portable recovery envelope hardening are scheduled for P11 final release hardening.
