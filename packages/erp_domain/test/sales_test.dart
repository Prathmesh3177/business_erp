import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Sales Domain Invariants', () {
    test('computes sale line extended price, taxable amount and COGS correctly', () {
      final taxResult = const TaxEngine().calculateInvoiceTax(
        lines: [
          TaxLineRequest(
            lineId: 'l1',
            unitPrice: UnitPrice.fromRupees(15000.0),
            quantity: Quantity.fromUnits(2.0),
            taxRate: TaxRate.fromBps(1800),
            lineDiscount: Money.fromPaise(100000), // ₹1,000.00 discount
          ),
        ],
        supplyType: TaxSupplyType.intraState,
      );

      final line = SaleLine(
        id: 'l1',
        saleId: 's1',
        productId: 'p1',
        productName: 'Solar Panel 540W Mono PERC',
        sku: 'SP-540',
        hsnCode: '85414011',
        baseUnit: 'NOS',
        quantity: Quantity.fromUnits(2.0),
        unitPrice: UnitPrice.fromRupees(15000.0),
        lineDiscountPaise: Money.fromPaise(100000), // ₹1,000.00
        taxSnapshot: taxResult.lineResults.first,
        costSnapshotMicroRupees: 11000000000, // ₹11,000.00 weighted avg cost
        netTotalPaise: taxResult.lineResults.first.totalAmount,
        serials: const ['SN-PANEL-100', 'SN-PANEL-101'],
      );

      // Gross subtotal before discount: 2 * 15,000 = 30,000 INR = 3,000,000 paise
      expect(line.subtotalBeforeDiscountPaise.paise, equals(3000000));
      // Taxable amount: 3,000,000 - 100,000 = 2,900,000 paise
      expect(line.taxableAmountPaise.paise, equals(2900000));
      // COGS: 2 * 11,000 = 22,000 INR = 2,200,000 paise
      expect(line.lineCogsPaise.paise, equals(2200000));
    });

    test('constructs warranty entitlement with correct coverage dates', () {
      final now = DateTime.now();
      final entitlement = WarrantyEntitlement(
        id: 'w1',
        serialId: 'sn1',
        productId: 'p1',
        serialNumber: 'SN-PANEL-100',
        partyId: 'cust1',
        saleDocumentId: 'doc1',
        startDate: now,
        endDate: now.add(const Duration(days: 365 * 25)), // 25 years solar panel performance warranty
        termsSnapshot: 'Standard 25-Year Performance Warranty',
        createdAtUtc: now,
      );

      expect(entitlement.serialNumber, equals('SN-PANEL-100'));
      expect(entitlement.endDate.difference(entitlement.startDate).inDays, greaterThanOrEqualTo(9000));
    });
  });
}
