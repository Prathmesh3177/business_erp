# P07 — Implement counter POS and atomic sale posting

Release: V1. Prerequisites: P06.

Copy the entire block below into your coding assistant. Paths are relative to the repository root; this phase must leave documentation updated.

```text
Implement P07: Implement counter POS and atomic sale posting for Solar Shop ERP.

Work only on this phase and its necessary prerequisites. First inspect the repository, applicable AGENTS.md, docs/README.md, docs/tracking/project-status.md, work-log.md and known-issues.md. Inspect existing code before editing; preserve user changes. Confirm prerequisites using evidence, not a status label alone. If a hard prerequisite is missing, record the blocker and finish independent work; do not fake a dependency.

Follow the documented module boundaries, atomic posting, fixed-point arithmetic, permission checks and single-branch-authority policy. Do not add product AI, OCR, chatbots, model APIs, embeddings or forecasting models. AI is only the coding assistant. Choose compatible versions from verified official documentation and commit lockfiles. Never claim an unavailable platform/hardware check passed.

Implement in reviewable task increments. If the phase cannot fit one session, complete a coherent increment and leave an exact handoff; do not silently omit remaining scope. Run checks appropriate to real behavior and invariants, including failure paths. Do not use mocks as proof of database atomicity or actual printing.

Read these additional design documents under docs/: 04-business-rules.md, 07-ux-and-printing.md, 08-quality-gates.md.
Prerequisites: P06.

Implementation tasks:
1. Build keyboard-first POS, product lookup/barcode text input, customer selection, fractional quantity, serial choice, line/cart discounts, tax breakdown, hold/resume drafts and credit limits.
2. Implement PostSale with fresh transactional revalidation, invoice number/snapshots, stock/COGS/revenue/tax journals, split tender/initial allocations, audit, outbox and command result. Post-commit printing remains an adapter job until P09.
3. Implement sales history, invoice detail, commit-unknown recovery and duplicate-click handling. Create warranty entitlement records from serial sale and snapshotted terms without implementing full service scheduling yet.
4. Add complete localized errors and display actual committed document identity. Never print a draft as a tax invoice or re-post because printing failed.

Expected artifacts: End-to-end POS/sale workflows; docs/implementation/sales-and-pos.md.
Acceptance checks: T01–T05, T09 and T14 applicable sale cases pass; final-unit race has one winner; credit limit cannot be bypassed; crash/retry has no duplicate invoice/stock/cash; historical snapshot unchanged after master edit.
Exit gate: Reliable purchase-to-sale vertical slice.

After the work is done, write the results in docs before ending the session. This is mandatory even if the work is partial or blocked:
1. Update docs/tracking/project-status.md with the actual phase/subtask status and evidence links.
2. Append docs/tracking/work-log.md with date, changes, affected files, schema/API/behavior changes, decisions, checks and exact next step.
3. Append docs/tracking/test-evidence.md with exact commands/procedures, environment, outcomes and artifacts; mark unexecuted checks Not run or Blocked.
4. Update docs/tracking/known-issues.md with remaining defects, missing credentials/hardware/reviews, risks and owners; close resolved items with evidence.
5. Update the relevant requirements, architecture, data model, business rules, security/sync/UX docs and phase-specific documents to match the actual implementation. Add an ADR if a decision changes.
6. Record migration, installation and recovery impacts and update affected runbooks/release notes. Verify documentation links.
Finish with a concise summary of what changed, what passed, what remains blocked and the next prompt/subtask. A phase is Complete only when its acceptance gate is evidenced. Do not begin the next phase automatically.
```

