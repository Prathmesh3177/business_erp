import 'package:erp_domain/erp_domain.dart';

import 'accounting_store.dart';
import 'command_context.dart';
import 'inventory_store.dart';

final class PostOpeningStockUseCase {
  const PostOpeningStockUseCase({
    required InventoryStore inventoryStore,
    required AccountingStore accountingStore,
  })  : _inventoryStore = inventoryStore,
        _accountingStore = accountingStore;

  final InventoryStore _inventoryStore;
  final AccountingStore _accountingStore;

  Future<StockBalance> execute(
    CommandContext context, {
    required String organizationId,
    required String branchId,
    required String productId,
    required String locationId,
    required Quantity quantity,
    required Money totalValue,
    List<String> serialNumbers = const [],
    required String commandId,
  }) async {
    context.requireCapability(Capability.inventoryManage);

    if (quantity.microUnits <= 0) {
      throw const ValidationFailure('invalid_opening_quantity', 'Opening stock quantity must be positive.');
    }
    if (totalValue.paise < 0) {
      throw const ValidationFailure('invalid_opening_value', 'Opening stock value cannot be negative.');
    }

    final now = DateTime.now();
    final documentId = 'doc_op_stock_${now.millisecondsSinceEpoch}';

    // Calculate unit cost in micro-rupees
    final unitCostMicroRupees = (totalValue.paise * 10000000000) ~/ quantity.microUnits;

    final movement = StockMovement(
      id: 'mv_op_${now.microsecondsSinceEpoch}',
      organizationId: organizationId,
      branchId: branchId,
      documentId: documentId,
      lineId: 'line_1',
      productId: productId,
      locationId: locationId,
      quantityMicroUnits: quantity.microUnits,
      valueDeltaPaise: totalValue.paise,
      costSnapshotMicroRupees: unitCostMicroRupees,
      movementKind: MovementKind.openingStock,
      createdAt: now,
    );

    // Save movement
    await _inventoryStore.saveStockMovement(movement);

    // Apply movement to stock balance
    final currentBal = await _inventoryStore.getStockBalance(productId, locationId) ??
        StockBalance(
          productId: productId,
          locationId: locationId,
          quantityMicroUnits: 0,
          valuePaise: 0,
          updatedAt: now,
        );

    final updatedBal = currentBal.applyMovement(movement: movement, updatedAt: now);
    await _inventoryStore.saveStockBalance(updatedBal);

    // Process Serials if provided
    for (final rawSerial in serialNumbers) {
      final normalized = SerialRecord.normalizeSerialNumber(rawSerial);
      final existing = await _inventoryStore.getSerialByNumber(organizationId, productId, normalized);
      if (existing != null) {
        throw ConflictFailure(
          'duplicate_serial',
          'Serial number $normalized already exists for product $productId.',
        );
      }

      final serialId = 'sn_${now.microsecondsSinceEpoch}_${normalized.hashCode}';
      final serialRecord = SerialRecord(
        id: serialId,
        organizationId: organizationId,
        productId: productId,
        serialNumber: normalized,
        state: SerialState.inStock,
        locationId: locationId,
        updatedAt: now,
      );
      await _inventoryStore.saveSerialRecord(serialRecord);

      final event = SerialEvent(
        id: 'se_${now.microsecondsSinceEpoch}_${normalized.hashCode}',
        serialId: serialId,
        fromState: SerialState.inStock,
        toState: SerialState.inStock,
        documentId: documentId,
        createdAt: now,
      );
      await _inventoryStore.saveSerialEvent(event);
    }

    // Post balanced double-entry journal
    // Debit 1200 Merchandise Inventory, Credit 3010 Opening Balance Equity
    final journalEntry = JournalEntry(
      id: 'je_op_stock_${now.millisecondsSinceEpoch}',
      organizationId: organizationId,
      branchId: branchId,
      documentId: documentId,
      postingDate: now,
      memo: 'Opening Stock Journal Entry for Product $productId',
      lines: [
        JournalLine(
          id: 'jl_1',
          journalEntryId: 'je_op_stock_${now.millisecondsSinceEpoch}',
          accountId: 'acc_inv', // 1200 Inventory
          debitPaise: totalValue.paise,
        ),
        JournalLine(
          id: 'jl_2',
          journalEntryId: 'je_op_stock_${now.millisecondsSinceEpoch}',
          accountId: 'acc_equity', // 3010 Opening Balance Equity
          creditPaise: totalValue.paise,
        ),
      ],
      createdAt: now,
    );

    await _accountingStore.saveJournalEntry(journalEntry);

    return updatedBal;
  }
}

final class PostStockAdjustmentUseCase {
  const PostStockAdjustmentUseCase({
    required InventoryStore inventoryStore,
    required AccountingStore accountingStore,
  })  : _inventoryStore = inventoryStore,
        _accountingStore = accountingStore;

  final InventoryStore _inventoryStore;
  final AccountingStore _accountingStore;

