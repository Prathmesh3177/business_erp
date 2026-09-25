# P00 business validation

This is an implementation checklist, not tax or accounting certification. It records what the product must ask and block before production. It deliberately contains no product GST rates.

## Requirements coverage

The available baseline describes the supplied scope through the root README, `docs/01-requirements.md`, the R01-R22 table, report inventory and end-to-end walkthrough. The original brief is not stored as a separate source artifact, so this check validates internal baseline coverage rather than claiming word-for-word source traceability.

| Scope group | Requirement IDs | Coverage conclusion |
|---|---|---|
| Platforms, localization, access and audit | R01-R02 | Windows/macOS/Android, English/Marathi, Admin/Counter permissions, sessions and audit are mapped. |
| Catalog, parties, attachments and identifiers | R03-R04 | Configurable solar attributes, SKU/barcode/HSN, prices/tax defaults and photos are mapped. |
| Stock, procurement and POS | R05-R07 | Ledger/location/serial/batch, purchase receipt/payable and fast idempotent sale/split/credit are mapped. |
| GST, accounts and corrections | R08-R11 | Tax snapshots/numbering, returns/adjustments/refunds, party ledgers/allocations, expenses/tenders/close/profit are mapped. |
| Documents, hardware, recovery and warranty | R12, R14-R16 | A4/thermal/PDF/locales, backup/restore/migrations, scanner/mobile transports and serial warranty chain are mapped. |
| Reporting and deterministic alerts | R13, R21 | All named report families, low/dead stock, trends and formula-based reorder suggestions are mapped without AI. |
| Cloud, branches and transfers | R17-R18 | Identity/storage/sync and branch transfers are mapped behind one posting authority per branch. |
| Projects, installation, service and AMC | R19-R20 | Quote/BOM/site/project/material/install and technician/warranty/service/AMC are mapped. |
| Packaging and operational handoff | R22 | Signed releases, diagnostics and recovery evidence are mapped. |

**Result:** no non-AI feature stated in the available baseline is uncovered. Product AI/OCR/chatbots/model APIs/embeddings/ML forecasting remain excluded; barcode decoding, formulas and reminders are deterministic features. Any later recovered source brief must be diffed against this table before P01 scope is treated as final.

## Tax and invoicing review checklist

