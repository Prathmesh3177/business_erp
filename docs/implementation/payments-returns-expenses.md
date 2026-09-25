# Payments, Returns, Expenses & Cash Register Counter Sessions

## Overview
This specification details the design and implementation of Module P08 (Payments, Customer Returns, Supplier Returns, Expense Vouchers, Cash Register Counter Sessions, and Party Aging Buckets) for **Shree Krushna Sales ERP**.

---

## 1. Domain Models & Rules
- **Sales Returns (`SalesReturnHeader`, `SalesReturnLine`)**:
  - Validates cumulative return quantity limits (`previousReturnedQty + newReturnQty <= originalSaleQty`).
  - Reverses COGS at original sale line cost snapshot (`Debit 1300 Stock Inventory / Quarantine, Credit 5000 COGS`).
  - Item disposition supports `returnToStock` (re-adds to sellable stock) or `quarantine` (isolates defective/damaged items).
- **Purchase Returns (`PurchaseReturnHeader`, `PurchaseReturnLine`)**:
  - Validates cumulative return quantity limits against original purchase line quantity.
  - Decommissions serial numbers to `scrapped` (returned to supplier).
  - Posts Debit Note entry (`Debit 2100 Accounts Payable, Credit 1300 Stock Inventory, Credit 1400 Input GST`).
- **Expense Vouchers (`ExpenseCategory`, `ExpenseEntry`)**:
  - Supports predefined and custom categories (Office Rent, Utilities, Freight, Stationery, Salaries, Refreshments, Misc).
  - Posts balanced double-entry accounting entries (`Debit 6xxx Expense Account, Credit 1100 Cash / Bank`).
- **Cash Register Counter Sessions (`CashSession`)**:
  - Manages POS counter session lifecycle (`open`, `closed`).
  - Reconciles expected cash against counted physical cash.
  - Automatically posts approved variance entries (`6900 Cash Shortage Expense` or `4900 Cash Overage Income`).
- **Party Aging Buckets (`PartyAgingBucket`)**:
  - Classifies outstanding receivables (customers) and payables (suppliers) into aging intervals: `0-30 days`, `31-60 days`, `61-90 days`, `90+ days`.

---

## 2. Capabilities & Security
- `financeManage`: Required to record payments, post sales returns, and post purchase returns.
- `expensesManage`: Required to manage expense categories and post expense vouchers.
- `cashSessionManage`: Required to open, reconcile, and close counter cash register sessions.

---

## 3. Drift Local Persistence (Schema V8 Migration)
Added 7 new SQLite tables in `packages/erp_local_data`:
1. `sales_return_headers`
2. `sales_return_lines`
3. `purchase_return_headers`
4. `purchase_return_lines`
5. `expense_categories`
6. `expense_entries`
7. `cash_sessions`

Registered `FinanceStore` repository implementation in `FoundationDatabase` with automatic migration at `schemaVersion = 8` and default expense category seeding.

---

## 4. Verification Evidence
- Domain & Use Case Unit Tests: 30 PASS (`packages/erp_domain/test/payments_returns_test.dart`, `packages/erp_application/test/payments_returns_use_cases_test.dart`).
- Database Integration Tests: 10 PASS (`packages/erp_local_data/test/foundation_database_test.dart`).
- App Analysis & Widget Tests: Clean analysis, 0 errors, 100% tests PASS (`business_erp`).
