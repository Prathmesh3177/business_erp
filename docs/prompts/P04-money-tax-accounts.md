# P04 — Implement deterministic money, GST and accounting engines

Release: V1. Prerequisites: P03.

Copy the entire block below into your coding assistant. Paths are relative to the repository root; this phase must leave documentation updated.

```text
Implement P04: Implement deterministic money, GST and accounting engines for Solar Shop ERP.

Work only on this phase and its necessary prerequisites. First inspect the repository, applicable AGENTS.md, docs/README.md, docs/tracking/project-status.md, work-log.md and known-issues.md. Inspect existing code before editing; preserve user changes. Confirm prerequisites using evidence, not a status label alone. If a hard prerequisite is missing, record the blocker and finish independent work; do not fake a dependency.

Follow the documented module boundaries, atomic posting, fixed-point arithmetic, permission checks and single-branch-authority policy. Do not add product AI, OCR, chatbots, model APIs, embeddings or forecasting models. AI is only the coding assistant. Choose compatible versions from verified official documentation and commit lockfiles. Never claim an unavailable platform/hardware check passed.

Implement in reviewable task increments. If the phase cannot fit one session, complete a coherent increment and leave an exact handoff; do not silently omit remaining scope. Run checks appropriate to real behavior and invariants, including failure paths. Do not use mocks as proof of database atomicity or actual printing.

Read these additional design documents under docs/: 03-data-model.md, 04-business-rules.md, 08-quality-gates.md.
Prerequisites: P03.

Implementation tasks:
1. Implement fixed-point Money, UnitPrice, Quantity and TaxRate with arbitrary-precision intermediates and bounds. Implement inclusive/exclusive tax, line and invoice discounts, residual allocation, round-off and effective-dated tax policy snapshots.
2. Build common document registry, fiscal periods/locks, compact registration-scoped sequences and idempotent command-result storage. Ensure numbering and result storage participate in the business transaction.
3. Create accounts, journal headers/lines, balanced posting templates, party control accounts, opening-balance documents and reconciliation queries. Prevent arbitrary edits/deletes of posted facts.
4. Build versioned synthetic fixtures and an approval mechanism for business-specific tax/accounting fixtures. Unsupported tax regimes are explicitly rejected. Record exact formulas and policy versions.

Expected artifacts: Pure domain engines, journal foundation; docs/implementation/calculation-fixtures.md.
Acceptance checks: T04/T09 pass with fixed-point edge cases, huge-value bounds and negative invalid inputs; balanced entries required; duplicate command with different payload rejected; opening balances reconcile. Business-reviewed fixtures pending must remain visible as a release blocker.
Exit gate: Exact arithmetic and reusable balanced posting contract.

After the work is done, write the results in docs before ending the session. This is mandatory even if the work is partial or blocked:
1. Update docs/tracking/project-status.md with the actual phase/subtask status and evidence links.
2. Append docs/tracking/work-log.md with date, changes, affected files, schema/API/behavior changes, decisions, checks and exact next step.
3. Append docs/tracking/test-evidence.md with exact commands/procedures, environment, outcomes and artifacts; mark unexecuted checks Not run or Blocked.
4. Update docs/tracking/known-issues.md with remaining defects, missing credentials/hardware/reviews, risks and owners; close resolved items with evidence.
5. Update the relevant requirements, architecture, data model, business rules, security/sync/UX docs and phase-specific documents to match the actual implementation. Add an ADR if a decision changes.
6. Record migration, installation and recovery impacts and update affected runbooks/release notes. Verify documentation links.
Finish with a concise summary of what changed, what passed, what remains blocked and the next prompt/subtask. A phase is Complete only when its acceptance gate is evidenced. Do not begin the next phase automatically.
```

