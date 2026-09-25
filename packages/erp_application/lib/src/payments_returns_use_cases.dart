import 'package:erp_domain/erp_domain.dart';
import 'accounting_store.dart';
import 'command_context.dart';
import 'finance_store.dart';
import 'inventory_store.dart';
import 'party_store.dart';
import 'purchasing_store.dart';
import 'sales_store.dart';

final class SalesReturnLineInput {
  const SalesReturnLineInput({
    required this.saleLineId,
    required this.quantity,
    this.disposition = ReturnDisposition.returnToStock,
    this.serials = const [],
  });

  final String saleLineId;
  final Quantity quantity;
  final ReturnDisposition disposition;
  final List<String> serials;
}

final class PostSalesReturnUseCase {
  const PostSalesReturnUseCase({
    required this.salesStore,
    required this.financeStore,
    required this.inventoryStore,
    required this.accountingStore,
    required this.partyStore,
  });

  final SalesStore salesStore;
  final FinanceStore financeStore;
  final InventoryStore inventoryStore;
  final AccountingStore accountingStore;
  final PartyStore partyStore;

  Future<SalesReturnHeader> execute(
    CommandContext context, {
    required String organizationId,
    required String branchId,
    required String originalSaleId,
    required DateTime returnDate,
    required String locationId,
    required List<SalesReturnLineInput> lineInputs,
    String? reason,
    String? notes,
  }) async {
    if (!context.session.hasCapability(Capability.financeManage)) {
      throw const AuthorizationFailure('unauthorized', 'User lacks financeManage capability');
    }

    final originalHeader = await salesStore.getSaleHeader(originalSaleId);
    if (originalHeader == null) {
      throw const ValidationFailure('sale_not_found', 'Original sales invoice not found');
    }

    final originalLines = await salesStore.getSaleLines(originalSaleId);
    final originalLineMap = {for (final l in originalLines) l.id: l};

    final previousReturns = await financeStore.listSalesReturns(organizationId);
    final previousReturnHeaders = previousReturns.where((r) => r.originalSaleId == originalSaleId).toList();
    
    final Map<String, int> cumulativeReturnedMicroUnits = {};
    for (final ret in previousReturnHeaders) {
      final retLines = await financeStore.getSalesReturnLines(ret.id);
      for (final l in retLines) {
        cumulativeReturnedMicroUnits[l.saleLineId] =
            (cumulativeReturnedMicroUnits[l.saleLineId] ?? 0) + l.quantity.microUnits;
      }
    }

    final now = DateTime.now();
    final returnId = 'sret_${now.microsecondsSinceEpoch}';
    final returnLines = <SalesReturnLine>[];

    var totalSubtotalPaise = 0;
    var totalTaxPaise = 0;
    var totalGrandPaise = 0;

    for (final input in lineInputs) {
      final origLine = originalLineMap[input.saleLineId];
      if (origLine == null) {
        throw ValidationFailure('invalid_line', 'Sale line ${input.saleLineId} not found in invoice');
      }

      final prevQtyMicro = cumulativeReturnedMicroUnits[input.saleLineId] ?? 0;
      if (prevQtyMicro + input.quantity.microUnits > origLine.quantity.microUnits) {
        throw ValidationFailure(
          'cumulative_quantity_exceeded',
          'Returned quantity exceeds remaining sellable quantity for ${origLine.productName}',
        );
      }

      final returnRatio = input.quantity.microUnits / origLine.quantity.microUnits;
      final lineSubtotal = (origLine.taxableAmountPaise.paise * returnRatio).round();
      final lineTax = (origLine.taxSnapshot.totalTax.paise * returnRatio).round();
      final lineGrand = lineSubtotal + lineTax;

      totalSubtotalPaise += lineSubtotal;
      totalTaxPaise += lineTax;
      totalGrandPaise += lineGrand;

      final retLine = SalesReturnLine(
        id: 'sret_line_${now.microsecondsSinceEpoch}_${returnLines.length}',
        salesReturnId: returnId,
        saleLineId: origLine.id,
        productId: origLine.productId,
        productName: origLine.productName,
        sku: origLine.sku,
        quantity: input.quantity,
        unitPrice: origLine.unitPrice,
        lineDiscountPaise: Money.fromPaise((origLine.lineDiscountPaise.paise * returnRatio).round()),
        taxSnapshot: TaxLineResult(
          lineId: origLine.id,
          taxableAmount: Money.fromPaise(lineSubtotal),
          cgst: Money.fromPaise((origLine.taxSnapshot.cgst.paise * returnRatio).round()),
          sgst: Money.fromPaise((origLine.taxSnapshot.sgst.paise * returnRatio).round()),
          igst: Money.fromPaise((origLine.taxSnapshot.igst.paise * returnRatio).round()),
          totalTax: Money.fromPaise(lineTax),
          totalAmount: Money.fromPaise(lineGrand),
        ),
        costSnapshotMicroRupees: origLine.costSnapshotMicroRupees,
        netTotalPaise: Money.fromPaise(lineGrand),
        serials: input.serials,
        disposition: input.disposition,
      );

      returnLines.add(retLine);
    }

    final currentYearStr = '${returnDate.year}';
    final docNumber = await accountingStore.allocateNextDocumentNumber(
      registrationId: branchId,
      fiscalYear: currentYearStr,
      series: 'CRN',
    );

    final docHeaderId = 'doc_crn_${now.microsecondsSinceEpoch}';
    final docHeader = DocumentHeader(
      id: docHeaderId,
      organizationId: organizationId,
      branchId: branchId,
      kind: DocumentKind.salesReturn, // Credit Note
      status: DocumentStatus.posted,
      businessDate: returnDate,
      documentNumber: docNumber,
      fiscalYear: currentYearStr,
      sourceCommandId: context.session.id.value,
      createdAt: now,
    );

    final returnHeader = SalesReturnHeader(
      id: returnId,
      organizationId: organizationId,
      branchId: branchId,
      documentHeaderId: docHeaderId,
      originalSaleId: originalSaleId,
      customerPartyId: originalHeader.customerPartyId,
      customerName: originalHeader.customerName,
      returnDate: returnDate,
      locationId: locationId,
      status: SalesReturnStatus.posted,
      subtotalPaise: Money.fromPaise(totalSubtotalPaise),
      totalTaxPaise: Money.fromPaise(totalTaxPaise),
      grandTotalPaise: Money.fromPaise(totalGrandPaise),
      refundedAmountPaise: Money.fromPaise(totalGrandPaise),
      createdAtUtc: now,
      reason: reason,
      notes: notes,
    );

    await accountingStore.saveDocumentHeader(docHeader);
    await financeStore.saveSalesReturn(header: returnHeader, lines: returnLines);

    // Stock Re-integration & Serial State Update
    for (final line in returnLines) {
      final targetLoc = line.disposition == ReturnDisposition.quarantine ? 'QUARANTINE' : locationId;
      final cogsReversalPaise = line.lineCogsReversalPaise.paise;

      final movement = StockMovement(
        id: 'mv_sret_${now.microsecondsSinceEpoch}_${line.id}',
        organizationId: organizationId,
        branchId: branchId,
        documentId: docHeaderId,
        lineId: line.id,
        productId: line.productId,
        locationId: targetLoc,
        movementKind: MovementKind.saleReturn,
        quantityMicroUnits: line.quantity.microUnits,
        valueDeltaPaise: cogsReversalPaise,
        costSnapshotMicroRupees: line.costSnapshotMicroRupees,
        createdAt: now,
      );

      final curBal = await inventoryStore.getStockBalance(line.productId, targetLoc);
      final newBal = curBal == null
          ? StockBalance(
              productId: line.productId,
              locationId: targetLoc,
              quantityMicroUnits: line.quantity.microUnits,
              valuePaise: cogsReversalPaise,
              updatedAt: now,
            )
          : curBal.applyMovement(movement: movement, updatedAt: now);

      await inventoryStore.saveStockMovement(movement);
      await inventoryStore.saveStockBalance(newBal);

      for (final sStr in line.serials) {
        final sRec = await inventoryStore.getSerialByNumber(organizationId, line.productId, sStr);
        if (sRec != null) {
          final newState = line.disposition == ReturnDisposition.quarantine
              ? SerialState.quarantined
              : SerialState.inStock;

          await inventoryStore.saveSerialRecord(SerialRecord(
            id: sRec.id,
            organizationId: organizationId,
            productId: line.productId,
            serialNumber: sRec.serialNumber,
            state: newState,
            locationId: targetLoc,
            updatedAt: now,
          ));

          await inventoryStore.saveSerialEvent(SerialEvent(
            id: 'se_sret_${now.microsecondsSinceEpoch}_${sRec.id}',
            serialId: sRec.id,
            fromState: SerialState.sold,
            toState: newState,
            documentId: docHeaderId,
            createdAt: now,
          ));
        }
      }
    }

    // Revenue/GST Credit Note Journal Entry
    final je1Id = 'je_crn_${now.microsecondsSinceEpoch}';
    final journal1 = JournalEntry(
      id: je1Id,
      organizationId: organizationId,
      branchId: branchId,
      documentId: docHeaderId,
      postingDate: returnDate,
      memo: 'Credit Note for Sales Return on invoice $originalSaleId',
      lines: [
        JournalLine(id: '${je1Id}_1', journalEntryId: je1Id, accountId: 'acc_4000', debitPaise: totalSubtotalPaise, creditPaise: 0, partyId: originalHeader.customerPartyId),
        if (totalTaxPaise > 0)
          JournalLine(id: '${je1Id}_2', journalEntryId: je1Id, accountId: 'acc_2200', debitPaise: totalTaxPaise, creditPaise: 0),
        JournalLine(id: '${je1Id}_3', journalEntryId: je1Id, accountId: 'acc_1200', debitPaise: 0, creditPaise: totalGrandPaise, partyId: originalHeader.customerPartyId),
      ],
      createdAt: now,
    );

    // COGS Reversal Journal Entry
    final totalCogsPaise = returnLines.fold<int>(0, (sum, l) => sum + l.lineCogsReversalPaise.paise);
    final je2Id = 'je_cogs_rev_${now.microsecondsSinceEpoch}';
    final journal2 = JournalEntry(
      id: je2Id,
      organizationId: organizationId,
      branchId: branchId,
      documentId: docHeaderId,
      postingDate: returnDate,
      memo: 'COGS Reversal for Sales Return on invoice $originalSaleId',
      lines: [
        JournalLine(id: '${je2Id}_1', journalEntryId: je2Id, accountId: 'acc_1300', debitPaise: totalCogsPaise, creditPaise: 0),
        JournalLine(id: '${je2Id}_2', journalEntryId: je2Id, accountId: 'acc_5000', debitPaise: 0, creditPaise: totalCogsPaise),
      ],
      createdAt: now,
    );

    await accountingStore.saveJournalEntry(journal1);
    await accountingStore.saveJournalEntry(journal2);

    return returnHeader;
  }
}

