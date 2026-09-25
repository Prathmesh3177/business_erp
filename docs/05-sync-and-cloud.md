# Cloud, synchronization and branch authority

P00 reaffirmed this authority model. Windows cloud identity has a feasible standards path using system-browser OIDC authorization code + PKCE and a loopback redirect, but no provider/tenant/credentials were available and no sign-in ran. Firebase Flutter plugins are not a Windows production dependency. Provider proof remains P13; see the [platform matrix](implementation/platform-matrix.md).

## Consistency decision

Local-first does not mean every disconnected device may sell the same stock. **One authority per branch** owns stock, invoice sequence, branch journal and reservations. In V1 it is the desktop app; in V2 it is a branch agent using the same Dart application services and SQLite repository. Counters connect over authenticated TLS on the LAN. Remote Android clients may read cached data and prepare drafts; if they cannot reach the authority, posting is disabled with a clear explanation. Internet loss does not prevent LAN-connected branch operations.

This explicitly trades disconnected counter availability for reliable stock and financial consistency. Separate branches may each trade offline against their own stock. Cloud cannot independently issue stock or numbers from an offline branch. Preallocated independent stock/credit partitions are a possible later design, not part of these releases.

## Ownership matrix

| Data | Writer | Offline behavior |
|---|---|---|
| V1 masters and branch facts | Main installation | Fully local |
| V2 organization product/tax/role masters | Cloud admin service using optimistic versions | Branch uses last accepted version; local edits become proposals |
| V2 branch facts, sequences, stock, reservations | Registered branch authority | Posts while internet unavailable |
| Customer creation at branch | Branch authority, branch-prefixed identity | UUID avoids collision; cloud may link duplicates without changing old snapshots |
| Global customer credit | Cloud policy with branch budgets | Cannot exceed the allocated branch budget |
| Client carts, photo staging, notes | Originating client | Draft only until acknowledged |
| Cloud reports | Cloud projections | Display last accepted branch cursor/time and incomplete-data warning |

During V1-to-V2 enrollment, freeze local writes, assign tenant/branch IDs, register authority epoch, reconcile counts/totals, upload baseline and attachments, receive verified cursor, then activate replication. Existing historical facts are imported once, not replayed as fresh business commands.

## Wire contract

Use authenticated HTTPS with device credentials and user sessions. Version an OpenAPI specification in P13. Never expose PostgreSQL or SQLite directly. Example branch event envelope:

```json
{
  "protocolVersion": 1,
  "eventId": "uuid",
  "organizationId": "uuid",
  "branchId": "uuid",
  "authorityEpoch": 1,
  "streamSequence": 123,
  "commandId": "uuid",
  "eventType": "SalePosted",
  "payloadVersion": 1,
  "occurredAt": "2026-09-24T06:00:00Z",
  "payloadHash": "sha256-of-canonical-payload",
  "payload": { "documentId": "uuid", "postingBundle": "schema-defined fields" }
}
```

The illustrative `postingBundle` becomes a typed schema containing the immutable document, movement and journal facts; it is not an arbitrary string in production. Server derives/validates tenant and branch from credentials. Hashes detect mismatched duplicates, not identity; TLS and credential validation provide authentication.

| Endpoint | Purpose and behavior |
|---|---|
| `POST /v1/branches/{id}/commands` | LAN authority command; idempotency key, actor session, expected draft version |
| `GET /v1/commands/{id}` | Resolve timeout/unknown commit without reposting |
| `POST /v1/sync/events:batch` | Ordered immutable branch events; acknowledge durable contiguous prefix |
| `GET /v1/sync/changes?cursor=...&limit=...` | Scoped master/branch feed; stable opaque continuation cursor |
| `POST /v1/master-change-requests` | Versioned proposals; conflict on stale base version |
| `POST /v1/attachments/upload-intents` | MIME/size/hash validation and bounded signed upload URL |
| `POST /v1/attachments/{id}/complete` | Verify object hash/size before publishing reference |
| `POST /v1/devices/enroll` | Admin-authorized pairing; no public self-enrollment |
| `GET /v1/health` | Minimal liveness; detailed diagnostics require permission |

Use typed errors: `permission_denied`, `stale_version`, `insufficient_stock`, `period_closed`, `authority_mismatch`, `sequence_gap`, `payload_mismatch`, `upgrade_required`, `temporarily_unavailable`. Do not blindly retry business rejection.

## Delivery and ingestion

1. Posting transaction writes an outbox event and increments a monotonic branch sequence. Transport sends at least once with bounded batches, exponential backoff and jitter.
2. Cloud ingestion locks that branch stream, checks epoch and expected sequence, validates posting bundle invariants and writes event, immutable facts, projections and inbox dedup key in one PostgreSQL transaction.
3. Identical duplicate returns the previous acknowledgment. Same event ID/sequence with a different hash is quarantined. A gap returns the missing expected sequence; later events wait. Clocks do not determine order.
4. Branch deletes/archives acknowledged payloads only according to retention policy, after recording durable cursor. Acknowledgment lost in transit leads to safe replay.
5. Download applies each accepted change and advances cursor in the same local transaction. Snapshot bootstrap has a fixed watermark and catches up from that watermark after the snapshot.
6. Payload versions are supported for a documented compatibility window. Unknown versions pause that stream and surface an upgrade action; they are never skipped.

No last-write-wins merging of stock, journals, posted invoices or serial ownership. Master conflicts retain proposed/base/current values for authorized resolution. Tombstones propagate; product deactivation does not remove historical references. Attachment upload is a separate job; failed photo upload cannot erase a committed sale.

## Branch transfers

Same registration workflow: source reserves -> dispatch posts source stock into transit -> signed transfer event reaches cloud/destination -> destination verifies physical serial/quantity -> receipt posts destination stock -> discrepancy records short/damaged goods without inventing stock. Partial receipts are bounded by dispatched quantity. Dispatch and receipt command IDs are stable. Offline receipt stays pending until its dispatch authorization can be validated; never fabricate a receipt from an unverified number. Transit is a real location/account and retains ownership/valuation until receipt. Cancellation after dispatch requires an explicit return/discrepancy process.

Transfers between different GST registrations remain disabled until their tax and commercial document handling is validated. Consolidation must eliminate internal movements appropriately and preserve entity boundaries.

## Failover, security and operations

Never auto-promote a disconnected client. Planned authority move: stop old posting, reconcile final sequence, back up, revoke/fence old authority, increment epoch, provision replacement, resume and test. A lost machine requires incident recovery and evidence that the former writer cannot continue posting; cloud rejection alone cannot prevent an old offline machine printing invoices. If the old writer cannot be fenced, recovery remains blocked for posting until an operational partition/series plan is approved.

After restore do not replay stale pending commands or restart a sequence from backup blindly. Compare last accepted cloud cursor and sequence, reconcile missing physical documents, and use a fresh authorized series when required. Keep posting disabled until gaps are explained.

Cloud deployment starts as a single modular API and worker, managed PostgreSQL and private object store. Schema migrations use expand/contract changes, staging and point-in-time recovery. Set upload/request/tenant quotas, batch limits, timeouts and rate limits. Alert on unacknowledged outbox age, missing sequence, reconciliation mismatch, disk pressure, credential expiry and failed backup. No Kubernetes or separate services are needed initially.
