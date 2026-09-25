import 'package:erp_domain/erp_domain.dart';

abstract interface class AccountingStore {
  Future<void> saveAccount(Account account);
  Future<List<Account>> getAccounts(String organizationId);
  Future<Account?> getAccountByCode(String organizationId, String code);

  Future<void> saveJournalEntry(JournalEntry entry);
  Future<List<JournalEntry>> getJournalEntries(String organizationId, {String? partyId, int limit = 100});

  Future<int> getPartyBalancePaise(String organizationId, String partyId);

  Future<void> saveDocumentHeader(DocumentHeader header);
  Future<DocumentHeader?> getDocumentHeaderById(String id);

  Future<String> allocateNextDocumentNumber({
    required String registrationId,
    required String fiscalYear,
    required String series,
  });

  Future<void> saveCommandResult(CommandResultRecord result);
  Future<CommandResultRecord?> getCommandResult(String commandId);
}
