# P17 — Complete V3 acceptance and operational handoff

Release: V3 gate. Prerequisites: P16.

Copy the entire block below into your coding assistant. Paths are relative to the repository root; this phase must leave documentation updated.

```text
Implement P17: Complete V3 acceptance and operational handoff for Solar Shop ERP.

Work only on this phase and its necessary prerequisites. First inspect the repository, applicable AGENTS.md, docs/README.md, docs/tracking/project-status.md, work-log.md and known-issues.md. Inspect existing code before editing; preserve user changes. Confirm prerequisites using evidence, not a status label alone. If a hard prerequisite is missing, record the blocker and finish independent work; do not fake a dependency.

Follow the documented module boundaries, atomic posting, fixed-point arithmetic, permission checks and single-branch-authority policy. No AI/ML features are in scope for this application. Choose compatible versions from verified official documentation and commit lockfiles. Never claim an unavailable platform/hardware check passed. Use local SQLite database; cloud/Firebase migration is deferred.

Implement in reviewable task increments. If the phase cannot fit one session, complete a coherent increment and leave an exact handoff; do not silently omit remaining scope. Run checks appropriate to real behavior and invariants, including failure paths. Do not use mocks as proof of database atomicity or actual printing.

Read these additional design documents under docs/: 01-requirements.md, 08-quality-gates.md, 09-roadmap.md, tracking/known-issues.md.
Prerequisites: P16.

Implementation tasks:
1. Audit R01–R22 against implemented screens/commands/tests. Close gaps and verify all supplied features are covered or explicitly blocked with reason.
2. Run the full purchase-sale-return-recovery walkthrough plus outage/branch transfer, quotation-installation-invoice and warranty/AMC scenarios. Repeat only affected regression tests after fixes; provide final reconciliation and real platform/hardware evidence.
3. Verify production migration/backup/fencing/upgrade runbooks, support diagnostics, dependency/security inventory, translated UI/invoice QA, performance targets and business acceptance.
4. Produce release notes, user/admin training guides, supported platform/device matrix, rollout checklist and issue ownership. Do not mark a release complete while required signing, business review, restore or target-platform tests are missing.

Expected artifacts: docs/releases/v3.md; docs/runbooks/user-guide.md; docs/runbooks/admin-guide.md; final acceptance record.
Acceptance checks: V3 gate and all applicable T01–T24 satisfied with linked evidence; requirements traceability complete; clean-device installation and recovery succeed; no critical open issue or unsupported success claim.
Exit gate: Complete ERP delivery with documented support handoff.

After the work is done, write the results in docs before ending the session. This is mandatory even if the work is partial or blocked:
1. Update docs/tracking/project-status.md with the actual phase/subtask status and evidence links.
2. Append docs/tracking/work-log.md with date, changes, affected files, schema/API/behavior changes, decisions, checks and exact next step.
3. Append docs/tracking/test-evidence.md with exact commands/procedures, environment, outcomes and artifacts; mark unexecuted checks Not run or Blocked.
4. Update docs/tracking/known-issues.md with remaining defects, missing credentials/hardware/reviews, risks and owners; close resolved items with evidence.
5. Update the relevant requirements, architecture, data model, business rules, security/sync/UX docs and phase-specific documents to match the actual implementation. Add an ADR if a decision changes.
6. Record migration, installation and recovery impacts and update affected runbooks/release notes. Verify documentation links.
Finish with a concise summary of what changed, what passed, what remains blocked and the next prompt/subtask. A phase is Complete only when its acceptance gate is evidenced. Do not begin the next phase automatically.
```

