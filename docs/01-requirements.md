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
| R01 | Windows/macOS/Android foundation; English/Marathi | P01, P09, P12 | Verified cross-platform local engine, localization delegates & mobile shell |
| R02 | Admin/Counter, sessions, permissions, audit | P02 | Salted PBKDF2, RBAC capability authorization, T08 denial & redacted audit trail verified |
| R03 | Configurable categories, brands, units and solar attributes | P03 | Solar panel, inverter, pump, battery and cable catalog & master CSV imports verified |
| R04 | SKU, barcode, HSN, prices, GST, multiple photos | P03, P09, P12 | Barcode lookup, price masking for counter staff & SHA-256 compressed camera attachments verified |
| R05 | Stock ledger, locations, batch/serial, opening stock, adjustments | P05 | Append-only ledger, weighted-average cost engine & serial state transitions verified |
| R06 | Suppliers, purchase invoice, costs, outstanding | P06 | Landed cost allocation, UnitOfWork posting & duplicate invoice check verified |
| R07 | Fast POS, customer, discounts, credit/split payments | P07 | Counter POS, hold/resume drafts, split tender & credit limit enforcement verified |
| R08 | GST breakdown, numbering, year, immutable snapshots | P04, P07 | 64-bit Money engine, Indian GST tax calculations & double-entry posting verified |
| R09 | Sales/purchase returns, credit/debit adjustments, refunds | P08 | Cumulative return limits, original cost snapshot reversal & debit notes verified |
| R10 | Customer/supplier ledgers, opening balances, allocations | P04, P08 | Party ledger ageing buckets & AR/AP control account reconciliation verified |
| R11 | Expenses, cash/UPI/card, daily close, profit | P08, P10 | Expense vouchers, counter session cash reconciliation & variance auditing verified |
| R12 | PDF, A4, thermal, English/Marathi/bilingual invoices | P09, P12 | Frozen InvoiceViewModel, A4 PDF renderer, 58/80mm thermal & copy watermarks verified |
| R13 | Dashboard and all report families | P10 | Sales, GSTR-1, GSTR-3B, Stock Valuation, Party Ageing & Executive Dashboard verified |
| R14 | Scheduled/manual encrypted backup, restore, migrations | P01, P11 | AES-256-GCM `.erpa` recovery envelopes, safety snapshots & sequence reconciliation verified |
| R15 | Barcode scanner, Android camera/Bluetooth/USB where supported | P09, P12 | Wedge listener, camera adapter, Bluetooth SPP/LE & USB OTG transport detection verified |
| R16 | Warranty and serial traceability | P07, P12, P16 | Invoice-to-serial lifecycle & warranty entitlement deduplication verified |
| R17 | Cloud identity, storage/backup, synchronized devices | P13, P14 | Offline single-authority local model enforced per ADR-013 & architecture bounds |
| R18 | Branches, transfers, multi-location reports | P14 | Multi-location stock balances & isolated single-branch authority model verified |
| R19 | Quotation, BOM, site, project, reservation, delivery/install | P15 | Solar quotation lifecycle, site creation, WIP 1400 asset accounting & final invoicing verified |
| R20 | Technicians, service jobs, customer documents and AMC | P16 | Service tickets, visit logging with spares deduction, serial swaps & AMC contract renewals verified |
| R21 | Low stock, dead stock, trends and reorder suggestions | P10, P16 | Deterministic reorder point alerts & AMC expiry/visit limit reminders verified |
| R22 | Production packaging, diagnostics and support handoff | P11, P17 | V1, V1.5, and V3 release certifications, user/admin guides & support handoff verified |

V3 release scope is 100% complete and verified. All operational requirements R01 through R22 have passed automated domain, use case, database, platform, and Flutter widget test suites.

## P19 presentation-system increment

P19 adds presentation-only acceptance criteria: neutral canvas/surface tokens, crimson primary emphasis, semantic status badges, 48dp controls, responsive tables/tabs, and no layout exception at desktop (1920×1080 and 1366×768) or compact (375×812) dashboard test viewports. It must not modify fixed-point arithmetic, GST, authorization, posting, branch authority, or schema contracts. Production visual certification additionally requires manual accessibility and real-device review; see the [design system](design/ui-ux-design-system.md).

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
