# Operational Runbook: Backup & Recovery Procedures

Phase: P11 (V1 Release Gate)  
Last Updated: 2026-09-25  

This runbook documents the standard operational procedures for backup creation, automatic overdue alerts, password-protected envelope encryption (ADR-013), and replacement-machine hardware restore drills.

---

## 1. Backup Architecture & Encryption (ADR-013)

- **Portable Recovery Envelope**: `.erpa` container file.
- **Payload Encryption**: Argon2id key derivation & PBKDF2 / AES-256-GCM ciphering.
- **Checksum Integrity**: SHA-256 manifest hash calculation for the active database (`foundation.db`) and all file attachments (`/attachments/*`).
- **Overdue Threshold**: 24 hours. A warning alert is raised if no verified backup has been completed within 24 hours.

---

## 2. Standard Backup Creation Procedure

1. Launch Solar Shop ERP desktop app.
2. From the main screen, click **Backup & Recovery (ADR-013)**.
3. Enter a strong backup encryption password (minimum 6 characters).
4. Click **Create Backup**.
5. The system:
   - Computes SHA-256 digest of active SQLite database.
   - Computes SHA-256 digest of all attachments.
   - Generates `manifest.json`.
   - Encrypts and saves the `.erpa` backup container in the system backup directory or user-selected external drive.

---

## 3. Replacement Machine Staged Restore & Recovery Procedure

1. Install Solar Shop ERP on target replacement machine.
2. Copy the `.erpa` backup package file to the system.
3. Open **Backup & Recovery (ADR-013)** modal.
4. Enter the password used during backup creation.
5. Click **Restore Backup**.
6. **Automated Safety Sequence**:
   - **Step 1 (Lock)**: Enforces maintenance mode locking active user input.
   - **Step 2 (Safety Copy)**: Creates a verified pre-restore safety copy (`.pre_restore_safety.bak`) of the current live database.
   - **Step 3 (Verification)**: Decrypts package, parses `manifest.json`, and verifies database SHA-256 checksums and file attachment hashes.
   - **Step 4 (Atomic Swap)**: Overwrites active database and attachment directory.
   - **Step 5 (Reconciliation)**: Reconciles Chart of Accounts and Document Sequence numbers.
   - **Step 6 (Release)**: Unlocks maintenance mode and presents completion summary.

> [!IMPORTANT]
> **Automatic Rollback Guarantee**: If package checksum verification fails or a wrong password is provided, the restore process aborts instantly, restores the live state from `.pre_restore_safety.bak`, and releases maintenance mode. No live data is ever lost.

---

## 4. Emergency Troubleshooting & Fault Recovery

| Symptom / Error | Root Cause | Resolution Procedure |
|---|---|---|
| `Decryption or verification failed` | Incorrect password or corrupted `.erpa` container bytes | Verify password with administrator. Re-export backup from source machine if container was corrupted during transfer. |
| `Database SHA-256 checksum mismatch` | Disk corruption or tampered payload | Reject backup container. Use an earlier verified `.erpa` backup file. |
| `Insufficient disk space` | Disk capacity < 50 MB | Free disk space on host drive before initiating restore drill. |
