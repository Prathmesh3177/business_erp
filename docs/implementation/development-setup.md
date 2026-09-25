# Development setup

P01 uses Flutter 3.47.5 / Dart 3.13.4. The retained application runner is `business_erp/`; pure/application/data/platform packages are under `packages/`. Run commands from the locations below so each retained lockfile is honored.

## Prerequisites

- Windows: Visual Studio C++ desktop workload, Flutter desktop prerequisites, and Developer Mode (or administrator-granted symlink privilege) for Flutter plugins. SQLite3MultipleCiphers is supplied by the pinned `sqlite3` native-asset hook.
- Android: Android SDK/API 24+, build tools, `adb`, and JDK 17 or newer. This host does not currently have the Android SDK or a device.
- macOS: a Mac with Xcode and CocoaPods/signing prerequisites. This Windows host cannot validate the macOS runner.
- Do not place the production database on SMB, a shared drive, or a consumer sync folder.

## Dependency and generation commands

```powershell
cd packages/erp_domain; dart pub get
cd ../erp_application; dart pub get
cd ../erp_local_data; dart pub get; dart run build_runner build
cd ../erp_platform; dart pub get
cd ../../business_erp; dart pub get
```

Direct dependencies use exact versions and every package/app has a `pubspec.lock`. Generated Drift sources are retained. Run `dart run build_runner build` from `packages/erp_local_data` after changing a Drift table.

## Checks

```powershell
dart format business_erp/lib packages/erp_domain packages/erp_application packages/erp_local_data/lib packages/erp_local_data/test packages/erp_platform/lib
powershell -NoProfile -ExecutionPolicy Bypass -File tool/check-package-boundaries.ps1
cd packages/erp_domain; dart analyze; dart test
cd ../erp_application; dart analyze; dart test
cd ../erp_local_data; dart analyze; dart test -r expanded
cd ../erp_platform; dart analyze
cd ../../business_erp; dart analyze; flutter test; flutter build windows
```

The sqlite3mc hook may download its pinned native asset on the first database test/build. Network failure is a blocked test, not a database pass. On 25 September 2026, `flutter doctor -v` and the locale widget test passed after granting the task access to the Flutter SDK cache. The Windows build then reported that plugin builds require symlink support; enable Developer Mode before retrying.

## Runtime data and startup

`erp_platform` obtains the application-support directory. The database is `solar-shop.erpdb`; verified manual snapshots are stored under its `recovery/` subdirectory. A random 32-byte key is created only when the database does not already exist, written through `flutter_secure_storage`, read back, and compared before the encrypted database is opened. If an existing database has no vault key, startup fails closed and does not replace or delete the database.

No default user or plaintext credential is created. P02 owns local user authentication and permissions. P01 setup creates only organization, branch, financial period, and the `single_branch` authority marker.

The startup failure screen offers retry and states that existing data was not changed. Never delete or rename the database as a troubleshooting shortcut. Capture redacted diagnostics and use a verified recovery path.
