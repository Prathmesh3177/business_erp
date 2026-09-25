# Architecture decisions, assumptions and sources

These decisions are proposed defaults for implementation. P00 validates platform/package feasibility and resolves blockers with recorded evidence. Change a decision through an ADR describing context, alternatives, decision, consequences and migration impact; do not silently drift from the architecture.

## Decision register

| ADR | Decision | Alternatives and consequences |
|---|---|---|
| ADR-001 | Modular monolith with pure Dart domain/application packages | Microservices increase operational complexity without demonstrated need; modular boundaries preserve later extraction options |
| ADR-002 | Flutter desktop/Android + Drift/SQLite locally | Raw SQL lacks generated migration/query assistance; Flutter plugins still require real per-platform proof |
| ADR-003 | One posting authority per branch | Multi-writer offline selling needs partitioned stock/credit or accepts oversell; current plan prioritizes correctness and makes disconnected clients draft-only |
| ADR-004 | Append-only posted facts with balanced accounting | Editable invoice/stock totals lose traceability; projections remain rebuildable without event-sourcing every UI action |
| ADR-005 | Fixed point money/quantities and per-location weighted average | Floating point is unsuitable for exact totals; FIFO/specific identification postponed pending a deliberate valuation migration |
| ADR-006 | PostgreSQL cloud ledger replica/coordination with a Dart API | This deliberately revises the brief's Firestore-as-business-database suggestion. Relational constraints and shared domain fixtures fit financial ingestion; adds backend deployment responsibility |
| ADR-007 | Firebase identity/storage optional adapters, not desktop requirement | Current official Flutter setup omits Windows configuration; use production-capable HTTP/OIDC or another provider. Firestore may later serve disposable read projections only |
| ADR-008 | Backup/encryption/migration foundations before the first sale | Waiting until the final phase risks losing development/pilot data; final release still needs full recovery certification |
| ADR-009 | English/Marathi from the first UI; printer-independent rendering | Translating late and raw thermal text can break layouts/shaping; fonts and device proof are mandatory |
| ADR-010 | No product AI in any planned release | AI coding prompts are development tools only. Rules-based alerts/reports remain transparent and deterministic |
| ADR-011 | Build core accounting before purchases/sales | Avoids retrofitting inconsistent parallel customer/payment balance tables; operational accounting does not automatically equal statutory compliance |
| ADR-012 | Do not promise cross-platform success from one Windows workspace | macOS builds/hardware require appropriate host; unsupported checks remain not run |
| [ADR-013](adr/ADR-013-local-database-encryption-and-recovery.md) | Drift/native sqlite3 with SQLite3MultipleCiphers; OS-vault data key plus independently wrapped portable recovery key | P01 production Drift integration passed on Windows; live vault, portable production archive/restore and other platforms remain gated |

## Open decisions and defaults

| Item | Default to proceed | Resolution point / impact |
|---|---|---|
| Product name, logo and shop details | Solar Shop ERP with clearly marked demo identity | Before pilot invoices |
| Actual registration, tax scenarios and e-invoice/e-way-bill duties | Configurable domestic GST; no sample rates treated as legal facts | P00 business review, P04 fixtures, P11 release gate |
| Exact printer/scanner models | PDF and OS print first; named physical test matrix | P00 spike, P09/P12 hardware gate |
| Encryption library and key portability | sqlite3 3.6.0 build hook with SQLite3MultipleCiphers; OS-vault key plus Argon2id/AES-GCM portable wrapping | P01 encrypted Drift/migration/same-key snapshot passed on Windows; live vault and production portable recovery remain P01/P11 gates |
| Minimum OS/SDK and dependency versions | Current compatible stable versions after platform spike | P00/P01; record exact versions |
| Cloud identity/provider/region/cost ceiling | OIDC abstraction, Dart API, managed PostgreSQL/private objects | P13 before provider-specific deployment |
| Number of branches and busy-hour volume | Benchmark targets in architecture | P00 validate with business; P14 load test |
| Credit/refund/discount limits | Deny overrides for Counter; Admin reasons required | P02/P07 settings |
| AMC and project recognition rules | WIP on issue; revenue schedule explicitly configured | P15/P16 accountant-reviewed fixtures |
| Retention and external reminder providers | Preserve financial history; local reminder queue/export only | P11/P16; external sending is opt-in |

