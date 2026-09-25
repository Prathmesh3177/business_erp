# P06 — Implement supplier purchasing and receipt posting

Release: V1. Prerequisites: P05.

Copy the entire block below into your coding assistant. Paths are relative to the repository root; this phase must leave documentation updated.

```text
Implement P06: Implement supplier purchasing and receipt posting for Solar Shop ERP.

Work only on this phase and its necessary prerequisites. First inspect the repository, applicable AGENTS.md, docs/README.md, docs/tracking/project-status.md, work-log.md and known-issues.md. Inspect existing code before editing; preserve user changes. Confirm prerequisites using evidence, not a status label alone. If a hard prerequisite is missing, record the blocker and finish independent work; do not fake a dependency.

Follow the documented module boundaries, atomic posting, fixed-point arithmetic, permission checks and single-branch-authority policy. Do not add product AI, OCR, chatbots, model APIs, embeddings or forecasting models. AI is only the coding assistant. Choose compatible versions from verified official documentation and commit lockfiles. Never claim an unavailable platform/hardware check passed.

Implement in reviewable task increments. If the phase cannot fit one session, complete a coherent increment and leave an exact handoff; do not silently omit remaining scope. Run checks appropriate to real behavior and invariants, including failure paths. Do not use mocks as proof of database atomicity or actual printing.

Read these additional design documents under docs/: 03-data-model.md, 04-business-rules.md.
Prerequisites: P05.

Implementation tasks:
1. Build purchase draft, supplier invoice capture, line quantity/price/discount/tax, serial/batch entry, eligible landed-cost allocation and optional initial supplier payment.
2. Implement PostPurchase as one UnitOfWork using command identity, draft version, permissions and fiscal checks. Atomically create document, stock receipt, inventory/input-tax/payable journals, payment allocation, audit and outbox.
3. Implement supplier history, duplicate supplier invoice protection, purchase search and frozen receipt/bill snapshots. Do not assume purchase price equals future sale COGS.
4. Provide clear errors for invalid serial counts, supplier duplicates and tax scenarios. Expose purchase-return entry point as pending P08 rather than a fake successful workflow.

Expected artifacts: Purchase workflow and transactional posting; docs/implementation/purchasing.md.
Acceptance checks: Repeated purchase command posts once; fault injection rolls back every side effect; receipt changes weighted average correctly; supplier outstanding equals payable account; credit and partly paid purchases reconcile.
Exit gate: Purchase-to-stock-to-payable vertical slice passes.

After the work is done, write the results in docs before ending the session. This is mandatory even if the work is partial or blocked:
1. Update docs/tracking/project-status.md with the actual phase/subtask status and evidence links.
2. Append docs/tracking/work-log.md with date, changes, affected files, schema/API/behavior changes, decisions, checks and exact next step.
3. Append docs/tracking/test-evidence.md with exact commands/procedures, environment, outcomes and artifacts; mark unexecuted checks Not run or Blocked.
4. Update docs/tracking/known-issues.md with remaining defects, missing credentials/hardware/reviews, risks and owners; close resolved items with evidence.
5. Update the relevant requirements, architecture, data model, business rules, security/sync/UX docs and phase-specific documents to match the actual implementation. Add an ADR if a decision changes.
6. Record migration, installation and recovery impacts and update affected runbooks/release notes. Verify documentation links.
Finish with a concise summary of what changed, what passed, what remains blocked and the next prompt/subtask. A phase is Complete only when its acceptance gate is evidenced. Do not begin the next phase automatically.
```

