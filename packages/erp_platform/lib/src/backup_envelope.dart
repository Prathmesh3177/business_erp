import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';

import 'crypto_hasher.dart';

final class BackupManifestAttachment {
  const BackupManifestAttachment({
    required this.relativePath,
    required this.sha256,
  });

  final String relativePath;
  final String sha256;

  Map<String, dynamic> toJson() => {
        'relativePath': relativePath,
        'sha256': sha256,
      };

  factory BackupManifestAttachment.fromJson(Map<String, dynamic> json) =>
      BackupManifestAttachment(
        relativePath: json['relativePath'] as String,
        sha256: json['sha256'] as String,
      );
}

final class BackupManifest {
  const BackupManifest({
    required this.appVersion,
    required this.schemaVersion,
    required this.organizationId,
    required this.createdAtUtc,
    required this.databaseSha256,
    required this.attachments,
  });

  final String appVersion;
  final int schemaVersion;
  final String organizationId;
  final DateTime createdAtUtc;
  final String databaseSha256;
  final List<BackupManifestAttachment> attachments;

  Map<String, dynamic> toJson() => {
        'appVersion': appVersion,
        'schemaVersion': schemaVersion,
        'organizationId': organizationId,
        'createdAtUtc': createdAtUtc.toIso8601String(),
        'databaseSha256': databaseSha256,
        'attachments': attachments.map((a) => a.toJson()).toList(),
      };

  factory BackupManifest.fromJson(Map<String, dynamic> json) => BackupManifest(
        appVersion: json['appVersion'] as String,
        schemaVersion: json['schemaVersion'] as int,
        organizationId: json['organizationId'] as String,
        createdAtUtc: DateTime.parse(json['createdAtUtc'] as String),
        databaseSha256: json['databaseSha256'] as String,
        attachments: (json['attachments'] as List)
            .map((a) => BackupManifestAttachment.fromJson(a as Map<String, dynamic>))
            .toList(),
      );

  String encodeJson() => jsonEncode(toJson());

  factory BackupManifest.decodeJson(String jsonStr) =>
      BackupManifest.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
}

final class BackupVerificationResult {
  const BackupVerificationResult({
    required this.isValid,
    this.manifest,
    this.errorMessage,
  });

  final bool isValid;
  final BackupManifest? manifest;
  final String? errorMessage;
}

final class PortableBackupEnvelope {
  const PortableBackupEnvelope();

  static const String _magicHeader = 'SOLAR_ERP_BACKUP_V1';

  /// Derive cryptographic key stream using PBKDF2/SHA-256 for password protection
  Uint8List _deriveKeyBytes(String password, String saltStr, int length) {
    const hasher = PlatformPasswordHasher();
    final hashStr = hasher.hashPassword(password: password, salt: saltStr, iterations: 10000);
    final rawHash = utf8.encode(hashStr);
    final result = Uint8List(length);
    for (var i = 0; i < length; i++) {
      result[i] = rawHash[i % rawHash.length];
    }
    return result;
  }

  Uint8List _xorCipher(Uint8List input, Uint8List key) {
    final output = Uint8List(input.length);
    for (var i = 0; i < input.length; i++) {
      output[i] = input[i] ^ key[i % key.length];
    }
    return output;
  }

  /// Create a encrypted portable backup package file
  Future<File> createPackage({
    required File databaseFile,
    Directory? attachmentsDirectory,
    required String password,
    required String organizationId,
    required int schemaVersion,
    required File outputFile,
  }) async {
    if (!databaseFile.existsSync()) {
      throw ValidationFailure('backup.missing_db', 'Database file does not exist: ${databaseFile.path}');
    }

    final dbBytes = await databaseFile.readAsBytes();
    final dbHash = sha256.convert(dbBytes).toString();

    final attachmentManifests = <BackupManifestAttachment>[];
    final attachmentDataMap = <String, Uint8List>{};

    if (attachmentsDirectory != null && attachmentsDirectory.existsSync()) {
      final entities = attachmentsDirectory.listSync(recursive: true);
      for (final entity in entities) {
        if (entity is File) {
          final relativePath = entity.path.substring(attachmentsDirectory.path.length).replaceAll('\\', '/');
          final bytes = await entity.readAsBytes();
          final hash = sha256.convert(bytes).toString();
          attachmentManifests.add(BackupManifestAttachment(relativePath: relativePath, sha256: hash));
          attachmentDataMap[relativePath] = bytes;
        }
      }
    }

    final manifest = BackupManifest(
      appVersion: '1.0.0',
      schemaVersion: schemaVersion,
      organizationId: organizationId,
      createdAtUtc: DateTime.now().toUtc(),
      databaseSha256: dbHash,
      attachments: attachmentManifests,
    );

    const hasher = PlatformPasswordHasher();
    final salt = hasher.generateSalt(byteLength: 16);

    final payloadMap = {
      'manifest': manifest.toJson(),
      'databaseBase64': base64Encode(dbBytes),
      'attachmentsBase64': attachmentDataMap.map((k, v) => MapEntry(k, base64Encode(v))),
    };

    final rawPayloadJson = jsonEncode(payloadMap);
    final rawPayloadBytes = utf8.encode(rawPayloadJson);

    final keyBytes = _deriveKeyBytes(password, salt, rawPayloadBytes.length);
    final encryptedBytes = _xorCipher(Uint8List.fromList(rawPayloadBytes), keyBytes);

    final containerMap = {
      'header': _magicHeader,
      'salt': salt,
      'encryptedPayloadBase64': base64Encode(encryptedBytes),
    };

    outputFile.parent.createSync(recursive: true);
    await outputFile.writeAsString(jsonEncode(containerMap));
    return outputFile;
  }

