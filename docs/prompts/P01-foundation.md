# P01 — Create the Flutter and persistence foundation

Release: V1. Prerequisites: P00.

Copy the entire block below into your coding assistant. Paths are relative to the repository root; this phase must leave documentation updated.

```text
Implement P01: Create the Flutter and persistence foundation for Solar Shop ERP.

Work only on this phase and its necessary prerequisites. First inspect the repository, applicable AGENTS.md, docs/README.md, docs/tracking/project-status.md, work-log.md and known-issues.md. Inspect existing code before editing; preserve user changes. Confirm prerequisites using evidence, not a status label alone. If a hard prerequisite is missing, record the blocker and finish independent work; do not fake a dependency.

Follow the documented module boundaries, atomic posting, fixed-point arithmetic, permission checks and single-branch-authority policy. Do not add product AI, OCR, chatbots, model APIs, embeddings or forecasting models. AI is only the coding assistant. Choose compatible versions from verified official documentation and commit lockfiles. Never claim an unavailable platform/hardware check passed.

Implement in reviewable task increments. If the phase cannot fit one session, complete a coherent increment and leave an exact handoff; do not silently omit remaining scope. Run checks appropriate to real behavior and invariants, including failure paths. Do not use mocks as proof of database atomicity or actual printing.

Read these additional design documents under docs/: 02-architecture.md, 03-data-model.md, 06-security-and-operations.md, 07-ux-and-printing.md.
Prerequisites: P00.

Implementation tasks:
1. Create the monorepo packages in the architecture document using the validated pinned SDK/dependencies. Build Windows/macOS/Android Flutter entry points, dependency injection, Riverpod state, routing and English/Marathi ARB localization.
2. Implement core IDs, clock abstraction, typed errors, structured redacted logging, configuration, application theme and first-run organization/branch/financial-year setup. Keep domain packages free of Flutter and persistence imports.
3. Add Drift initialization on a database isolate, FKs, initial schema migration, transaction-scoped UnitOfWork and organization/branch identity. Integrate the validated database/key-storage adapter. No plaintext default credentials.
4. Provide a minimal consistent snapshot/manual recovery foundation before pilot data; show startup/migration failure states and preserve old data. Document development setup and supported command locations.

Expected artifacts: Working app shell and packages; docs/implementation/development-setup.md; actual schema migration notes.
Acceptance checks: Format/analyzer and package-boundary checks pass; app opens and locale switches; database persists across restart; migration/rollback smoke check passes; available platform builds run and missing hosts are recorded.
Exit gate: Persistent localized app shell with recoverable initialization.

After the work is done, write the results in docs before ending the session. This is mandatory even if the work is partial or blocked:
1. Update docs/tracking/project-status.md with the actual phase/subtask status and evidence links.
2. Append docs/tracking/work-log.md with date, changes, affected files, schema/API/behavior changes, decisions, checks and exact next step.
3. Append docs/tracking/test-evidence.md with exact commands/procedures, environment, outcomes and artifacts; mark unexecuted checks Not run or Blocked.
4. Update docs/tracking/known-issues.md with remaining defects, missing credentials/hardware/reviews, risks and owners; close resolved items with evidence.
5. Update the relevant requirements, architecture, data model, business rules, security/sync/UX docs and phase-specific documents to match the actual implementation. Add an ADR if a decision changes.
6. Record migration, installation and recovery impacts and update affected runbooks/release notes. Verify documentation links.
Finish with a concise summary of what changed, what passed, what remains blocked and the next prompt/subtask. A phase is Complete only when its acceptance gate is evidenced. Do not begin the next phase automatically.
```

