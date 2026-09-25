# Operational Runbook: Release, Upgrade & Database Migration

Phase: P11 (V1 Release Gate)  
Last Updated: 2026-09-25  

This runbook documents the build packaging, database migration sequence, rollback plan, and license compliance rules for Solar Shop ERP V1 releases.

---

## 1. Release Packaging & Building

- **Target OS**: Windows 11 (Desktop Executable) / macOS (macOS App Bundle).
- **Flutter Framework Version**: Pinned to Flutter 3.47.5 / Dart 3.13.4.
- **Build Commands**:
  - Windows: `flutter build windows --release`
  - macOS: `flutter build macos --release`

---

## 2. Database Schema Migration Sequence

Drift SQLite database migrations execute automatically on application boot within `FoundationDatabase`:
- `schemaVersion = 1`: Foundation tables (Organizations, Branches, FinancialPeriods, Users).
- `schemaVersion = 2`: Identity & Security tables (UserCredentials, Roles, Sessions, AuditEvents, LoginAttempts).
- `schemaVersion = 3`: Catalog & Parties tables (Categories, Brands, Units, Products, Barcodes, Parties, Attachments, ImportCommands).
- `schemaVersion = 4`: Accounting & Money tables (Accounts, JournalEntries, JournalLines, DocumentHeaders, DocumentSequences, CommandResults).
- `schemaVersion = 5`: Inventory & Serials tables (Locations, StockMovements, StockBalances, Serials, SerialEvents, Reservations).
- `schemaVersion = 6`: Purchasing & Landed Cost tables (PurchaseHeaders, PurchaseLines, LandedCosts).
- `schemaVersion = 7`: Sales & Counter POS tables (SaleHeaders, SaleLines, SaleDrafts, Warranties).
- `schemaVersion = 8`: Payments, Returns & Expenses tables (SalesReturnHeaders, SalesReturnLines, PurchaseReturnHeaders, PurchaseReturnLines, ExpenseEntries, CashSessions).

---

## 3. Pre-Upgrade & Rollback Procedures

1. **Pre-Upgrade Step**:
   - Create an encrypted `.erpa` backup container before installing any app update.
2. **Upgrade Step**:
   - Run the new version installer. On startup, schema migrations execute inside a single SQLite transaction.
3. **Rollback Step**:
   - If migration fails or runtime errors occur post-update:
     1. Reinstall the previous executable build.
     2. Restore the pre-upgrade `.erpa` backup using `StagedRestoreUseCase`.

---

## 4. License Compliance & Open-Source Audit

- **Flutter / Dart Core**: BSD 3-Clause License.
- **Drift / sqlite3 / sqlite3mc**: MIT License / Public Domain.
- **Riverpod / GoRouter**: MIT License.
- **Devanagari Fonts**: OFL (Open Font License) embedded TTF fonts for Marathi rendering.
