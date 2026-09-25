import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

void main() {
  group('P18 Production Readiness — GST Calculation & Edge Cases Engine Tests', () {
    const taxEngine = TaxEngine();

    test('3.a GST-inclusive back-calculation for MRP ₹1000 with 18% GST matches exact paisa', () {
      final req = TaxLineRequest(
        lineId: 'line_1',
        unitPrice: UnitPrice.fromRupees(1000.0),
        quantity: Quantity.fromUnits(1.0),
        taxRate: TaxRate.gst18,
        isTaxInclusive: true,
      );

      final result = taxEngine.calculateInvoiceTax(
        lines: [req],
        supplyType: TaxSupplyType.intraState,
      );

      final line = result.lineResults.first;
      expect(line.taxableAmount, Money.fromPaise(84746)); // ₹847.46
      expect(line.cgst, Money.fromPaise(7627));          // ₹76.27
      expect(line.sgst, Money.fromPaise(7627));          // ₹76.27
      expect(line.totalTax, Money.fromPaise(15254));      // ₹152.54
      expect(line.totalAmount, Money.fromPaise(100000));  // ₹1000.00 exact!
      expect(result.grandTotal, Money.fromPaise(100000));
    });

    test('3.b GST-exclusive forward calculation for ₹1000 with 18% GST matches exact forward sum', () {
      final req = TaxLineRequest(
        lineId: 'line_1',
        unitPrice: UnitPrice.fromRupees(1000.0),
        quantity: Quantity.fromUnits(1.0),
        taxRate: TaxRate.gst18,
        isTaxInclusive: false,
      );

      final result = taxEngine.calculateInvoiceTax(
        lines: [req],
        supplyType: TaxSupplyType.intraState,
      );

      final line = result.lineResults.first;
      expect(line.taxableAmount, Money.fromPaise(100000)); // ₹1000.00
      expect(line.cgst, Money.fromPaise(9000));           // ₹90.00
      expect(line.sgst, Money.fromPaise(9000));           // ₹90.00
      expect(line.totalTax, Money.fromPaise(18000));       // ₹180.00
      expect(line.totalAmount, Money.fromPaise(118000));   // ₹1180.00
    });

    test('4.b Discounted GST-inclusive price (MRP ₹1000 with 10% discount) recalculates tax on discounted sum', () {
      final req = TaxLineRequest(
        lineId: 'line_1',
        unitPrice: UnitPrice.fromRupees(900.0), // 10% discounted MRP ₹900
        quantity: Quantity.fromUnits(1.0),
        taxRate: TaxRate.gst18,
        isTaxInclusive: true,
      );

      final result = taxEngine.calculateInvoiceTax(
        lines: [req],
        supplyType: TaxSupplyType.intraState,
      );

      final line = result.lineResults.first;
      expect(line.taxableAmount, Money.fromPaise(76271)); // ₹762.71
      expect(line.cgst, Money.fromPaise(6864));          // ₹68.64
      expect(line.sgst, Money.fromPaise(6865));          // ₹68.65
      expect(line.totalTax, Money.fromPaise(13729));      // ₹137.29
      expect(line.totalAmount, Money.fromPaise(90000));   // ₹900.00 exact!
    });

    test('3.d Inter-state supply switches automatically to IGST without CGST/SGST', () {
      final req = TaxLineRequest(
        lineId: 'line_1',
        unitPrice: UnitPrice.fromRupees(1000.0),
        quantity: Quantity.fromUnits(1.0),
        taxRate: TaxRate.gst18,
        isTaxInclusive: true,
      );

      final result = taxEngine.calculateInvoiceTax(
        lines: [req],
        supplyType: TaxSupplyType.interState,
      );

      final line = result.lineResults.first;
      expect(line.cgst, Money.zero);
      expect(line.sgst, Money.zero);
      expect(line.igst, Money.fromPaise(15254)); // ₹152.54 IGST
      expect(result.totalIgst, Money.fromPaise(15254));
    });

    test('3.c Multi-line invoice with mixed GST rates (5%, 12%, 18%, 28%, exempt) reconciles line-level and total taxes', () {
      final lines = [
        TaxLineRequest(
          lineId: 'l1',
          unitPrice: UnitPrice.fromRupees(100.0),
          quantity: Quantity.fromUnits(1.0),
          taxRate: TaxRate.zero,
          isTaxInclusive: false,
        ),
        TaxLineRequest(
          lineId: 'l2',
          unitPrice: UnitPrice.fromRupees(200.0),
          quantity: Quantity.fromUnits(1.0),
          taxRate: TaxRate.fromPercentage(5.0),
          isTaxInclusive: false,
        ),
        TaxLineRequest(
          lineId: 'l3',
          unitPrice: UnitPrice.fromRupees(500.0),
          quantity: Quantity.fromUnits(1.0),
          taxRate: TaxRate.fromPercentage(12.0),
          isTaxInclusive: false,
        ),
        TaxLineRequest(
          lineId: 'l4',
          unitPrice: UnitPrice.fromRupees(1000.0),
          quantity: Quantity.fromUnits(1.0),
          taxRate: TaxRate.gst18,
          isTaxInclusive: false,
        ),
        TaxLineRequest(
          lineId: 'l5',
          unitPrice: UnitPrice.fromRupees(2000.0),
          quantity: Quantity.fromUnits(1.0),
          taxRate: TaxRate.fromPercentage(28.0),
          isTaxInclusive: false,
        ),
      ];

      final result = taxEngine.calculateInvoiceTax(
        lines: lines,
        supplyType: TaxSupplyType.intraState,
      );

      expect(result.lineResults.length, 5);
      final sumLineTaxes = result.lineResults.fold<int>(0, (sum, l) => sum + l.totalTax.paise);
      expect(result.totalTax.paise, sumLineTaxes);
    });
  });
}