  Future<StockBalance> execute(
    CommandContext context, {
    required String organizationId,
    required String branchId,
    required String productId,
    required String locationId,
    required int quantityDeltaMicroUnits,
    required String reason,
    required String approvedByUserId,
  }) async {
    context.requireCapability(Capability.inventoryManage);

    if (quantityDeltaMicroUnits == 0) {
      throw const ValidationFailure('zero_adjustment', 'Stock adjustment quantity cannot be zero.');
    }
    if (reason.trim().isEmpty) {
      throw const ValidationFailure('empty_reason', 'Stock adjustment requires a valid reason.');
    }

    final now = DateTime.now();
    final documentId = 'doc_adj_${now.millisecondsSinceEpoch}';

    final currentBal = await _inventoryStore.getStockBalance(productId, locationId) ??
        StockBalance(
          productId: productId,
          locationId: locationId,
          quantityMicroUnits: 0,
          valuePaise: 0,
          updatedAt: now,
        );

    final currentCostMicroRupees = currentBal.weightedAverageUnitCostMicroRupees;
    final valueDeltaPaise = (quantityDeltaMicroUnits * currentCostMicroRupees) ~/ 10000000000;

    final isSurplus = quantityDeltaMicroUnits > 0;
    final movementKind = isSurplus ? MovementKind.adjustmentIn : MovementKind.adjustmentOut;

    final movement = StockMovement(
      id: 'mv_adj_${now.microsecondsSinceEpoch}',
      organizationId: organizationId,
      branchId: branchId,
      documentId: documentId,
      lineId: 'line_1',
      productId: productId,
      locationId: locationId,
      quantityMicroUnits: quantityDeltaMicroUnits,
      valueDeltaPaise: valueDeltaPaise,
      costSnapshotMicroRupees: currentCostMicroRupees,
      movementKind: movementKind,
      createdAt: now,
    );

    final updatedBal = currentBal.applyMovement(movement: movement, updatedAt: now);
    await _inventoryStore.saveStockMovement(movement);
    await _inventoryStore.saveStockBalance(updatedBal);

    final adjustment = StockAdjustment(
      id: 'adj_${now.millisecondsSinceEpoch}',
      organizationId: organizationId,
      branchId: branchId,
      productId: productId,
      locationId: locationId,
      quantityDeltaMicroUnits: quantityDeltaMicroUnits,
      valueDeltaPaise: valueDeltaPaise,
      reason: reason,
      approvedByUserId: approvedByUserId,
      createdAt: now,
    );
    await _inventoryStore.saveStockAdjustment(adjustment);

    // Journal Entry: Surplus (Dr Inv, Cr Equity/Gain) vs Shrinkage (Dr COGS, Cr Inv)
    final absValuePaise = valueDeltaPaise.abs();
    if (absValuePaise > 0) {
      final debitAccountId = isSurplus ? 'acc_inv' : 'acc_cogs';
      final creditAccountId = isSurplus ? 'acc_equity' : 'acc_inv';

      final journalEntry = JournalEntry(
        id: 'je_adj_${now.millisecondsSinceEpoch}',
        organizationId: organizationId,
        branchId: branchId,
        documentId: documentId,
        postingDate: now,
        memo: 'Stock Adjustment (${isSurplus ? "Surplus" : "Shrinkage"}): $reason',
        lines: [
          JournalLine(
            id: 'jl_1',
            journalEntryId: 'je_adj_${now.millisecondsSinceEpoch}',
            accountId: debitAccountId,
            debitPaise: absValuePaise,
          ),
          JournalLine(
            id: 'jl_2',
            journalEntryId: 'je_adj_${now.millisecondsSinceEpoch}',
            accountId: creditAccountId,
            creditPaise: absValuePaise,
          ),
        ],
        createdAt: now,
      );
      await _accountingStore.saveJournalEntry(journalEntry);
    }

    return updatedBal;
  }
}

final class TransferStockUseCase {
  const TransferStockUseCase(this._inventoryStore);

  final InventoryStore _inventoryStore;

