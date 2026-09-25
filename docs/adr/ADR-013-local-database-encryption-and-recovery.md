# ADR-013: SQLite3MultipleCiphers with independent portable key recovery

- Date: 2026-09-25
- Status: Accepted for implementation; cross-platform release evidence pending

P01 implementation note (2026-09-25): the production Drift isolate/schema path now verifies sqlite3mc, keys before schema access, uses memory temp storage and passed Windows restart, wrong-key, rollback, migration and same-key snapshot tests. The Flutter OS-vault runtime and password-wrapped portable archive/restore are still unverified/unimplemented, so this ADR is not a completed recovery claim.

## Context

The baseline selected Drift/SQLite but left the encryption library and portable recovery mechanism unresolved. Ordinary SQLite is plaintext. The database key must be protected by each OS while a replacement device must still be able to restore an encrypted backup without copying a device-bound vault secret.

## Options considered

1. Plain SQLite plus full-disk encryption only: rejected because copied database/backup files would not have application-level protection.
2. Commercial SQLite SEE: technically credible, but requires a paid source license and custom binary process not presently justified.
3. Legacy `sqlcipher_flutter_libs`: rejected because current Drift/sqlite3 documentation marks it obsolete.
4. Drift `NativeDatabase` over `sqlite3` 3.x configured for SQLite3MultipleCiphers, with an OS-vault data key and separately wrapped portable recovery key: selected.

## Decision and evidence

Use `drift` 2.35.0 with `sqlite3` 3.6.0 and the `source: sqlite3mc` build-hook configuration. At database setup, verify that `PRAGMA cipher` is present, set the key before any schema query, set temp storage to memory, and fail closed if encryption is unavailable. The Windows P00 spike compiled the native asset and proved the default `chacha20` cipher, rejection of unkeyed/wrong-key reads, and correct-key recovery.

Generate a random 256-bit database key. Store its device copy through a platform vault adapter (Windows DPAPI-protected application storage, macOS Keychain, Android Keystore-backed storage after tests). For recovery/export, wrap the data key with a password-derived key using reviewed Argon2id parameters and AES-256-GCM. The P00 algorithm spike passed round-trip and wrong-password authentication failure. The recovery archive stores versioned KDF/cipher parameters and salt, never the plaintext key.

## Consequences

- Native C compilation becomes an installation/build prerequisite. Every shipping platform must prove the encrypted build, vault lifecycle, wrong-key behavior, migrations and recovery.
- SQLite3MultipleCiphers limitations apply: temp tables are not encrypted, so temp storage stays in memory; metadata/header behavior and journal/WAL handling require tests.
- A lost device-vault key is recoverable only with valid portable recovery material. Losing both remains permanent data loss and must be explained during setup.
- Recovery passwords are never retained as routine application secrets. KDF parameters are versioned and benchmarked before release.
- Existing plaintext pilot data, if any, must be migrated through a verified staged export/import with backup and rollback; P00 contains no production data and performs no migration.
- This does not change domain, fixed-point, posting, permission or one-authority boundaries.

## Reversal plan

Keep encryption and vault ports outside domain/application packages. A future audited engine can replace sqlite3mc by decrypting/exporting through a verified maintenance migration, reconciling manifests/control totals, importing into the replacement, and preserving rollback material. Changing cipher/storage format requires a new ADR and recovery drill.

## Affected documents

[Architecture](../02-architecture.md), [security and operations](../06-security-and-operations.md), [platform matrix](../implementation/platform-matrix.md), and [dependency register](../implementation/dependency-register.md).
