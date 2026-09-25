# Release notes

## 2026-09-25 - P01 foundation increment (no product release)

- Added pure domain/application packages, encrypted Drift local data, platform vault/filesystem adapters, Riverpod/GoRouter shell, English/Marathi catalogs, first-run organization/branch/financial-year setup and a manual snapshot action.
- Added encrypted schema version 1 for organization identity only. No user credential, stock, tax, accounting or posting schema exists.
- Windows real-database tests passed restart persistence, wrong-key rejection, transaction rollback, schema-0 migration and verified encrypted snapshot reopening.
- Installation impact: exact package/app lockfiles are retained; sqlite3mc requires its pinned native asset and Windows C++ runtime/build prerequisites. Android SDK/JDK and macOS/Xcode requirements are unchanged and unverified.
- Recovery impact: the snapshot is consistent and encrypted but still uses the device-vault key. It is not a portable archive; no pilot data should be entered until password-wrapped recovery and clean-device restore pass.
- Locale switching now passes a Flutter widget test and Windows `flutter doctor` passes. Windows build/launch and live DPAPI vault behavior remain blocked because Developer Mode/symlink support is disabled; Android/macOS builds remain unavailable. Portable recovery is deferred to P11 before pilot data. This is not a distributable release.

## 2026-09-25 - P00 design gate (no product release)

- Validated and locked a compatible Flutter/Drift/encryption/PDF dependency candidate set in disposable spikes.
- Selected SQLite3MultipleCiphers plus OS-vault data-key protection and independent portable recovery wrapping through ADR-013.
- Proved Windows sqlite encryption failure paths, portable key wrapping, and visually correct HarfBuzz-shaped Marathi PDF output.
- No ERP feature, production schema, installer or distributable build was added. No data migration is required.
- Installation impact for later phases: native C/C++ build tools are required for sqlite3mc/HarfBuzz; Android needs JDK 17+ and Android SDK; macOS needs Xcode; a licensed Devanagari TTF and notices must ship with the app.
- Recovery impact for later phases: start the first production database encrypted; preserve versioned KDF/cipher metadata in backup archives; P11 must still prove clean-device restore, wrong key, corruption and disk-full behavior.
- Unsupported: macOS, Android, cloud sign-in, OS-vault integration and all physical printers/scanners remain unverified. The generated Android release configuration still uses a debug key and generated app identifiers.

