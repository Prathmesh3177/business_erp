# Security, backup and operations

## Threat model and authorization

Protect against unauthorized staff actions, stolen backups/devices, accidental data loss, malformed imports and cross-tenant access. A person with unrestricted OS administrator access can tamper with a running local application; an offline audit table is not proof against that adversary. Use OS accounts, restricted file permissions and full-disk encryption along with application controls. Cloud replication improves evidence durability.

Use audited password hashing (Argon2id candidate) with per-password random salt and parameters benchmarked on supported hardware; never invent crypto. First-run setup creates the initial administrator with no shipped default password. Store secrets outside source code/logs/database settings. Persist sessions only through protected storage; enforce idle locking, failed-login throttling and reauthentication for key export, restore, user privileges and large refunds. Explicitly log recovery events. Offline local authentication must work without cloud credentials in V1.

Enforce role, organization, branch, document state and approval limits in application commands and server endpoints, not only routing. Sensitive cost data must be absent from unauthorized query DTOs, exports and diagnostics. Permissions use deny-by-default. Audit records include actor/device/session, action, entity, reason, correlation ID, UTC time and redacted old/new values. Exclude passwords, tokens, keys, unnecessary PAN/bank details and photo bytes.

V2 offline role grants have a maximum configured validity (default proposed seven days, finalized during enrollment). Branch authority evaluates cached signed grants. Revocation cannot reach an offline branch instantly; show expiry and document this tradeoff. An expired grant blocks protected posting until renewed or an audited local recovery policy is applied. Local Administrator is not silently equivalent to organization cloud owner.

## Encryption and file handling

Database encryption must be proven on all shipping platforms; ordinary Drift/SQLite is not automatically encrypted. P00 selected Drift/native sqlite3 with SQLite3MultipleCiphers through [ADR-013](adr/ADR-013-local-database-encryption-and-recovery.md). The Windows sqlite-layer spike proved cipher activation and correct/wrong/missing-key behavior, but the production Drift schema, OS vault and macOS/Android builds remain unverified. Production startup must verify cipher availability, apply the key before any schema query, use memory temp storage and fail closed.

Generate a random database data key and keep its routine copy behind a platform-vault port. The Windows candidate is DPAPI-protected application storage rather than Credential Manager; test application separation, file ACLs, corruption, profile/password changes and removal. Test Keychain and Android Keystore paths on real targets. Backups use independent authenticated encryption and a recovery password-derived wrapping key portable to a replacement machine. P00 proved an Argon2id/AES-256-GCM wrapping algorithm including wrong-password rejection. The product owner prioritized the working application shell and deferred final parameters, production archive format, operator flow and clean-device drill to P11; no pilot/production data is authorized before that gate passes. Losing both device key and recovery material means data is unrecoverable; setup includes a recovery check before release.

Attachments use an application-managed directory and content hashes. Write to temporary file, validate type/size/decode, hash, atomically rename, then link the manifest. Handle crashes/orphans with a grace-period cleanup job. Reject path traversal, executable masquerading, oversized decoded images and archive extraction escapes. Keep customer documents private; signed cloud object links expire. Do not log signed URLs.

## Backup policy

Defaults: hourly while running, on orderly close when appropriate, and mandatory pre-migration/manual snapshots. Proposed retention: 24 hourly, 14 daily and 8 weekly validated backups, bounded by disk quota and organization retention requirements. A schedule cannot run when the app/agent is stopped: run an overdue backup at next launch and display last success prominently. A scheduled OS agent is introduced only if required and tested.

Backup manifest includes format/app/schema version, tenant/branch, authority epoch, latest posting/outbox sequence, document count, journal/stock control totals, creation time, attachment hash list and archive hash. Use SQLite's supported consistent backup mechanism or an equivalent tested snapshot; never copy only a live `.db` file while ignoring WAL. Pin the attachment manifest during backup and prevent cleanup of referenced objects. Include required key-recovery metadata, not plaintext encryption keys.

Write encrypted archive to a temporary destination, verify readability/authentication and manifest, then atomically finalize. Record failures, available space and verified success separately. Retention deletes only old validated copies, never the only restorable backup. Local backups protect against application failure, not total disk loss; configure an external drive/manual encrypted export in V1 and optional cloud copy in V2. Missing external storage is visible, not silently reported as success.

## Restore runbook

1. Administrator selects archive and authenticates; show timestamp, organization, version, target and whether newer local data exists.
2. Enter maintenance mode, stop posting/sync/printing jobs, create and verify a safety backup of current data. If space cannot support recovery safely, stop with a clear action.
3. Decrypt/extract into staging with path/size limits. Validate manifest, SQLite integrity/FKs, attachment hashes, supported schema and tenant. Run upgrades against staging only.
4. Reconcile stock totals, journal balance, party control totals, document counts, numbering and sync identity. Reject wrong tenant/unsupported future schema.
5. Close DB handles, atomically switch the validated data set, reopen and run smoke checks. On failure retain/revert to the prior data set. Keep a recovery marker so restart can finish or roll back the swap.
6. For an existing trading business, keep posting disabled until numbers and events since the backup are reconciled. Restore to replacement hardware requires portable key recovery; V2 requires new device enrollment and authority epoch/fencing.
7. Record operator, archive hash, totals, outcome, duration and remaining reconciliation work. Do not automatically resend old reminders, print jobs or financial commands.

P01 migration/recovery impact: schema version 1 starts encrypted and a Windows sqlite3mc suite proved restart persistence, wrong-key rejection, rollback, schema-0 creation upgrade and a verified same-key snapshot. The app provisions a random key through a vault port and refuses to create a replacement key when an existing database has lost its vault entry. Live DPAPI/Keychain/Keystore calls and fresh-device restore remain unverified. The snapshot is device-key-bound; independent password-wrapped recovery, archive manifest, restore staging/swap and clean-device drill still block pilot data. See [P01 migration notes](implementation/p01-migration-notes.md).

Targets: local hourly backup recovery point <= one hour only while the process is running successfully; external/cloud recovery point depends on last verified copy. Proposed recovery time <= 60 minutes at the benchmark dataset, measured on replacement hardware. These are release targets, not guarantees before testing.

## Diagnostics, release and support

Keep bounded rotating structured logs with error code, command ID, duration and redacted context. Support export previews what will be shared; no automatic customer-data upload. Detect low disk before posting/backup; a failed commit must not produce a successful invoice UI. App update checks must not interrupt trading. Package a versioned installer, verify signature, verify upgrade compatibility, back up, update, smoke test; binary rollback uses a compatible DB or a verified backup, never arbitrary schema downgrade.

CI runs static checks, domain/DB tests and platform builds on actual OS runners. macOS signing/notarization requires Mac tooling and credentials; Windows signing requires configured certificates; Android release signing requires controlled key custody. Keep these as explicit release gates. Maintain a dependency/license inventory, security update routine, secret scanning, release notes and migration/recovery instructions.

Retention and deletion policy separates legally retained invoices/ledgers from optional contact/photo data. Deactivate masters, restrict PII exports and audit access. Define specific retention periods with the business before destructive cleanup; never delete financial history as generic storage maintenance.
