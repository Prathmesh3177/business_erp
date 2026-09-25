import 'errors.dart';

enum LocationType { sellable, quarantine, transit }

final class Location {
  const Location({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.name,
    this.type = LocationType.sellable,
    this.active = true,
  });

  final String id;
  final String organizationId;
  final String branchId;
  final String name;
  final LocationType type;
  final bool active;
}

enum MovementKind {
  openingStock,
  purchaseReceipt,
  saleIssue,
  transferOut,
  transferIn,
  adjustmentIn,
  adjustmentOut,
  saleReturn,
  purchaseReturn,
}

final class StockMovement {
  const StockMovement({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.documentId,
    required this.lineId,
    required this.productId,
    required this.locationId,
    this.batchId,
    required this.quantityMicroUnits,
    required this.valueDeltaPaise,
    required this.costSnapshotMicroRupees,
    required this.movementKind,
    required this.createdAt,
  });

  final String id;
  final String organizationId;
  final String branchId;
  final String documentId;
  final String lineId;
  final String productId;
  final String locationId;
  final String? batchId;
  final int quantityMicroUnits; // Signed: + for receipt, - for issue
  final int valueDeltaPaise; // Signed: + for receipt, - for issue
  final int costSnapshotMicroRupees;
  final MovementKind movementKind;
  final DateTime createdAt;

  double get quantityInUnits => quantityMicroUnits / 1000000.0;
  double get valueDeltaInRupees => valueDeltaPaise / 100.0;
}

final class StockBalance {
  const StockBalance({
    required this.productId,
    required this.locationId,
    required this.quantityMicroUnits,
    required this.valuePaise,
    required this.updatedAt,
  });

  final String productId;
  final String locationId;
  final int quantityMicroUnits;
  final int valuePaise;
  final DateTime updatedAt;

  double get quantityInUnits => quantityMicroUnits / 1000000.0;
  double get valueInRupees => valuePaise / 100.0;

  int get weightedAverageUnitCostMicroRupees {
    if (quantityMicroUnits <= 0) return 0;
    return (valuePaise * 10000000000) ~/ quantityMicroUnits;
  }

  StockBalance applyMovement({
    required StockMovement movement,
    required DateTime updatedAt,
  }) {
    final newQty = quantityMicroUnits + movement.quantityMicroUnits;
    if (newQty < 0) {
      throw ValidationFailure(
        'negative_stock_prohibited',
        'Stock issue of ${(movement.quantityMicroUnits.abs() / 1000000.0).toStringAsFixed(2)} units exceeds available stock of ${(quantityMicroUnits / 1000000.0).toStringAsFixed(2)} units.',
      );
    }

    int newValue = valuePaise + movement.valueDeltaPaise;
    if (newQty == 0) {
      newValue = 0; // Clean up any residual rounding paise on full depletion
    }

    return StockBalance(
      productId: productId,
      locationId: locationId,
      quantityMicroUnits: newQty,
      valuePaise: newValue,
      updatedAt: updatedAt,
    );
  }
}

enum SerialState { inStock, reserved, sold, quarantined, scrapped }

final class SerialRecord {
  const SerialRecord({
    required this.id,
    required this.organizationId,
    required this.productId,
    required this.serialNumber,
    this.state = SerialState.inStock,
    this.locationId,
    this.batchId,
    required this.updatedAt,
  });

  final String id;
  final String organizationId;
  final String productId;
  final String serialNumber;
  final SerialState state;
  final String? locationId;
  final String? batchId;
  final DateTime updatedAt;

  static String normalizeSerialNumber(String raw) {
    final normalized = raw.trim().toUpperCase();
    if (normalized.isEmpty) {
      throw const ValidationFailure('empty_serial_number', 'Serial number cannot be empty.');
    }
    return normalized;
  }
}

final class SerialEvent {
  const SerialEvent({
    required this.id,
    required this.serialId,
    required this.fromState,
    required this.toState,
    required this.documentId,
    required this.createdAt,
  });

  final String id;
  final String serialId;
  final SerialState fromState;
  final SerialState toState;
  final String documentId;
  final DateTime createdAt;
}

final class BatchRecord {
  const BatchRecord({
    required this.id,
    required this.organizationId,
    required this.productId,
    required this.lotNumber,
    this.expiryDate,
    this.supplierPartyId,
    required this.createdAt,
  });

  final String id;
  final String organizationId;
  final String productId;
  final String lotNumber;
  final DateTime? expiryDate;
  final String? supplierPartyId;
  final DateTime createdAt;
}

enum ReservationStatus { active, fulfilled, cancelled, expired }

final class Reservation {
  const Reservation({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.productId,
    required this.quantityMicroUnits,
    this.status = ReservationStatus.active,
    this.expiresAt,
    this.projectId,
    required this.createdAt,
  });

  final String id;
  final String organizationId;
  final String branchId;
  final String productId;
  final int quantityMicroUnits;
  final ReservationStatus status;
  final DateTime? expiresAt;
  final String? projectId;
  final DateTime createdAt;

  double get quantityInUnits => quantityMicroUnits / 1000000.0;
}

final class StockAdjustment {
  const StockAdjustment({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.productId,
    required this.locationId,
    required this.quantityDeltaMicroUnits,
    required this.valueDeltaPaise,
    required this.reason,
    required this.approvedByUserId,
    required this.createdAt,
  });

  final String id;
  final String organizationId;
  final String branchId;
  final String productId;
  final String locationId;
  final int quantityDeltaMicroUnits;
  final int valueDeltaPaise;
  final String reason;
  final String approvedByUserId;
  final DateTime createdAt;
}
