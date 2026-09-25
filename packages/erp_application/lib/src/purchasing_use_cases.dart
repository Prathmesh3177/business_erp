import 'package:erp_domain/erp_domain.dart';
import 'accounting_store.dart';
import 'command_context.dart';
import 'inventory_store.dart';
import 'purchasing_store.dart';

final class PurchaseLineInput {
  const PurchaseLineInput({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPurchasePrice,
    required this.taxRate,
    this.discount = Money.zero,
    this.serials = const [],
    this.batchLot,
    this.expiryDate,
  });

  final String productId;
  final String productName;
  final String sku;
  final Quantity quantity;
  final UnitPrice unitPurchasePrice;
  final TaxRate taxRate;
  final Money discount;
  final List<String> serials;
  final String? batchLot;
  final DateTime? expiryDate;
}

final class PostPurchaseUseCase {
  const PostPurchaseUseCase({
    required this.purchasingStore,
    required this.inventoryStore,
    required this.accountingStore,
  });

  final PurchasingStore purchasingStore;
  final InventoryStore inventoryStore;
  final AccountingStore accountingStore;

  Future<PurchaseHeader> execute(
    CommandContext context, {
    required String organizationId,
    required String branchId,
    required String supplierId,
    required String supplierName,
    required String externalInvoiceNumber,
    required DateTime invoiceDate,
    required String locationId,
    required TaxSupplyType supplyType,
    required List<PurchaseLineInput> lineInputs,
    Money landedCostTotal = Money.zero,
    LandedCostAllocationType landedCostAllocationType = LandedCostAllocationType.byValue,
    Money? initialPaymentAmount,
    PaymentMethod? initialPaymentMethod,
    String? notes,
  }) async {
    // 1. Authorization check
    context.requireCapability(Capability.purchaseManage);

    if (lineInputs.isEmpty) {
      throw const ValidationFailure('empty_lines', 'Purchase bill must contain at least one line item');
    }

    final normalizedExtNo = PurchaseHeader.normalizeExternalInvoiceNumber(externalInvoiceNumber);
    final currentYearStr = '${invoiceDate.year}';

    // 2. Duplicate supplier invoice check
    final isDuplicate = await purchasingStore.hasDuplicateSupplierInvoice(
      organizationId: organizationId,
      supplierId: supplierId,
      financialYear: currentYearStr,
      externalInvoiceNumber: normalizedExtNo,
    );
    if (isDuplicate) {
      throw ConflictFailure(
        'duplicate_supplier_invoice',
        'Supplier invoice $externalInvoiceNumber already exists for this supplier in fiscal year $currentYearStr',
      );
    }

    // 3. Tax calculation & Purchase Lines construction
    const taxEngine = TaxEngine();
    final taxRequests = <TaxLineRequest>[];
    for (var i = 0; i < lineInputs.length; i++) {
      final input = lineInputs[i];
      taxRequests.add(
        TaxLineRequest(
          lineId: 'line_$i',
          unitPrice: input.unitPurchasePrice,
          quantity: input.quantity,
          taxRate: input.taxRate,
          lineDiscount: input.discount,
        ),
      );
    }

    final taxInvoiceResult = taxEngine.calculateInvoiceTax(
      lines: taxRequests,
      supplyType: supplyType,
    );

    final now = DateTime.now();
    final purchaseId = 'pur_${now.microsecondsSinceEpoch}';
    final tempLines = <PurchaseLine>[];

    for (var i = 0; i < lineInputs.length; i++) {
      final input = lineInputs[i];
      final lineResult = taxInvoiceResult.lineResults[i];

      if (input.serials.isNotEmpty) {
        final expectedCount = (input.quantity.inUnits).round();
        if (input.serials.length != expectedCount) {
          throw ValidationFailure(
            'invalid_serial_count',
            'Line ${input.productName} expected $expectedCount serials but received ${input.serials.length}',
          );
        }
      }

      tempLines.add(
        PurchaseLine(
          id: 'pur_line_${now.microsecondsSinceEpoch}_$i',
          purchaseId: purchaseId,
          productId: input.productId,
          productName: input.productName,
          sku: input.sku,
          quantity: input.quantity,
          unitPurchasePrice: input.unitPurchasePrice,
          discountPaise: input.discount,
          taxSnapshot: lineResult,
          landedCostAllocationPaise: Money.zero,
          netTotalPaise: lineResult.totalAmount,
          serials: input.serials.map(SerialRecord.normalizeSerialNumber).toList(),
          batchLot: input.batchLot,
          expiryDate: input.expiryDate,
        ),
      );
    }

    // 4. Landed cost allocation
    final landedAllocations = LandedCostAllocator.allocate(
      totalLandedCost: landedCostTotal,
      lines: tempLines,
      allocationType: landedCostAllocationType,
    );

    final finalLines = <PurchaseLine>[];
    var subtotalPaiseSum = 0;
    var totalTaxPaiseSum = 0;
    var netTotalPaiseSum = 0;

    for (var i = 0; i < tempLines.length; i++) {
      final line = tempLines[i];
      final allocatedLanded = landedAllocations[i];
      final updatedLine = line.copyWith(
        landedCostAllocationPaise: allocatedLanded,
      );
      finalLines.add(updatedLine);

      subtotalPaiseSum += line.subtotalBeforeDiscountPaise.paise;
      totalTaxPaiseSum += line.taxSnapshot.totalTax.paise;
      netTotalPaiseSum += line.taxSnapshot.totalAmount.paise + allocatedLanded.paise;
    }

    final netTotalPaiseWithRoundOff = netTotalPaiseSum + taxInvoiceResult.roundOff.paise;
    final initialPaid = initialPaymentAmount ?? Money.zero;
    final balanceDue = Money.fromPaise(netTotalPaiseWithRoundOff - initialPaid.paise);

    // 5. Generate document header number
    final docNumber = await accountingStore.allocateNextDocumentNumber(
      registrationId: branchId,
      fiscalYear: currentYearStr,
      series: 'PUR',
    );

    final docHeaderId = 'doc_${now.microsecondsSinceEpoch}';
    final docHeader = DocumentHeader(
      id: docHeaderId,
      organizationId: organizationId,
      branchId: branchId,
      kind: DocumentKind.purchaseBill,
      status: DocumentStatus.posted,
      businessDate: invoiceDate,
      documentNumber: docNumber,
      fiscalYear: currentYearStr,
      sourceCommandId: context.session.id.value,
      createdAt: now,
    );

    final header = PurchaseHeader(
      id: purchaseId,
      organizationId: organizationId,
      branchId: branchId,
      documentHeaderId: docHeaderId,
      supplierId: supplierId,
      supplierName: supplierName,
      externalInvoiceNumber: externalInvoiceNumber,
      normalizedExternalInvoiceNumber: normalizedExtNo,
      invoiceDate: invoiceDate,
      locationId: locationId,
      status: PurchaseStatus.posted,
      subtotalPaise: Money.fromPaise(subtotalPaiseSum),
      landedCostTotalPaise: landedCostTotal,
      totalTaxPaise: Money.fromPaise(totalTaxPaiseSum),
      netTotalPaise: Money.fromPaise(netTotalPaiseWithRoundOff),
      amountPaidPaise: initialPaid,
      balanceDuePaise: balanceDue,
      createdAtUtc: now,
      notes: notes,
    );

    // 6. Build Stock Movements & Serials
    final movements = <StockMovement>[];
    final serialRecords = <SerialRecord>[];
    final serialEvents = <SerialEvent>[];

    for (final line in finalLines) {
      final lineInvValuePaise = line.inventoryValuePaise;

      final movement = StockMovement(
        id: 'mv_${now.microsecondsSinceEpoch}_${line.id}',
        organizationId: organizationId,
        branchId: branchId,
        documentId: docHeaderId,
        lineId: line.id,
        productId: line.productId,
        locationId: locationId,
        movementKind: MovementKind.purchaseReceipt,
        quantityMicroUnits: line.quantity.microUnits,
        valueDeltaPaise: lineInvValuePaise.paise,
        costSnapshotMicroRupees: (lineInvValuePaise.paise * 10000000000) ~/ line.quantity.microUnits,
        createdAt: now,
      );
      movements.add(movement);

      final currentBalance = await inventoryStore.getStockBalance(line.productId, locationId);

      final updatedBalance = (currentBalance ??
              StockBalance(
                productId: line.productId,
                locationId: locationId,
                quantityMicroUnits: 0,
                valuePaise: 0,
                updatedAt: now,
              ))
          .applyMovement(movement: movement, updatedAt: now);

      await inventoryStore.saveStockMovement(movement);
      await inventoryStore.saveStockBalance(updatedBalance);

      for (final serialStr in line.serials) {
        final existingSerial = await inventoryStore.getSerialByNumber(
          organizationId,
          line.productId,
          serialStr,
        );

        if (existingSerial != null && existingSerial.state == SerialState.inStock) {
          throw ConflictFailure(
            'duplicate_serial',
            'Serial $serialStr for product ${line.productName} is already active in stock',
          );
        }

        final serialId = existingSerial?.id ?? 'sn_${now.microsecondsSinceEpoch}_$serialStr';
        final serialRec = SerialRecord(
          id: serialId,
          organizationId: organizationId,
          productId: line.productId,
          serialNumber: serialStr,
          state: SerialState.inStock,
          locationId: locationId,
          updatedAt: now,
        );

        final serialEvt = SerialEvent(
          id: 'se_${now.microsecondsSinceEpoch}_$serialStr',
          serialId: serialId,
          fromState: SerialState.inStock,
          toState: SerialState.inStock,
          documentId: docHeaderId,
          createdAt: now,
        );

        serialRecords.add(serialRec);
        serialEvents.add(serialEvt);

        await inventoryStore.saveSerialRecord(serialRec);
        await inventoryStore.saveSerialEvent(serialEvt);
      }
    }

    // 7. Build Journal Entry
    final journalLines = <JournalLine>[];
    final totalInventoryPaise = finalLines.fold<int>(
      0,
      (sum, l) => sum + l.inventoryValuePaise.paise,
    );

    journalLines.add(
      JournalLine(
        id: 'jl_1',
        journalEntryId: docHeaderId,
        accountId: 'acc_inv',
        debitPaise: totalInventoryPaise,
        creditPaise: 0,
      ),
    );

    if (supplyType == TaxSupplyType.intraState) {
      if (taxInvoiceResult.totalCgst.paise > 0) {
        journalLines.add(
          JournalLine(
            id: 'jl_2',
            journalEntryId: docHeaderId,
            accountId: 'acc_cgst_in',
            debitPaise: taxInvoiceResult.totalCgst.paise,
            creditPaise: 0,
          ),
        );
      }
      if (taxInvoiceResult.totalSgst.paise > 0) {
        journalLines.add(
          JournalLine(
            id: 'jl_3',
            journalEntryId: docHeaderId,
            accountId: 'acc_sgst_in',
            debitPaise: taxInvoiceResult.totalSgst.paise,
            creditPaise: 0,
          ),
        );
      }
    } else {
      if (taxInvoiceResult.totalIgst.paise > 0) {
        journalLines.add(
          JournalLine(
            id: 'jl_2',
            journalEntryId: docHeaderId,
            accountId: 'acc_igst_in',
            debitPaise: taxInvoiceResult.totalIgst.paise,
            creditPaise: 0,
          ),
        );
      }
    }

    journalLines.add(
      JournalLine(
        id: 'jl_ap',
        journalEntryId: docHeaderId,
        accountId: 'acc_ap',
        debitPaise: 0,
        creditPaise: netTotalPaiseWithRoundOff,
        partyId: supplierId,
      ),
    );

    final journalEntry = JournalEntry(
      id: docHeaderId,
      organizationId: organizationId,
      branchId: branchId,
      documentId: docHeaderId,
      postingDate: invoiceDate,
      memo: 'Purchase bill $externalInvoiceNumber from $supplierName',
      lines: journalLines,
      createdAt: now,
    );

    await accountingStore.saveDocumentHeader(docHeader);
    await purchasingStore.savePurchase(header: header, lines: finalLines);
    await accountingStore.saveJournalEntry(journalEntry);

    // 8. Initial Payment if provided
    if (initialPaid.paise > 0) {
      final paymentId = 'pmt_${now.microsecondsSinceEpoch}';
      final payment = Payment(
        id: paymentId,
        organizationId: organizationId,
        branchId: branchId,
        partyId: supplierId,
        partyName: supplierName,
        direction: PaymentDirection.outbound,
        paymentMethod: initialPaymentMethod ?? PaymentMethod.cash,
        amountPaise: initialPaid,
        paymentDate: invoiceDate,
        createdAtUtc: now,
        notes: 'Initial payment for bill $externalInvoiceNumber',
      );

      final allocation = PaymentAllocation(
        id: 'pmt_alloc_${now.microsecondsSinceEpoch}',
        paymentId: paymentId,
        documentId: docHeaderId,
        allocatedAmountPaise: initialPaid,
        createdAtUtc: now,
      );

      await purchasingStore.savePayment(payment: payment, allocations: [allocation]);

      final paymentJournalId = 'je_pmt_${now.microsecondsSinceEpoch}';
      final pmtLines = [
        JournalLine(
          id: 'jl_pmt_1',
          journalEntryId: paymentJournalId,
          accountId: 'acc_ap',
          debitPaise: initialPaid.paise,
          creditPaise: 0,
          partyId: supplierId,
        ),
        JournalLine(
          id: 'jl_pmt_2',
          journalEntryId: paymentJournalId,
          accountId: (initialPaymentMethod == PaymentMethod.cash) ? 'acc_cash' : 'acc_bank',
          debitPaise: 0,
          creditPaise: initialPaid.paise,
        ),
      ];

      final pmtJournal = JournalEntry(
        id: paymentJournalId,
        organizationId: organizationId,
        branchId: branchId,
        documentId: docHeaderId,
        postingDate: invoiceDate,
        memo: 'Payment for bill $externalInvoiceNumber',
        lines: pmtLines,
        createdAt: now,
      );

      await accountingStore.saveJournalEntry(pmtJournal);
    }

    return header;
  }
}
