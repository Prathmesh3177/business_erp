import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

final class _MemoryAccountingStore implements AccountingStore {
  final Map<String, Account> _accounts = {};
  final Map<String, JournalEntry> _journals = {};
  final Map<String, CommandResultRecord> _commandResults = {};

  @override
  Future<void> saveAccount(Account account) async {
    _accounts[account.code] = account;
  }

  @override
  Future<List<Account>> getAccounts(String organizationId) async => _accounts.values.toList();

  @override
  Future<Account?> getAccountByCode(String organizationId, String code) async => _accounts[code];

  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {
    _journals[entry.id] = entry;
  }

  @override
  Future<List<JournalEntry>> getJournalEntries(String organizationId, {String? partyId, int limit = 100}) async {
    return _journals.values.toList();
  }

  @override
  Future<int> getPartyBalancePaise(String organizationId, String partyId) async {
    int balance = 0;
    for (final j in _journals.values) {
      for (final line in j.lines) {
        if (line.partyId == partyId) {
          balance += (line.debitPaise - line.creditPaise);
        }
      }
    }
    return balance;
  }

  @override
  Future<void> saveDocumentHeader(DocumentHeader header) async {}

  @override
  Future<DocumentHeader?> getDocumentHeaderById(String id) async => null;

  @override
  Future<String> allocateNextDocumentNumber({
    required String registrationId,
    required String fiscalYear,
    required String series,
  }) async {
    return '$series/2627/000001';
  }

  @override
  Future<void> saveCommandResult(CommandResultRecord result) async {
    _commandResults[result.commandId] = result;
  }

  @override
  Future<CommandResultRecord?> getCommandResult(String commandId) async {
    return _commandResults[commandId];
  }
}

void main() {
  late _MemoryAccountingStore store;
  late PostOpeningBalancesUseCase postOpeningUseCase;
  final now = DateTime.now();

  setUp(() {
    store = _MemoryAccountingStore();
    postOpeningUseCase = PostOpeningBalancesUseCase(store);
  });

  test('PostOpeningBalancesUseCase posts balanced journal against Opening Balance Equity', () async {
    final adminSession = UserSession(
      id: const SessionId('sess_admin'),
      userId: const UserId('user_admin'),
      username: 'admin',
      roleId: Role.adminRoleId,
      branchId: const BranchId('branch_1'),
      capabilities: {Capability.inventoryManage},
      token: 'tok_admin',
      expiresAtUtc: now.add(const Duration(hours: 8)),
      lastActivityAtUtc: now,
    );
    final context = CommandContext(session: adminSession, timestampUtc: now);

    final journal = await postOpeningUseCase.execute(
      context,
      organizationId: 'org_1',
      branchId: 'branch_1',
      openingInventoryValue: Money.fromRupees(150000.00), // ₹1,50,000 Inventory
      customerDues: [
        PartyOpeningDue(partyId: 'cust_1', amount: Money.fromRupees(25000.00)), // ₹25,000 Receivable
      ],
      supplierDues: [
        PartyOpeningDue(partyId: 'supp_1', amount: Money.fromRupees(40000.00)), // ₹40,000 Payable
      ],
      commandId: 'cmd_opening_1',
    );

    expect(journal.lines.length, equals(4));

    // Calculate total debits and credits
    final totalDebits = journal.lines.fold<int>(0, (sum, l) => sum + l.debitPaise);
    final totalCredits = journal.lines.fold<int>(0, (sum, l) => sum + l.creditPaise);

    expect(totalDebits, equals(totalCredits));
    expect(totalDebits, equals(17500000)); // ₹1,75,000 Total Debits

    // Verify party balance calculation
    final custBalance = await store.getPartyBalancePaise('org_1', 'cust_1');
    expect(custBalance, equals(2500000)); // ₹25,000

    final suppBalance = await store.getPartyBalancePaise('org_1', 'supp_1');
    expect(suppBalance, equals(-4000000)); // -₹40,000 (Payable)
  });
}
