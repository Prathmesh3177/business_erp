# P13 — Create cloud identity, storage and ingestion foundations

Release: V2. Prerequisites: P12.

Copy the entire block below into your coding assistant. Paths are relative to the repository root; this phase must leave documentation updated.

```text
Implement P13: Create cloud identity, storage and ingestion foundations for Solar Shop ERP.

Work only on this phase and its necessary prerequisites. First inspect the repository, applicable AGENTS.md, docs/README.md, docs/tracking/project-status.md, work-log.md and known-issues.md. Inspect existing code before editing; preserve user changes. Confirm prerequisites using evidence, not a status label alone. If a hard prerequisite is missing, record the blocker and finish independent work; do not fake a dependency.

Follow the documented module boundaries, atomic posting, fixed-point arithmetic, permission checks and single-branch-authority policy. Do not add product AI, OCR, chatbots, model APIs, embeddings or forecasting models. AI is only the coding assistant. Choose compatible versions from verified official documentation and commit lockfiles. Never claim an unavailable platform/hardware check passed.

Implement in reviewable task increments. If the phase cannot fit one session, complete a coherent increment and leave an exact handoff; do not silently omit remaining scope. Run checks appropriate to real behavior and invariants, including failure paths. Do not use mocks as proof of database atomicity or actual printing.

Read these additional design documents under docs/: 02-architecture.md, 05-sync-and-cloud.md, 06-security-and-operations.md.
Prerequisites: P12.

Implementation tasks:
1. Create a Dart API/worker modular service with PostgreSQL schema, private object adapter, configuration/secrets, local integration environment, OpenAPI contracts and CI. Select region/provider against documented production capability and budget assumptions.
2. Implement OIDC/device enrollment and branch-scoped authorization. Prove Windows sign-in through a production-supported adapter; do not assume FlutterFire Windows plugins are production-ready. Firebase Auth/Storage are optional implementations behind ports.
3. Implement transactional ordered event ingestion, inbox deduplication, contiguous cursor acknowledgment, immutable fact validation, projection updates, signed attachment upload completion and cloud backup manifest handling.
4. Add tenant isolation checks, limits, redacted observability, staging deployment, database recovery and expand/contract migrations. Keep credentials out of repository. Do not declare live deployment if credentials or infrastructure are absent.

Expected artifacts: Cloud services/contracts and integration environment; docs/runbooks/cloud-operations.md.
Acceptance checks: API contract and PostgreSQL integration tests pass; duplicated/altered/gapped events behave correctly; cross-tenant requests denied; object URLs scoped/expiring; no branch facts posted independently by cloud.
Exit gate: Secure ingestion and identity/storage capability proven.

After the work is done, write the results in docs before ending the session. This is mandatory even if the work is partial or blocked:
1. Update docs/tracking/project-status.md with the actual phase/subtask status and evidence links.
2. Append docs/tracking/work-log.md with date, changes, affected files, schema/API/behavior changes, decisions, checks and exact next step.
3. Append docs/tracking/test-evidence.md with exact commands/procedures, environment, outcomes and artifacts; mark unexecuted checks Not run or Blocked.
4. Update docs/tracking/known-issues.md with remaining defects, missing credentials/hardware/reviews, risks and owners; close resolved items with evidence.
5. Update the relevant requirements, architecture, data model, business rules, security/sync/UX docs and phase-specific documents to match the actual implementation. Add an ADR if a decision changes.
6. Record migration, installation and recovery impacts and update affected runbooks/release notes. Verify documentation links.
Finish with a concise summary of what changed, what passed, what remains blocked and the next prompt/subtask. A phase is Complete only when its acceptance gate is evidenced. Do not begin the next phase automatically.
```

