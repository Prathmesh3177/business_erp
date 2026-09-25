# P00 dependency register

Reviewed 25 September 2026 against official project documentation and pub.dev package records. Versions below are exact P00 compatibility pins, not an instruction to add all packages to production before their owning phase. The complete candidate set resolved together under Dart 3.13.4 and is locked in `spikes/p00_flutter_dependency_resolution/pubspec.lock`.

| Component | P00 version | License | Platforms / host requirements | Status and use |
|---|---:|---|---|---|
| Flutter / Dart | 3.47.5 / 3.13.4 | BSD-3-Clause | Windows build tools; macOS/Xcode; Android SDK/JDK | Installed SDK files verified. Flutter CLI blocked by an existing lock; direct Dart analysis passed. Initial P01 toolchain pin. |
| `flutter_riverpod` | 3.4.3 | MIT | Flutter; min Dart 3.12 | Resolved. UI/application dependency injection only; authorization remains in application commands. |
| `go_router` | 18.0.1 | BSD-3-Clause | Flutter | Resolved. Navigation guards are convenience, never the permission boundary. |
| `intl` | 0.20.3 | BSD-3-Clause | Dart/Flutter; min Dart 3.9 | Resolved. Locale presentation only; posted fixed-point values never round-trip through localized strings. |
| `uuid` | 4.6.0 | MIT | Pure Dart | Admitted in P01 behind the domain `IdGenerator` port; organization/branch/period IDs are client-generated UUIDs. |
| `path` / `path_provider` | 1.9.1 / 2.1.6 | BSD-3-Clause | `path_provider` uses Flutter platform adapters | Admitted in P01 for application-support database and recovery directories. Platform execution remains part of the vault/app launch gate. |
| `drift_dev` / `build_runner` | 2.35.0 / 2.16.1 | MIT / BSD-3-Clause | Code generation; Dart 3.13 compatible | Admitted for Drift schema generation. `test` was raised to 1.32.0 because 1.29.0's Analyzer constraint conflicts with Drift 2.35.0. |
| `drift` | 2.35.0 | MIT | Dart/Flutter native platforms; min Dart 3.10 | Resolved with sqlite3 3.6.0. P01 repository/migration layer; application coordinator owns cross-module transactions. |
| `sqlite3` | 3.6.0 | MIT | Native-assets C toolchain | Resolved and executed on Windows. Version 3.1.4 was rejected because its native-toolchain constraint conflicts with HarfBuzz; 3.6.0 resolves the full set. |
| SQLite3MultipleCiphers | 2.5.0 source line bundled by the sqlite3 build hook | MIT | C compiler; use `source: sqlite3mc`; temp data kept in memory | Windows cipher spike passed with default ChaCha20-Poly1305. Project documents encrypted journals but not temp tables and recommends memory temp storage ([upstream overview](https://utelle.github.io/SQLite3MultipleCiphers/)). P01 must assert `PRAGMA cipher` at runtime before applying the key. |
| `flutter_secure_storage` | 11.2.0 (Windows implementation resolved to 4.2.2) | BSD-3-Clause | Android API 23+; Windows C++ ATL; macOS Keychain provisioning choices | Resolved, not executed. Candidate vault adapter only. Windows DPAPI file behavior, app separation, corruption, logout and recovery must pass before adoption. |
| `cryptography` | 2.9.0 | Apache-2.0 | Pure Dart fallback; platform acceleration varies | Portable key-wrap spike passed using Argon2id + AES-256-GCM. Final KDF parameters require supported-hardware benchmark and security review. |
| `pdf` | 3.13.1 | Apache-2.0 | Pure Dart PDF generation | Executed. Use immutable invoice view models; this library alone does not shape Devanagari correctly. |
| `pdf_text_shaper` | 1.1.0 | Apache-2.0 | HarfBuzz native compile; native platforms listed, no web | Executed on Windows. Required for Marathi shaping. Newer/small ecosystem component, so pin and keep visual golden/fallback raster tests. |
| HarfBuzz (`harfbuzz_ffi`) | 0.5.1 transitive | MIT | Native C++ compile | Resolved/compiled on Windows as a transitive dependency. Record notices in release inventory. |
| Noto Sans Devanagari | Google Fonts current variable TTF used by proof; final asset hash/version to pin in P01/P09 | SIL Open Font License 1.1 | Bundle TTF plus OFL notice | Proof source was Google Fonts; SHA-256 `14EC4AF41F27482216D1C2229F417FF9B1425E1BABB014E57D1D40D03229853E`. Production must vendor the reviewed font and license rather than fetch at runtime. |
| `printing` | 5.15.1 | Apache-2.0 | Flutter plugin; OS print services/drivers | Resolved; actual transport not run. Baseline is PDF + OS dialog/spooler. No raw-device guarantee. |
| OAuth client pieces | `oauth2` 2.0.5 (BSD-3-Clause) and `url_launcher` to be pinned in P13 | Provider and redirect dependent | System browser, PKCE and loopback/custom redirect | Architecture path only; not included in P00 lock because provider capabilities are unresolved. Do not use an embedded web view or ship a client secret. |
| Firebase Flutter plugins | None | Product-specific | Current official setup lists Apple/Android/web, not Windows | Deliberately not selected as a Windows production dependency. Firebase identity/storage may be server-side/provider adapters after P13 proof. |

## License and supply-chain gates

- Current selected licenses are permissive, and the font is OFL. Generate a transitive license notice from the final application lockfile before each release; this register does not replace legal review.
- SQLite core is public domain; SQLite3MultipleCiphers is MIT. The commercial SQLite SEE alternative was reviewed but not selected because it requires a separate paid source license.
- Never use obsolete `sqlcipher_flutter_libs`; Drift now recommends `sqlite3` 3.x with the sqlite3mc build hook ([Drift encryption guidance](https://drift.simonbinder.eu/platforms/encryption/)).
- Automated dependency/security updates must open a reviewed change, rerun schema/encryption/recovery/PDF/platform tests, and preserve lockfiles. Do not use unconstrained `any` versions.

## Lockfiles and production admission

P01 retained exact direct constraints and lockfiles for `business_erp` and all four packages. The real local-data adapter passed failure-path tests; Flutter plugin/platform admission is still conditional on live vault and target build checks. This workspace still lacks Git metadata, so the files are retained on disk but cannot truthfully be called committed.