Current official references confirm that Rule 46 requires prescribed invoice particulars and a financial-year-unique consecutive serial using allowed characters ([CBIC invoice rules](https://cbic-gst.gov.in/gst-invoice-rules.html)). GSTN guidance states the notified e-invoice turnover threshold is INR 5 crore and above from 1 August 2023, based on aggregate turnover in any preceding financial year since 2017-18 ([GSTN e-invoice overview](https://tutorial.gst.gov.in/downloads/news/pamphlet_e_invoice_overview_updated_on_17_08_2023_approved_final.pdf)). An IRP advisory applies a 30-day reporting restriction from 1 April 2025 to taxpayers with AATO of INR 10 crore or more. E-way-bill guidance uses a general INR 50,000 consignment threshold but explicitly directs users to state/UT rules for intrastate movement ([E-way-bill FAQ](https://docs.ewaybillgst.gov.in/html/faq_new.html)). These facts determine review questions, not hard-coded business rules or product rates.

Before pilot, the business owner and a qualified Indian tax/accounting reviewer must sign off the following with effective dates and source links:

- Legal name, addresses, GSTIN(s), registration type, state codes, branch/location mapping and whether composition, SEZ, export, reverse-charge, job-work or unregistered-supply scenarios occur.
- PAN-level aggregate turnover for every year relevant to e-invoice applicability; applicable exemptions; IRP workflow/credentials; cancellation and the 30-day restriction; whether missing integration blocks pilot or only specific documents.
- Goods-movement scenarios and origin/destination states; interstate/intrastate treatment; e-way-bill applicability, state variations, exemptions, transporter/vehicle data and portal/API process.
- Product-by-product HSN, description/unit, taxable/nil/exempt/zero-rated classification, effective-dated rate/cess, input-credit eligibility and any solar-project composite/mixed-supply treatment. No rate is accepted merely because it appears in a sample.
- B2B/B2C/customer-registration and place-of-supply cases; required buyer/delivery details; tax-inclusive/exclusive pricing; discounts, freight/charges and round-off policy.
- Invoice, bill-of-supply, receipt/payment/refund voucher, credit/debit note, delivery challan and purchase-return particulars; original-reference requirements and printed declarations/QR/IRN fields when applicable.
- Series per registration/document type/branch, allowed characters and maximum length, April-March fiscal rollover, cancellation gaps, duplicate prevention, backdate/closed-period rules and restore/failover series handling.
- GSTR/report/export needs, record retention, document language expectations and reconciliation ownership. The ERP's operational summaries are not represented as statutory returns unless separately certified.

Unsupported tax cases must fail with a stable `tax_scenario_unsupported`-style error before posting; they must not silently fall back to the domestic taxable flow.

## Accounting and posting validation checklist

- Approve chart-of-accounts/control-account mapping for inventory, input/output tax, receivable/payable, cash, UPI, card clearing, advances, discounts, round-off, COGS, expenses, quarantine/transit/WIP and return variances.
- Confirm April-March periods, opening dates, lock/reopen authority and correction/reversal treatment.
- Review recoverable versus nonrecoverable tax in inventory cost, landed-cost allocation, per-location weighted average, final-unit residual handling and purchase-return variance policy.
- Approve sale/purchase/return/payment/expense/cash-close posting templates and fixtures. Every journal entry must balance; party subledgers and inventory projections must reconcile to control accounts.
- Approve tender lifecycle: recorded payment is not bank settlement; split tender, advance, allocation, refund and reversal remain distinct from revenue.
- Approve credit, discount, refund, adjustment and backdate limits plus reason/second-approval thresholds. Defaults remain deny for Counter overrides.
- Approve project WIP/revenue recognition and AMC recognition before P15/P16; those unresolved policies do not block V1.
- Execute the documented serialized pump + fractional cable walkthrough, including purchase, sale, later receipt, quarantine return/refund, Marathi PDF, backup/restore and reconciliation.

## Roles and authority

The documented Admin/Counter templates remain defaults. Permissions are named capabilities enforced in application commands and queries; hiding a route is never evidence of authorization. Counter cost/margin/report fields are omitted, not merely hidden. Posted documents and ledgers are immutable for both roles.

V1 has exactly one authoritative desktop installation. V1.5 Android uses an isolated dataset and cannot post to the live desktop business. V2 clients post only through the reachable branch authority over authenticated LAN; loss of internet does not stop the authority, but loss of LAN authority makes clients draft-only. There is no SQLite file sharing, file-sync replication, second offline writer or automatic promotion. Any proposal to change this requires a new ADR and stock/credit partition design.

## Release boundary validation

| Release | Included gate | Explicitly not implied |
|---|---|---|
| V1 / P11 | One authoritative verified desktop, core R01-R14, target printer(s), encryption/recovery and reviewed business fixtures | macOS unless actually verified; Android live companion; cloud; multi-branch |
| V1.5 / P12 | Android camera/hardware workflows with isolated data and named-device evidence | synchronized live selling or independent live posting |
| V2 / P14 | Branch agent as sole writer, LAN clients, authenticated cloud replication, transfers and fencing | multi-writer offline branch posting or cloud-issued offline numbers |
| V3 / P17 | Projects, installation, warranty/service/AMC with reviewed accounting | product AI or unreviewed recognition rules |

## Unresolved business choices and owners

| Choice | Default while unresolved | Owner / blocking phase |
|---|---|---|
| Legal identity, GST registrations, turnover/applicability and actual tax scenarios | Demo identity only; no production invoice | Business + tax reviewer / P00 follow-up, P04, P11 |
| Approved HSN/rates/classifications and accounting fixtures | No production tax master; sample 18% remains synthetic test data | Tax/accounting reviewer / P04, P11 |
| Exact invoice/credit-note series and branch prefixes | Proposed `A/2627/000001`; not production-approved | Business + tax reviewer / P04, P07 |
| Printer/scanner/device models and paper widths | PDF + OS print path only | Business + device tester / P09, P12 |
| Credit/discount/refund/backdate approval limits | Counter override denied; Admin reason required | Business + accounting / P02, P07, P08 |
| External backup destination, recovery custodian and retention | Proposed documented defaults only | Business + operations / P01, P11 |
| Cloud provider/region/cost/identity tenant | Standards-based ports; no provider dependency | Business + implementation / P13 |
| Project/AMC recognition | WIP and schedules remain unresolved | Accounting / P15, P16 |

