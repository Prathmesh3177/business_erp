# P12 — Build Android workflows and V1.5 hardware support

Release: V1.5 gate. Prerequisites: P11.

Copy the entire block below into your coding assistant. Paths are relative to the repository root; this phase must leave documentation updated.

```text
Implement P12: Build Android workflows and V1.5 hardware support for Solar Shop ERP.

Work only on this phase and its necessary prerequisites. First inspect the repository, applicable AGENTS.md, docs/README.md, docs/tracking/project-status.md, work-log.md and known-issues.md. Inspect existing code before editing; preserve user changes. Confirm prerequisites using evidence, not a status label alone. If a hard prerequisite is missing, record the blocker and finish independent work; do not fake a dependency.

Follow the documented module boundaries, atomic posting, fixed-point arithmetic, permission checks and single-branch-authority policy. No AI/ML features are in scope for this application. Choose compatible versions from verified official documentation and commit lockfiles. Never claim an unavailable platform/hardware check passed. Use local SQLite database; cloud/Firebase migration is deferred.

Implement in reviewable task increments. If the phase cannot fit one session, complete a coherent increment and leave an exact handoff; do not silently omit remaining scope. Run checks appropriate to real behavior and invariants, including failure paths. Do not use mocks as proof of database atomicity or actual printing.

Read these additional design documents under docs/: 01-requirements.md, 07-ux-and-printing.md, 05-sync-and-cloud.md.
Prerequisites: P11.

Implementation tasks:
1. Implement mobile-first navigation, camera capture/crop/compression, gallery/nameplate photos, barcode/serial scanning, stock/customer lookup and authorized draft workflows.
2. Implement Android permission lifecycle, app resume/crash draft recovery and manual entry fallback. Use isolated local-only data; cloud synchronization is deferred to a future phase. Do not copy the desktop DB to pretend synchronization works.
3. Add supported Bluetooth/network/USB OTG print adapters with capability detection and device tests. Add warranty active/expired/expiring views and deterministic local reminder queue/export with duplicate suppression.
4. Record signed Android build, physical device/OS/plugin/printer versions, storage limits, denied permissions and offline UX. Keep untested transports disabled.

Expected artifacts: Android workflows; hardware matrix updates; docs/releases/v1.5.md.
Acceptance checks: R15/R16 mobile checks, T13 and process/permission lifecycle tests pass; app clearly shows isolated data mode; no unauthorized stock mutation; known physical printer results recorded.
Exit gate: Verified mobile workflows without misleading live-sync claims.

After the work is done, write the results in docs before ending the session. This is mandatory even if the work is partial or blocked:
1. Update docs/tracking/project-status.md with the actual phase/subtask status and evidence links.
2. Append docs/tracking/work-log.md with date, changes, affected files, schema/API/behavior changes, decisions, checks and exact next step.
3. Append docs/tracking/test-evidence.md with exact commands/procedures, environment, outcomes and artifacts; mark unexecuted checks Not run or Blocked.
4. Update docs/tracking/known-issues.md with remaining defects, missing credentials/hardware/reviews, risks and owners; close resolved items with evidence.
5. Update the relevant requirements, architecture, data model, business rules, security/sync/UX docs and phase-specific documents to match the actual implementation. Add an ADR if a decision changes.
6. Record migration, installation and recovery impacts and update affected runbooks/release notes. Verify documentation links.
Finish with a concise summary of what changed, what passed, what remains blocked and the next prompt/subtask. A phase is Complete only when its acceptance gate is evidenced. Do not begin the next phase automatically.
```

