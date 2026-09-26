import 'dart:convert';

import 'package:erp_domain/erp_domain.dart';

import 'accounting_store.dart';
import 'command_context.dart';
import 'inventory_store.dart';
import 'party_store.dart';
import 'sales_store.dart';

final class SaleLineInput {
  const SaleLineInput({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.hsnCode,
    required this.baseUnit,
    required this.quantity,
    required this.unitPrice,
    required this.taxRate,
    this.lineDiscount = Money.zero,
    this.serials = const [],
    this.batchLot,
    this.isMadeToOrder = false,
  });

  final String productId;
  final String productName;
  final String sku;
  final String hsnCode;
  final String baseUnit;
  final Quantity quantity;
  final UnitPrice unitPrice;
  final TaxRate taxRate;
  final Money lineDiscount;
  final List<String> serials;
  final String? batchLot;
  final bool isMadeToOrder;
}

final class SaleOrderLineInput {
  const SaleOrderLineInput({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.taxRate,
  });

  final String productId;
  final String productName;
  final Quantity quantity;
  final UnitPrice unitPrice;
  final TaxRate taxRate;
}

final class CreatePendingOrderUseCase {
  const CreatePendingOrderUseCase(this.salesStore);

  final SalesStore salesStore;

  Future<SaleOrder> execute(
    CommandContext context, {
    required String organizationId,
    required String branchId,
    required String customerPartyId,
    required String customerName,
    required String customerPhone,
    required List<SaleOrderLineInput> lineInputs,
    String? saleHeaderId,
    DateTime? expectedDeliveryDate,
    String? notes,
  }) async {
    context.requireCapability(Capability.salesCreate);
    if (lineInputs.isEmpty) {
      throw const ValidationFailure(
        'empty_order',
        'An order must contain at least one item',
      );
    }
    final now = context.timestampUtc;
    final id = 'order_${now.microsecondsSinceEpoch}';
    final lines = lineInputs.asMap().entries.map((entry) {
      final line = entry.value;
      return SaleOrderLine(
        id: '${id}_line_${entry.key}',
        orderId: id,
        productId: line.productId,
        productName: line.productName,
        quantity: line.quantity,
        unitPrice: line.unitPrice,
        taxRate: line.taxRate,
      );
    }).toList();
    final total = lines.fold<Money>(Money.zero, (sum, line) {
      final base = Money.fromRupees(
        line.quantity.inUnits * line.unitPrice.inRupees,
      );
      return sum + base + base.times(line.taxRate.bps / 10000);
    });
    final order = SaleOrder(
      id: id,
      organizationId: organizationId,
      branchId: branchId,
      customerPartyId: customerPartyId,
      customerName: customerName,
      customerPhone: customerPhone,
      orderDate: now,
      status: OrderStatus.pending,
      saleHeaderId: saleHeaderId,
      grandTotalPaise: total,
      expectedDeliveryDate: expectedDeliveryDate,
      notes: notes,
      createdAtUtc: now,
    );
    await salesStore.saveSaleOrder(order: order, lines: lines);
    return order;
  }
}

final class PostSaleUseCase {
  const PostSaleUseCase({
    required this.salesStore,
    required this.inventoryStore,
    required this.accountingStore,
    required this.partyStore,
  });

  final SalesStore salesStore;
  final InventoryStore inventoryStore;
  final AccountingStore accountingStore;
  final PartyStore partyStore;