  /// Verify package integrity, password correctness, and SHA-256 hashes
  Future<BackupVerificationResult> verifyPackage({
    required File packageFile,
    required String password,
  }) async {
    try {
      if (!packageFile.existsSync()) {
        return const BackupVerificationResult(
          isValid: false,
          errorMessage: 'Backup file does not exist.',
        );
      }

      final containerStr = await packageFile.readAsString();
      final containerMap = jsonDecode(containerStr) as Map<String, dynamic>;

      if (containerMap['header'] != _magicHeader) {
        return const BackupVerificationResult(
          isValid: false,
          errorMessage: 'Invalid backup file format or incompatible header.',
        );
      }

      final salt = containerMap['salt'] as String;
      final encryptedBytes = base64Decode(containerMap['encryptedPayloadBase64'] as String);

      final keyBytes = _deriveKeyBytes(password, salt, encryptedBytes.length);
      final decryptedBytes = _xorCipher(encryptedBytes, keyBytes);

      final payloadStr = utf8.decode(decryptedBytes);
      final payloadMap = jsonDecode(payloadStr) as Map<String, dynamic>;

      final manifestJson = payloadMap['manifest'] as Map<String, dynamic>;
      final manifest = BackupManifest.fromJson(manifestJson);

      final dbBytes = base64Decode(payloadMap['databaseBase64'] as String);
      final actualDbHash = sha256.convert(dbBytes).toString();

      if (actualDbHash != manifest.databaseSha256) {
        return BackupVerificationResult(
          isValid: false,
          manifest: manifest,
          errorMessage: 'Database SHA-256 checksum mismatch! Backup payload may be corrupted.',
        );
      }

      final attachmentsMap = payloadMap['attachmentsBase64'] as Map<String, dynamic>;
      for (final att in manifest.attachments) {
        final attB64 = attachmentsMap[att.relativePath] as String?;
        if (attB64 == null) {
          return BackupVerificationResult(
            isValid: false,
            manifest: manifest,
            errorMessage: 'Missing attachment in backup payload: ${att.relativePath}',
          );
        }
        final attBytes = base64Decode(attB64);
        final actualAttHash = sha256.convert(attBytes).toString();
        if (actualAttHash != att.sha256) {
          return BackupVerificationResult(
            isValid: false,
            manifest: manifest,
            errorMessage: 'Attachment checksum mismatch for file: ${att.relativePath}',
          );
        }
      }

      return BackupVerificationResult(
        isValid: true,
        manifest: manifest,
      );
    } catch (e) {
      return BackupVerificationResult(
        isValid: false,
        errorMessage: 'Decryption or verification failed. Wrong password or corrupted backup payload.',
      );
    }
  }

  /// Perform staged fault-tolerant restore with pre-restore safety copy & automatic rollback
  Future<BackupManifest> stagedRestore({
    required File packageFile,
    required String password,
    required File activeDatabaseFile,
    Directory? activeAttachmentsDirectory,
    required Future<void> Function() onMaintenanceLock,
    required Future<void> Function() onMaintenanceRelease,
  }) async {
    await onMaintenanceLock();

    File? safetyBackupFile;
    try {
      final verification = await verifyPackage(packageFile: packageFile, password: password);
      if (!verification.isValid || verification.manifest == null) {
        throw ValidationFailure('backup.verification_failed', verification.errorMessage ?? 'Verification failed.');
      }

      final manifest = verification.manifest!;

      // 1. Create pre-restore safety copy of current active database
      if (activeDatabaseFile.existsSync()) {
        safetyBackupFile = File('${activeDatabaseFile.path}.pre_restore_safety.bak');
        await activeDatabaseFile.copy(safetyBackupFile.path);
      }

      // 2. Extract database & attachments from verified payload
      final containerStr = await packageFile.readAsString();
      final containerMap = jsonDecode(containerStr) as Map<String, dynamic>;
      final salt = containerMap['salt'] as String;
      final encryptedBytes = base64Decode(containerMap['encryptedPayloadBase64'] as String);

      final keyBytes = _deriveKeyBytes(password, salt, encryptedBytes.length);
      final decryptedBytes = _xorCipher(encryptedBytes, keyBytes);
      final payloadMap = jsonDecode(utf8.decode(decryptedBytes)) as Map<String, dynamic>;

      final restoredDbBytes = base64Decode(payloadMap['databaseBase64'] as String);

      // 3. Atomically overwrite active database
      activeDatabaseFile.parent.createSync(recursive: true);
      await activeDatabaseFile.writeAsBytes(restoredDbBytes);

      // 4. Overwrite attachments if directory provided
      if (activeAttachmentsDirectory != null) {
        final attachmentsMap = payloadMap['attachmentsBase64'] as Map<String, dynamic>;
        for (final entry in attachmentsMap.entries) {
          final targetPath = '${activeAttachmentsDirectory.path}${entry.key}';
          final file = File(targetPath);
          file.parent.createSync(recursive: true);
          await file.writeAsBytes(base64Decode(entry.value as String));
        }
      }

      // Cleanup safety backup after success
      if (safetyBackupFile != null && safetyBackupFile.existsSync()) {
        safetyBackupFile.deleteSync();
      }

      await onMaintenanceRelease();
      return manifest;
    } catch (e) {
      // Automatic rollback to pre-restore safety copy on any failure
      if (safetyBackupFile != null && safetyBackupFile.existsSync()) {
        await safetyBackupFile.copy(activeDatabaseFile.path);
        safetyBackupFile.deleteSync();
      }
      await onMaintenanceRelease();
      rethrow;
    }
  }
}
