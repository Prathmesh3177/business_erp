# P08 — Complete payments, returns, refunds and expenses

Release: V1. Prerequisites: P07.

Copy the entire block below into your coding assistant. Paths are relative to the repository root; this phase must leave documentation updated.

```text
Implement P08: Complete payments, returns, refunds and expenses for Solar Shop ERP.

Work only on this phase and its necessary prerequisites. First inspect the repository, applicable AGENTS.md, docs/README.md, docs/tracking/project-status.md, work-log.md and known-issues.md. Inspect existing code before editing; preserve user changes. Confirm prerequisites using evidence, not a status label alone. If a hard prerequisite is missing, record the blocker and finish independent work; do not fake a dependency.

Follow the documented module boundaries, atomic posting, fixed-point arithmetic, permission checks and single-branch-authority policy. Do not add product AI, OCR, chatbots, model APIs, embeddings or forecasting models. AI is only the coding assistant. Choose compatible versions from verified official documentation and commit lockfiles. Never claim an unavailable platform/hardware check passed.

Implement in reviewable task increments. If the phase cannot fit one session, complete a coherent increment and leave an exact handoff; do not silently omit remaining scope. Run checks appropriate to real behavior and invariants, including failure paths. Do not use mocks as proof of database atomicity or actual printing.

Read these additional design documents under docs/: 03-data-model.md, 04-business-rules.md, 08-quality-gates.md.
Prerequisites: P07.

Implementation tasks:
1. Implement independent customer receipts/supplier payments, allocations, advances, unapplied credit, reversals and party statements. Separate recorded UPI/card receipts from bank-cleared settlement.
2. Implement linked partial sales and purchase returns with original tax/discount snapshots, cumulative quantity limits, original sale-cost reversal/current-cost purchase return variance, quarantine disposition and appropriate credit/debit documents.
3. Implement refunds with limits and approvals; allocation reversal is not a cash refund. Add expense categories/entries, cash sessions, counted-vs-expected close and approved variance postings.
4. Support opening dues through journals, receivable/payable ageing and period locks. Reconcile all cash/party/stock effects and document allowed correction paths.

Expected artifacts: Finance and correction workflows; docs/implementation/payments-returns-expenses.md.
Acceptance checks: T06/T07/T14 pass, including multiple partial returns with residual paise, overpayment, refund retry, supplier credit, expense reversal, credit-limit override denial and cash variance.
Exit gate: No editable parallel balances; corrections reconcile across ledgers.

After the work is done, write the results in docs before ending the session. This is mandatory even if the work is partial or blocked:
1. Update docs/tracking/project-status.md with the actual phase/subtask status and evidence links.
2. Append docs/tracking/work-log.md with date, changes, affected files, schema/API/behavior changes, decisions, checks and exact next step.
3. Append docs/tracking/test-evidence.md with exact commands/procedures, environment, outcomes and artifacts; mark unexecuted checks Not run or Blocked.
4. Update docs/tracking/known-issues.md with remaining defects, missing credentials/hardware/reviews, risks and owners; close resolved items with evidence.
5. Update the relevant requirements, architecture, data model, business rules, security/sync/UX docs and phase-specific documents to match the actual implementation. Add an ADR if a decision changes.
6. Record migration, installation and recovery impacts and update affected runbooks/release notes. Verify documentation links.
Finish with a concise summary of what changed, what passed, what remains blocked and the next prompt/subtask. A phase is Complete only when its acceptance gate is evidenced. Do not begin the next phase automatically.
```

