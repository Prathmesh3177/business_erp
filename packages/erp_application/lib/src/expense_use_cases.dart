import 'package:erp_domain/erp_domain.dart';
import 'accounting_store.dart';
import 'command_context.dart';
import 'finance_store.dart';

final class PostExpenseUseCase {
  const PostExpenseUseCase({
    required this.financeStore,
    required this.accountingStore,
  });

  final FinanceStore financeStore;
  final AccountingStore accountingStore;

  Future<ExpenseEntry> execute(
    CommandContext context, {
    required String organizationId,
    required String branchId,
    required String categoryId,
    required String categoryName,
    required String accountCode,
    required Money amountPaise,
    required DateTime expenseDate,
    required String paymentMethod,
    String? referenceNumber,
    String? notes,
  }) async {
    if (!context.session.hasCapability(Capability.expensesManage)) {
      throw const AuthorizationFailure('unauthorized', 'User lacks expensesManage capability');
    }

    if (amountPaise.paise <= 0) {
      throw const ValidationFailure('invalid_expense_amount', 'Expense amount must be positive');
    }

    final now = DateTime.now();
    final entry = ExpenseEntry(
      id: 'exp_${now.microsecondsSinceEpoch}',
      organizationId: organizationId,
      branchId: branchId,
      categoryId: categoryId,
      categoryName: categoryName,
      accountCode: accountCode,
      amountPaise: amountPaise,
      expenseDate: expenseDate,
      paymentMethod: paymentMethod,
      createdAtUtc: now,
      referenceNumber: referenceNumber,
      notes: notes,
    );

    await financeStore.saveExpenseEntry(entry);

    // Balanced Expense Journal: Debit Expense Account, Credit Cash/Bank (1100)
    final jeId = 'je_exp_${now.microsecondsSinceEpoch}';
    final journal = JournalEntry(
      id: jeId,
      organizationId: organizationId,
      branchId: branchId,
      documentId: entry.id,
      postingDate: expenseDate,
      memo: 'Expense Voucher: $categoryName',
      lines: [
        JournalLine(id: '${jeId}_1', journalEntryId: jeId, accountId: 'acc_$accountCode', debitPaise: amountPaise.paise, creditPaise: 0),
        JournalLine(id: '${jeId}_2', journalEntryId: jeId, accountId: 'acc_1100', debitPaise: 0, creditPaise: amountPaise.paise),
      ],
      createdAt: now,
    );

    await accountingStore.saveJournalEntry(journal);

    return entry;
  }
}

final class CashSessionUseCases {
  const CashSessionUseCases({
    required this.financeStore,
    required this.accountingStore,
  });

  final FinanceStore financeStore;
  final AccountingStore accountingStore;

  Future<CashSession> startSession(
    CommandContext context, {
    required String organizationId,
    required String branchId,
    required Money openingCashPaise,
    String? notes,
  }) async {
    if (!context.session.hasCapability(Capability.cashSessionManage)) {
      throw const AuthorizationFailure('unauthorized', 'User lacks cashSessionManage capability');
    }

    final active = await financeStore.getActiveCashSession(organizationId, context.session.userId.value);
    if (active != null) {
      throw const ValidationFailure('active_session_exists', 'An active cash session is already open');
    }

    final now = DateTime.now();
    final session = CashSession(
      id: 'csess_${now.microsecondsSinceEpoch}',
      organizationId: organizationId,
      branchId: branchId,
      userId: context.session.userId.value,
      username: context.session.username,
      openedAtUtc: now,
      openingCashPaise: openingCashPaise,
      expectedCashPaise: openingCashPaise,
      countedCashPaise: openingCashPaise,
      variancePaise: Money.zero,
      status: CashSessionStatus.open,
      notes: notes,
    );

    await financeStore.saveCashSession(session);
    return session;
  }

  Future<CashSession> closeSession(
    CommandContext context, {
    required String sessionId,
    required Money expectedCashPaise,
    required Money countedCashPaise,
    String? notes,
  }) async {
    if (!context.session.hasCapability(Capability.cashSessionManage)) {
      throw const AuthorizationFailure('unauthorized', 'User lacks cashSessionManage capability');
    }

    final now = DateTime.now();
    final variancePaise = countedCashPaise.paise - expectedCashPaise.paise;

    final session = CashSession(
      id: sessionId,
      organizationId: context.session.branchId.value,
      branchId: context.session.branchId.value,
      userId: context.session.userId.value,
      username: context.session.username,
      openedAtUtc: now.subtract(const Duration(hours: 8)),
      closedAtUtc: now,
      openingCashPaise: Money.zero,
      expectedCashPaise: expectedCashPaise,
      countedCashPaise: countedCashPaise,
      variancePaise: Money.fromPaise(variancePaise),
      status: CashSessionStatus.closed,
      notes: notes,
    );

    await financeStore.saveCashSession(session);

    // If there is cash shortage/overage, post adjusting journal entry
    if (variancePaise != 0) {
      final isShortage = variancePaise < 0;
      final absVariance = variancePaise.abs();

      final jeId = 'je_cvar_${now.microsecondsSinceEpoch}';
      final journal = JournalEntry(
        id: jeId,
        organizationId: context.session.branchId.value,
        branchId: context.session.branchId.value,
        documentId: sessionId,
        postingDate: now,
        memo: isShortage ? 'Cash Register Shortage Variance' : 'Cash Register Overage Variance',
        lines: isShortage
            ? [
                JournalLine(id: '${jeId}_1', journalEntryId: jeId, accountId: 'acc_6900', debitPaise: absVariance, creditPaise: 0),
                JournalLine(id: '${jeId}_2', journalEntryId: jeId, accountId: 'acc_1100', debitPaise: 0, creditPaise: absVariance),
              ]
            : [
                JournalLine(id: '${jeId}_1', journalEntryId: jeId, accountId: 'acc_1100', debitPaise: absVariance, creditPaise: 0),
                JournalLine(id: '${jeId}_2', journalEntryId: jeId, accountId: 'acc_4900', debitPaise: 0, creditPaise: absVariance),
              ],
        createdAt: now,
      );

      await accountingStore.saveJournalEntry(journal);
    }

    return session;
  }
}
