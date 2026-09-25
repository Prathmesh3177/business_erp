# Report Definitions & Business Intelligence Specification

Phase: P10  
Last Updated: 2026-09-25  

This document details the metric definitions, calculation formulas, capability authorization rules, and CSV formula injection prevention for all report families and the Executive BI Dashboard in Solar Shop ERP.

---

## 1. Security & Capability Authorization Matrix

| Report / Metric | Capability Required | Counter Staff View | Admin View |
|---|---|---|---|
| **Sales Summary (Gross, Tax, Net)** | `Capability.salesCreate` | Visible | Visible |
| **Sales COGS & Gross Profit** | `Capability.costDataRead` | **Masked** (Hidden / `null`) | Visible |
| **GSTR-1 & GSTR-3B Tax Summaries** | `Capability.salesCreate` | Visible | Visible |
| **Stock On-Hand & Available Qty** | `Capability.inventoryManage` | Visible | Visible |
| **Stock Unit Cost & Total Valuation** | `Capability.costDataRead` | **Masked** (Hidden / `null`) | Visible |
| **Deterministic Reorder Point Alerts** | `Capability.inventoryManage` | Visible | Visible |
| **Party Receivable / Payable Ageing** | `Capability.salesCreate` | Visible | Visible |
| **Financial Trial Balance & P&L** | `Capability.costDataRead` | **Forbidden** (Throws `AuthorizationFailure`) | Visible |

---

## 2. Report Calculations & Formulas

### 2.1 Sales Summary
- **Gross Sales** = $\sum \text{SaleLine.netTotal} + \text{SaleLine.lineDiscount}$
- **Total Discounts** = $\sum \text{SaleLine.lineDiscount}$
- **Net Sales** = $\sum \text{SaleLine.netTotal}$
- **COGS (Cost of Goods Sold)** = $\sum (\text{SaleLine.costSnapshotMicroRupees} \times \text{Quantity}) / 10000$
- **Gross Profit** = $\text{Net Sales} - \text{COGS}$
- **Gross Margin %** = $\left(\frac{\text{Gross Profit}}{\text{Net Sales}}\right) \times 100$

> [!IMPORTANT]
> **Data Integrity Invariant**: COGS is calculated directly from the immutable `costSnapshotMicroRupees` captured on each line at the exact moment of sale posting. Reports **NEVER** compute historical COGS from current catalog product costs.

### 2.2 Deterministic Reorder Alert Formula
$$\text{Reorder Point} = (\text{Average Daily Usage} \times \text{Lead Time Days}) + \text{Safety Stock}$$
$$\text{Suggested Order Quantity} = (\text{Reorder Point} - \text{Current Stock}) + \text{Safety Stock}$$

- **Average Daily Usage**: Estimated unit sales per day.
- **Lead Time Days**: Configured supplier lead time (default 7 days).
- **Safety Stock**: Minimum stock buffer (default 5.0 units).

### 2.3 GST Return Summaries (GSTR-1 & GSTR-3B)
- **GSTR-1 B2B Outward**: Sales made to customers possessing a valid registered GSTIN.
- **GSTR-1 B2C Small**: Sales made to unregistered retail customers.
- **GSTR-3B Net Tax Payable**:
  $$\text{Net CGST Payable} = \max(0, \text{Outward CGST} - \text{Inward ITC CGST})$$
  $$\text{Net SGST Payable} = \max(0, \text{Outward SGST} - \text{Inward ITC SGST})$$

---

## 3. CSV Formula Injection Prevention

To protect export files from malicious formula execution in spreadsheet applications (e.g. Microsoft Excel, LibreOffice Calc):
- Any cell string starting with `=`, `+`, `-`, `@`, `\t`, or `\r` is escaped with a leading single quote (`'`).
- Example: `=SUM(A1:A10)` is exported as `'=SUM(A1:A10)`.

---

## 4. Verification & Test Evidence

All report calculation logic, capability masking, CSV sanitization, and database query aggregations are verified by automated unit and integration suites:
- `packages/erp_domain/test/reports_test.dart`
- `packages/erp_application/test/report_use_cases_test.dart`
- `packages/erp_local_data/test/drift_report_store_test.dart`
- `business_erp/test/reports_dashboard_test.dart`