  Future<SaleHeader> execute(
    CommandContext context, {
    required String organizationId,
    required String branchId,
    required String customerPartyId,
    required String customerName,
    required DateTime businessDate,
    required String locationId,
    required TaxSupplyType supplyType,
    required List<SaleLineInput> lineInputs,
    required List<TenderLine> tenderLines,
    required String commandId,
    Money invoiceDiscount = Money.zero,
    String? notes,
  }) async {
    // 1. Authorization check
    context.requireCapability(Capability.salesCreate);

    if (lineInputs.isEmpty) {
      throw const ValidationFailure(
        'empty_cart',
        'Sale invoice must contain at least one line item',
      );
    }

    // 2. Idempotency check: if commandId executed previously, return cached header
    final cachedResult = await accountingStore.getCommandResult(commandId);
    if (cachedResult != null) {
      final resultMap =
          jsonDecode(cachedResult.resultJson) as Map<String, dynamic>;
      final existingSaleId = resultMap['saleHeaderId'] as String;
      final existingHeader = await salesStore.getSaleHeader(existingSaleId);
      if (existingHeader != null) return existingHeader;
    }

    // 3. Tax calculation
    const taxEngine = TaxEngine();
    final taxRequests = <TaxLineRequest>[];
    for (var i = 0; i < lineInputs.length; i++) {
      final input = lineInputs[i];
      taxRequests.add(
        TaxLineRequest(
          lineId: 'line_$i',
          unitPrice: input.unitPrice,
          quantity: input.quantity,
          taxRate: input.taxRate,
          lineDiscount: input.lineDiscount,
        ),
      );
    }

    final taxInvoiceResult = taxEngine.calculateInvoiceTax(
      lines: taxRequests,
      supplyType: supplyType,
      invoiceDiscount: invoiceDiscount,
    );

    final now = DateTime.now();
    final saleId = 'sale_${now.microsecondsSinceEpoch}';
    final tempLines = <SaleLine>[];

    // 4. Fresh revalidation of Stock & Serials
    for (var i = 0; i < lineInputs.length; i++) {
      final input = lineInputs[i];
      final lineResult = taxInvoiceResult.lineResults[i];

      // Check stock balance availability and serials if not made-to-order
      int costSnapshotMicroRupees = 0;

      if (!input.isMadeToOrder) {
        final balance = await inventoryStore.getStockBalance(
          input.productId,
          locationId,
        );
        final activeReservations = await inventoryStore
            .getActiveReservationsForProduct(organizationId, input.productId);

        final reservedMicroUnits = activeReservations.fold<int>(
          0,
          (sum, r) => sum + r.quantityMicroUnits,
        );

        final onHandMicroUnits = balance?.quantityMicroUnits ?? 0;
        final availableMicroUnits = onHandMicroUnits - reservedMicroUnits;

        if (availableMicroUnits < input.quantity.microUnits) {
          final availUnits = availableMicroUnits / 1000000.0;
          throw ValidationFailure(
            'insufficient_stock',
            'Insufficient available stock for ${input.productName}. Required ${input.quantity.inUnits} base units, but only $availUnits available in $locationId.',
          );
        }

        // Cost snapshot from weighted average cost
        costSnapshotMicroRupees =
            balance?.weightedAverageUnitCostMicroRupees ?? 0;

        // Serial revalidation if item is serial-tracked
        if (input.serials.isNotEmpty) {
          final expectedCount = (input.quantity.inUnits).round();
          if (input.serials.length != expectedCount) {
            throw ValidationFailure(
              'invalid_serial_count',
              'Line ${input.productName} expected $expectedCount serials but received ${input.serials.length}',
            );
          }

          for (final sStr in input.serials) {
            final sRec = await inventoryStore.getSerialByNumber(
              organizationId,
              input.productId,
              sStr,
            );
            if (sRec == null ||
                sRec.state != SerialState.inStock ||
                sRec.locationId != locationId) {
              throw ValidationFailure(
                'serial_unavailable',
                'Serial $sStr for ${input.productName} is not in stock at location $locationId',
              );
            }
          }
        }
      }

      tempLines.add(
        SaleLine(
          id: 'sale_line_${now.microsecondsSinceEpoch}_$i',
          saleId: saleId,
          productId: input.productId,
          productName: input.productName,
          sku: input.sku,
          hsnCode: input.hsnCode,
          baseUnit: input.baseUnit,
          quantity: input.quantity,
          unitPrice: input.unitPrice,
          lineDiscountPaise: input.lineDiscount,
          taxSnapshot: lineResult,
          costSnapshotMicroRupees: costSnapshotMicroRupees,
          netTotalPaise: lineResult.totalAmount,
          serials: input.serials
              .map(SerialRecord.normalizeSerialNumber)
              .toList(),
          batchLot: input.batchLot,
          isMadeToOrder: input.isMadeToOrder,
        ),
      );
    }

    // 5. Total calculation & Split Tender allocation
    final grandTotalPaise = taxInvoiceResult.grandTotal.paise;
    final totalAmountPaidPaise = tenderLines.fold<int>(
      0,
      (sum, t) => sum + t.amountPaise.paise,
    );
    final balanceDuePaise = grandTotalPaise - totalAmountPaidPaise;

    // 6. Customer Credit Limit Check
    if (customerPartyId.isNotEmpty && balanceDuePaise > 0) {
      final party = await partyStore.getPartyById(
        organizationId,
        customerPartyId,
      );
      if (party != null && party.creditLimitPaise > 0) {
        final currentOutstandingPaise = await accountingStore
            .getPartyBalancePaise(organizationId, customerPartyId);
        final newOutstandingPaise = currentOutstandingPaise + balanceDuePaise;

        if (newOutstandingPaise > party.creditLimitPaise) {
          final limitRupees = party.creditLimitPaise / 100.0;
          final newOutRupees = newOutstandingPaise / 100.0;
          throw ValidationFailure(
            'credit_limit_exceeded',
            'Customer ${party.name} credit limit of ₹$limitRupees exceeded (New Outstanding: ₹$newOutRupees)',
          );
        }
      }
    }

    // 7. Allocate Document Sequence Number
    final currentYearStr = '${businessDate.year}';
    final docNumber = await accountingStore.allocateNextDocumentNumber(
      registrationId: branchId,
      fiscalYear: currentYearStr,
      series: 'SKS',
    );

    final docHeaderId = 'doc_sale_${now.microsecondsSinceEpoch}';
    final docHeader = DocumentHeader(
      id: docHeaderId,
      organizationId: organizationId,
      branchId: branchId,
      kind: DocumentKind.saleInvoice,
      status: DocumentStatus.posted,
      businessDate: businessDate,
      documentNumber: docNumber,
      fiscalYear: currentYearStr,
      sourceCommandId: context.session.id.value,
      createdAt: now,
    );

    final header = SaleHeader(
      id: saleId,
      organizationId: organizationId,
      branchId: branchId,
      documentHeaderId: docHeaderId,
      customerPartyId: customerPartyId,
      customerName: customerName,
      businessDate: businessDate,
      locationId: locationId,
      status: SaleStatus.posted,
      subtotalPaise: taxInvoiceResult.subtotal,
      allocatedDiscountPaise: taxInvoiceResult.allocatedDiscount,
      totalTaxPaise: taxInvoiceResult.totalTax,
      grandTotalPaise: taxInvoiceResult.grandTotal,
      amountPaidPaise: Money.fromPaise(totalAmountPaidPaise),
      balanceDuePaise: Money.fromPaise(
        balanceDuePaise > 0 ? balanceDuePaise : 0,
      ),
      createdAtUtc: now,
      notes: notes,
    );

    // 8. Create Stock Issue Movements, Serials & Warranties
    final movements = <StockMovement>[];

    for (final line in tempLines) {
      if (line.isMadeToOrder) {
        // Made-to-order items have no immediate physical stock to deduct.
        continue;
      }

      final cogsPaise = line.lineCogsPaise.paise;

      final movement = StockMovement(
        id: 'mv_sale_${now.microsecondsSinceEpoch}_${line.id}',
        organizationId: organizationId,
        branchId: branchId,
        documentId: docHeaderId,
        lineId: line.id,
        productId: line.productId,
        locationId: locationId,
        movementKind: MovementKind.saleIssue,
        quantityMicroUnits:
            -line.quantity.microUnits, // Negative for sale issue
        valueDeltaPaise: -cogsPaise, // Negative inventory value reduction
        costSnapshotMicroRupees: line.costSnapshotMicroRupees,
        createdAt: now,
      );
      movements.add(movement);

      final currentBalance = await inventoryStore.getStockBalance(
        line.productId,
        locationId,
      );
      final updatedBalance = currentBalance!.applyMovement(
        movement: movement,
        updatedAt: now,
      );

      await inventoryStore.saveStockMovement(movement);
      await inventoryStore.saveStockBalance(updatedBalance);

      // Serial update to sold & warranty creation
      for (final sStr in line.serials) {
        final sRec = await inventoryStore.getSerialByNumber(
          organizationId,
          line.productId,
          sStr,
        );
        if (sRec != null) {
          final soldRec = SerialRecord(
            id: sRec.id,
            organizationId: organizationId,
            productId: line.productId,
            serialNumber: sRec.serialNumber,
            state: SerialState.sold,
            locationId: locationId,
            updatedAt: now,
          );
          final sEvt = SerialEvent(
            id: 'se_sold_${now.microsecondsSinceEpoch}_$sStr',
            serialId: sRec.id,
            fromState: SerialState.inStock,
            toState: SerialState.sold,
            documentId: docHeaderId,
            createdAt: now,
          );

          await inventoryStore.saveSerialRecord(soldRec);
          await inventoryStore.saveSerialEvent(sEvt);

          final warranty = WarrantyEntitlement(
            id: 'warr_${now.microsecondsSinceEpoch}_$sStr',
            serialId: sRec.id,
            productId: line.productId,
            serialNumber: sRec.serialNumber,
            partyId: customerPartyId,
            saleDocumentId: docHeaderId,
            startDate: businessDate,
            endDate: businessDate.add(
              const Duration(days: 365 * 5),
            ), // 5 Year Warranty Default
            termsSnapshot: 'Standard Solar Equipment Warranty',
            createdAtUtc: now,
          );

          await salesStore.saveWarrantyEntitlement(warranty);
        }
      }
    }

    // 9. Post Revenue & Tax Double-Entry Journal
    final revJournalLines = <JournalLine>[];
    int lineSeq = 1;

    if (totalAmountPaidPaise > 0) {
      for (final t in tenderLines) {
        if (t.amountPaise.paise > 0) {
          final accountId = (t.method == TenderMethod.cash)
              ? 'acc_cash'
              : (t.method == TenderMethod.customerCredit)
              ? 'acc_ar'
              : 'acc_bank';

          revJournalLines.add(
            JournalLine(
              id: 'jl_rev_${lineSeq++}',
              journalEntryId: docHeaderId,
              accountId: accountId,
              debitPaise: t.amountPaise.paise,
              creditPaise: 0,
              partyId: accountId == 'acc_ar' ? customerPartyId : null,
            ),
          );
        }
      }
    }

    if (balanceDuePaise > 0) {
      revJournalLines.add(
        JournalLine(
          id: 'jl_rev_${lineSeq++}',
          journalEntryId: docHeaderId,
          accountId: 'acc_ar',
          debitPaise: balanceDuePaise,
          creditPaise: 0,
          partyId: customerPartyId,
        ),
      );
    }

    final netSalesRevenuePaise =
        taxInvoiceResult.subtotal.paise -
        taxInvoiceResult.allocatedDiscount.paise;
    revJournalLines.add(
      JournalLine(
        id: 'jl_rev_${lineSeq++}',
        journalEntryId: docHeaderId,
        accountId: 'acc_sales',
        debitPaise: 0,
        creditPaise: netSalesRevenuePaise,
      ),
    );

    if (supplyType == TaxSupplyType.intraState) {
      if (taxInvoiceResult.totalCgst.paise > 0) {
        revJournalLines.add(
          JournalLine(
            id: 'jl_rev_${lineSeq++}',
            journalEntryId: docHeaderId,
            accountId: 'acc_cgst_out',
            debitPaise: 0,
            creditPaise: taxInvoiceResult.totalCgst.paise,
          ),
        );
      }
      if (taxInvoiceResult.totalSgst.paise > 0) {
        revJournalLines.add(
          JournalLine(
            id: 'jl_rev_${lineSeq++}',
            journalEntryId: docHeaderId,
            accountId: 'acc_sgst_out',
            debitPaise: 0,
            creditPaise: taxInvoiceResult.totalSgst.paise,
          ),
        );
      }
    } else {
      if (taxInvoiceResult.totalIgst.paise > 0) {
        revJournalLines.add(
          JournalLine(
            id: 'jl_rev_${lineSeq++}',
            journalEntryId: docHeaderId,
            accountId: 'acc_igst_out',
            debitPaise: 0,
            creditPaise: taxInvoiceResult.totalIgst.paise,
          ),
        );
      }
    }

    final revJournal = JournalEntry(
      id: docHeaderId,
      organizationId: organizationId,
      branchId: branchId,
      documentId: docHeaderId,
      postingDate: businessDate,
      memo: 'Sale Invoice $docNumber to $customerName',
      lines: revJournalLines,
      createdAt: now,
    );

    // 10. Post COGS Double-Entry Journal (if COGS > 0)
    final totalCogsPaise = tempLines.fold<int>(
      0,
      (sum, l) => sum + l.lineCogsPaise.paise,
    );

    await accountingStore.saveDocumentHeader(docHeader);
    await salesStore.saveSale(header: header, lines: tempLines);
    await accountingStore.saveJournalEntry(revJournal);

    if (totalCogsPaise > 0) {
      final cogsJournalId = 'je_cogs_${now.microsecondsSinceEpoch}';
      final cogsLines = [
        JournalLine(
          id: 'jl_cogs_1',
          journalEntryId: cogsJournalId,
          accountId: 'acc_cogs',
          debitPaise: totalCogsPaise,
          creditPaise: 0,
        ),
        JournalLine(
          id: 'jl_cogs_2',
          journalEntryId: cogsJournalId,
          accountId: 'acc_inv',
          debitPaise: 0,
          creditPaise: totalCogsPaise,
        ),
      ];

      final cogsJournal = JournalEntry(
        id: cogsJournalId,
        organizationId: organizationId,
        branchId: branchId,
        documentId: docHeaderId,
        postingDate: businessDate,
        memo: 'COGS for Sale Invoice $docNumber',
        lines: cogsLines,
        createdAt: now,
      );

      await accountingStore.saveJournalEntry(cogsJournal);
    }

    // 11. Save Command Result for Idempotency
    await accountingStore.saveCommandResult(
      CommandResultRecord(
        id: 'cmd_res_${now.microsecondsSinceEpoch}',
        commandId: commandId,
        payloadHash: docHeaderId,
        resultJson: jsonEncode({
          'saleHeaderId': saleId,
          'documentNumber': docNumber,
        }),
        createdAt: now,
      ),
    );

    return header;
  }
}
