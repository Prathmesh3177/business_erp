# P02 — Implement identity, authorization and auditing

Release: V1. Prerequisites: P01.

Copy the entire block below into your coding assistant. Paths are relative to the repository root; this phase must leave documentation updated.

```text
Implement P02: Implement identity, authorization and auditing for Solar Shop ERP.

Work only on this phase and its necessary prerequisites. First inspect the repository, applicable AGENTS.md, docs/README.md, docs/tracking/project-status.md, work-log.md and known-issues.md. Inspect existing code before editing; preserve user changes. Confirm prerequisites using evidence, not a status label alone. If a hard prerequisite is missing, record the blocker and finish independent work; do not fake a dependency.

Follow the documented module boundaries, atomic posting, fixed-point arithmetic, permission checks and single-branch-authority policy. Do not add product AI, OCR, chatbots, model APIs, embeddings or forecasting models. AI is only the coding assistant. Choose compatible versions from verified official documentation and commit lockfiles. Never claim an unavailable platform/hardware check passed.

Implement in reviewable task increments. If the phase cannot fit one session, complete a coherent increment and leave an exact handoff; do not silently omit remaining scope. Run checks appropriate to real behavior and invariants, including failure paths. Do not use mocks as proof of database atomicity or actual printing.

Read these additional design documents under docs/: 01-requirements.md, 06-security-and-operations.md.
Prerequisites: P01.

Implementation tasks:
1. Implement first-administrator setup, audited password hashing with stored parameters, local login, idle lock, logout, active sessions, failed-login throttling and an explicit administrator recovery workflow.
2. Implement capability-based roles using Admin/Counter defaults, branch scope and authorization inside application commands. Separate public and cost-sensitive query DTOs; routing is only a usability layer.
3. Add user/role management, protected-operation reauthentication, append-only audit events and redaction. Protect against deleting/deactivating the last recoverable administrator without an alternative.
4. Document security boundaries, local OS-admin limitations and key/session handling; add permission tables tied to actual capability identifiers.

Expected artifacts: Identity module, audit infrastructure; docs/implementation/security-permissions.md.
Acceptance checks: T08 direct command/export denial passes; no plaintext password/token in storage or logs; user deactivation invalidates sessions; session expiry and first-run recovery scenarios pass.
Exit gate: Verified command-level authorization and safe local authentication.

After the work is done, write the results in docs before ending the session. This is mandatory even if the work is partial or blocked:
1. Update docs/tracking/project-status.md with the actual phase/subtask status and evidence links.
2. Append docs/tracking/work-log.md with date, changes, affected files, schema/API/behavior changes, decisions, checks and exact next step.
3. Append docs/tracking/test-evidence.md with exact commands/procedures, environment, outcomes and artifacts; mark unexecuted checks Not run or Blocked.
4. Update docs/tracking/known-issues.md with remaining defects, missing credentials/hardware/reviews, risks and owners; close resolved items with evidence.
5. Update the relevant requirements, architecture, data model, business rules, security/sync/UX docs and phase-specific documents to match the actual implementation. Add an ADR if a decision changes.
6. Record migration, installation and recovery impacts and update affected runbooks/release notes. Verify documentation links.
Finish with a concise summary of what changed, what passed, what remains blocked and the next prompt/subtask. A phase is Complete only when its acceptance gate is evidenced. Do not begin the next phase automatically.
```

