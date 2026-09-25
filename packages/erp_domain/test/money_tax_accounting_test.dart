import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Money & Fixed-Point Domain Invariants', () {
    test('handles rupees and paise conversion accurately', () {
      final m1 = Money.fromRupees(100.50);
      expect(m1.paise, equals(10050));
      expect(m1.inRupees, equals(100.50));

      final m2 = Money.fromPaise(5025);
      expect(m2.inRupees, equals(50.25));
    });

    test('allocates invoice discount proportionally using largest-remainder algorithm', () {
      final lineBases = [
        Money.fromRupees(1000.00),
        Money.fromRupees(500.00),
        Money.fromRupees(500.00),
      ];
      final totalDiscount = Money.fromRupees(100.00); // ₹100 discount

      final allocated = Money.allocateProportionally(
        bases: lineBases,
        totalDiscount: totalDiscount,
      );

      expect(allocated.length, equals(3));
      expect(allocated[0].inRupees, equals(50.00));
      expect(allocated[1].inRupees, equals(25.00));
      expect(allocated[2].inRupees, equals(25.00));

      final totalAllocatedPaise = allocated.fold<int>(0, (sum, m) => sum + m.paise);
      expect(totalAllocatedPaise, equals(totalDiscount.paise));
    });
  });

  group('GST Tax Engine Calculations', () {
    const taxEngine = TaxEngine();

    test('calculates 18% Intra-state GST with CGST 9% and SGST 9% split', () {
      final req = TaxLineRequest(
        lineId: 'line_1',
        unitPrice: UnitPrice.fromRupees(1000.00),
        quantity: Quantity.fromUnits(1.0),
        taxRate: TaxRate.gst18,
      );

      final result = taxEngine.calculateInvoiceTax(
        lines: [req],
        supplyType: TaxSupplyType.intraState,
      );

      expect(result.subtotal.inRupees, equals(1000.00));
      expect(result.totalCgst.inRupees, equals(90.00));
      expect(result.totalSgst.inRupees, equals(90.00));
      expect(result.totalIgst.inRupees, equals(0.00));
      expect(result.totalTax.inRupees, equals(180.00));
      expect(result.grandTotal.inRupees, equals(1180.00));
    });

    test('calculates 18% Inter-state GST with IGST 18% split', () {
      final req = TaxLineRequest(
        lineId: 'line_1',
        unitPrice: UnitPrice.fromRupees(1000.00),
        quantity: Quantity.fromUnits(1.0),
        taxRate: TaxRate.gst18,
      );

      final result = taxEngine.calculateInvoiceTax(
        lines: [req],
        supplyType: TaxSupplyType.interState,
      );

      expect(result.totalCgst.inRupees, equals(0.00));
      expect(result.totalSgst.inRupees, equals(0.00));
      expect(result.totalIgst.inRupees, equals(180.00));
      expect(result.grandTotal.inRupees, equals(1180.00));
    });

    test('extracts taxable base from inclusive tax price', () {
      final req = TaxLineRequest(
        lineId: 'line_1',
        unitPrice: UnitPrice.fromRupees(1180.00), // Inclusive of 18% GST
        quantity: Quantity.fromUnits(1.0),
        taxRate: TaxRate.gst18,
        isTaxInclusive: true,
      );

      final result = taxEngine.calculateInvoiceTax(
        lines: [req],
        supplyType: TaxSupplyType.intraState,
      );

      expect(result.subtotal.inRupees, equals(1000.00));
      expect(result.totalTax.inRupees, equals(180.00));
      expect(result.grandTotal.inRupees, equals(1180.00));
    });
  });

  group('Balanced Accounting Journal Invariants', () {
    test('permits balanced journal entry and rejects unbalanced entries', () {
      final now = DateTime.now();
      final validEntry = JournalEntry(
        id: 'je_1',
        organizationId: 'org_1',
        branchId: 'br_1',
        documentId: 'doc_1',
        postingDate: now,
        memo: 'Cash Sale',
        lines: [
          JournalLine(id: 'l1', journalEntryId: 'je_1', accountId: 'acc_cash', debitPaise: 118000),
          JournalLine(id: 'l2', journalEntryId: 'je_1', accountId: 'acc_sales', creditPaise: 100000),
          JournalLine(id: 'l3', journalEntryId: 'je_1', accountId: 'acc_cgst_out', creditPaise: 9000),
          JournalLine(id: 'l4', journalEntryId: 'je_1', accountId: 'acc_sgst_out', creditPaise: 9000),
        ],
        createdAt: now,
      );

      expect(validEntry.lines.length, equals(4));

      expect(() => JournalEntry(
        id: 'je_2',
        organizationId: 'org_1',
        branchId: 'br_1',
        documentId: 'doc_2',
        postingDate: now,
        memo: 'Unbalanced',
        lines: [
          JournalLine(id: 'l1', journalEntryId: 'je_2', accountId: 'acc_cash', debitPaise: 100000),
          JournalLine(id: 'l2', journalEntryId: 'je_2', accountId: 'acc_sales', creditPaise: 50000),
        ],
        createdAt: now,
      ), throwsA(isA<ValidationFailure>()));
    });
  });

  group('Document Sequence Formatting', () {
    test('formats compact document sequence numbers correctly', () {
      const seq = DocumentSequence(
        id: 'seq_1',
        registrationId: 'reg_1',
        fiscalYear: '2026-2027',
        series: 'A',
        nextValue: 1,
      );

      expect(seq.formatNextNumber(), equals('A/2627/000001'));
    });
  });
}
