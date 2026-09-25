# Platform and capability matrix

Validated on 25 September 2026. `Pass` means the named procedure ran on the named host. `Blocked` and `Not run` are not support claims. Package metadata is compatibility evidence only; it is not a substitute for a platform build or physical-device test.

## Validation host

- Windows APIs report `Microsoft Windows 10.0.26200`, x64. The product-name API reported Windows 10 Pro; the build number is recorded without attempting to relabel the OS.
- Flutter SDK files report stable 3.47.5, revision `6a19cca56475dbfba1478ee68d7bd0c2ef891da1`; bundled Dart is 3.13.4.
- Visual Studio 2022 Build Tools C/C++ compiler 19.44.35228 compiled both sqlite3mc and HarfBuzz native assets.
- The workspace has no Git metadata and no `AGENTS.md`. Existing files were therefore treated as user-owned without a clean-tree claim.

## Toolchain matrix

| Target | Official floor/current constraint | Host evidence | Result | Required next evidence |
|---|---|---|---|---|
| Windows x64 | Flutter 3.47 supports Windows 10 and 11 ([Flutter supported platforms](https://docs.flutter.dev/reference/supported-platforms)) | `flutter doctor -v` passes Flutter 3.47.5, Windows 11 25H2, VS Build Tools 17.14.37, devices and network. Locale widget test passes. `flutter build windows --debug` stops because plugin symlinks require Developer Mode or symlink privilege. | **Partially passed / build blocked by host setting** | Enable Developer Mode or symlink privilege, rerun build, launch, live vault test and package on the target Windows baseline. |
| macOS x64/arm64 | Flutter 3.47 documents Monterey 12 through Golden Gate 27 as supported; build/sign/notarize on macOS with Xcode | macOS runner files exist, but this is a Windows host with no Xcode, Mac, signing identity, or printer. | **Not run** | Build and launch on each marketed architecture; exercise Keychain, encrypted DB, PDF, OS print, signing and notarization on a Mac. |
| Android arm64/x64 | Flutter 3.47 documents API 24-37 supported, API 24-36 CI-tested. `flutter_secure_storage` 11.2.0 requires API 23+, so API 24 is compatible. | Android runner exists. Generated project pins AGP 9.1.0, Gradle 9.3.1 and Kotlin 2.4.0. Official AGP 9.1 compatibility requires JDK 17 and Gradle 9.3.1 ([Android release notes](https://developer.android.com/build/releases/agp-9-1-0-release-notes)). JDK 21 is installed, but `JAVA_HOME` points to JDK 11; Android SDK, `adb`, emulator and device are absent. Wrapper download timed out. | **Blocked** | Install Android SDK/API and build tools, set the Flutter/Gradle JDK to 17 or 21, resolve Gradle distribution access, accept licenses, run debug/release builds, and test on a named API 24+ device. |

The present project uses the generated identifiers `com.example.business_erp` / `com.example.businessErp` and Android release builds use the debug signing key. Those paths are development-only and must be replaced before any release.

## Security, document and transport spikes

| Capability | Windows result | macOS result | Android result | Support conclusion |
|---|---|---|---|---|
| Drift-compatible encrypted SQLite | **Pass through production P01 adapter.** Drift isolate/schema v1 with `sqlite3` 3.6.0 sqlite3mc passed restart persistence, wrong-key rejection, transactional rollback, encrypted schema migration and verified snapshot reopening on Windows. | Not run | Not run | Windows database path is implemented and evidenced. Shipping still requires real Flutter build/vault proof and the same suite on every marketed platform. Do not claim ordinary SQLite is encrypted. |
| Portable key recovery | **Pass algorithm spike.** A random 256-bit DB key was wrapped with Argon2id (19 MiB, 2 iterations, parallelism 1) and AES-256-GCM; recovery passed, a wrong password failed authentication, and the archive did not contain the plaintext key. | Algorithm is pure Dart; platform run not performed | Algorithm is pure Dart; platform run not performed | Feasible format path. Parameters are provisional until benchmark/security review. P11 still requires a fresh-device archive restore, corruption cases, and operator recovery-material handling. |
| OS key protection | Dependency resolution selected `flutter_secure_storage` 11.2.0 / Windows implementation 4.2.2. No vault call ran because Flutter was locked. The Windows implementation uses a DPAPI-protected encrypted file, not Credential Manager; application separation and corruption behavior need explicit tests. | Keychain not run | Keystore-backed defaults not run; Android auto-backup exclusions not configured/tested | **Blocked for release, not for architecture.** Keep an application vault port and reject startup if the database key cannot be retrieved. Never rely on the portable recovery password as an always-online key. |
| Devanagari PDF shaping | **Pass.** `pdf` 3.13.1 + `pdf_text_shaper` 1.1.0 compiled HarfBuzz, embedded OFL Noto Sans Devanagari, created a one-page A4 PDF, and Poppler rendering showed correct Marathi matras/conjuncts with no clipping or missing glyph boxes. The installed Nirmala `.ttc` failed because `package:pdf` expected a supported TTF; the production font must be bundled as TTF. | Not run | Not run | A PDF renderer path is feasible. Proof artifact: [P00 Devanagari shaping PDF](../../output/pdf/p00-devanagari-shaping-proof.pdf). This is not a tax invoice or printer proof. |
| Windows OS print | Print Spooler was running; no installed printer was returned. `printing` 5.15.1 resolves and declares Windows support, but no dialog/job/device test ran. | Not run | Not run | PDF + OS spool remains the baseline. **No actual printing claim.** |
| Thermal/raw/network/Bluetooth/USB transports | No printer or scanner model supplied; no physical transport exercised. | Not run | No SDK/device and no peripherals | Unsupported until P09/P12 records named model, driver/firmware, connection, page width, Marathi raster output, disconnect and unknown-delivery behavior. |

## Cloud identity on Windows

Firebase's current Flutter setup workflow documents Apple, Android and web configuration, not Windows ([Firebase Flutter setup](https://firebase.google.com/docs/flutter/setup)). Windows production must therefore not depend on a FlutterFire desktop authentication plugin.

The feasible path is an identity-provider-neutral OIDC authorization-code flow with PKCE in the system browser and a loopback redirect bound only to `127.0.0.1`, following [RFC 8252](https://www.rfc-editor.org/info/rfc8252/). Tokens are stored behind the OS-vault adapter; local V1 authentication stays independent and offline. No provider, tenant, redirect registration or credentials exist, so sign-in was **not run**. Provider selection and end-to-end authentication remain P13 gates.

## Installation and unsupported paths

- P01 pinned Flutter 3.47.5/Dart 3.13.4 dependencies and retained app/package lockfiles. The workspace has no Git metadata, so no commit claim is possible; upgrades require the same platform matrix again.
- Native builds require MSVC on Windows, Xcode on macOS, and JDK 17+ plus Android SDK on Android. HarfBuzz and sqlite3mc add first-build native compilation time.
- Bundle a reviewed OFL Devanagari TTF and its license. Do not depend on host fonts or a TTC file.
- Do not place SQLite on SMB, a shared drive, or a consumer sync folder. Do not add a second offline writer. Do not advertise macOS, Android, printer, scanner, signing or cloud authentication until their rows have passing evidence.
- P01 adds encrypted schema v1 and a verified same-device snapshot; portable archive/restore and attachments remain unimplemented. [Security and operations](../06-security-and-operations.md) remains the production contract.

## Exact next probes

1. Enable Windows Developer Mode or symlink privilege, rerun `flutter build windows --debug`, launch, and run a vault create/read/restart/delete/corruption/missing-key integration on this host.
2. Provision Android SDK and a named API 24+ device; correct `JAVA_HOME`; run encrypted DB, vault, PDF and system-print checks.
3. Run the same encrypted DB/vault/PDF/build set on an arm64 Mac with Xcode, then sign/notarize a test build.
4. Obtain exact A4/thermal printer and scanner models before any P09 transport implementation.

