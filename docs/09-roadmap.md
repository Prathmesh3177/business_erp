# Phase roadmap and delivery dependencies

This plan covers all non-AI scope in the supplied brief. Estimates are intentionally not invented: size each task after P00 identifies the team, platform readiness and business review requirements. Dependencies and acceptance gates determine order, not calendar promises.

## Release sequence

```mermaid
flowchart LR
  P00[Design validation] --> P01[Foundation]
  P01 --> P02[Security]
  P02 --> P03[Catalog and parties]
  P03 --> P04[Money / tax / accounts]
  P04 --> P05[Inventory]
  P05 --> P06[Purchases]
  P06 --> P07[POS / sales]
  P07 --> P08[Payments / returns]
  P08 --> P09[Printing]
  P09 --> P10[Reports]
  P10 --> P11[V1 hardening]
  P11 --> P12[Android V1.5]
  P12 --> P13[Cloud platform]
  P13 --> P14[Sync / branches V2]
  P14 --> P15[Projects]
  P15 --> P16[Service / AMC]
  P16 --> P17[V3 acceptance]
```

## Implementation phases

| Phase / prompt | Depends on | Release | Required exit outcome |
|---|---|---|---|
| [P00 — Validate requirements and platform feasibility](prompts/P00-validate-design.md) | Documentation baseline | Design gate | Feasible platform/security stack; explicit business and hardware blockers |
| [P01 — Create the Flutter and persistence foundation](prompts/P01-foundation.md) | P00 | V1 | Persistent localized app shell with recoverable initialization |
| [P02 — Implement identity, authorization and auditing](prompts/P02-identity-security.md) | P01 | V1 | Verified command-level authorization and safe local authentication |
| [P03 — Build product catalog, parties and attachments](prompts/P03-catalog-parties.md) | P02 | V1 | Usable validated product and party masters |
| [P04 — Implement deterministic money, GST and accounting engines](prompts/P04-money-tax-accounts.md) | P03 | V1 | Exact arithmetic and reusable balanced posting contract |
| [P05 — Build inventory, valuation and serial control](prompts/P05-inventory.md) | P04 | V1 | Rebuildable stock ledger with consistent serial ownership and valuation |
| [P06 — Implement supplier purchasing and receipt posting](prompts/P06-purchases.md) | P05 | V1 | Purchase-to-stock-to-payable vertical slice passes |
| [P07 — Implement counter POS and atomic sale posting](prompts/P07-sales-pos.md) | P06 | V1 | Reliable purchase-to-sale vertical slice |
| [P08 — Complete payments, returns, refunds and expenses](prompts/P08-payments-returns-expenses.md) | P07 | V1 | No editable parallel balances; corrections reconcile across ledgers |
| [P09 — Implement invoices, printing and desktop scanners](prompts/P09-printing-barcode.md) | P08 | V1 | Validated invoices and truthful device support matrix |
| [P10 — Build dashboards, reports and deterministic alerts](prompts/P10-reports-dashboard.md) | P09 | V1 | Actionable reports with documented formulas and reconciliation |
| [P11 — Certify backup, recovery and the V1 release](prompts/P11-v1-hardening.md) | P10 | V1 gate | Recoverable, reconciled and supportable V1 |
| [P12 — Build Android workflows and V1.5 hardware support](prompts/P12-android-companion.md) | P11 | V1.5 gate | Verified mobile workflows without misleading live-sync claims |
| [P13 — Create cloud identity, storage and ingestion foundations](prompts/P13-cloud-platform.md) | P12 | V2 | Secure ingestion and identity/storage capability proven |
| [P14 — Deliver branch authority, synchronization and V2](prompts/P14-sync-branches.md) | P13 | V2 gate | Consistent, recoverable multi-branch operation |
| [P15 — Build quotations, installations and project inventory](prompts/P15-solar-projects.md) | P14 | V3 | Quote-to-installation-to-invoice traceability with reconciled costs |
| [P16 — Build warranty, technician, service and AMC workflows](prompts/P16-service-amc.md) | P15 | V3 | Traceable service and recurring maintenance with bounded permissions |
| [P17 — Complete V3 acceptance and operational handoff](prompts/P17-final-acceptance.md) | P16 | V3 gate | Complete non-AI ERP delivery with documented support handoff |

## Work within each phase

Each linked prompt includes four ordered task increments. For a large phase, use separate sessions for domain/schema, application transactions, UI/adapters and integration verification. Keep the original phase ID and track increments as Pxx.1–Pxx.4 in the work log. Complete required shared foundations before downstream UI. Do not treat a pretty screen with stubbed posting as a delivered business feature.

Default ownership roles are implementer, business reviewer, tax/accounting reviewer and device/release tester. A small team may combine roles, but evidence must identify which checks are still outstanding. No parallel agents or external teams are assumed.

## Vertical milestone demonstrations

- After P05: opening stock, adjustment, serial trace and valuation reconciliation.
- After P06: credit purchase increases stock and supplier payable once.
- After P07: purchase -> sale -> receipt -> stock/COGS/dues reconciliation.
- After P08: partial return/refund and expense/cash close preserve balances.
- After P11: restore the business on clean hardware and produce the same invoice/report totals; only then pilot V1.
- After P14: two counters race for one serial, WAN fails while LAN trading continues, outbox catches up, branch transfer reconciles; only then claim live multi-device operation.
- After P17: quote -> reserve -> install -> invoice -> payment -> warranty -> service/AMC with no duplicate stock or revenue effects.

## Done and blocked rules

A phase is Complete when its implementation tasks, applicable acceptance checks, updated docs and required artifact evidence exist. If code is implemented but a Mac, printer, signing key, cloud account or business review is unavailable, use Implemented awaiting verification or Blocked. Continue independent authorized work, but do not certify the affected release.

The documentation requirement applies after every session, including fixes and incomplete work. [Project status](tracking/project-status.md), [work log](tracking/work-log.md), [test evidence](tracking/test-evidence.md) and [known issues](tracking/known-issues.md) are the durable handoff, together with updated design docs. Use the next prompt only when prerequisites have real evidence.

## Scope change rule

If a requested change affects money, stock ownership, schema, offline authority, security, tax treatment or a release gate, write/update an ADR and impacted requirements before implementing the changed behavior. Do not add AI as a later roadmap item. The currently planned endpoint is the complete conventional Solar ERP V3.

