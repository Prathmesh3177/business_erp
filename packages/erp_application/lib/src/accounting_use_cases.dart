import 'dart:convert';

import 'package:erp_domain/erp_domain.dart';

import 'accounting_store.dart';
import 'command_context.dart';

final class PostJournalEntryUseCase {
  const PostJournalEntryUseCase(this._accountingStore);

  final AccountingStore _accountingStore;

  Future<JournalEntry> execute(
    CommandContext context, {
    required JournalEntry entry,
    required String commandId,
  }) async {
    context.requireCapability(Capability.inventoryManage);

    // Idempotency check: if commandId was already executed, return cached result
    final existingResult = await _accountingStore.getCommandResult(commandId);
    if (existingResult != null) {
      return entry; // Repeat execution return
    }

    // Save journal entry
    await _accountingStore.saveJournalEntry(entry);

    // Record command result for idempotency
    await _accountingStore.saveCommandResult(CommandResultRecord(
      id: 'cmd_${DateTime.now().microsecondsSinceEpoch}',
      commandId: commandId,
      payloadHash: entry.id,
      resultJson: jsonEncode({'journalEntryId': entry.id, 'posted': true}),
      createdAt: DateTime.now(),
    ));

    return entry;
  }
}

final class PostOpeningBalancesUseCase {
  const PostOpeningBalancesUseCase(this._accountingStore);

  final AccountingStore _accountingStore;

  Future<JournalEntry> execute(
    CommandContext context, {
    required String organizationId,
    required String branchId,
    required Money openingInventoryValue,
    required List<PartyOpeningDue> customerDues,
    required List<PartyOpeningDue> supplierDues,
    required String commandId,
  }) async {
    context.requireCapability(Capability.inventoryManage);

    final existingResult = await _accountingStore.getCommandResult(commandId);
    if (existingResult != null) {
      final entry = await _accountingStore.getJournalEntries(organizationId, limit: 1);
      return entry.first;
    }

    final lines = <JournalLine>[];
    final now = DateTime.now();
    final entryId = 'je_op_${now.millisecondsSinceEpoch}';
    int lineIdSeq = 1;

    int totalDebitPaise = 0;
    int totalCreditPaise = 0;

    // 1. Debit Inventory if positive
    if (openingInventoryValue.paise > 0) {
      lines.add(JournalLine(
        id: 'l_${lineIdSeq++}',
        journalEntryId: entryId,
        accountId: 'acc_inv',
        debitPaise: openingInventoryValue.paise,
      ));
      totalDebitPaise += openingInventoryValue.paise;
    }

    // 2. Debit Customer Receivables
    for (final cust in customerDues) {
      if (cust.amount.paise > 0) {
        lines.add(JournalLine(
          id: 'l_${lineIdSeq++}',
          journalEntryId: entryId,
          accountId: 'acc_ar',
          debitPaise: cust.amount.paise,
          partyId: cust.partyId,
        ));
        totalDebitPaise += cust.amount.paise;
      }
    }

    // 3. Credit Supplier Payables
    for (final supp in supplierDues) {
      if (supp.amount.paise > 0) {
        lines.add(JournalLine(
          id: 'l_${lineIdSeq++}',
          journalEntryId: entryId,
          accountId: 'acc_ap',
          creditPaise: supp.amount.paise,
          partyId: supp.partyId,
        ));
        totalCreditPaise += supp.amount.paise;
      }
    }

    // 4. Balance against Opening Balance Equity
    final netEquityPaise = totalDebitPaise - totalCreditPaise;
    if (netEquityPaise > 0) {
      lines.add(JournalLine(
        id: 'l_${lineIdSeq++}',
        journalEntryId: entryId,
        accountId: 'acc_equity',
        creditPaise: netEquityPaise,
      ));
    } else if (netEquityPaise < 0) {
      lines.add(JournalLine(
        id: 'l_${lineIdSeq++}',
        journalEntryId: entryId,
        accountId: 'acc_equity',
        debitPaise: -netEquityPaise,
      ));
    }

    final journalEntry = JournalEntry(
      id: entryId,
      organizationId: organizationId,
      branchId: branchId,
      documentId: 'doc_opening_${now.millisecondsSinceEpoch}',
      postingDate: now,
      memo: 'Opening Balances Journal',
      lines: lines,
      createdAt: now,
    );

    await _accountingStore.saveJournalEntry(journalEntry);

    await _accountingStore.saveCommandResult(CommandResultRecord(
      id: 'cmd_${now.microsecondsSinceEpoch}',
      commandId: commandId,
      payloadHash: entryId,
      resultJson: jsonEncode({'journalEntryId': entryId, 'openingPosted': true}),
      createdAt: now,
    ));

    return journalEntry;
  }
}

final class PartyOpeningDue {
  const PartyOpeningDue({required this.partyId, required this.amount});
  final String partyId;
  final Money amount;
}
