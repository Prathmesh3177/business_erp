# Solar Projects & Site Costing Architecture

## Overview
This document specifies the architecture, accounting entries, domain entities, and data models for Prompt 15 (`P15-solar-projects.md`).

## Core Domain Models

### Quotations & BOM
- **`QuotationHeader`**: Quotation document containing revisions, customer details, installation charges, tax breakdown, validity dates, and terms snapshot.
- **`QuotationLine`**: Line item representing equipment or installation services, including quantity, unit price, line discount, tax snapshot, and optional `bomSnapshotJson`.
- **`QuotationStatus`**: `draft`, `sent`, `approved`, `rejected`, `superseded`.

### Solar Projects & Site Record
- **`SolarProject`**: Project site record generated automatically upon quotation acceptance. Tracks:
  - Budgeted materials and labor costs
  - Actual materials and expense costs
  - Current Work-in-Progress (WIP) asset balance (`1400 Work In Progress`)
  - Invoiced amount and project status (`inProgress`, `completed`, `cancelled`)

### Material Issues & Returns
- **`ProjectMaterialIssue`**: Material issue document capturing items delivered to site or returned back to storage.
- **`ProjectMaterialIssueLine`**: Line items with serial numbers and cost snapshots at weighted-average cost.

## Accounting Workflows & Ledger Entries

### 1. Quotation Acceptance & Site Creation
- **Effect**: Creates `SolarProject` site record.
- **Ledger Impact**: **None** (prevents double-posting of revenue or immediate physical stock issue).

### 2. Material Issuance to Site (`IssueProjectMaterialsUseCase`)
- **Stock Movement**: Physical stock out from storage location.
- **Inventory Ledger**: Stock balance reduced by quantity; weighted-average unit cost captured.
- **Accounting Entry**:
  - `Debit 1400 Work In Progress` (Asset)
  - `Credit 1200 Inventory` (Asset)

### 3. Return of Unused Site Materials (`ReturnProjectMaterialsUseCase`)
- **Stock Movement**: Physical stock restored to storage location.
- **Inventory Ledger**: Stock balance increased at captured original issue cost snapshot.
- **Accounting Entry**:
  - `Debit 1200 Inventory` (Asset)
  - `Credit 1400 Work In Progress` (Asset)

### 4. Final Project Completion & Invoicing (`PostProjectInvoiceUseCase`)
- **Customer Revenue Invoice Entry**:
  - `Debit 1100 Accounts Receivable` (Asset)
  - `Credit 4010 Revenue` (Revenue)
  - `Credit 2100 Output GST` (Liability)
- **WIP Cost Transfer Entry**:
  - `Debit 5000 Cost of Goods Sold` (Expense)
  - `Credit 1400 Work In Progress` (Asset)

## BI Reporting (`GenerateProjectBudgetReportUseCase`)
Generates `ProjectBudgetReport` aggregating:
- `totalBudgetPaise`: Budgeted Materials + Budgeted Labor
- `totalActualCostPaise`: Actual Materials Cost + Actual Expenses
- `wipBalancePaise`: Un-invoiced WIP balance in account `1400`
- `estimatedGrossProfitPaise`: Invoiced Revenue - Total Actual Cost
- `marginPercentage`: `(Gross Profit / Invoiced Revenue) * 100`

## Drift Data Layer & Schema Version 9
- Schema Version updated to `9`.
- Added tables: `Quotations`, `QuotationLines`, `SolarProjects`, `ProjectMaterialIssues`, `ProjectMaterialIssueLines`.