final class PurchaseReturnLineInput {
  const PurchaseReturnLineInput({
    required this.purchaseLineId,
    required this.quantity,
    this.serials = const [],
  });

  final String purchaseLineId;
  final Quantity quantity;
  final List<String> serials;
}

final class PostPurchaseReturnUseCase {
  const PostPurchaseReturnUseCase({
    required this.purchasingStore,
    required this.financeStore,
    required this.inventoryStore,
    required this.accountingStore,
  });

  final PurchasingStore purchasingStore;
  final FinanceStore financeStore;
  final InventoryStore inventoryStore;
  final AccountingStore accountingStore;

  Future<PurchaseReturnHeader> execute(
    CommandContext context, {
    required String organizationId,
    required String branchId,
    required String originalPurchaseId,
    required DateTime returnDate,
    required String locationId,
    required List<PurchaseReturnLineInput> lineInputs,
    String? reason,
    String? notes,
  }) async {
    if (!context.session.hasCapability(Capability.financeManage)) {
      throw const AuthorizationFailure('unauthorized', 'User lacks financeManage capability');
    }

    final originalHeader = await purchasingStore.getPurchaseHeader(originalPurchaseId);
    if (originalHeader == null) {
      throw const ValidationFailure('purchase_not_found', 'Original purchase bill not found');
    }

    final originalLines = await purchasingStore.getPurchaseLines(originalPurchaseId);
    final originalLineMap = {for (final l in originalLines) l.id: l};

    final previousReturns = await financeStore.listPurchaseReturns(organizationId);
    final previousReturnHeaders = previousReturns.where((r) => r.originalPurchaseId == originalPurchaseId).toList();

    final Map<String, int> cumulativeReturnedMicroUnits = {};
    for (final ret in previousReturnHeaders) {
      final retLines = await financeStore.getPurchaseReturnLines(ret.id);
      for (final l in retLines) {
        cumulativeReturnedMicroUnits[l.purchaseLineId] =
            (cumulativeReturnedMicroUnits[l.purchaseLineId] ?? 0) + l.quantity.microUnits;
      }
    }

    final now = DateTime.now();
    final returnId = 'pret_${now.microsecondsSinceEpoch}';
    final returnLines = <PurchaseReturnLine>[];

    var totalSubtotalPaise = 0;
    var totalTaxPaise = 0;
    var totalGrandPaise = 0;

    for (final input in lineInputs) {
      final origLine = originalLineMap[input.purchaseLineId];
      if (origLine == null) {
        throw ValidationFailure('invalid_line', 'Purchase line ${input.purchaseLineId} not found in bill');
      }

      final prevQtyMicro = cumulativeReturnedMicroUnits[input.purchaseLineId] ?? 0;
      if (prevQtyMicro + input.quantity.microUnits > origLine.quantity.microUnits) {
        throw ValidationFailure(
          'cumulative_quantity_exceeded',
          'Returned quantity exceeds remaining purchased quantity for ${origLine.productName}',
        );
      }

      final returnRatio = input.quantity.microUnits / origLine.quantity.microUnits;
      final lineSubtotal = (origLine.subtotalBeforeDiscountPaise.paise * returnRatio).round();
      final lineTax = (origLine.taxSnapshot.totalTax.paise * returnRatio).round();
      final lineGrand = lineSubtotal + lineTax;

      totalSubtotalPaise += lineSubtotal;
      totalTaxPaise += lineTax;
      totalGrandPaise += lineGrand;

      final retLine = PurchaseReturnLine(
        id: 'pret_line_${now.microsecondsSinceEpoch}_${returnLines.length}',
        purchaseReturnId: returnId,
        purchaseLineId: origLine.id,
        productId: origLine.productId,
        productName: origLine.productName,
        sku: origLine.sku,
        quantity: input.quantity,
        unitPurchasePrice: origLine.unitPurchasePrice,
        taxSnapshot: TaxLineResult(
          lineId: origLine.id,
          taxableAmount: Money.fromPaise(lineSubtotal),
          cgst: Money.fromPaise((origLine.taxSnapshot.cgst.paise * returnRatio).round()),
          sgst: Money.fromPaise((origLine.taxSnapshot.sgst.paise * returnRatio).round()),
          igst: Money.fromPaise((origLine.taxSnapshot.igst.paise * returnRatio).round()),
          totalTax: Money.fromPaise(lineTax),
          totalAmount: Money.fromPaise(lineGrand),
        ),
        netTotalPaise: Money.fromPaise(lineGrand),
        serials: input.serials,
      );

      returnLines.add(retLine);
    }

    final currentYearStr = '${returnDate.year}';
    final docNumber = await accountingStore.allocateNextDocumentNumber(
      registrationId: branchId,
      fiscalYear: currentYearStr,
      series: 'DBN',
    );

    final docHeaderId = 'doc_dbn_${now.microsecondsSinceEpoch}';
    final docHeader = DocumentHeader(
      id: docHeaderId,
      organizationId: organizationId,
      branchId: branchId,
      kind: DocumentKind.purchaseReturn, // Debit Note
      status: DocumentStatus.posted,
      businessDate: returnDate,
      documentNumber: docNumber,
      fiscalYear: currentYearStr,
      sourceCommandId: context.session.id.value,
      createdAt: now,
    );

    final returnHeader = PurchaseReturnHeader(
      id: returnId,
      organizationId: organizationId,
      branchId: branchId,
      documentHeaderId: docHeaderId,
      originalPurchaseId: originalPurchaseId,
      supplierId: originalHeader.supplierId,
      supplierName: originalHeader.supplierName,
      returnDate: returnDate,
      locationId: locationId,
      status: PurchaseReturnStatus.posted,
      subtotalPaise: Money.fromPaise(totalSubtotalPaise),
      totalTaxPaise: Money.fromPaise(totalTaxPaise),
      grandTotalPaise: Money.fromPaise(totalGrandPaise),
      createdAtUtc: now,
      reason: reason,
      notes: notes,
    );

    await accountingStore.saveDocumentHeader(docHeader);
    await financeStore.savePurchaseReturn(header: returnHeader, lines: returnLines);

    // Stock Issue to Supplier & Serial Decommission
    for (final line in returnLines) {
      final curBal = await inventoryStore.getStockBalance(line.productId, locationId);
      final currentAvgCostMicro = curBal != null && curBal.quantityMicroUnits > 0
          ? curBal.weightedAverageUnitCostMicroRupees
          : line.unitPurchasePrice.microRupees;

      final inventoryValueDeltaPaise = (currentAvgCostMicro * line.quantity.microUnits) ~/ 10000000000;

      final movement = StockMovement(
        id: 'mv_pret_${now.microsecondsSinceEpoch}_${line.id}',
        organizationId: organizationId,
        branchId: branchId,
        documentId: docHeaderId,
        lineId: line.id,
        productId: line.productId,
        locationId: locationId,
        movementKind: MovementKind.purchaseReturn,
        quantityMicroUnits: -line.quantity.microUnits,
        valueDeltaPaise: -inventoryValueDeltaPaise,
        costSnapshotMicroRupees: currentAvgCostMicro,
        createdAt: now,
      );

      final newBal = curBal!.applyMovement(movement: movement, updatedAt: now);
      await inventoryStore.saveStockMovement(movement);
      await inventoryStore.saveStockBalance(newBal);

      for (final sStr in line.serials) {
        final sRec = await inventoryStore.getSerialByNumber(organizationId, line.productId, sStr);
        if (sRec != null) {
          await inventoryStore.saveSerialRecord(SerialRecord(
            id: sRec.id,
            organizationId: organizationId,
            productId: line.productId,
            serialNumber: sRec.serialNumber,
            state: SerialState.scrapped, // Returned to supplier
            locationId: locationId,
            updatedAt: now,
          ));

          await inventoryStore.saveSerialEvent(SerialEvent(
            id: 'se_pret_${now.microsecondsSinceEpoch}_${sRec.id}',
            serialId: sRec.id,
            fromState: sRec.state,
            toState: SerialState.scrapped,
            documentId: docHeaderId,
            createdAt: now,
          ));
        }
      }
    }

    // Debit Note Journal Entry
    final jeId = 'je_dbn_${now.microsecondsSinceEpoch}';
    final journal = JournalEntry(
      id: jeId,
      organizationId: organizationId,
      branchId: branchId,
      documentId: docHeaderId,
      postingDate: returnDate,
      memo: 'Debit Note for Purchase Return on bill $originalPurchaseId',
      lines: [
        JournalLine(id: '${jeId}_1', journalEntryId: jeId, accountId: 'acc_2100', debitPaise: totalGrandPaise, creditPaise: 0, partyId: originalHeader.supplierId),
        JournalLine(id: '${jeId}_2', journalEntryId: jeId, accountId: 'acc_1300', debitPaise: 0, creditPaise: totalSubtotalPaise),
        if (totalTaxPaise > 0)
          JournalLine(id: '${jeId}_3', journalEntryId: jeId, accountId: 'acc_1400', debitPaise: 0, creditPaise: totalTaxPaise),
      ],
      createdAt: now,
    );

    await accountingStore.saveJournalEntry(journal);

    return returnHeader;
  }
}

