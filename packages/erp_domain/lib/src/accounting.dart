import 'errors.dart';

enum AccountType { asset, liability, equity, revenue, expense }

enum AccountControlRole {
  none,
  customerControl,
  supplierControl,
  cashControl,
  bankControl,
  salesControl,
  cogsControl,
  taxControl,
  roundOffControl,
}

final class Account {
  const Account({
    required this.id,
    required this.organizationId,
    required this.code,
    required this.name,
    required this.type,
    this.controlRole = AccountControlRole.none,
    this.active = true,
  });

  final String id;
  final String organizationId;
  final String code;
  final String name;
  final AccountType type;
  final AccountControlRole controlRole;
  final bool active;

  static const String codeCash = '1010';
  static const String codeBank = '1020';
  static const String codeReceivable = '1100';
  static const String codeInventory = '1200';
  static const String codeCgstInput = '1310';
  static const String codeSgstInput = '1320';
  static const String codeIgstInput = '1330';
  static const String codeWip = '1400';

  static const String codePayable = '2100';

  static const String codeCgstOutput = '2210';
  static const String codeSgstOutput = '2220';
  static const String codeIgstOutput = '2230';

  static const String codeOpeningEquity = '3010';

  static const String codeSalesRevenue = '4010';

  static const String codeCogs = '5010';
  static const String codeRoundOffExpense = '5090';

  static List<Account> defaultAccounts(String organizationId) {
    return [
      Account(id: 'acc_cash', organizationId: organizationId, code: codeCash, name: 'Cash in Hand', type: AccountType.asset, controlRole: AccountControlRole.cashControl),
      Account(id: 'acc_bank', organizationId: organizationId, code: codeBank, name: 'Bank Account / UPI Clearing', type: AccountType.asset, controlRole: AccountControlRole.bankControl),
      Account(id: 'acc_ar', organizationId: organizationId, code: codeReceivable, name: 'Accounts Receivable (Customers)', type: AccountType.asset, controlRole: AccountControlRole.customerControl),
      Account(id: 'acc_inv', organizationId: organizationId, code: codeInventory, name: 'Merchandise Inventory', type: AccountType.asset),
      Account(id: 'acc_wip', organizationId: organizationId, code: codeWip, name: 'Work in Progress (Solar Projects)', type: AccountType.asset),
      Account(id: 'acc_cgst_in', organizationId: organizationId, code: codeCgstInput, name: 'CGST Input Tax Credit', type: AccountType.asset, controlRole: AccountControlRole.taxControl),

      Account(id: 'acc_sgst_in', organizationId: organizationId, code: codeSgstInput, name: 'SGST Input Tax Credit', type: AccountType.asset, controlRole: AccountControlRole.taxControl),
      Account(id: 'acc_igst_in', organizationId: organizationId, code: codeIgstInput, name: 'IGST Input Tax Credit', type: AccountType.asset, controlRole: AccountControlRole.taxControl),

      Account(id: 'acc_ap', organizationId: organizationId, code: codePayable, name: 'Accounts Payable (Suppliers)', type: AccountType.liability, controlRole: AccountControlRole.supplierControl),
      Account(id: 'acc_cgst_out', organizationId: organizationId, code: codeCgstOutput, name: 'CGST Output Payable', type: AccountType.liability, controlRole: AccountControlRole.taxControl),
      Account(id: 'acc_sgst_out', organizationId: organizationId, code: codeSgstOutput, name: 'SGST Output Payable', type: AccountType.liability, controlRole: AccountControlRole.taxControl),
      Account(id: 'acc_igst_out', organizationId: organizationId, code: codeIgstOutput, name: 'IGST Output Payable', type: AccountType.liability, controlRole: AccountControlRole.taxControl),

      Account(id: 'acc_equity', organizationId: organizationId, code: codeOpeningEquity, name: 'Opening Balance Equity', type: AccountType.equity),

      Account(id: 'acc_sales', organizationId: organizationId, code: codeSalesRevenue, name: 'Sales Revenue', type: AccountType.revenue, controlRole: AccountControlRole.salesControl),

      Account(id: 'acc_cogs', organizationId: organizationId, code: codeCogs, name: 'Cost of Goods Sold', type: AccountType.expense, controlRole: AccountControlRole.cogsControl),
      Account(id: 'acc_roundoff', organizationId: organizationId, code: codeRoundOffExpense, name: 'Invoice Round-off Expense', type: AccountType.expense, controlRole: AccountControlRole.roundOffControl),
    ];
  }
}

final class JournalLine {
  JournalLine({
    required this.id,
    required this.journalEntryId,
    required this.accountId,
    this.debitPaise = 0,
    this.creditPaise = 0,
    this.partyId,
    this.projectId,
  }) {
    if (debitPaise < 0 || creditPaise < 0) {
      throw const ValidationFailure('invalid_journal_line', 'Journal line debits and credits cannot be negative');
    }
    if (debitPaise == 0 && creditPaise == 0) {
      throw const ValidationFailure('zero_journal_line', 'Journal line must have non-zero debit or credit');
    }
    if (debitPaise > 0 && creditPaise > 0) {
      throw const ValidationFailure('dual_journal_line', 'Journal line cannot have both debit and credit');
    }
  }

  final String id;
  final String journalEntryId;
  final String accountId;
  final int debitPaise;
  final int creditPaise;
  final String? partyId;
  final String? projectId;
}

final class JournalEntry {
  JournalEntry({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.documentId,
    required this.postingDate,
    this.reversalOfId,
    required this.memo,
    required this.lines,
    required this.createdAt,
  }) {
    if (lines.length < 2) {
      throw const ValidationFailure('insufficient_lines', 'Journal entry must contain at least 2 lines');
    }

    int totalDebit = 0;
    int totalCredit = 0;

    for (final line in lines) {
      totalDebit += line.debitPaise;
      totalCredit += line.creditPaise;
    }

    if (totalDebit <= 0) {
      throw const ValidationFailure('zero_total_journal', 'Journal entry total debits must be greater than zero');
    }

    if (totalDebit != totalCredit) {
      throw ValidationFailure(
        'unbalanced_journal',
        'Journal entry is unbalanced. Total Debits (₹${totalDebit / 100}) != Total Credits (₹${totalCredit / 100})',
      );
    }
  }

  final String id;
  final String organizationId;
  final String branchId;
  final String documentId;
  final DateTime postingDate;
  final String? reversalOfId;
  final String memo;
  final List<JournalLine> lines;
  final DateTime createdAt;
}
