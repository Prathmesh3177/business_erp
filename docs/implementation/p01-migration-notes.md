# P01 schema and recovery notes

## Schema version 1

The first production schema is encrypted from its first open. `PRAGMA cipher` is required, a 256-bit key is applied before schema access, temporary storage is in memory, and foreign keys are enabled. Startup fails if sqlite3mc is absent or the key is missing/wrong.

| Table | Purpose and constraints |
|---|---|
| `organizations` | Text UUID primary key, legal/display names, UTC creation epoch |
| `branches` | Text UUID primary key; restrictive FK to organization; unique `(id, organization_id)`; timezone and stable locale code |
| `financial_periods` | Text UUID primary key; restrictive organization FK and composite `(branch_id, organization_id)` FK; `ends_on > starts_on`; locked flag defaults false |
| `app_metadata` | Stable key/value settings; P01 writes `authority_mode=single_branch` |

Dates are persisted as ISO `YYYY-MM-DD`; audit instants use UTC epoch milliseconds. No money, quantity, tax, credential, posting, audit or outbox table is introduced in P01.

Migration `0 -> 1` creates these constrained tables. The integration suite created an encrypted schema-0 file, opened it through the production Drift isolate, migrated it, inserted setup, and read it back. A deliberate exception after all setup inserts proved the transaction rolls back all rows.

## Backup and rollback behavior

Manual snapshot uses SQLite `VACUUM INTO` after a full WAL checkpoint, writes to a staging file, reopens it with the same encryption key, checks `PRAGMA integrity_check` and schema version, then renames it to the final destination. An existing target is never overwritten. The test reopened the final encrypted snapshot and read the persisted identity.

This is a consistent same-device recovery foundation, not a portable archive or a completed restore workflow. The snapshot currently depends on the device-vault key. The product owner deferred the independent password-wrapped recovery envelope, manifest, restore staging/swap, safety backup and clean-device drill to P11 so development can first produce a working application. Do not put pilot/production data into the app until that P11 gate is implemented and verified.

Migration failures do not delete, replace or downgrade the source database. Future schema upgrades must create and verify a pre-migration snapshot, migrate a staging or safely backed-up database, and retain rollback material. There is no supported plaintext-to-v1 migration because no production plaintext database exists.
