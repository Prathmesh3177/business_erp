# Posting, valuation, tax and accounts

P00 changed no posting formula or accounting policy. The requirements/tax/accounting review in [business validation](implementation/business-validation.md) reaffirmed fixed-point arithmetic, application-owned atomic transactions, permission checks, immutable snapshots and one posting authority. No sample rate is a production fixture.

## Invariants

Posted business documents are immutable. Corrections create linked reversing/adjusting documents in an open period. Cancellation preserves the number and history and applies the permitted reversal workflow; no destructive invoice editing. Drafts are mutable with optimistic versions. Posting failure rolls back invoice, numbering, stock, journal, allocations, audit and outbox together.

State machine: `draft -> validated -> posted`; validation is repeated inside posting. A posted record may have derived states such as partly returned, settled or reversed; these come from linked events, not overwritten totals. A print failure is a print failure, never a failed sale.

## Sale posting sequence

```mermaid
sequenceDiagram
  participant UI as POS
  participant APP as Posting coordinator
  participant DB as Local authority DB
  participant PRINT as Print worker
  UI->>APP: PostSale(commandId, expectedVersion)
  APP->>DB: Begin transaction and check prior result
  APP->>DB: Validate permission, period, stock, serials, credit
  APP->>DB: Allocate number; write immutable invoice
  APP->>DB: Append stock, balanced journals, allocations
  APP->>DB: Audit + outbox + command result + print job
  APP->>DB: Commit
  APP-->>UI: Existing or new committed invoice
  PRINT->>DB: Read queued job and frozen invoice
  PRINT-->>UI: Printed / failed / delivery unknown
```

At commit uncertainty, query the command ID before offering another sale. All external side effects happen after commit and are independently retryable.

## Money and tax algorithm

Rates, HSN treatment, place-of-supply rules, rounding policy, exemptions and effective dates are configured/versioned. Do not hardcode the pasted brief's pump rate. Tax overrides require permission, reason and a frozen snapshot. Distinguish nil-rated, exempt, zero-rated and taxable classifications in reporting even when a line's tax is zero. V1 supports the approved domestic shop scenarios; unsupported reverse charge/export/composition/special cases must be explicitly blocked until implemented and validated.

1. Convert quantity to base units without binary floating point. Compute extended price at high precision. Inclusive-price lines extract the configured tax component; exclusive-price lines add tax after discount.
2. Apply line discounts, then proportionally allocate invoice discount across eligible taxable bases with largest-remainder allocation. Tie-break on stable line ID. Allocations sum exactly to the invoice discount; no negative taxable line.
3. Select tax treatment from registration, place of supply and approved policy, not customer address alone. Compute applicable components at high precision, round to paise with the configured versioned rule, and sum stored line values. Split-tax components and any residual distribution are deterministic.
4. Grand total = sum(taxable line values + tax components + approved charges) + explicit round-off. Round-off posts to a separate account. Printed totals must equal persisted totals.
5. For returns use the original tax and discount snapshots, cumulative proportional rounding, and give the last eligible return the residual paise. Never recalculate old invoices using today's tax master.

Synthetic engine fixture only: taxable value INR 1,000.00 and test rate 18% yields INR 180.00 tax and INR 1,180.00 gross. With a 10% pre-tax discount the base is INR 900.00 and tax INR 162.00. This does not prescribe a rate for solar equipment. Add inclusive, mixed rates, fractional quantity, invoice discount, zero tax and rounding-boundary fixtures approved for the actual business.

Numbering design: compact series such as `A/2627/000001`, registration-scoped, unique per fiscal year and allocated atomically. Validate length/characters against the currently applicable rules. Never reuse a cancelled number. Restore must not rewind a live series into duplicates; see recovery rules.

## Inventory and weighted average cost

V1 chooses perpetual weighted average **per product and location**. Serial tracking identifies physical units; valuation remains weighted average. Do not offer FIFO as a UI toggle after postings exist. A future costing change requires a dated migration, reconciliation and ADR.

