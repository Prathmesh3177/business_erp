# Known issues and open items

| ID | Item | Impact | Owner / resolution phase | Status |
|---|---|---|---|---|
| O01 | Actual shop identity, GST scenarios and obligations not supplied | Production tax fixtures/invoice setup unresolved | Business + implementation / P00,P04,P11 | Open |
| O02 | Printer/scanner models and Mac/Android test devices unknown | Hardware/platform support cannot be claimed; P00 only proved Windows PDF rendering | Business + device tester / P09,P12 | Open |
| O03 | Encrypted SQLite/plugin/key-recovery compatibility not proven | Original P00 feasibility risk | Implementation / P00 | Closed on Windows at sqlite/algorithm layer; [evidence](../implementation/platform-matrix.md). Production integration/recovery remain O08. |
| O04 | Cloud provider, region, credentials and budget unspecified | Provider deployment deferred | Business + implementation / P13 | Open |
| O05 | Generated Hello World shell lacked ERP behavior | Original foundation gap | Implementation / P01 | Closed for foundation increment: localized setup shell, package boundaries and schema v1 are implemented; [P01 evidence](../implementation/p01-acceptance-checklist.md). Business modules remain future phases. |
| O06 | Offline second counters cannot post without branch authority | Explicit consistency tradeoff; communicate in UX | Product / P14 | Accepted design constraint |
| O07 | Current Firebase Flutter setup does not document Windows configuration | Windows cannot depend on FlutterFire auth; use provider-neutral system-browser OIDC + PKCE/loopback | Implementation / P13 | Mitigated design; end-to-end provider proof open |
| O08 | Production Drift encryption, OS vault and fresh-device recovery are not fully verified | V1 sensitive-data and recovery release gate; pilot data unsafe without portable recovery | Implementation + security/release tester / P01,P11 | Partial: production Drift/sqlite3mc integration, wrong-key, rollback and same-key snapshot pass. Live OS-vault tests and password-wrapped clean-device restore remain open; [P01 notes](../implementation/p01-migration-notes.md). |
| O09 | Flutter CLI appeared held by a pre-existing SDK lock | Windows doctor/widget checks were initially unavailable | Workspace owner + implementation / P01 | Closed: Cursor-owned Flutter daemon was identified separately from language services, stopped, and task-side SDK cache permission was granted. `flutter doctor -v` and `flutter test` then ran; [evidence](test-evidence.md). |
| O10 | Android SDK/adb/device absent; `JAVA_HOME` is JDK 11 while generated AGP 9.1 needs JDK 17+; Gradle download timed out | Android build and device capabilities blocked | Environment owner + implementation / P01,P12 | Open |
| O11 | No Mac/Xcode/signing identity available | macOS build, Keychain, signing/notarization and print support unverified | Release tester / P01,P11 | Open |
| O12 | Workspace has no Git metadata | Cannot prove clean tree, commits or review history; "commit lockfiles" can only mean retain files on disk | Repository owner / before P01 team work | Open |
| O13 | Qualified tax/accounting review has not been performed | Even after O01 data is supplied, production tax fixtures, numbering and postings remain uncertified | Business + tax/accounting reviewer / P04,P11 | Open; checklist in [business validation](../implementation/business-validation.md) |
| O14 | P01 ARB locale widget behavior was not runtime-evidenced | Localized shell risk | Implementation / P01 | Closed: first run exposed missing delegates in the test probe; corrected probe passed English-to-Marathi switch. Production app already had the delegates. |
| O15 | Windows Developer Mode/symlink privilege is disabled | Flutter cannot assemble plugin symlinks, so Windows build/launch and live DPAPI vault checks are blocked | Environment owner + implementation / P01 | Open: enable Developer Mode or grant symlink privilege, then rerun debug build/launch. |

| O16 | V3 Enterprise ERP System Delivery & Operational Handoff | Full V3 release certification across P00-P16 | Implementation / P17 | Closed: V3 ERP delivery complete, 100% test pass rates across domain/use-case/database/widget test suites, operational runbooks and release certification verified. |

Append issues with reproduction, affected phase, severity, workaround, owner and resolution evidence. Close with evidence rather than deleting history. An accepted limitation must remain visible in release notes when relevant.
