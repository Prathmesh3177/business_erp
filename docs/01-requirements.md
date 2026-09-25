# Requirements and release scope

## Product objective

Run a solar shop reliably without internet, retain traceable financial and stock records, and extend the same domain to multiple branches, installations and service operations. Start with a modular monolith; scale deployment only when the business requires it.

## Operating assumptions

- Initial business: one Indian legal entity, one GST registration, one branch, multiple stock locations, INR and an April–March financial year. Schema supports more entities/registrations; each location belongs to a registration and branch.
- V1 has one authoritative desktop installation. Windows is the first operational target; macOS must be verified on a Mac before advertised support. Independent desktop installations do not share live data in V1.
- Android builds from the foundation phase; real camera/mobile workflows arrive in P12. Before V2, Android uses a separate demonstration dataset or explicitly independent business. It is not a second live writer for the desktop shop.
- V2 allows many connected counters per branch, with exactly one posting authority for each branch. Connected means LAN connectivity to that branch authority; internet loss alone does not stop branch sales.
- Business dates use the configured branch timezone, initially Asia/Kolkata. Audit instants use UTC. Preserve the original document date separately from posting time.
- Purchase receiving and supplier billing are combined in V1. Separate purchase orders, goods receipt and invoice matching are later extensions if requested; they are not necessary to deliver the supplied scope.
- GST configuration requires current rule validation for the business. E-invoice/e-way-bill applicability must be checked before production; if required for the target business, the necessary integration becomes a release blocker, not an ignored omission.
- Platform support is conditional: P01's Windows encrypted Drift path passes real migration/rollback/snapshot tests, while a full Flutter build, locale widget test and live vault call remain blocked by the existing SDK lock; Android lacks an SDK/device; macOS and all physical printers/scanners are untested. See the [platform matrix](implementation/platform-matrix.md). These gaps do not become support claims merely because runner files exist.

## Feature coverage and traceability

| ID | Requirement | Phase | Acceptance outcome |
|---|---|---|---|
| R01 | Windows/macOS/Android foundation; English/Marathi | P01, P09, P12 | Platform builds and locale switching verified |
| R02 | Admin/Counter, sessions, permissions, audit | P02 | Direct use-case calls reject unauthorized actions |
| R03 | Configurable categories, brands, units and solar attributes | P03 | Panel, pump, battery and cable products created |
| R04 | SKU, barcode, HSN, prices, GST, multiple photos | P03, P09, P12 | Search and capture/export round trip |
| R05 | Stock ledger, locations, batch/serial, opening stock, adjustments | P05 | Rebuild equals live balances; no duplicate serial ownership |
| R06 | Suppliers, purchase invoice, costs, outstanding | P06 | Purchase posts stock and balanced journal atomically |
| R07 | Fast POS, customer, discounts, credit/split payments | P07 | Complete sale survives retry/restart without duplication |
| R08 | GST breakdown, numbering, year, immutable snapshots | P04, P07 | Approved calculation fixtures and period rollover pass |
| R09 | Sales/purchase returns, credit/debit adjustments, refunds | P08 | Partial returns bounded by original quantities |
| R10 | Customer/supplier ledgers, opening balances, allocations | P04, P08 | Outstanding reconciles to journal control accounts |
| R11 | Expenses, cash/UPI/card, daily close, profit | P08, P10 | Settlement separate from revenue; cash variances audited |
| R12 | PDF, A4, thermal, English/Marathi/bilingual invoices | P09, P12 | Long invoices and real printer matrix pass |
| R13 | Dashboard and all report families | P10 | Date/entity/branch filters and totals reconcile |
| R14 | Scheduled/manual encrypted backup, restore, migrations | P01, P11 | Fresh-device restore matches ledger and attachment checksums |
| R15 | Barcode scanner, Android camera/Bluetooth/USB where supported | P09, P12 | Named tested devices recorded; unavailable paths disabled |
| R16 | Warranty and serial traceability | P07, P12, P16 | Invoice-to-serial-to-customer-to-service chain preserved |
| R17 | Cloud identity, storage/backup, synchronized devices | P13, P14 | Replay, access isolation and outage recovery pass |
| R18 | Branches, transfers, multi-location reports | P14 | Dispatch/receipt has one ownership transition per unit |
| R19 | Quotation, BOM, site, project, reservation, delivery/install | P15 | Accepted quote drives project without double stock issue |
| R20 | Technicians, service jobs, customer documents and AMC | P16 | Service/reminder/renewal workflow works deterministically |
| R21 | Low stock, dead stock, trends and reorder suggestions | P10, P16 | Transparent formulas; no AI models |
| R22 | Production packaging, diagnostics and support handoff | P11, P17 | Signed target releases and recovery drill recorded |

P01 progress covers only the R01 localized shell and the same-device foundation portion of R14. Neither requirement is accepted yet: no platform app has launched, the locale widget test has not run, and portable fresh-device recovery is absent. No other feature requirement is claimed by the foundation schema.

## Report inventory

Sales: day/week/month/year, product/category/customer/counter, tax, payment method and returns. Inventory: on-hand/available/reserved, ledger, low/out-of-stock, valuation, dead stock, movement and adjustments. Purchasing: supplier/product/month and returns. Finance: expenses, gross/operating profit, receivable/payable ageing, cash, UPI, card clearing and credit. V2 adds branch consolidation with replication timestamps; V3 adds project budget/actual/margin, technician workload, warranties, service due and AMC expiry.

## Default permission matrix

Permissions are named capabilities, not hard-coded screen roles. Admin and Counter are bundled role templates. Add Inventory/Accountant/Technician templates only as workflows require them.

| Operation | Admin | Counter default |
|---|---|---|
| Search products and available stock | Yes | Yes |
| See purchase cost, margins, company financial reports | Yes | No |
| Create sale / customer / receipt | Yes | Yes, scoped to assigned branch |
| Discount | Yes | Within configured limit; default zero until set |
| Override credit limit / change tax | Yes, with reason | No |
| Return or refund | Yes | Request only; granted limits optional |
| Purchase / stock adjustment / backdate | Yes | No |
| User administration / restore / keys / settings | Yes | No |
| Reprint invoice | Yes | Yes, permitted branch; audit copies |
| Edit posted documents / delete ledgers | No | No |

## Exclusions and boundaries

No product AI features in V1, V1.5, V2 or V3: no OCR, natural-language reporting, generative summaries, machine learning forecasts or photo classification. Traditional barcode decoding, deterministic trends and reminders are included. No payroll engine, manufacturing MRP, ecommerce marketplace or automatic bank/payment-provider integration by default. Recording a UPI payment does not prove bank settlement. User-mediated invoice sharing is allowed; external messaging integrations require an explicitly chosen provider and consent workflow during implementation.

P00 verified every available baseline scope group against R01-R22; no non-AI feature is uncovered. The original source brief is not stored as a separate artifact, so this is internal baseline traceability rather than a word-for-word source comparison. See [business validation](implementation/business-validation.md).

## Business walkthrough used throughout development

Create a serialized 5 HP pump, non-serialized cable sold in fractional meters, supplier and customer. Receive stock on credit; sell pump and cable using split tender and credit; print in Marathi; receive a later payment; accept a partial return into quarantine; refund only the allowed balance; restore backup and reconcile stock, cash and customer dues. Later repeat across connected counters, then complete a quoted installation and warranty service.
