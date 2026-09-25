import 'dart:io';

import 'package:erp_domain/erp_domain.dart';
import 'package:erp_platform/erp_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late File dbFile;
  late Directory attachmentsDir;
  late File outputFile;
  late File activeDbFile;
  const envelope = PortableBackupEnvelope();

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('solar-erp-backup-test-');
    dbFile = File('${tempDir.path}${Platform.pathSeparator}test.db');
    await dbFile.writeAsString('SAMPLE_SQLITE_DATABASE_DATA_V1');

    attachmentsDir = Directory('${tempDir.path}${Platform.pathSeparator}attachments');
    attachmentsDir.createSync(recursive: true);
    final attFile = File('${attachmentsDir.path}${Platform.pathSeparator}invoice_1.pdf');
    await attFile.writeAsString('SAMPLE_PDF_BYTES');

    outputFile = File('${tempDir.path}${Platform.pathSeparator}backup.erpa');
    activeDbFile = File('${tempDir.path}${Platform.pathSeparator}active.db');
    await activeDbFile.writeAsString('LIVE_ACTIVE_DB_DATA');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('P11 PortableBackupEnvelope Tests', () {
    test('creates backup package and verifies package checksums with correct password', () async {
      await envelope.createPackage(
        databaseFile: dbFile,
        attachmentsDirectory: attachmentsDir,
        password: 'SecretBackupPassword123!',
        organizationId: 'org_1',
        schemaVersion: 8,
        outputFile: outputFile,
      );

      expect(outputFile.existsSync(), isTrue);

      final verification = await envelope.verifyPackage(
        packageFile: outputFile,
        password: 'SecretBackupPassword123!',
      );

      expect(verification.isValid, isTrue);
      expect(verification.manifest, isNotNull);
      expect(verification.manifest!.organizationId, equals('org_1'));
      expect(verification.manifest!.schemaVersion, equals(8));
      expect(verification.manifest!.attachments.length, equals(1));
    });

    test('verifyPackage rejects wrong password', () async {
      await envelope.createPackage(
        databaseFile: dbFile,
        attachmentsDirectory: attachmentsDir,
        password: 'SecretBackupPassword123!',
        organizationId: 'org_1',
        schemaVersion: 8,
        outputFile: outputFile,
      );

      final verification = await envelope.verifyPackage(
        packageFile: outputFile,
        password: 'WrongPassword456!',
      );

      expect(verification.isValid, isFalse);
      expect(verification.errorMessage, contains('Decryption or verification failed'));
    });

    test('stagedRestore atomically replaces database and releases maintenance lock', () async {
      await envelope.createPackage(
        databaseFile: dbFile,
        attachmentsDirectory: attachmentsDir,
        password: 'SecretBackupPassword123!',
        organizationId: 'org_1',
        schemaVersion: 8,
        outputFile: outputFile,
      );

      var lockAcquired = false;
      var lockReleased = false;

      final manifest = await envelope.stagedRestore(
        packageFile: outputFile,
        password: 'SecretBackupPassword123!',
        activeDatabaseFile: activeDbFile,
        onMaintenanceLock: () async {
          lockAcquired = true;
        },
        onMaintenanceRelease: () async {
          lockReleased = true;
        },
      );

      expect(lockAcquired, isTrue);
      expect(lockReleased, isTrue);
      expect(manifest.organizationId, equals('org_1'));

      final restoredContent = await activeDbFile.readAsString();
      expect(restoredContent, equals('SAMPLE_SQLITE_DATABASE_DATA_V1'));
    });

    test('stagedRestore rolls back to pre-restore safety copy on wrong password failure', () async {
      await envelope.createPackage(
        databaseFile: dbFile,
        attachmentsDirectory: attachmentsDir,
        password: 'CorrectPassword123!',
        organizationId: 'org_1',
        schemaVersion: 8,
        outputFile: outputFile,
      );

      var lockReleased = false;

      await expectLater(
        envelope.stagedRestore(
          packageFile: outputFile,
          password: 'WrongPassword!',
          activeDatabaseFile: activeDbFile,
          onMaintenanceLock: () async {},
          onMaintenanceRelease: () async {
            lockReleased = true;
          },
        ),
        throwsA(isA<ValidationFailure>()),
      );

      expect(lockReleased, isTrue);
      // Active DB remains untouched with live content
      final content = await activeDbFile.readAsString();
      expect(content, equals('LIVE_ACTIVE_DB_DATA'));
    });
  });
}
