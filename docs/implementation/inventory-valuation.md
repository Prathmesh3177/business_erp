# Inventory Valuation, Stock Movements, and Serial Tracking Implementation

## Overview

This document details the architecture, valuation formulas, ledger rebuild mechanics, and serial/batch tracking primitives implemented in **P05 — Inventory, Valuation and Serial Control** for Solar Shop ERP (`business_erp`).

The inventory sub-system provides complete perpetual stock accounting with weighted-average cost valuation per product and location, append-only movement ledgers, whole-unit serial tracking, active stock reservations, and automated double-entry journal postings.

---

## 1. Domain Architecture & Entities

The inventory domain model resides in `packages/erp_domain/lib/src/inventory.dart` and operates with non-negative fixed-point integer representations to eliminate floating-point rounding errors.

### Key Domain Primitives

1. **`Location`**: Physical or logical storage points (e.g., `MAIN_WH` - Main Warehouse, `SHOWROOM` - Showroom Display, `QUARANTINE` - Quarantine/Damaged).
2. **`StockMovement`**: Immutable append-only ledger entry capturing every quantity and value movement (Opening Stock, Purchase Receipt, Sales Issue, Location Transfer, Adjustment, Return).
3. **`StockBalance`**: Transactionally maintained stock snapshot per `(productId, locationId)`.
4. **`SerialRecord` & `SerialEvent`**: Tracks individual whole-unit serial numbers (normalized uppercase) and their lifecycle transitions (`in_stock`, `reserved`, `sold`, `quarantined`, `scrapped`).
5. **`BatchRecord`**: Manages batch-tracked items with manufacture dates, expiry dates, and lot identifiers.
6. **`Reservation`**: Holds sellable stock for unfulfilled sales orders or pending transfers (`active`, `fulfilled`, `cancelled`).
7. **`StockAdjustment`**: Approved audit record for physical counts, variance corrections, damage write-offs, or initial stock setup.

---

## 2. Fixed-Point Arithmetic & Weighted-Average Valuation

### Fixed-Point Scale Factors
- **Quantity**: Micro-units (`1.0 unit = 1,000,000 micro-units`).
- **Valuation**: Micro-rupees (`1.00 INR = 100 paise = 10,000,000 micro-rupees`) for internal cost rates, paired with integer `valuePaise` (`1.00 INR = 100 paise`).

### Weighted-Average Cost Formula

When stock enters a location (positive `quantityMicroUnits`):
$$\text{New Value} = \text{Current Value} + \text{Incoming Value}$$
$$\text{New Quantity} = \text{Current Quantity} + \text{Incoming Quantity}$$
$$\text{Unit Cost Micro-Rupees} = \frac{\text{New Value Paise} \times 10,000,000,000}{\text{New Quantity Micro-Units}}$$

When stock leaves a location (negative `quantityMicroUnits`):
$$\text{Issue Value Paise} = \frac{|\text{Issue Quantity Micro-Units}| \times \text{Unit Cost Micro-Rupees}}{10,000,000,000}$$
$$\text{Remaining Quantity} = \text{Current Quantity} - |\text{Issue Quantity Micro-Units}|$$
$$\text{Remaining Value} = \text{Current Value} - \text{Issue Value Paise}$$

### Full Depletion Rounding Rule
When `Remaining Quantity == 0`, any remaining residual rounding value is set strictly to `0 paise`. This prevents leftover fractional paise artifacts when inventory is fully depleted.

---

## 3. Stock Ledger & Rebuild Parity Guarantee

Direct mutation of product stock totals is strictly prohibited across UI and CSV imports. All stock updates are appended as `StockMovement` records.

### Transactional Rebuild Algorithm
The `RebuildStockLedgerUseCase` clears and re-computes all `StockBalance` projections directly from the ordered historical `StockMovement` stream:
1. Re-sort movements chronologically by `timestampUtc`.
2. Process incoming receipts and recalculate weighted-average cost snapshots.
3. Apply outgoing issues at the exact historical unit cost.
4. Recalculate `onHandMicroUnits`, `valuePaise`, and `unitCostMicroRupees`.
5. Verify zero variance between calculated balances and persisted balances.

---

## 4. Availability & Reservations

Stock availability is computed dynamically:
$$\text{Available Stock} = \text{Sellable On-Hand} - \text{Active Reservations}$$

- **Quarantine / Damaged Stock**: Excluded from sellable on-hand totals.
- **Active Reservations**: Lock stock for pending orders to prevent over-selling.
- **Non-Negative Constraint**: Operations resulting in negative available stock are rejected with `StateError('Insufficient available stock...')`.

---

## 5. Whole-Unit Serial & Batch Primitives

- **Serial Constraint**: Serials are tied to whole-unit quantities (`1 serial = 1.0 unit = 1,000,000 micro-units`).
- **Uniqueness**: Serial numbers are normalized to uppercase and unique per `(organizationId, productId, serialNumber)`.
- **Duplicate Prevention**: Attempts to register duplicate active serials fail transactionally.

---

## 6. Double-Entry Accounting Links

Stock movements automatically produce balanced double-entry journal entries:
- **Opening Stock**: Debit `1300 Stock Inventory`, Credit `3000 Opening Balance Equity`.
- **Purchase Receipt**: Debit `1300 Stock Inventory`, Credit `2100 Accounts Payable`.
- **Sales Issue**: Debit `5000 Cost of Goods Sold`, Credit `1300 Stock Inventory`.
- **Adjustment Gain / Loss**: Debit/Credit `1300 Stock Inventory`, Credit/Debit `5100 Inventory Adjustment Variance`.

---

## 7. Data Persistence (Drift v5 Database)

Schema v5 introduces 8 dedicated tables in `packages/erp_local_data`:
- `locations`, `stock_movements`, `stock_balances`
- `serials`, `serial_events`, `batches`
- `reservations`, `stock_adjustments`

Default seeding populates:
- `MAIN_WH`: Main Warehouse
- `SHOWROOM`: Showroom Display
- `QUARANTINE`: Quarantine / Damaged

---

## 8. Verification & Acceptance Evidence

| Verification Test | Command | Result |
|---|---|---|
| Domain Unit Tests | `dart test packages/erp_domain/test/inventory_test.dart` | 19 / 19 Passed |
| Use Case Tests | `dart test packages/erp_application/test/inventory_use_cases_test.dart` | 15 / 15 Passed |
| Database Integration Tests | `dart test packages/erp_local_data/test/foundation_database_test.dart` | 7 / 7 Passed |
| App Analyzer | `flutter analyze` (in `business_erp`) | 0 Issues |
| Master Workspace Check | `dart run tool/check_all.dart` | All Checks Passed |
