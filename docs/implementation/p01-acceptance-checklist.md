# P01 acceptance checklist

Status: **In progress — code and locale behavior implemented; Windows build/launch still host-blocked.**

| Gate | Evidence | Result |
|---|---|---|
| Domain/application boundaries | Five package/app analyzers and `tool/check-package-boundaries.ps1` | Pass |
| Core IDs, clock, typed errors, redacted logs, config, theme, setup | Package sources and unit tests | Pass for implemented contracts |
| Real encrypted Drift persistence | Five-test sqlite3mc integration suite | Pass on Windows x64 |
| Foreign keys and transaction-scoped UnitOfWork | Schema constraints plus deliberate rollback test | Pass |
| Initial migration | Encrypted schema-0 to schema-1 integration test | Pass |
| Consistent snapshot | `VACUUM INTO`, integrity/schema verification, encrypted reopen | Pass for same-device snapshot |
| English/Marathi locale switch | ARB catalogs and Flutter widget test | Pass on Windows Flutter 3.47.5 |
| Windows app open/build and live OS vault | Runner/wiring exist; doctor passes Windows toolchain | Blocked: Windows Developer Mode/symlink privilege is disabled; not claimed |
| Android build | Runner exists | Blocked: SDK/adb/device absent and JDK configuration unresolved |
| macOS build | Runner exists | Not run: no Mac/Xcode |
| Portable recovery | P00 algorithm proof only | Deferred to P11 final hardening by product owner; not a P01 completion claim or permission for pilot data |

Exact handoff: enable Windows Developer Mode (or provide an administrator-granted symlink privilege), rerun `flutter build windows --debug`, launch the app, and exercise DPAPI-backed vault create/read/restart/corruption/missing-key paths. Portable password-wrapped recovery and staged clean-machine restore are deliberately deferred to P11 final hardening; they remain mandatory before pilot/production data, but do not silently block development of the working shell.
