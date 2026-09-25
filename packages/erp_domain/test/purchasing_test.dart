import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Purchasing Domain Invariants', () {
    test('normalizes external invoice number correctly', () {
      expect(PurchaseHeader.normalizeExternalInvoiceNumber('  inv-2026/001 '), equals('INV-2026/001'));
      expect(PurchaseHeader.normalizeExternalInvoiceNumber('Bill # 9982 '), equals('BILL#9982'));
    });

    test('allocates landed cost by value cleanly with exact total sum', () {
      const engine = TaxEngine();
      final taxResult1 = engine.calculateInvoiceTax(
        lines: [
          TaxLineRequest(
            lineId: 'l1',
            unitPrice: UnitPrice.fromRupees(12000.0),
            quantity: Quantity.fromUnits(10.0),
            taxRate: TaxRate.fromBps(1200),
          ),
        ],
        supplyType: TaxSupplyType.intraState,
      );

      final line1 = PurchaseLine(
        id: 'l1',
        purchaseId: 'p1',
        productId: 'prod1',
        productName: 'Solar Panel 540W',
        sku: 'SP-540',
        quantity: Quantity.fromUnits(10.0),
        unitPurchasePrice: UnitPrice.fromRupees(12000.0),
        discountPaise: Money.zero,
        taxSnapshot: taxResult1.lineResults.first,
        landedCostAllocationPaise: Money.zero,
        netTotalPaise: taxResult1.lineResults.first.totalAmount,
      );

      final taxResult2 = engine.calculateInvoiceTax(
        lines: [
          TaxLineRequest(
            lineId: 'l2',
            unitPrice: UnitPrice.fromRupees(40000.0),
            quantity: Quantity.fromUnits(2.0),
            taxRate: TaxRate.fromBps(1800),
          ),
        ],
        supplyType: TaxSupplyType.intraState,
      );

      final line2 = PurchaseLine(
        id: 'l2',
        purchaseId: 'p1',
        productId: 'prod2',
        productName: 'Inverter 5kW',
        sku: 'INV-5KW',
        quantity: Quantity.fromUnits(2.0),
        unitPurchasePrice: UnitPrice.fromRupees(40000.0),
        discountPaise: Money.zero,
        taxSnapshot: taxResult2.lineResults.first,
        landedCostAllocationPaise: Money.zero,
        netTotalPaise: taxResult2.lineResults.first.totalAmount,
      );

      // Total landed cost 5,000 INR = 500,000 paise
      final totalLandedCost = Money.fromPaise(500000);
      final allocated = LandedCostAllocator.allocate(
        totalLandedCost: totalLandedCost,
        lines: [line1, line2],
        allocationType: LandedCostAllocationType.byValue,
      );

      expect(allocated.length, equals(2));
      // line1 value ratio 120,000 / 200,000 = 60% -> 300,000 paise
      // line2 value ratio 80,000 / 200,000 = 40% -> 200,000 paise
      expect(allocated[0].paise, equals(300000));
      expect(allocated[1].paise, equals(200000));
      expect(allocated[0].paise + allocated[1].paise, equals(totalLandedCost.paise));
    });

    test('allocates landed cost by quantity cleanly', () {
      const engine = TaxEngine();
      final taxResult1 = engine.calculateInvoiceTax(
        lines: [
          TaxLineRequest(
            lineId: 'l1',
            unitPrice: UnitPrice.fromRupees(12000.0),
            quantity: Quantity.fromUnits(10.0),
            taxRate: TaxRate.fromBps(1200),
          ),
        ],
        supplyType: TaxSupplyType.intraState,
      );

      final line1 = PurchaseLine(
        id: 'l1',
        purchaseId: 'p1',
        productId: 'prod1',
        productName: 'Solar Panel 540W',
        sku: 'SP-540',
        quantity: Quantity.fromUnits(10.0),
        unitPurchasePrice: UnitPrice.fromRupees(12000.0),
        discountPaise: Money.zero,
        taxSnapshot: taxResult1.lineResults.first,
        landedCostAllocationPaise: Money.zero,
        netTotalPaise: taxResult1.lineResults.first.totalAmount,
      );

      final taxResult2 = engine.calculateInvoiceTax(
        lines: [
          TaxLineRequest(
            lineId: 'l2',
            unitPrice: UnitPrice.fromRupees(40000.0),
            quantity: Quantity.fromUnits(10.0),
            taxRate: TaxRate.fromBps(1800),
          ),
        ],
        supplyType: TaxSupplyType.intraState,
      );

      final line2 = PurchaseLine(
        id: 'l2',
        purchaseId: 'p1',
        productId: 'prod2',
        productName: 'Inverter 5kW',
        sku: 'INV-5KW',
        quantity: Quantity.fromUnits(10.0),
        unitPurchasePrice: UnitPrice.fromRupees(40000.0),
        discountPaise: Money.zero,
        taxSnapshot: taxResult2.lineResults.first,
        landedCostAllocationPaise: Money.zero,
        netTotalPaise: taxResult2.lineResults.first.totalAmount,
      );

      final totalLandedCost = Money.fromPaise(300000); // 3,000 INR
      final allocated = LandedCostAllocator.allocate(
        totalLandedCost: totalLandedCost,
        lines: [line1, line2],
        allocationType: LandedCostAllocationType.byQuantity,
      );

      expect(allocated.length, equals(2));
      // Quantity 10.0 vs 10.0 -> 50% split each
      expect(allocated[0].paise, equals(150000));
      expect(allocated[1].paise, equals(150000));
      expect(allocated[0].paise + allocated[1].paise, equals(totalLandedCost.paise));
    });
  });
}
