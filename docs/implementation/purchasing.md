# Supplier Purchasing, Receipt Posting, Landed Cost Allocation, and Supplier Dues Implementation

## Overview

This document details the technical implementation, transactional guarantees, landed cost allocation algorithms, double-entry accounting integration, and duplicate supplier bill protections implemented in **P06 — Supplier Purchasing and Receipt Posting** for Solar Shop ERP (`business_erp`).

The purchasing module provides a complete purchase-to-stock-to-payable vertical slice, linking supplier invoices to perpetual inventory valuation updates, whole-unit serial tracking, and input tax accounting.

---

## 1. Purchasing Data Model & Domain Entities

Defined in `packages/erp_domain/lib/src/purchasing.dart`:

1. **`PurchaseHeader`**: Captures invoice metadata (`supplierId`, `supplierName`, `externalInvoiceNumber`, `normalizedExternalInvoiceNumber`, `invoiceDate`, `locationId`, `status`), and summary financial totals (`subtotalPaise`, `landedCostTotalPaise`, `totalTaxPaise`, `netTotalPaise`, `amountPaidPaise`, `balanceDuePaise`).
2. **`PurchaseLine`**: Commercial line item containing `productId`, `quantity` (`Quantity`), `unitPurchasePrice` (`UnitPrice`), `discountPaise` (`Money`), `taxSnapshot` (`TaxLineResult`), `landedCostAllocationPaise` (`Money`), `netTotalPaise` (`Money`), `serials` (`List<String>`), and optional `batchLot`/`expiryDate`.
3. **`LandedCostAllocator`**: Helper utility providing proportional landed cost allocation by line subtotal value or quantity.
4. **`Payment` & `PaymentAllocation`**: Records payment transactions against supplier accounts and links them to purchase bills.

---

## 2. Landed Cost Allocation Algorithms

Landed costs (freight, handling, customs, insurance) are allocated across purchase lines at posting time to reflect accurate inventory acquisition costs:

### Allocation By Value (`LandedCostAllocationType.byValue`)
$$\text{Line Landed Cost} = \left\lfloor \frac{\text{Line Taxable Amount} \times \text{Total Landed Cost}}{\text{Total Invoice Taxable Amount}} \right\rfloor$$

### Allocation By Quantity (`LandedCostAllocationType.byQuantity`)
$$\text{Line Landed Cost} = \left\lfloor \frac{\text{Line Quantity Micro-Units} \times \text{Total Landed Cost}}{\text{Total Invoice Micro-Units}} \right\rfloor$$

### Remainder Allocation
Any unallocated remainder integer paise resulting from integer floor division is distributed 1 paise at a time across lines to guarantee:
$$\sum \text{Line Landed Costs} = \text{Total Landed Cost}$$

---

## 3. Atomic UnitOfWork Posting (`PostPurchaseUseCase`)

Posting a purchase bill executes transactionally as a single atomic operation:

1. **Authorization Verification**: Enforces `Capability.purchaseManage` (throws `AuthorizationFailure` if unauthorized).
2. **Duplicate Invoice Protection**: Rejects duplicate supplier bills matching `(supplierId, financialYear, normalizedExternalInvoiceNumber)` with `ConflictFailure`.
3. **Serial Number Validation**: Verifies whole-unit serial counts match line quantities and checks that serials are not currently active in stock (`SerialState.inStock`).
4. **Common Document Header**: Creates `DocumentHeader` (`DocumentKind.purchaseBill`, generates format e.g. `PUR/2627/000001`).
5. **Stock Receipt Movements**: Creates `StockMovement` entries (`movementKind = purchaseReceipt`) updating perpetual weighted-average unit cost and location stock balances.
6. **Serial Registration**: Registers `SerialRecord` (state `in_stock`, location set to receipt location) and logs `SerialEvent` (`received`).
7. **Balanced Double-Entry Journal Entry**:
   - **Debit**: `1300 Stock Inventory` (Subtotal + Landed Cost)
   - **Debit**: `1400 Input CGST / SGST / IGST` (Tax Receivable)
   - **Credit**: `2100 Accounts Payable` (Total Invoice Net Total)
8. **Initial Supplier Payment** (If provided):
   - Creates `Payment` and `PaymentAllocation` records.
   - Posts Payment Journal: Debit `2100 Accounts Payable`, Credit `1100 Cash / Bank`.

---

## 4. Duplicate Supplier Bill Protection

External supplier invoice numbers are normalized via:
```dart
String normalizeExternalInvoiceNumber(String input) =>
    input.trim().replaceAll(RegExp(r'\s+'), '').toUpperCase();
```
Before posting, the system queries `hasDuplicateSupplierInvoice(...)`. Attempts to re-submit an invoice with the same normalized number for the same supplier within the same financial year fail closed.

---

## 5. Schema v6 Drift Database Tables

Schema v6 introduces 4 new Drift tables in `packages/erp_local_data`:
- `purchase_headers`: Stores purchase bill headers.
- `purchase_lines`: Stores purchase bill line items with JSON tax and serial snapshots.
- `payments`: Stores inbound/outbound party payments.
- `payment_allocations`: Links payments to financial documents.

---

## 6. UI Integration (`business_erp`)

- **`PurchasesPage`** (`/purchases`):
  - **Purchase Invoices Tab**: Searchable history list with bill details modal.
  - **New Purchase Bill Wizard Tab**: Form for supplier selection, external invoice number, target warehouse, line items with GST/serials, landed cost calculator, and initial payment option.
  - **Supplier Payables & Returns Tab**: Displays outstanding payable balance per supplier and provides entry point for purchase returns (pending P08).

---

## 7. Acceptance & Verification Evidence

| Verification Test | Command | Outcome |
|---|---|---|
| Domain Unit Tests | `dart test packages/erp_domain/test/purchasing_test.dart` | 3 / 3 Passed |
| Application Use Case Tests | `dart test packages/erp_application/test/purchasing_use_cases_test.dart` | 3 / 3 Passed |
| Database Integration Tests | `dart test packages/erp_local_data/test/foundation_database_test.dart` | 8 / 8 Passed |
| Flutter Analyzer | `flutter analyze` in `business_erp` | 0 Issues Found |
| Flutter Widget Tests | `flutter test` in `business_erp` | 1 / 1 Passed |
| Master Workspace Check | `dart run tool/check_all.dart` | All Checks Passed |
