# P03 — Build product catalog, parties and attachments

Release: V1. Prerequisites: P02.

Copy the entire block below into your coding assistant. Paths are relative to the repository root; this phase must leave documentation updated.

```text
Implement P03: Build product catalog, parties and attachments for Solar Shop ERP.

Work only on this phase and its necessary prerequisites. First inspect the repository, applicable AGENTS.md, docs/README.md, docs/tracking/project-status.md, work-log.md and known-issues.md. Inspect existing code before editing; preserve user changes. Confirm prerequisites using evidence, not a status label alone. If a hard prerequisite is missing, record the blocker and finish independent work; do not fake a dependency.

Follow the documented module boundaries, atomic posting, fixed-point arithmetic, permission checks and single-branch-authority policy. Do not add product AI, OCR, chatbots, model APIs, embeddings or forecasting models. AI is only the coding assistant. Choose compatible versions from verified official documentation and commit lockfiles. Never claim an unavailable platform/hardware check passed.

Implement in reviewable task increments. If the phase cannot fit one session, complete a coherent increment and leave an exact handoff; do not silently omit remaining scope. Run checks appropriate to real behavior and invariants, including failure paths. Do not use mocks as proof of database atomicity or actual printing.

Read these additional design documents under docs/: 01-requirements.md, 03-data-model.md, 07-ux-and-printing.md.
Prerequisites: P02.

Implementation tasks:
1. Build categories, brands, units and conversion rules, product CRUD/deactivation, SKU/barcode uniqueness, supplier links, HSN/tax defaults, prices, minimum stock and typed solar attribute definitions. Include pump/panel/inverter/battery/cable fixtures.
2. Implement customers and suppliers as party roles with contacts, addresses, GST details, payment terms and credit limits. Do not implement editable opening-balance totals; opening balances will post through finance.
3. Implement managed attachments, hashes, thumbnails, safe image import, size/type limits and orphan cleanup. Provide paginated search by name, SKU, barcode, brand/model, HSN and serial integration port.
4. Add CSV master import with preview, validation and repeat-safe import IDs; permission-filter purchase costs. Supply localized forms, empty/error states and keyboard-friendly search.

Expected artifacts: Catalog/party screens and repositories; docs/implementation/catalog-and-imports.md.
Acceptance checks: R03/R04 master scenarios pass; duplicate SKU/barcode and invalid units fail cleanly; re-import does not duplicate masters; unsafe attachments rejected; Counter queries omit costs.
Exit gate: Usable validated product and party masters.

After the work is done, write the results in docs before ending the session. This is mandatory even if the work is partial or blocked:
1. Update docs/tracking/project-status.md with the actual phase/subtask status and evidence links.
2. Append docs/tracking/work-log.md with date, changes, affected files, schema/API/behavior changes, decisions, checks and exact next step.
3. Append docs/tracking/test-evidence.md with exact commands/procedures, environment, outcomes and artifacts; mark unexecuted checks Not run or Blocked.
4. Update docs/tracking/known-issues.md with remaining defects, missing credentials/hardware/reviews, risks and owners; close resolved items with evidence.
5. Update the relevant requirements, architecture, data model, business rules, security/sync/UX docs and phase-specific documents to match the actual implementation. Add an ADR if a decision changes.
6. Record migration, installation and recovery impacts and update affected runbooks/release notes. Verify documentation links.
Finish with a concise summary of what changed, what passed, what remains blocked and the next prompt/subtask. A phase is Complete only when its acceptance gate is evidenced. Do not begin the next phase automatically.
```

