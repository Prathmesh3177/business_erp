# Shree Krushna Sales ERP — Administrator & Support Guide

## Overview
This document specifies technical administration, database migration procedures, data security key management, portable backup/restore operations, and support diagnostics for **Shree Krushna Sales ERP**.

---

## 1. System Setup & Data Security Architecture

### 1.1 First-Run Initialization
Upon initial launch of a fresh installation, the system prompts for:
- Organization Legal Name (`Shree Krushna Sales`) and Display Name.
- Branch Name (`Kalamb Main Branch`).
- Financial Year Start Date (defaulting to April 1st of the active year).
- Master Administrator Credentials (`admin` username and password).

### 1.2 Master Recovery Key Safeguard
- During first-run setup, a 16-character **Master Recovery Key** is generated and displayed.
- **IMPORTANT**: Store this key in a secure physical location or enterprise password vault. If an administrator forgets their password, this key is required to execute a password reset without data loss.

### 1.3 Local Database Encryption & Cipher Modes
- Per **ADR-013**, production deployments utilize SQLite with **SQLite3MultipleCiphers** (DPAPI-protected key on Windows / Keychain-protected key on macOS).
- In development or desktop fallback mode, standard SQLite is supported transparently without breaking schema contracts.

---

## 2. Backup, Restore & Recovery Runbook

### 2.1 Manual & Scheduled Backups
1. On the main menu screen, click **Backup & Recovery (ADR-013)**.
2. Click **Create Verified Backup Snapshot**.
3. The system generates a password-protected `.erpa` archive containing:
   - Encrypted database snapshot.
   - Managed attachment files (SHA-256 verified).
   - Document sequence state file.
4. **Overdue Backup Warning**: A warning badge displays on the dashboard if no backup has been generated within 24 hours.

### 2.2 Staged Disaster Recovery Procedure
1. Open **Backup & Recovery (ADR-013)** dialog.
2. Select the Target Backup Archive (`.erpa` file) and enter the archive password.
3. Click **Initiate Staged Restore**.
4. **Safety Snapshot**: The system automatically creates a local safety snapshot (`.pre_restore_safety.bak`) before modifying active storage.
5. **Reconciliation**: Post-restore reconciliation verifies Chart of Accounts balance invariants ($Dr = Cr$) and document sequence numbers.
6. If any verification step fails, the restoration automatically rolls back to `.pre_restore_safety.bak`.

---

## 3. Drift Database Schema Evolution (v1 to v10)

The system manages schema migrations automatically via Drift database migration hooks (`onUpgrade`):

| Version | Incremental Schema Additions |
|---|---|
| **v1** | Core foundation: `Organizations`, `Branches`, `FinancialPeriods`, `AppMetadata` |
| **v2** | Identity & Security: `Users`, `UserCredentials`, `Roles`, `Sessions`, `AuditEvents`, `LoginAttempts` |
| **v3** | Catalog & Masters: `Products`, `Parties`, `Attachments` |
| **v4** | Double-Entry Accounting: `JournalEntries`, `Accounts`, `DocumentSequences` |
| **v5** | Inventory & Valuation: `StockLocations`, `StockMovements`, `StockBalances`, `SerialRecords` |
| **v6** | Purchasing: `PurchaseHeaders`, `PurchaseLines`, `LandedCostAllocations` |
| **v7** | Sales & POS: `SalesHeaders`, `SalesLines`, `PosDrafts`, `WarrantyEntitlements` |
| **v8** | Finance & Returns: `SalesReturns`, `PurchaseReturns`, `Expenses`, `CashSessions`, `PartyAgeing` |
| **v9** | Solar Projects: `Quotations`, `QuotationLines`, `SolarProjects`, `ProjectMaterialIssues` |
| **v10** | Service & AMC: `ServiceJobs`, `ServiceJobVisits`, `AmcContracts`, `SerialReplacements` |

---

## 4. Support Diagnostics & Maintenance Commands

### 4.1 System Boundary & Documentation Integrity Verification
Run the integrated cross-platform verification script from terminal:
```bash
dart run tool/check_all.dart
```
This script checks:
- Package boundary compliance (`erp_domain` does not import `erp_application` or `erp_local_data`).
- Markdown link validity across `docs/`.
- Markdown code fence pairing integrity.

### 4.2 Diagnostic Logs & Audit Inspection
- Audit events are logged append-only in table `AuditEvents`.
- All sensitive parameters (passwords, tokens, tax registration numbers) are sanitized via `AuditRedactor` prior to storage.
- Admin users can view audit logs via **User Management** -> **Audit Log View**.