## Principal risks and mitigations

- Offline authority failure: main branch machine is a single point of posting availability. UPS, backups and rehearsed fenced replacement reduce downtime; clients cannot safely auto-take-over.
- Tax-rule change: effective-dated rules and frozen invoice snapshots prevent silent historical change. Validate current legal requirements for the actual business before release.
- Price/tax defaults becoming stale offline: show cached configuration version and require review on reconnect; already posted documents keep their original approved snapshot.
- Encryption/key loss: portable recovery archive and fresh-machine drill; encryption claims depend on a tested implementation.
- Native dependency churn: sqlite3mc and HarfBuzz compile during builds; exact locks, toolchain prerequisites and per-platform artifacts must be reproduced. A package compatibility solve does not certify runtime behavior.
- Printer/Marathi incompatibility: PDF/raster fallback and actual hardware acceptance. Do not advertise every USB/Bluetooth device.
- Cloud growth/cost: bounded jobs, batch sync, quotas, observability and an explicit provider budget. No cost estimates without region/volume/pricing verification.
- Scope overload: each release has a gate; V1 is useful independently. Scope changes revise the requirements map and phase dependencies first.

## Sources and verification notes

Reviewed initially on 24 September 2026 and rechecked for P00 on 25 September 2026. These establish technical constraints, not a guarantee that every plugin/version or tax rule remains unchanged. Recheck before dependency upgrades and before a production tax release.

- [Flutter architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations): official guidance on separating UI/data responsibilities. The specific domain/package layout here is a design choice.
- [Flutter platform integration](https://docs.flutter.dev/platform-integration): platform targets need appropriate setup and plugin support.
- [Drift supported platforms](https://drift.simonbinder.eu/platforms/), [transactions](https://drift.simonbinder.eu/dart_api/transactions/) and [migrations](https://drift.simonbinder.eu/migrations/): basis for local native persistence, atomic units of work and migration testing.
- [Drift encryption](https://drift.simonbinder.eu/platforms/encryption/): current recommended native path uses sqlite3 3.x configured for SQLite3MultipleCiphers; legacy SQLCipher Flutter library packages are obsolete.
- [SQLite3MultipleCiphers overview](https://utelle.github.io/SQLite3MultipleCiphers/) and [license](https://github.com/utelle/SQLite3MultipleCiphers/blob/main/LICENSE.spdx): cipher/temporary-data constraints and MIT licensing.
- [SQLite appropriate uses](https://www.sqlite.org/whentouse.html) and [SQLite over a network](https://www.sqlite.org/useovernet.html): local database and single-writer/network-file constraints inform the branch authority design.
- [Firebase Flutter setup](https://firebase.google.com/docs/flutter/setup): current setup workflow documents Apple, Android and web rather than Windows; verify provider options again during P13.
- [RFC 8252](https://www.rfc-editor.org/info/rfc8252/): system-browser native OAuth, PKCE and loopback redirect basis for the Windows OIDC path.
- [Firestore transactions](https://firebase.google.com/docs/firestore/manage-data/transactions): client transactions fail offline; a cache is not a cross-device offline stock coordination mechanism. Our single-authority protocol is an architectural choice based on the consistency requirement.
- [CBIC invoice rules](https://cbic-gst.gov.in/gst-invoice-rules.html) and [published CGST rules compilation](https://cbic-gst.gov.in/pdf/15102020_CGST-Rules-2017-Part-A-Rules.pdf): baseline references for invoice particulars, serial format/financial-year uniqueness. The compilation is dated, so P00/P04 must check amendments and applicable notifications; this plan does not certify current GST compliance or prescribe product rates.
- [GSTN e-invoice overview](https://tutorial.gst.gov.in/downloads/news/pamphlet_e_invoice_overview_updated_on_17_08_2023_approved_final.pdf) and [e-way-bill FAQ](https://docs.ewaybillgst.gov.in/html/faq_new.html): current applicability questions recorded in P00; the actual shop turnover, exemptions, state and movement scenarios are still unknown.

## ADR template for future work

`ADR-NNN: title; date/status; context; options; chosen decision; evidence; positive/negative consequences; security/data migration impact; affected docs; reversal plan.`
