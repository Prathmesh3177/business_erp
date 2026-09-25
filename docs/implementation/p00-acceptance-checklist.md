# P00 implementation-ready acceptance checklist

Date: 25 September 2026.

- [x] Documentation baseline and generated code inspected; no `AGENTS.md` or Git metadata exists.
- [x] Available baseline scope maps to R01-R22 with no uncovered non-AI feature.
- [x] Module boundaries, application-owned atomic posting, fixed-point arithmetic, command-level permissions and one branch writer remain unchanged.
- [x] Exact dependency candidate set resolves under Dart 3.13.4; disposable lockfiles are retained and production dependencies were not added.
- [x] Windows sqlite3mc build proves cipher activation, correct-key recovery, and unkeyed/wrong-key failure.
- [x] Portable key wrapping proves authenticated round-trip and wrong-password failure; no plaintext DB key appears in the archive serialization.
- [x] Devanagari PDF proof was rendered and visually inspected with a bundled-font candidate.
- [x] Windows cloud authentication has a standards-based browser/PKCE/loopback path without FlutterFire desktop dependency.
- [x] Tax/accounting, fiscal numbering, role, authority and release-boundary review checklists are concrete and contain no invented product rate.
- [x] Tested, blocked and not-run platform/hardware paths are distinguished.
- [x] Installation, migration and recovery impacts are recorded; P00 performs no production schema/data migration.
- [x] ADR-013 records the chosen encryption/key-recovery direction.
- [ ] Full Windows Flutter build and OS-vault integration: **Blocked** by pre-existing Flutter SDK lock.
- [ ] Android build/device/vault/print: **Blocked** by missing Android SDK/device, incorrect default JDK, and Gradle download timeout.
- [ ] macOS build/Keychain/sign/notarize/print: **Not run**, no Mac/Xcode.
- [ ] Physical A4/thermal printer and scanner transports: **Blocked**, no named hardware.
- [ ] Tax/accounting checklist approval: **Blocked**, business identity/scenarios/reviewer not supplied.

## Gate decision

P00 is **Complete with explicit downstream blockers**: the selected platform/security architecture has an evidenced feasible Windows path, package compatibility is locked, Windows cloud auth has a standards path, and all unavailable business/platform/hardware validations are explicit. This does not certify any release or shipping platform. P01 may start only as foundation work; pilot/release gates remain blocked by the unchecked items above.

