# P14 — Deliver branch authority, synchronization and V2

> **⚠️ DEFERRED** — This phase is deferred until the cloud platform (P13) is implemented. Multi-branch synchronization requires cloud infrastructure that is not yet in place. See [future-deferred-features.md](future-deferred-features.md) for details.

Release: V2 gate. Prerequisites: P13.

---

The original prompt content is preserved below for future implementation when cloud infrastructure is ready.

<details>
<summary>Original P14 prompt (click to expand)</summary>

```text
Implement P14: Deliver branch authority, synchronization and V2 for Solar Shop ERP.

Work only on this phase and its necessary prerequisites. First inspect the repository, applicable AGENTS.md, docs/README.md, docs/tracking/project-status.md, work-log.md and known-issues.md. Inspect existing code before editing; preserve user changes. Confirm prerequisites using evidence, not a status label alone. If a hard prerequisite is missing, record the blocker and finish independent work; do not fake a dependency.

Follow the documented module boundaries, atomic posting, fixed-point arithmetic, permission checks and single-branch-authority policy. Do not add product AI, OCR, chatbots, model APIs, embeddings or forecasting models. AI is only the coding assistant. Choose compatible versions from verified official documentation and commit lockfiles. Never claim an unavailable platform/hardware check passed.

Implement in reviewable task increments. If the phase cannot fit one session, complete a coherent increment and leave an exact handoff; do not silently omit remaining scope. Run checks appropriate to real behavior and invariants, including failure paths. Do not use mocks as proof of database atomicity or actual printing.

Read these additional design documents under docs/: 05-sync-and-cloud.md, 03-data-model.md, 08-quality-gates.md.
Prerequisites: P13.

Implementation tasks:
1. Package branch agent using the same Dart application services and local repositories; provide authenticated TLS LAN command/query API. Migrate V1 authority through frozen enrollment and reconciled baseline; desktop/Android become clients with caches and drafts.
2. Implement durable outbox transport, ordered retry/dedup, download cursor transactions, bootstrap watermark, master proposals/conflict resolution, tombstones, attachment jobs and compatibility/version handling.
3. Implement branch locations/permissions, global credit budgets, dispatch/transit/partial receipt transfer workflow, consolidation with data-age indicators and customer linking without historical mutation. Keep unsupported cross-registration transfers disabled.
4. Implement explicit paired-device recovery, stale-authority fencing, epoch move, restore cursor/series reconciliation and no automatic offline promotion. Rehearse WAN/LAN outages, duplicated/reordered events and ten-counter load before release.

Expected artifacts: Real live multi-device/branch workflows; docs/runbooks/sync-recovery.md; docs/releases/v2.md.
Acceptance checks: T16–T21/T24 pass; LAN trading continues without WAN; disconnected client can only draft; same serial never sold twice; restored writer cannot silently reuse series; source/transit/destination quantities and cloud totals reconcile.
Exit gate: Consistent, recoverable multi-branch operation.

After the work is done, write the results in docs before ending the session. This is mandatory even if the work is partial or blocked:
1. Update docs/tracking/project-status.md with the actual phase/subtask status and evidence links.
2. Append docs/tracking/work-log.md with date, changes, affected files, schema/API/behavior changes, decisions, checks and exact next step.
3. Append docs/tracking/test-evidence.md with exact commands/procedures, environment, outcomes and artifacts; mark unexecuted checks Not run or Blocked.
4. Update docs/tracking/known-issues.md with remaining defects, missing credentials/hardware/reviews, risks and owners; close resolved items with evidence.
5. Update the relevant requirements, architecture, data model, business rules, security/sync/UX docs and phase-specific documents to match the actual implementation. Add an ADR if a decision changes.
6. Record migration, installation and recovery impacts and update affected runbooks/release notes. Verify documentation links.
Finish with a concise summary of what changed, what passed, what remains blocked and the next prompt/subtask. A phase is Complete only when its acceptance gate is evidenced. Do not begin the next phase automatically.
```

</details>