final class PostPaymentUseCase {
  const PostPaymentUseCase({
    required this.purchasingStore,
    required this.accountingStore,
  });

  final PurchasingStore purchasingStore;
  final AccountingStore accountingStore;

  Future<Payment> execute(
    CommandContext context, {
    required String organizationId,
    required String branchId,
    required String partyId,
    required String partyName,
    required PaymentDirection direction,
    required PaymentMethod paymentMethod,
    required Money amountPaise,
    required DateTime paymentDate,
    String? referenceNumber,
    String? notes,
    List<PaymentAllocation> allocations = const [],
  }) async {
    if (!context.session.hasCapability(Capability.financeManage)) {
      throw const AuthorizationFailure('unauthorized', 'User lacks financeManage capability');
    }

    if (amountPaise.paise <= 0) {
      throw const ValidationFailure('invalid_payment_amount', 'Payment amount must be positive');
    }

    final now = DateTime.now();
    final payment = Payment(
      id: 'pmt_${now.microsecondsSinceEpoch}',
      organizationId: organizationId,
      branchId: branchId,
      partyId: partyId,
      partyName: partyName,
      direction: direction,
      paymentMethod: paymentMethod,
      amountPaise: amountPaise,
      paymentDate: paymentDate,
      createdAtUtc: now,
      referenceNumber: referenceNumber,
      notes: notes,
    );

    await purchasingStore.savePayment(payment: payment, allocations: allocations);

    // Balanced Journal Entry
    final jeId = 'je_pmt_${now.microsecondsSinceEpoch}';
    final journal = JournalEntry(
      id: jeId,
      organizationId: organizationId,
      branchId: branchId,
      documentId: payment.id,
      postingDate: paymentDate,
      memo: '${direction == PaymentDirection.inbound ? "Customer Receipt" : "Supplier Payment"} — ${paymentMethod.name}',
      lines: direction == PaymentDirection.inbound
          ? [
              JournalLine(id: '${jeId}_1', journalEntryId: jeId, accountId: 'acc_1100', debitPaise: amountPaise.paise, creditPaise: 0),
              JournalLine(id: '${jeId}_2', journalEntryId: jeId, accountId: 'acc_1200', debitPaise: 0, creditPaise: amountPaise.paise, partyId: partyId),
            ]
          : [
              JournalLine(id: '${jeId}_1', journalEntryId: jeId, accountId: 'acc_2100', debitPaise: amountPaise.paise, creditPaise: 0, partyId: partyId),
              JournalLine(id: '${jeId}_2', journalEntryId: jeId, accountId: 'acc_1100', debitPaise: 0, creditPaise: amountPaise.paise),
            ],
      createdAt: now,
    );

    await accountingStore.saveJournalEntry(journal);

    return payment;
  }
}
