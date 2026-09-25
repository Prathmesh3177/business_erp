import 'dart:io';

import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

final class _MockAccountingStore implements AccountingStore {
  @override
  Future<void> saveAccount(Account account) async {}

  @override
  Future<Account?> getAccountByCode(String organizationId, String code) async => null;

  @override
  Future<List<Account>> getAccounts(String organizationId) async {
    return [
      Account(
        id: 'acc_1',
        organizationId: organizationId,
        code: '1000',
        name: 'Cash',
        type: AccountType.asset,
        active: true,
      ),
    ];
  }

  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {}

  @override
  Future<List<JournalEntry>> getJournalEntries(
    String organizationId, {
    String? partyId,
    int limit = 100,
  }) async =>
      [];

  @override
  Future<int> getPartyBalancePaise(String organizationId, String partyId) async => 0;

  @override
  Future<void> saveDocumentHeader(DocumentHeader header) async {}

  @override
  Future<DocumentHeader?> getDocumentHeaderById(String id) async => null;

  @override
  Future<String> allocateNextDocumentNumber({
    required String registrationId,
    required String fiscalYear,
    required String series,
  }) async =>
      'SKS/2627/000001';

  @override
  Future<CommandResultRecord?> getCommandResult(String commandId) async => null;

  @override
  Future<void> saveCommandResult(CommandResultRecord result) async {}
}

void main() {
  final now = DateTime.utc(2026, 9, 25, 12, 0, 0);

  group('P11 Backup Application Use Cases Tests', () {
    test('CheckOverdueBackupUseCase flags missing backup as overdue', () {
      const useCase = CheckOverdueBackupUseCase();
      final status = useCase.execute(lastBackupAtUtc: null, nowUtc: now);

      expect(status.isOverdue, isTrue);
      expect(status.lastBackupAtUtc, isNull);
    });

    test('CheckOverdueBackupUseCase flags backup older than 24 hours as overdue', () {
      const useCase = CheckOverdueBackupUseCase();
      final oldBackup = now.subtract(const Duration(hours: 25));
      final status = useCase.execute(lastBackupAtUtc: oldBackup, nowUtc: now);

      expect(status.isOverdue, isTrue);

      final recentBackup = now.subtract(const Duration(hours: 4));
      final recentStatus = useCase.execute(lastBackupAtUtc: recentBackup, nowUtc: now);

      expect(recentStatus.isOverdue, isFalse);
    });

    test('CheckDiskSpaceUseCase returns true for accessible directory', () async {
      const useCase = CheckDiskSpaceUseCase();
      final tempDir = Directory.systemTemp;
      final hasSpace = await useCase.execute(targetDirectory: tempDir);

      expect(hasSpace, isTrue);
    });

    test('ReconcileDocumentSequencesUseCase validates next sequence numbers', () async {
      final store = _MockAccountingStore();
      final useCase = ReconcileDocumentSequencesUseCase(store);

      await expectLater(
        useCase.execute(organizationId: 'org_1', branchId: 'branch_1'),
        completes,
      );
    });
  });
}
