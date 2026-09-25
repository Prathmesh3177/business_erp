# P16 — Build warranty, technician, service and AMC workflows

Release: V3. Prerequisites: P15.

Copy the entire block below into your coding assistant. Paths are relative to the repository root; this phase must leave documentation updated.

```text
Implement P16: Build warranty, technician, service and AMC workflows for Solar Shop ERP.

Work only on this phase and its necessary prerequisites. First inspect the repository, applicable AGENTS.md, docs/README.md, docs/tracking/project-status.md, work-log.md and known-issues.md. Inspect existing code before editing; preserve user changes. Confirm prerequisites using evidence, not a status label alone. If a hard prerequisite is missing, record the blocker and finish independent work; do not fake a dependency.

Follow the documented module boundaries, atomic posting, fixed-point arithmetic, permission checks and single-branch-authority policy. Do not add product AI, OCR, chatbots, model APIs, embeddings or forecasting models. AI is only the coding assistant. Choose compatible versions from verified official documentation and commit lockfiles. Never claim an unavailable platform/hardware check passed.

Implement in reviewable task increments. If the phase cannot fit one session, complete a coherent increment and leave an exact handoff; do not silently omit remaining scope. Run checks appropriate to real behavior and invariants, including failure paths. Do not use mocks as proof of database atomicity or actual printing.

Read these additional design documents under docs/: 01-requirements.md, 03-data-model.md, 04-business-rules.md.
Prerequisites: P15.

Implementation tasks:
1. Build warranty terms/start-basis history, serial replacement lineage, customer/site equipment view, claims, service jobs, technician assignment, visits and repair outcomes.
2. Use existing stock issue/return and expense commands for spares/labor/travel; differentiate covered work and billable services without inventing a parallel finance ledger.
3. Implement AMC contract coverage, visit limits, effective dates, renewal, invoicing and reviewed recognition schedules. Add deterministic due/expiry reminders with idempotent job keys and local/export delivery.
4. Provide technician-scoped mobile workflows, customer document access, service history and operational reports. External email/SMS/WhatsApp sending is not enabled without a selected provider, consent and explicit configuration. No AI diagnosis or OCR.

Expected artifacts: Service/AMC modules; docs/implementation/service-warranty-amc.md.
Acceptance checks: T23 passes across partial coverage, replaced serial, expired warranty, AMC renewal, visit limits, spare return and repeated scheduler execution; unauthorized technicians cannot view unrelated customer data.
Exit gate: Traceable service and recurring maintenance with bounded permissions.

After the work is done, write the results in docs before ending the session. This is mandatory even if the work is partial or blocked:
1. Update docs/tracking/project-status.md with the actual phase/subtask status and evidence links.
2. Append docs/tracking/work-log.md with date, changes, affected files, schema/API/behavior changes, decisions, checks and exact next step.
3. Append docs/tracking/test-evidence.md with exact commands/procedures, environment, outcomes and artifacts; mark unexecuted checks Not run or Blocked.
4. Update docs/tracking/known-issues.md with remaining defects, missing credentials/hardware/reviews, risks and owners; close resolved items with evidence.
5. Update the relevant requirements, architecture, data model, business rules, security/sync/UX docs and phase-specific documents to match the actual implementation. Add an ADR if a decision changes.
6. Record migration, installation and recovery impacts and update affected runbooks/release notes. Verify documentation links.
Finish with a concise summary of what changed, what passed, what remains blocked and the next prompt/subtask. A phase is Complete only when its acceptance gate is evidenced. Do not begin the next phase automatically.
```

