import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Inventory Domain Invariants', () {
    final now = DateTime.now();

    test('normalizes serial number to uppercase and rejects empty string', () {
      expect(SerialRecord.normalizeSerialNumber('  sn-12345-abc  '), equals('SN-12345-ABC'));
      expect(() => SerialRecord.normalizeSerialNumber('   '), throwsA(isA<ValidationFailure>()));
    });

    test('computes weighted average unit cost correctly and zeroes out value on full depletion', () {
      var balance = StockBalance(
        productId: 'prod_1',
        locationId: 'loc_1',
        quantityMicroUnits: 0,
        valuePaise: 0,
        updatedAt: now,
      );

      // 1. Receive 10 units at ₹100.00 each (₹1,000.00 total = 100,000 paise)
      final movement1 = StockMovement(
        id: 'm1',
        organizationId: 'org_1',
        branchId: 'branch_1',
        documentId: 'doc_1',
        lineId: 'line_1',
        productId: 'prod_1',
        locationId: 'loc_1',
        quantityMicroUnits: 10000000, // 10 units
        valueDeltaPaise: 100000, // ₹1,000.00
        costSnapshotMicroRupees: 100000000, // ₹100.00
        movementKind: MovementKind.openingStock,
        createdAt: now,
      );
      balance = balance.applyMovement(movement: movement1, updatedAt: now);

      expect(balance.quantityInUnits, equals(10.0));
      expect(balance.valueInRupees, equals(1000.0));
      expect(balance.weightedAverageUnitCostMicroRupees, equals(100000000)); // ₹100.00

      // 2. Receive 5 units at ₹150.00 each (₹750.00 total = 75,000 paise)
      // Total 15 units valued at ₹1,750.00 (175,000 paise)
      final movement2 = StockMovement(
        id: 'm2',
        organizationId: 'org_1',
        branchId: 'branch_1',
        documentId: 'doc_2',
        lineId: 'line_2',
        productId: 'prod_1',
        locationId: 'loc_1',
        quantityMicroUnits: 5000000, // 5 units
        valueDeltaPaise: 75000, // ₹750.00
        costSnapshotMicroRupees: 150000000, // ₹150.00
        movementKind: MovementKind.purchaseReceipt,
        createdAt: now,
      );
      balance = balance.applyMovement(movement: movement2, updatedAt: now);

      expect(balance.quantityInUnits, equals(15.0));
      expect(balance.valueInRupees, equals(1750.0));
      // Average cost = 1750 / 15 = 116.666666... micro rupees
      expect(balance.weightedAverageUnitCostMicroRupees, equals(116666666));

      // 3. Issue 15 units (Full Depletion) -> Stock balance must become 0 Qty and 0 Value
      final movement3 = StockMovement(
        id: 'm3',
        organizationId: 'org_1',
        branchId: 'branch_1',
        documentId: 'doc_3',
        lineId: 'line_3',
        productId: 'prod_1',
        locationId: 'loc_1',
        quantityMicroUnits: -15000000, // -15 units
        valueDeltaPaise: -175000,
        costSnapshotMicroRupees: 116666666,
        movementKind: MovementKind.saleIssue,
        createdAt: now,
      );
      balance = balance.applyMovement(movement: movement3, updatedAt: now);

      expect(balance.quantityMicroUnits, equals(0));
      expect(balance.valuePaise, equals(0)); // Zeroes out rounding residue!
    });

    test('prohibits negative stock issues', () {
      final balance = StockBalance(
        productId: 'prod_1',
        locationId: 'loc_1',
        quantityMicroUnits: 5000000, // 5 units on hand
        valuePaise: 50000,
        updatedAt: now,
      );

      final excessiveIssue = StockMovement(
        id: 'm_fail',
        organizationId: 'org_1',
        branchId: 'branch_1',
        documentId: 'doc_fail',
        lineId: 'line_fail',
        productId: 'prod_1',
        locationId: 'loc_1',
        quantityMicroUnits: -10000000, // Attempt to issue 10 units
        valueDeltaPaise: -100000,
        costSnapshotMicroRupees: 100000000,
        movementKind: MovementKind.saleIssue,
        createdAt: now,
      );

      expect(
        () => balance.applyMovement(movement: excessiveIssue, updatedAt: now),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });
}
