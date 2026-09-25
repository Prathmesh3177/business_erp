import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Payments & Returns Domain Invariants', () {
    test('SalesReturnLine computes COGS reversal from micro rupees cost snapshot', () {
      final line = SalesReturnLine(
        id: 'ret_line_1',
        salesReturnId: 'ret_1',
        saleLineId: 'sale_line_1',
        productId: 'prod_1',
        productName: 'Solar Panel 540W',
        sku: 'SOL-540',
        quantity: Quantity.fromUnits(2.0),
        unitPrice: UnitPrice.fromRupees(15000.0),
        lineDiscountPaise: Money.zero,
        taxSnapshot: TaxLineResult(
          lineId: 'ret_line_1',
          taxableAmount: Money.fromPaise(3000000),
          cgst: Money.fromPaise(270000),
          sgst: Money.fromPaise(270000),
          igst: Money.zero,
          totalTax: Money.fromPaise(540000),
          totalAmount: Money.fromPaise(3540000),
        ),
        costSnapshotMicroRupees: 12000000000, // ₹12,000 unit cost
        netTotalPaise: Money.fromPaise(3540000),
      );

      // 2 units * ₹12,000 = ₹24,000 = 2,400,000 paise
      expect(line.lineCogsReversalPaise.inRupees, equals(24000.0));
    });

    test('PartyAgingBucket calculates total outstanding across aging buckets', () {
      final bucket = PartyAgingBucket(
        partyId: 'party_1',
        partyName: 'Rahul Sharma',
        days0To30: Money.fromRupees(10000.0),
        days31To60: Money.fromRupees(5000.0),
        days61To90: Money.fromRupees(2000.0),
        days90Plus: Money.fromRupees(1000.0),
      );

      expect(bucket.totalOutstanding.inRupees, equals(18000.0));
    });
  });
}
