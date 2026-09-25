# P10 — Build dashboards, reports and deterministic alerts

Release: V1. Prerequisites: P09.

Copy the entire block below into your coding assistant. Paths are relative to the repository root; this phase must leave documentation updated.

```text
Implement P10: Build dashboards, reports and deterministic alerts for Solar Shop ERP.

Work only on this phase and its necessary prerequisites. First inspect the repository, applicable AGENTS.md, docs/README.md, docs/tracking/project-status.md, work-log.md and known-issues.md. Inspect existing code before editing; preserve user changes. Confirm prerequisites using evidence, not a status label alone. If a hard prerequisite is missing, record the blocker and finish independent work; do not fake a dependency.

Follow the documented module boundaries, atomic posting, fixed-point arithmetic, permission checks and single-branch-authority policy. Do not add product AI, OCR, chatbots, model APIs, embeddings or forecasting models. AI is only the coding assistant. Choose compatible versions from verified official documentation and commit lockfiles. Never claim an unavailable platform/hardware check passed.

Implement in reviewable task increments. If the phase cannot fit one session, complete a coherent increment and leave an exact handoff; do not silently omit remaining scope. Run checks appropriate to real behavior and invariants, including failure paths. Do not use mocks as proof of database atomicity or actual printing.

Read these additional design documents under docs/: 01-requirements.md, 08-quality-gates.md, 02-architecture.md.
Prerequisites: P09.

Implementation tasks:
1. Implement all report families in the requirements with entity/branch/date/timezone filters, cursor pagination, authorized exports, totals and drill-downs. Label net sales, gross profit and operating profit accurately.
2. Add incrementally maintained read projections and rebuild/reconciliation commands. Reports never write business facts or recompute historical taxes from current masters.
3. Create role-appropriate dashboard, sales trends, category/top products, low/out-of-stock, dead stock, receivable/payable ageing and deterministic reorder formula with visible window/lead-time assumptions.
4. Benchmark representative data, inspect indexes/query plans, move large exports to cancellable jobs, and protect CSV export from spreadsheet formula injection. No generative summaries or AI services.

Expected artifacts: Dashboard/report catalog; docs/implementation/report-definitions.md and benchmark evidence.
Acceptance checks: Every report reconciles to source ledger/journal fixtures; Counter cannot infer hidden costs via exports; date boundaries pass; scale measurements include p95, dataset and hardware; rebuild preserves totals.
Exit gate: Actionable reports with documented formulas and reconciliation.

After the work is done, write the results in docs before ending the session. This is mandatory even if the work is partial or blocked:
1. Update docs/tracking/project-status.md with the actual phase/subtask status and evidence links.
2. Append docs/tracking/work-log.md with date, changes, affected files, schema/API/behavior changes, decisions, checks and exact next step.
3. Append docs/tracking/test-evidence.md with exact commands/procedures, environment, outcomes and artifacts; mark unexecuted checks Not run or Blocked.
4. Update docs/tracking/known-issues.md with remaining defects, missing credentials/hardware/reviews, risks and owners; close resolved items with evidence.
5. Update the relevant requirements, architecture, data model, business rules, security/sync/UX docs and phase-specific documents to match the actual implementation. Add an ADR if a decision changes.
6. Record migration, installation and recovery impacts and update affected runbooks/release notes. Verify documentation links.
Finish with a concise summary of what changed, what passed, what remains blocked and the next prompt/subtask. A phase is Complete only when its acceptance gate is evidenced. Do not begin the next phase automatically.
```

