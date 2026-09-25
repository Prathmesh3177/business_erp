# Verification and release gates

All checks below are planned until evidence is recorded in [test evidence](tracking/test-evidence.md). Documentation creation does not mean implementation or production verification has passed.

P00 exceptions now evidenced are limited to dependency resolution, Windows sqlite3mc/key-recovery failure paths and a rendered Devanagari PDF. They do not satisfy the later application/database atomicity, restore or physical-printer scenarios below.

## Test layers

- Pure Dart: money/quantity arithmetic, discount allocation, tax snapshots, journal balancing, cost, periods, serial/reservation and permission policies.
- Database integration against real SQLite: FKs, uniqueness, transaction rollback, concurrent commands, migrations, indexes, atomic outbox and projection rebuilds. Mocks alone do not prove transaction behavior.
- Application integration: the full shop walkthrough, corrections, failed printing and restore. Dependency adapters are faked only at genuine external boundaries.
- Flutter widget/accessibility: keyboard POS, locale changes, long strings, large text, validation and permission-filtered UI.
- Platform/hardware: actual Windows/macOS/Android builds, encrypted DB/vault, PDF shaping and representative printers/scanners. Record model, OS, driver and connection.
- V2 integration: real PostgreSQL, API auth, tenant isolation, LAN loss, event replay, ordering, conflict and failover recovery.

## Mandatory invariant and failure scenarios

| ID | Scenario | Expected evidence |
|---|---|---|
| T01 | Repeat same sale command 100 times | One document, one number, one set of movements/journals |
| T02 | Two counters sell the final serialized unit | Exactly one commits; second gets typed stock/serial error |
| T03 | Kill process before/after each posting boundary | Entire transaction absent or complete; no partial posting |
| T04 | Fractional meters, mixed tax, inclusive prices, discounts, rounding | Golden totals and all line/header sums agree |
| T05 | Product/tax/customer changes after invoice | Original invoice and return tax snapshots remain unchanged |
| T06 | Partial repeated sale/purchase returns and refunds | Cannot exceed quantity, credit or refundable amount |
| T07 | Weighted average, return variance, final-unit rounding | Stock value and COGS reconcile, no orphan residual |
| T08 | Direct unauthorized command and export calls | Denied even if UI bypassed; sensitive fields absent |
| T09 | New fiscal year, locked period, timezone boundary | Correct series/date; no reuse and no closed-period writes |
| T10 | Printer disconnected/unknown delivery | Sale retained; reprint creates no new financial effects |
| T11 | Restore to clean machine, wrong key, corrupt archive, disk full | Valid restore reconciles; invalid restore preserves current DB |
| T12 | Upgrade from each supported schema; kill mid-upgrade | Data retained or safe rollback; newer DB not downgraded |
| T13 | English/Marathi/bilingual invoices with long content | Visual QA of A4 and actual thermal output |
| T14 | Payment split, advance, allocation reversal, credit limit, cash close | Cash/clearing/party journals agree with statements |
| T15 | CSV import repeated; invalid rows; duplicate supplier bill | No duplicate postings; row-level actionable errors |
| T16 | Cloud event duplicated/reordered/ack lost/invalid payload | Stable dedup, gap recovery, atomic accepted prefix |
| T17 | Client disconnected from LAN while internet is available | Draft allowed; no unauthorized local posting |
| T18 | Internet unavailable with branch LAN active | Normal branch sale works; outbox catches up later |
| T19 | Old writer restored or two authority epochs | No unsafe promotion; stale writer quarantined/fenced |
| T20 | Partial transfer receipt and lost delivery acknowledgment | Transit + destination + source reconcile, serial has one owner |
| T21 | Cross-tenant IDs, expired grants, forged device/role | API rejects; no data leakage |
| T22 | Quote revision -> reservation -> material issue -> invoice | One stock issue, correct WIP/COGS, releases unused material |
| T23 | Warranty replacement, AMC visit limits and repeated reminders | Serial lineage retained; no duplicate jobs/messages |
| T24 | Large dataset and ten connected counters | Measured p95s, query plans, queue age, no invariant failure |

## Report reconciliation definitions

Net sales = posted sales excluding tax minus accepted sale credits excluding tax. Gross profit = net sales - net COGS. Operating profit = gross profit - recognized operating expenses; do not label it statutory net profit if depreciation/finance costs/other adjustments are absent. Stock value = sum ledger value by location; inventory control account reconciles with sellable/quarantine/transit/project WIP categories. Receivables/payables reconcile party subledgers to control accounts. Payment reports separate recorded tender, advances, refunds and bank-cleared settlements. GST summaries use stored posted tax values, not today's rates.

Deterministic reorder quantity = max(0, average daily eligible sales over configured window * (lead days + safety days) - available stock - confirmed inbound quantity). V1 has no purchase-order pipeline, so confirmed inbound is zero unless an explicit eligible inbound record exists. Label window, exclusions and assumptions. Dead stock uses a configurable no-sale interval, not an unexplained score.

## Release acceptance

**V1 (P11):** R01–R14 core scope; applicable T01–T15 pass; actual target OS/printers validated; tax/accounting fixtures reviewed for target business; encryption, restore drill, reconciliation and support guide complete. Unsupported hardware or legally required missing tax integrations block the affected release. Day-one opening balances and stock reconcile before trading.

**V1.5 (P12):** mobile camera/scanning and supported printers/warranty UX pass on Android; isolated dataset boundary is visible. It is not marketed as live multi-device operation.

**V2 (P14):** P13 infrastructure plus T16–T21/T24 pass, enrollment/fencing/backup recovery rehearsed, branch transfer and cloud credit policy validated. Reconcile aggregate and per-branch totals after outage.

**V3 (P17):** T22–T23 and all affected earlier checks pass; project/service/AMC accounting reviewed; installation and service user acceptance recorded. Every shipped platform has an actual build artifact and signed release evidence.

## Performance measurement procedure

Seed deterministic synthetic data at architecture targets; document hardware, app/schema versions and dataset counts. Warm up, then record at least 100 representative operations and p50/p95/p99 plus failures. Separate UI, DB and printer/network timing. Measure cold start separately. Run concurrency with unique command IDs and deliberate retries. Rebuild all projections and compare checksums/control totals. Track slow-query plans and exported report durations. Mark targets missed honestly and fix before widening scale claims.
