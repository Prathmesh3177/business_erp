# P00 — Validate requirements and platform feasibility

Release: Design gate. Prerequisites: Documentation baseline.

Copy the entire block below into your coding assistant. Paths are relative to the repository root; this phase must leave documentation updated.

```text
Implement P00: Validate requirements and platform feasibility for Solar Shop ERP.

Work only on this phase and its necessary prerequisites. First inspect the repository, applicable AGENTS.md, docs/README.md, docs/tracking/project-status.md, work-log.md and known-issues.md. Inspect existing code before editing; preserve user changes. Confirm prerequisites using evidence, not a status label alone. If a hard prerequisite is missing, record the blocker and finish independent work; do not fake a dependency.

Follow the documented module boundaries, atomic posting, fixed-point arithmetic, permission checks and single-branch-authority policy. Do not add product AI, OCR, chatbots, model APIs, embeddings or forecasting models. AI is only the coding assistant. Choose compatible versions from verified official documentation and commit lockfiles. Never claim an unavailable platform/hardware check passed.

Implement in reviewable task increments. If the phase cannot fit one session, complete a coherent increment and leave an exact handoff; do not silently omit remaining scope. Run checks appropriate to real behavior and invariants, including failure paths. Do not use mocks as proof of database atomicity or actual printing.

Read these additional design documents under docs/: 01-requirements.md, 02-architecture.md, 10-decisions-and-risks.md.
Prerequisites: Documentation baseline.

Implementation tasks:
1. Inspect the repository and any applicable AGENTS.md. Confirm the supplied brief is covered by R01–R22. Keep the documented defaults unless actual evidence requires a change; record unresolved business choices.
2. Create docs/implementation/platform-matrix.md and dependency-register.md. Run small isolated spikes for Windows/macOS/Android toolchains, encrypted Drift/SQLite, portable key recovery, Devanagari PDF shaping and printer transports. Record actual versions, licenses, host requirements and unsupported paths. Do not treat untested platforms as successful.
3. Validate the business tax scenario checklist, fiscal/numbering needs, roles, single-authority constraint and release boundaries. Recheck current official tax and dependency documentation. Record a concrete tax/accounting review checklist without inventing product rates.
4. Keep spikes disposable and separate from the production app. Produce an implementation-ready acceptance checklist and an ADR for any changed architecture decision.

Expected artifacts: docs/implementation/platform-matrix.md, docs/implementation/dependency-register.md, docs/implementation/business-validation.md.
Acceptance checks: Requirements map has no uncovered non-AI feature; exact tested/untested platform capabilities are recorded; encryption and Windows cloud-auth risks have a feasible path or an explicit blocker. No full application is required in this phase.
Exit gate: Feasible platform/security stack; explicit business and hardware blockers.

After the work is done, write the results in docs before ending the session. This is mandatory even if the work is partial or blocked:
1. Update docs/tracking/project-status.md with the actual phase/subtask status and evidence links.
2. Append docs/tracking/work-log.md with date, changes, affected files, schema/API/behavior changes, decisions, checks and exact next step.
3. Append docs/tracking/test-evidence.md with exact commands/procedures, environment, outcomes and artifacts; mark unexecuted checks Not run or Blocked.
4. Update docs/tracking/known-issues.md with remaining defects, missing credentials/hardware/reviews, risks and owners; close resolved items with evidence.
5. Update the relevant requirements, architecture, data model, business rules, security/sync/UX docs and phase-specific documents to match the actual implementation. Add an ADR if a decision changes.
6. Record migration, installation and recovery impacts and update affected runbooks/release notes. Verify documentation links.
Finish with a concise summary of what changed, what passed, what remains blocked and the next prompt/subtask. A phase is Complete only when its acceptance gate is evidenced. Do not begin the next phase automatically.
```

