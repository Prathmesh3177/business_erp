# P09 — Implement invoices, printing and desktop scanners

Release: V1. Prerequisites: P08.

Copy the entire block below into your coding assistant. Paths are relative to the repository root; this phase must leave documentation updated.

```text
Implement P09: Implement invoices, printing and desktop scanners for Solar Shop ERP.

Work only on this phase and its necessary prerequisites. First inspect the repository, applicable AGENTS.md, docs/README.md, docs/tracking/project-status.md, work-log.md and known-issues.md. Inspect existing code before editing; preserve user changes. Confirm prerequisites using evidence, not a status label alone. If a hard prerequisite is missing, record the blocker and finish independent work; do not fake a dependency.

Follow the documented module boundaries, atomic posting, fixed-point arithmetic, permission checks and single-branch-authority policy. Do not add product AI, OCR, chatbots, model APIs, embeddings or forecasting models. AI is only the coding assistant. Choose compatible versions from verified official documentation and commit lockfiles. Never claim an unavailable platform/hardware check passed.

Implement in reviewable task increments. If the phase cannot fit one session, complete a coherent increment and leave an exact handoff; do not silently omit remaining scope. Run checks appropriate to real behavior and invariants, including failure paths. Do not use mocks as proof of database atomicity or actual printing.

Read these additional design documents under docs/: 07-ux-and-printing.md, 06-security-and-operations.md.
Prerequisites: P08.

Implementation tasks:
1. Implement frozen InvoiceViewModel, versioned PDF templates, A4 pagination and 58/80 mm thermal renderers. Include approved invoice fields, line/component totals, serial appendix and English/Marathi/bilingual labels with licensed embedded fonts.
2. Implement persistent print jobs, preview, PDF export/share and OS printer adapters. Separate failed from delivery-unknown; audited copy reprint never posts another sale.
3. Integrate keyboard-wedge scanners with focus/timeouts/manual fallback and deterministic QR/barcode labels where useful. Use capability checks instead of showing unsupported transports as available.
4. Run real named desktop printer/scanner checks where hardware exists. Document driver/model/OS and a concrete manual test procedure for every unavailable device.

Expected artifacts: Print/scanner adapters; docs/implementation/hardware-matrix.md and invoice QA evidence.
Acceptance checks: T10/T13 pass on available hardware; 100-line and long Marathi invoice visual QA; totals match frozen invoice; unplug/retry does not duplicate business effects. Missing hardware checks remain blocked.
Exit gate: Validated invoices and truthful device support matrix.

After the work is done, write the results in docs before ending the session. This is mandatory even if the work is partial or blocked:
1. Update docs/tracking/project-status.md with the actual phase/subtask status and evidence links.
2. Append docs/tracking/work-log.md with date, changes, affected files, schema/API/behavior changes, decisions, checks and exact next step.
3. Append docs/tracking/test-evidence.md with exact commands/procedures, environment, outcomes and artifacts; mark unexecuted checks Not run or Blocked.
4. Update docs/tracking/known-issues.md with remaining defects, missing credentials/hardware/reviews, risks and owners; close resolved items with evidence.
5. Update the relevant requirements, architecture, data model, business rules, security/sync/UX docs and phase-specific documents to match the actual implementation. Add an ADR if a decision changes.
6. Record migration, installation and recovery impacts and update affected runbooks/release notes. Verify documentation links.
Finish with a concise summary of what changed, what passed, what remains blocked and the next prompt/subtask. A phase is Complete only when its acceptance gate is evidenced. Do not begin the next phase automatically.
```

