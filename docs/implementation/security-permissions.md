# Security, Capabilities and Permission Model

This document outlines the security architecture, capability-based permission model, role assignments, password hashing standards, session lifecycle, audit redaction rules, and local OS-admin threat boundaries for Solar Shop ERP.

---

## 1. Threat Model & OS-Admin Boundaries

- **Adversary with Local OS Administrator Access**: A person with root / OS administrator access can tamper with a running local application process or unencrypted memory. Application-level audit logging alone cannot prevent a root user from altering physical disk files. Therefore, Solar Shop ERP relies on:
  1. OS user account segregation and disk permissions.
  2. Database encryption (unencrypted standard SQLite mode supported for development; SQLite3MultipleCiphers/Argon2id for production release hardening).
  3. Deny-by-default capability checks inside application command handlers.
- **Offline Operation**: Local authentication does not depend on cloud server connectivity. Password hashes and recovery keys are validated locally.

---

## 2. Password Hashing & Key Derivation Specification

- **Algorithm**: Salted PBKDF2-HMAC-SHA256.
- **Iterations**: 100,000 rounds.
- **Salt**: 16-byte cryptographically secure random salt (`Random.secure()`), base64url encoded.
- **Recovery Key**: 16-character alphanumeric string generated via `Random.secure()` (excluding ambiguous characters `I, 1, O, 0`), formatted as `XXXX-XXXX-XXXX-XXXX`. Stored as a SHA-256 hash (`recovery_key_hash`).

---

## 3. Capability Identifiers & Permission Matrix

Permissions are enforced at the **application command layer** (`CommandContext.requireCapability`) regardless of UI or routing.

| Capability Identifier | Description | Admin Role | Counter Role |
|---|---|:---:|:---:|
| `user.manage` | Create, edit, and toggle status of users | Yes | No |
| `role.manage` | Create and modify system and custom roles | Yes | No |
| `audit.read` | Inspect append-only security audit log events | Yes | No |
| `system.snapshot` | Create verified local database snapshots | Yes | No |
| `cost_data.read` | Access purchase costs, margins & vendor prices | Yes | No |
| `sales.create` | Post POS counter sales & create receipts | Yes | Yes |
| `sales.read` | Read sales invoice history and receipts | Yes | Yes |
| `party.manage` | Create & edit customer profiles | Yes | Yes |
| `inventory.manage` | View stock items and record inventory movements | Yes | Yes |

---

## 4. DTO Data Segregation (Public vs. Cost-Sensitive)

- **Public DTOs**: `PublicProductCatalogDto` excludes sensitive cost and margin figures (safe for Counter Staff).
- **Cost-Sensitive DTOs**: `CostSensitiveProductDto` explicitly requires `Capability.costDataRead`. Attempting to instantiate or read cost DTOs without this capability throws `AuthorizationFailure('authorization.denied')`.

---

## 5. Session Lifecycle & Idle Lock

- **Session Expiry**: 12 hours from initial authentication.
- **Idle Lock**: Sessions can be manually locked or auto-locked after inactivity. Locked sessions require re-entering the account password (`unlockSession`). Commands executed on a locked session throw `LockedFailure('session.locked')`.
- **Failed Login Throttling**: 5 consecutive failed login attempts trigger a **15-minute temporary lockout** (`LoginThrottleStatus.isLockedOut`).

---

## 6. Last-Administrator Safeguard

- The system strictly enforces `User.validateLastAdminSafeguard`.
- Any attempt to deactivate, delete, or remove the `Administrator` role from the final remaining active Administrator throws `ConflictFailure('user.last_admin_protected')`.

---

## 7. Append-Only Audit Event Logging & Redaction

- All security-relevant actions (`user.login`, `user.first_admin_created`, `user.created`, `user.status_toggled`, `user.password_reset_recovery_key`) append immutable records to the `audit_events` table.
- `AuditRedactor` automatically sanitizes all payload fields matching sensitive keys (`password`, `recoveryKey`, `token`, `secret`, `pan`, `bank_account`, etc.) before persistence.
