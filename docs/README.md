# Documentation index

Design baseline: 24 September 2026. Status: proposed implementation baseline. User supplied a detailed Solar Shop ERP brief; the workspace was empty when this plan was prepared.

| Document | Purpose |
|---|---|
| [01 Requirements](01-requirements.md) | Scope, releases, roles, assumptions and traceability |
| [02 Architecture](02-architecture.md) | Boundaries, stack, deployment and scaling |
| [03 Data model](03-data-model.md) | Entities, relationships, constraints and migrations |
| [04 Business rules](04-business-rules.md) | Posting, money, GST, valuation and accounting |
| [05 Sync and cloud](05-sync-and-cloud.md) | Authority, protocol, conflicts and branch transfers |
| [06 Security and operations](06-security-and-operations.md) | Access control, encryption, backup, restore and releases |
| [07 UX and printing](07-ux-and-printing.md) | Screens, wireframes, localization and hardware |
| [08 Quality gates](08-quality-gates.md) | Acceptance scenarios, performance and release evidence |
| [09 Roadmap](09-roadmap.md) | Dependency-ordered implementation phases |
| [10 Decisions and risks](10-decisions-and-risks.md) | ADRs, tradeoffs, open decisions and sources |
| [P00 platform matrix](implementation/platform-matrix.md) | Tested, blocked and untested platform/security/hardware capabilities |
| [P00 dependency register](implementation/dependency-register.md) | Exact compatibility pins, licenses and host requirements |
| [P00 business validation](implementation/business-validation.md) | Requirements, tax/accounting and release-boundary review checklist |
| [P00 acceptance checklist](implementation/p00-acceptance-checklist.md) | Design-gate result and downstream blockers |
| [P01 development setup](implementation/development-setup.md) | Package layout, supported commands and runtime data locations |
| [P01 migration notes](implementation/p01-migration-notes.md) | Encrypted schema v1, rollback and snapshot behavior |
| [P01 acceptance checklist](implementation/p01-acceptance-checklist.md) | Implemented foundation evidence and remaining exit blockers |
| [ADR-013](adr/ADR-013-local-database-encryption-and-recovery.md) | Encrypted SQLite and portable recovery decision |
| [Prompt library](prompts/README.md) | Copy-ready phase prompts with mandatory documentation updates |
| [Project status](tracking/project-status.md) | Honest implementation progress |
| [Work log](tracking/work-log.md) | Work completed and next handoff |
| [Test evidence](tracking/test-evidence.md) | Checks actually run and platform gaps |
| [Known issues](tracking/known-issues.md) | Blockers and unresolved decisions |
| [Release notes](tracking/release-notes.md) | User-visible phase/release impacts and unsupported paths |

## How to use this plan

1. Read requirements, architecture and decisions. Defaults are explicit so development can start without repeated clarification.
2. Run prompt P00, then P01 through P17 in dependency order. Use one phase per coding session; split a large phase at the task boundaries listed inside its prompt.
3. Every prompt requires the assistant to update architecture/schema/workflow docs when they change, plus the status, work log, evidence and issue files after doing the work.
4. A phase is complete only when its acceptance checks pass. Unsupported hardware, unavailable build hosts and missing credentials are recorded as blocked or not run, never passed.
5. Release V1 only after P11; V1.5 after P12; V2 after P14; V3 after P17. Cloud is not required for a V1 shop to operate.

This is Markdown documentation intended to live beside the code and remain reviewable in version control. Diagrams use Mermaid. The original brief's sample rates and invoice arithmetic are examples, not production tax fixtures. No AI/OCR/chatbot/forecasting modules, model providers, embeddings, vector databases or AI roadmap phases are authorized.

P00 found that this workspace currently has no Git metadata. Lockfiles and documentation artifacts exist on disk, but no commit provenance can be claimed until the workspace is placed under version control.
