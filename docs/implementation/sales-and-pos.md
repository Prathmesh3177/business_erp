# Counter POS, Sales Invoicing, Stock Issue & Warranty Entitlements Implementation

## Overview

This document details the technical implementation, transactional guarantees, double-entry accounting integration, duplicate-click idempotency protection, customer credit limit enforcement, serial sale state transitions, and warranty entitlement generation implemented in **P07 — Sales Invoicing and Counter POS** for Solar Shop ERP (`business_erp`).

The sales module provides a complete counter sales-to-stock issue-to-receivables vertical slice, supporting fast barcode item scanning, multi-tender split payments (Cash, UPI, Card, Bank Transfer, Customer Credit), held drafts, and automated double-entry journal posting for both revenue/GST and cost of goods sold (COGS).

---

## 1. Sales Data Model & Domain Entities

Defined in `packages/erp_domain/lib/src/sales.dart`:

1. **`SaleHeader`**: Captures invoice header metadata (`organizationId`, `branchId`, `documentHeaderId`, `customerPartyId`, `customerName`, `businessDate`, `locationId`, `status`), and summary financial totals (`subtotalPaise`, `allocatedDiscountPaise`, `totalTaxPaise`, `grandTotalPaise`, `amountPaidPaise`, `balanceDuePaise`).
2. **`SaleLine`**: Line item containing `productId`, `productName`, `sku`, `hsnCode`, `baseUnit`, `quantity` (`Quantity`), `unitPrice` (`UnitPrice`), `lineDiscountPaise` (`Money`), `taxSnapshot` (`TaxLineResult`), `costSnapshotMicroRupees` (`int`), `netTotalPaise` (`Money`), `serials` (`List<String>`), and optional `batchLot`.
3. **`TenderLine`**: Split tender line item specifying `method` (`TenderMethod`: cash, bankTransfer, upi, card, customerCredit) and `amountPaise` (`Money`).
4. **`SaleDraft`**: Saved counter POS draft containing `linesJson`, `customerPartyId`, `customerName`, `updatedAtUtc`, and `notes`.
5. **`WarrantyEntitlement`**: Manufacturer performance/warranty record linking `serialId`, `serialNumber`, `productId`, `partyId`, `saleDocumentId`, `startDate`, `endDate`, and `termsSnapshot`.

---

## 2. Business Invariants & Posting Validation Rules

`PostSaleUseCase` enforces the following strict business invariants prior to committing any state change:

1. **Capability Authorization**: Enforces `Capability.salesCreate` (throws `AuthorizationFailure` if unauthorized).
2. **Idempotency Protection**: Checks `accountingStore.getCommandResult(commandId)`. On duplicate submit (e.g. rapid double-click on POS register), returns existing `SaleHeader` idempotently without re-issuing stock or re-posting financial journals.
3. **Stock Availability Re-validation**: Checks that available sellable stock (`Available = Sellable On-Hand - Active Reservations`) is sufficient for each product line. Throws `ValidationFailure` if requested quantity exceeds available stock.
4. **Serial State Verification**: Verifies that specified serial numbers exist in inventory and are in state `SerialState.inStock` at the target location. Throws `ValidationFailure` if serial is invalid or already sold/transferred.
5. **Customer Credit Limit Enforcement**: If sale balance is credited to customer account (`TenderMethod.customerCredit` or partial payment), verifies `currentOutstanding + newBalanceDue <= customer.creditLimitPaise`. Throws `ValidationFailure` if credit limit is exceeded.

---

## 3. Atomic UnitOfWork Posting (`PostSaleUseCase`)

Posting a POS sale executes transactionally as a single atomic unit of work:

1. **Document Header Allocation**: Allocates common document number (`DocumentKind.salesInvoice`, e.g. `INV/2627/000001`).
2. **Stock Issue Movements**: Creates `StockMovement` entries (`movementKind = salesIssue`, quantity negative) updating location stock balance.
3. **Serial State Transition**: Updates `SerialRecord.state` to `SerialState.sold` and logs `SerialEvent` (`sold`).
4. **Warranty Entitlement Creation**: Generates `WarrantyEntitlement` for every sold serial number (default 25-year performance warranty snapshot).
5. **Balanced Double-Entry Journals**:
   - **Journal 1: Sales Revenue & GST**
     - **Debit**: `1100 Cash / Bank / Tender Accounts` (Amount Paid)
     - **Debit**: `1200 Accounts Receivable` (Balance Due, if customer credit)
     - **Credit**: `4000 Sales Revenue` (Taxable Base Amount)
     - **Credit**: `2200 Output CGST / SGST / IGST` (Tax Payable)
   - **Journal 2: Cost of Goods Sold (COGS)**
     - **Debit**: `5000 Cost of Goods Sold` (Weighted Average Cost Snapshot)
     - **Credit**: `1300 Stock Inventory` (Weighted Average Cost Snapshot)
6. **Command Result Persistence**: Saves `CommandResultRecord` with `commandId` for duplicate-click idempotency protection.

---

## 4. Schema v7 Drift Database Tables

Schema v7 introduces 4 new Drift tables in `packages/erp_local_data`:
- `sale_headers`: Stores sales invoice headers and financial totals.
- `sale_lines`: Stores line items with JSON tax and serial snapshots and unit cost snapshots.
- `sale_drafts`: Stores held POS draft sales.
- `warranties`: Stores customer warranty entitlements.

---

## 5. UI Integration (`business_erp`)

- **`PosPage`** (`/sales`):
  - **Counter POS Tab**: Touch-friendly product grid with instant search/barcode lookup, customer credit limit indicator, item cart table with inline quantity/discount/serial inputs, order totals breakdown card, and split tender payment modal.
  - **Held Drafts Tab**: List of pending counter drafts with resume-to-cart and delete actions.
  - **Sales History Tab**: Searchable history of posted invoices with full item detail and warranty status modal.

---

## 6. Acceptance & Verification Evidence

| Verification Test | Command | Outcome |
|---|---|---|
| Domain Unit Tests | `dart test packages/erp_domain/test/sales_test.dart` | 2 / 2 Passed |
| Application Use Case Tests | `dart test packages/erp_application/test/sales_use_cases_test.dart` | 4 / 4 Passed |
| Database Integration Tests | `dart test packages/erp_local_data/test/foundation_database_test.dart` | 9 / 9 Passed |
| Flutter Analyzer | `flutter analyze` in `business_erp` | 0 Issues Found |
| Flutter Widget Tests | `flutter test` in `business_erp` | 1 / 1 Passed |
| Master Workspace Verification | `dart run tool/check_all.dart` | All Checks Passed |
