# P15 — Build quotations, installations and project inventory

Release: V3. Prerequisites: P14.

Copy the entire block below into your coding assistant. Paths are relative to the repository root; this phase must leave documentation updated.

```text
Implement P15: Build quotations, installations and project inventory for Solar Shop ERP.

Work only on this phase and its necessary prerequisites. First inspect the repository, applicable AGENTS.md, docs/README.md, docs/tracking/project-status.md, work-log.md and known-issues.md. Inspect existing code before editing; preserve user changes. Confirm prerequisites using evidence, not a status label alone. If a hard prerequisite is missing, record the blocker and finish independent work; do not fake a dependency.

Follow the documented module boundaries, atomic posting, fixed-point arithmetic, permission checks and single-branch-authority policy. Do not add product AI, OCR, chatbots, model APIs, embeddings or forecasting models. AI is only the coding assistant. Choose compatible versions from verified official documentation and commit lockfiles. Never claim an unavailable platform/hardware check passed.

Implement in reviewable task increments. If the phase cannot fit one session, complete a coherent increment and leave an exact handoff; do not silently omit remaining scope. Run checks appropriate to real behavior and invariants, including failure paths. Do not use mocks as proof of database atomicity or actual printing.

Read these additional design documents under docs/: 01-requirements.md, 03-data-model.md, 04-business-rules.md.
Prerequisites: P14.

Implementation tasks:
1. Build quotation revisions with solar BOM, product/service lines, installation charges, tax, validity, approval and accepted version. Acceptance creates a project/site but does not independently create revenue or stock issue.
2. Implement project states, materials reservation, delivery/material issue, installation tasks, milestones, change orders and customer documents with permissions. Use inventory commands and shared transaction boundaries.
3. Track issued materials in project WIP with original cost, return unused materials at captured issue cost, invoice without a second physical issue, and transfer WIP to COGS according to approved recognition policy.
4. Add project budget vs actual, labor/transport/subcontract expenses, milestone advances and margin reports. Preserve quote/project/invoice links and document cancellation/release behavior.

Expected artifacts: Solar project ERP modules; docs/implementation/projects-and-costing.md.
Acceptance checks: T22 passes including partial delivery, reservation race, accepted revision change, cancelled project, unused material return and installment billing; stock/accounting is not counted twice.
Exit gate: Quote-to-installation-to-invoice traceability with reconciled costs.

After the work is done, write the results in docs before ending the session. This is mandatory even if the work is partial or blocked:
1. Update docs/tracking/project-status.md with the actual phase/subtask status and evidence links.
2. Append docs/tracking/work-log.md with date, changes, affected files, schema/API/behavior changes, decisions, checks and exact next step.
3. Append docs/tracking/test-evidence.md with exact commands/procedures, environment, outcomes and artifacts; mark unexecuted checks Not run or Blocked.
4. Update docs/tracking/known-issues.md with remaining defects, missing credentials/hardware/reviews, risks and owners; close resolved items with evidence.
5. Update the relevant requirements, architecture, data model, business rules, security/sync/UX docs and phase-specific documents to match the actual implementation. Add an ADR if a decision changes.
6. Record migration, installation and recovery impacts and update affected runbooks/release notes. Verify documentation links.
Finish with a concise summary of what changed, what passed, what remains blocked and the next prompt/subtask. A phase is Complete only when its acceptance gate is evidenced. Do not begin the next phase automatically.
```

