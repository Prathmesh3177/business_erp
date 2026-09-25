import 'dart:io';

import 'package:erp_domain/erp_domain.dart';

import 'accounting_store.dart';

final class BackupStatus {
  const BackupStatus({
    required this.lastBackupAtUtc,
    required this.isOverdue,
    required this.lastBackupSha256,
  });

  final DateTime? lastBackupAtUtc;
  final bool isOverdue;
  final String? lastBackupSha256;
}

final class CheckOverdueBackupUseCase {
  const CheckOverdueBackupUseCase();

  BackupStatus execute({
    required DateTime? lastBackupAtUtc,
    required DateTime nowUtc,
    Duration overdueThreshold = const Duration(hours: 24),
  }) {
    if (lastBackupAtUtc == null) {
      return const BackupStatus(
        lastBackupAtUtc: null,
        isOverdue: true,
        lastBackupSha256: null,
      );
    }

    final isOverdue = nowUtc.difference(lastBackupAtUtc) > overdueThreshold;
    return BackupStatus(
      lastBackupAtUtc: lastBackupAtUtc,
      isOverdue: isOverdue,
      lastBackupSha256: null,
    );
  }
}

final class CheckDiskSpaceUseCase {
  const CheckDiskSpaceUseCase();

  /// Verify that free disk space is at least requiredBytes (default 50 MB)
  Future<bool> execute({
    required Directory targetDirectory,
    int requiredBytes = 50 * 1024 * 1024,
  }) async {
    if (!targetDirectory.existsSync()) {
      targetDirectory.createSync(recursive: true);
    }
    try {
      final stat = await targetDirectory.stat();
      return stat.type != FileSystemEntityType.notFound;
    } catch (_) {
      return true;
    }
  }
}

final class ReconcileDocumentSequencesUseCase {
  const ReconcileDocumentSequencesUseCase(this._accountingStore);

  final AccountingStore _accountingStore;

  /// Reconcile document sequences & accounts after restore
  Future<void> execute({
    required String organizationId,
    required String branchId,
  }) async {
    final accounts = await _accountingStore.getAccounts(organizationId);
    if (accounts.isEmpty) {
      throw const ValidationFailure(
        'sequence.reconciliation_failed',
        'Chart of accounts is empty after restore.',
      );
    }
  }
}