- Receipt: new quantity = old quantity + received; new value = old value + net acquisition cost including allocated eligible landed costs and nonrecoverable tax. Recoverable tax is kept outside inventory value according to approved accounting policy.
- Issue: cost = issue quantity * pre-issue average, with the chosen high-precision cost policy. When all units are issued, consume the full remaining inventory value to remove residual rounding. Persist cost on movement and sale line.
- Example: 10 units valued at INR 1,000 plus 5 valued at INR 750 => 15 valued at INR 1,750; average 116.666667. Three-unit issue costs INR 350.00, leaving 12 valued at INR 1,400.00.
- Sales return: reverse original issued cost for the accepted quantity. Sellable goods return to sellable stock; damaged goods go to quarantine. The credit note and physical disposition are linked but distinct. Scrap/write-down is a separate approved adjustment.
- Purchase return: physically issue at current weighted average; reverse supplier liability/input tax using the original bill's accepted credit values; post the value difference to a configured purchase-return variance account. Never create negative stock value by blindly subtracting old purchase cost. Business accounting review validates this policy.
- Backdating: business dates can be recorded with permission, but costing follows immutable posting sequence. Closed periods cannot be posted into; prior-period corrections use an open-period adjustment. Do not silently recompute historical COGS.
- Negative available stock is prohibited. Reservations are checked under the transaction lock. Adjustment requires reason, approval and cost basis; opening stock uses the same ledger.

Same-branch transfer posts source issue and destination receipt at the source issued value in one transaction. Interbranch transfers use dispatch/transit/receipt with independent confirmations. Across different tax registrations, required commercial/tax documents must be implemented before enabling such transfers.

## Minimal balanced accounting core

Build a small double-entry engine before purchases/sales. It supports operational accounts and reconciliation; statutory filing/full general accounting is not automatically claimed.

| Event | Debit | Credit |
|---|---|---|
| Purchase on credit | Inventory + eligible input tax | Supplier payable |
| Supplier payment | Supplier payable | Cash/bank/clearing |
| Sale | Customer receivable | Sales revenue + output tax |
| Sale stock issue | Cost of goods sold | Inventory |
| Customer receipt | Cash/bank/UPI/card clearing | Customer receivable |
| Expense paid | Expense + eligible input tax | Cash/bank/payable |
| Sale credit note | Sales returns + output tax reversal | Customer receivable |
| Accepted sale stock return | Inventory | Cost of goods sold reversal |
| Refund | Customer receivable / customer credit liability as configured | Cash/bank/clearing |
| Opening stock | Inventory | Opening balance equity/clearing |
| Customer opening dues | Customer receivable | Opening balance equity/clearing |
| Supplier opening dues | Opening balance equity/clearing | Supplier payable |

Cash sales still use sale + receipt postings so credit and paid sales share one model. Party subledgers derive from journal lines with party IDs. No separate manually editable `customer.balance` or `supplier.balance`. Accounts marked as control accounts require party references.

Payments are independent documents; allocation settles an invoice without generating revenue again. Support partial/split payment, unapplied advances, credit notes, overpayments and reversal. Separate allocation reversal from cash refund. Cash change is not revenue. UPI/card recorded payments use clearing accounts until reconciled to bank; payment reference deduplication prevents accidental repeats but does not imply provider verification. Cash sessions capture expected vs counted cash and an approved variance posting.

Credit check uses current exposure including the proposed unpaid amount. Counter cannot bypass limits. In V2, a customer shared across branches has either cloud-verified global credit or preallocated branch credit budgets; offline branches cannot all spend the full global limit. Cross-branch payment allocation waits for the owning branch and is not posted twice.

## Solar project and service rules

Quotes are versioned commercial offers and never alter stock/accounts. Acceptance freezes the revision. Reservations reduce availability only. Material issue/delivery moves stock once into project WIP at captured cost; final invoicing recognizes revenue and transfers WIP to COGS without issuing stock again. Cash milestones are advances until their applicable accounting treatment. Unused materials return from project at captured issue cost. Change orders have their own accepted revision and budget effect.

Warranty terms are snapshotted at sale, with an explicit start basis (sale or documented installation). Returns/replacements link old and new serials, preserving coverage history. Service jobs use existing spare-issue and expense commands. AMC invoicing, deferred revenue/revenue recognition and included/excluded service limits require an approved schedule; do not count full contract cash as earned service revenue automatically.
