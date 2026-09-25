# P11 — Certify backup, recovery and the V1 release

Release: V1 gate. Prerequisites: P10.

Copy the entire block below into your coding assistant. Paths are relative to the repository root; this phase must leave documentation updated.

```text
Implement P11: Certify backup, recovery and the V1 release for Solar Shop ERP.

Work only on this phase and its necessary prerequisites. First inspect the repository, applicable AGENTS.md, docs/README.md, docs/tracking/project-status.md, work-log.md and known-issues.md. Inspect existing code before editing; preserve user changes. Confirm prerequisites using evidence, not a status label alone. If a hard prerequisite is missing, record the blocker and finish independent work; do not fake a dependency.

Follow the documented module boundaries, atomic posting, fixed-point arithmetic, permission checks and single-branch-authority policy. No AI/ML features are in scope for this application. Choose compatible versions from verified official documentation and commit lockfiles. Never claim an unavailable platform/hardware check passed. Use local SQLite database; cloud/Firebase migration is deferred.

Implement in reviewable task increments. If the phase cannot fit one session, complete a coherent increment and leave an exact handoff; do not silently omit remaining scope. Run checks appropriate to real behavior and invariants, including failure paths. Do not use mocks as proof of database atomicity or actual printing.

Read these additional design documents under docs/: 06-security-and-operations.md, 08-quality-gates.md, 10-decisions-and-risks.md.
Prerequisites: P10.

Implementation tasks:
1. Finish automatic/manual backups, manifest/attachment consistency, retention, overdue startup handling, disk-space checks and external-drive export. Show last verified backup, not merely last attempted job.
2. Implement staged restore with maintenance mode, safety backup, schema/integrity validation, atomic switch/rollback and post-restore numbering reconciliation. Rehearse replacement-machine recovery.
3. Run applicable T01–T15 and V1 performance targets, migrations from all supported versions and fault injection for disk-full/process kill/corrupt backup. Resolve production blockers rather than hiding them.
4. Prepare signed target installers, upgrade/rollback procedures, dependency/license inventory, release notes, first-run/opening reconciliation, support guide and business acceptance checklist. Required tax integrations, hardware or credentials that are unavailable remain explicit release blockers.

Expected artifacts: docs/runbooks/backup-restore.md, docs/runbooks/release-and-upgrade.md, docs/releases/v1.md; tested installers when possible.
Acceptance checks: V1 gate in quality document satisfied; actual recovery time/point measured; ledger/attachment totals match restore; no unverified OS/signing/tax/hardware claim. If evidence is missing mark Implemented awaiting verification, not released.
Exit gate: Recoverable, reconciled and supportable V1.

After the work is done, write the results in docs before ending the session. This is mandatory even if the work is partial or blocked:
1. Update docs/tracking/project-status.md with the actual phase/subtask status and evidence links.
2. Append docs/tracking/work-log.md with date, changes, affected files, schema/API/behavior changes, decisions, checks and exact next step.
3. Append docs/tracking/test-evidence.md with exact commands/procedures, environment, outcomes and artifacts; mark unexecuted checks Not run or Blocked.
4. Update docs/tracking/known-issues.md with remaining defects, missing credentials/hardware/reviews, risks and owners; close resolved items with evidence.
5. Update the relevant requirements, architecture, data model, business rules, security/sync/UX docs and phase-specific documents to match the actual implementation. Add an ADR if a decision changes.
6. Record migration, installation and recovery impacts and update affected runbooks/release notes. Verify documentation links.
Finish with a concise summary of what changed, what passed, what remains blocked and the next prompt/subtask. A phase is Complete only when its acceptance gate is evidenced. Do not begin the next phase automatically.
```

