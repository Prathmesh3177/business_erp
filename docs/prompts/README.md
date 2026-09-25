# Phase-by-phase AI implementation prompts

These are development instructions for an AI coding assistant; they do not introduce AI features into the application.

## How to run

1. Open the repository in the coding assistant and start with P00.
2. Open one prompt below and copy the entire text code block. Each block contains its own operating rules, prerequisites, tasks, checks and mandatory documentation handoff.
3. Finish the current phase or record a precise partial handoff before continuing. For big phases, work through its four task increments across multiple sessions.
4. Review the changed files and evidence. Do not skip backup, accounting, migration or platform gates to reach UI features faster.
5. Start the next numbered prompt when prerequisites are satisfied. AI-written claims of success are not a substitute for test output and business/device review.

| Prompt | Goal | Release |
|---|---|---|
| [P00](P00-validate-design.md) | Validate requirements and platform feasibility | Design gate |
| [P01](P01-foundation.md) | Create the Flutter and persistence foundation | V1 |
| [P02](P02-identity-security.md) | Implement identity, authorization and auditing | V1 |
| [P03](P03-catalog-parties.md) | Build product catalog, parties and attachments | V1 |
| [P04](P04-money-tax-accounts.md) | Implement deterministic money, GST and accounting engines | V1 |
| [P05](P05-inventory.md) | Build inventory, valuation and serial control | V1 |
| [P06](P06-purchases.md) | Implement supplier purchasing and receipt posting | V1 |
| [P07](P07-sales-pos.md) | Implement counter POS and atomic sale posting | V1 |
| [P08](P08-payments-returns-expenses.md) | Complete payments, returns, refunds and expenses | V1 |
| [P09](P09-printing-barcode.md) | Implement invoices, printing and desktop scanners | V1 |
| [P10](P10-reports-dashboard.md) | Build dashboards, reports and deterministic alerts | V1 |
| [P11](P11-v1-hardening.md) | Certify backup, recovery and the V1 release | V1 gate |
| [P12](P12-android-companion.md) | Build Android workflows and V1.5 hardware support | V1.5 gate |
| [P13](P13-cloud-platform.md) | Create cloud identity, storage and ingestion foundations | V2 |
| [P14](P14-sync-branches.md) | Deliver branch authority, synchronization and V2 | V2 gate |
| [P15](P15-solar-projects.md) | Build quotations, installations and project inventory | V3 |
| [P16](P16-service-amc.md) | Build warranty, technician, service and AMC workflows | V3 |
| [P17](P17-final-acceptance.md) | Complete V3 acceptance and operational handoff | V3 gate |

## Mandatory documentation in every prompt

After work, update status; append the work log; record actual test evidence; record/resolve known issues; update the relevant design/schema/workflow/API documentation; and document migrations/recovery/release impacts. This is repeated inside **all 18 copy-ready prompts**, so the requirement is not lost when an individual prompt is used in a fresh session.

## Resuming an interrupted phase

Use the same phase prompt and add: “Resume from the latest entry in docs/tracking/work-log.md. Verify existing changes and test evidence, preserve user edits, complete the next unfinished task, and write the results back into docs before ending. Do not repeat completed work unless new evidence requires it.”

## Unexpected defects after a phase

Use the owning phase prompt and add a precise reproduction. Require a focused fix, meaningful regression evidence, updated issue/work-log/status records and any revised architecture or migration notes. Re-run affected checks; do not mark unrelated platforms passed.

