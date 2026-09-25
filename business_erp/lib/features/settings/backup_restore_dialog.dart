import 'dart:io';

import 'package:erp_platform/erp_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/bootstrap.dart';

final class BackupRestoreDialog extends ConsumerStatefulWidget {
  const BackupRestoreDialog({super.key});

  @override
  ConsumerState<BackupRestoreDialog> createState() => _BackupRestoreDialogState();
}

final class _BackupRestoreDialogState extends ConsumerState<BackupRestoreDialog> {
  final _passwordController = TextEditingController();
  bool _busy = false;
  String? _statusMessage;
  bool _isError = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createBackup() async {
    final password = _passwordController.text.trim();
    if (password.length < 6) {
      setState(() {
        _isError = true;
        _statusMessage = 'Password must be at least 6 characters.';
      });
      return;
    }

    setState(() {
      _busy = true;
      _statusMessage = 'Creating encrypted backup package...';
      _isError = false;
    });

    try {
      final runtime = ref.read(runtimeProvider).value;
      if (runtime == null) throw StateError('Runtime not initialized');

      final dbFile = await runtime.locations.databaseFile();
      final dbDirectory = dbFile.parent;
      final attachmentsDir = await runtime.locations.snapshotDirectory();

      final backupDir = Directory('${dbDirectory.path}${Platform.pathSeparator}backups');
      await backupDir.create(recursive: true);
      final outputFile = File(
        '${backupDir.path}${Platform.pathSeparator}solar-erp-backup-'
        '${DateTime.now().toUtc().millisecondsSinceEpoch}.erpa',
      );

      const envelope = PortableBackupEnvelope();
      await envelope.createPackage(
        databaseFile: dbFile,
        attachmentsDirectory: attachmentsDir,
        password: password,
        organizationId: runtime.identity?.organization.id.value ?? 'org_1',
        schemaVersion: 8,
        outputFile: outputFile,
      );

      if (mounted) {
        setState(() {
          _busy = false;
          _isError = false;
          _statusMessage = 'Encrypted backup package created successfully!\nSaved to: ${outputFile.path}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _isError = true;
          _statusMessage = 'Backup failed: $e';
        });
      }
    }
  }

  Future<void> _verifyAndRestore() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() {
        _isError = true;
        _statusMessage = 'Enter backup password to restore.';
      });
      return;
    }

    setState(() {
      _busy = true;
      _statusMessage = 'Verifying backup package integrity...';
      _isError = false;
    });

    try {
      final runtime = ref.read(runtimeProvider).value;
      if (runtime == null) throw StateError('Runtime not initialized');

      final activeDbFile = await runtime.locations.databaseFile();
      final dbDirectory = activeDbFile.parent;
      final backupDir = Directory('${dbDirectory.path}${Platform.pathSeparator}backups');
      if (!backupDir.existsSync() || backupDir.listSync().isEmpty) {
        throw StateError('No backup package files found in backup directory.');
      }

      final backupFiles = backupDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.erpa'))
          .toList();

      if (backupFiles.isEmpty) {
        throw StateError('No .erpa backup files found.');
      }

      // Sort by newest
      backupFiles.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      final targetPackage = backupFiles.first;

      final activeAttachmentsDir = await runtime.locations.snapshotDirectory();

      const envelope = PortableBackupEnvelope();
      final manifest = await envelope.stagedRestore(
        packageFile: targetPackage,
        password: password,
        activeDatabaseFile: activeDbFile,
        activeAttachmentsDirectory: activeAttachmentsDir,
        onMaintenanceLock: () async {
          setState(() => _statusMessage = 'Maintenance mode active. Creating safety pre-restore backup...');
        },
        onMaintenanceRelease: () async {
          setState(() => _statusMessage = 'Post-restore reconciliation complete. Releasing maintenance mode...');
        },
      );

      if (mounted) {
        setState(() {
          _busy = false;
          _isError = false;
          _statusMessage = 'Staged restore complete!\nRestored Organization: ${manifest.organizationId}\n'
              'Restored Schema Version: ${manifest.schemaVersion}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _isError = true;
          _statusMessage = 'Restore failed & safety copy restored: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.shield, color: Color(0xFF990000)),
          SizedBox(width: 8),
          Text('Encrypted Backup & Recovery (ADR-013)'),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Portable recovery envelope stores encrypted database, attachments, and SHA-256 manifest hashes.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Backup / Restore Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isError ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _isError ? Colors.red : Colors.green),
                ),
                child: Text(
                  _statusMessage!,
                  style: TextStyle(
                    fontSize: 12,
                    color: _isError ? Colors.red.shade900 : Colors.green.shade900,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.upload_file),
          label: const Text('Restore Backup'),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF004D40), foregroundColor: Colors.white),
          onPressed: _busy ? null : _verifyAndRestore,
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.archive),
          label: const Text('Create Backup'),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF990000), foregroundColor: Colors.white),
          onPressed: _busy ? null : _createBackup,
        ),
      ],
    );
  }
}