  Future<void> execute(
    CommandContext context, {
    required String organizationId,
    required String branchId,
    required String productId,
    required String fromLocationId,
    required String toLocationId,
    required Quantity quantity,
    List<String> serialNumbers = const [],
  }) async {
    context.requireCapability(Capability.inventoryManage);

    if (fromLocationId == toLocationId) {
      throw const ValidationFailure('same_location_transfer', 'Source and destination locations must be different.');
    }
    if (quantity.microUnits <= 0) {
      throw const ValidationFailure('invalid_transfer_quantity', 'Transfer quantity must be positive.');
    }

    final now = DateTime.now();
    final documentId = 'doc_trf_${now.millisecondsSinceEpoch}';

    final sourceBal = await _inventoryStore.getStockBalance(productId, fromLocationId);
    if (sourceBal == null || sourceBal.quantityMicroUnits < quantity.microUnits) {
      final avail = (sourceBal?.quantityMicroUnits ?? 0) / 1000000.0;
      throw ValidationFailure(
        'insufficient_stock_transfer',
        'Cannot transfer ${quantity.inUnits} units. Source location has only $avail units available.',
      );
    }

    final currentCostMicroRupees = sourceBal.weightedAverageUnitCostMicroRupees;
    final transferValuePaise = (quantity.microUnits * currentCostMicroRupees) ~/ 10000000000;

    // Movement 1: Outflow from source
    final outMovement = StockMovement(
      id: 'mv_trf_out_${now.microsecondsSinceEpoch}',
      organizationId: organizationId,
      branchId: branchId,
      documentId: documentId,
      lineId: 'line_out',
      productId: productId,
      locationId: fromLocationId,
      quantityMicroUnits: -quantity.microUnits,
      valueDeltaPaise: -transferValuePaise,
      costSnapshotMicroRupees: currentCostMicroRupees,
      movementKind: MovementKind.transferOut,
      createdAt: now,
    );

    // Movement 2: Inflow into destination
    final inMovement = StockMovement(
      id: 'mv_trf_in_${now.microsecondsSinceEpoch}',
      organizationId: organizationId,
      branchId: branchId,
      documentId: documentId,
      lineId: 'line_in',
      productId: productId,
      locationId: toLocationId,
      quantityMicroUnits: quantity.microUnits,
      valueDeltaPaise: transferValuePaise,
      costSnapshotMicroRupees: currentCostMicroRupees,
      movementKind: MovementKind.transferIn,
      createdAt: now,
    );

    await _inventoryStore.saveStockMovement(outMovement);
    await _inventoryStore.saveStockMovement(inMovement);

    final destBal = await _inventoryStore.getStockBalance(productId, toLocationId) ??
        StockBalance(
          productId: productId,
          locationId: toLocationId,
          quantityMicroUnits: 0,
          valuePaise: 0,
          updatedAt: now,
        );

    final updatedSourceBal = sourceBal.applyMovement(movement: outMovement, updatedAt: now);
    final updatedDestBal = destBal.applyMovement(movement: inMovement, updatedAt: now);

    await _inventoryStore.saveStockBalance(updatedSourceBal);
    await _inventoryStore.saveStockBalance(updatedDestBal);

    // Update Serial locations if serialized
    for (final rawSerial in serialNumbers) {
      final normalized = SerialRecord.normalizeSerialNumber(rawSerial);
      final serialRecord = await _inventoryStore.getSerialByNumber(organizationId, productId, normalized);
      if (serialRecord != null) {
        final updatedSerial = SerialRecord(
          id: serialRecord.id,
          organizationId: serialRecord.organizationId,
          productId: serialRecord.productId,
          serialNumber: serialRecord.serialNumber,
          state: serialRecord.state,
          locationId: toLocationId,
          batchId: serialRecord.batchId,
          updatedAt: now,
        );
        await _inventoryStore.saveSerialRecord(updatedSerial);
      }
    }
  }
}

final class ReserveStockUseCase {
  const ReserveStockUseCase(this._inventoryStore);

  final InventoryStore _inventoryStore;

  Future<Reservation> execute(
    CommandContext context, {
    required String organizationId,
    required String branchId,
    required String productId,
    required Quantity quantity,
    DateTime? expiresAt,
    String? projectId,
  }) async {
    context.requireCapability(Capability.inventoryManage);

    // Check availability across sellable locations
    final balances = await _inventoryStore.getStockBalancesForProduct(organizationId, productId);
    final sellableOnHand = balances.fold<int>(0, (sum, b) => sum + b.quantityMicroUnits);

    final activeReservations = await _inventoryStore.getActiveReservationsForProduct(organizationId, productId);
    final reservedUnits = activeReservations.fold<int>(0, (sum, r) => sum + r.quantityMicroUnits);

    final availableMicroUnits = sellableOnHand - reservedUnits;

    if (availableMicroUnits < quantity.microUnits) {
      throw ValidationFailure(
        'insufficient_available_stock',
        'Cannot reserve ${quantity.inUnits} units. Available sellable stock is ${(availableMicroUnits / 1000000.0).toStringAsFixed(2)} units.',
      );
    }

    final now = DateTime.now();
    final reservation = Reservation(
      id: 'res_${now.microsecondsSinceEpoch}',
      organizationId: organizationId,
      branchId: branchId,
      productId: productId,
      quantityMicroUnits: quantity.microUnits,
      expiresAt: expiresAt,
      projectId: projectId,
      createdAt: now,
    );

    await _inventoryStore.saveReservation(reservation);
    return reservation;
  }
}

final class RebuildStockLedgerUseCase {
  const RebuildStockLedgerUseCase(this._inventoryStore);

  final InventoryStore _inventoryStore;

  Future<List<StockBalance>> execute(CommandContext context, {required String organizationId}) async {
    context.requireCapability(Capability.inventoryManage);
    return _inventoryStore.rebuildStockBalances(organizationId);
  }
}
