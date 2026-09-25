import 'money.dart';

enum TaxSupplyType { intraState, interState }

final class TaxLineRequest {
  const TaxLineRequest({
    required this.lineId,
    required this.unitPrice,
    required this.quantity,
    required this.taxRate,
    this.lineDiscount = Money.zero,
    this.isTaxInclusive = false,
  });

  final String lineId;
  final UnitPrice unitPrice;
  final Quantity quantity;
  final TaxRate taxRate;
  final Money lineDiscount;
  final bool isTaxInclusive;
}

final class TaxLineResult {
  const TaxLineResult({
    required this.lineId,
    required this.taxableAmount,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.totalTax,
    required this.totalAmount,
  });

  final String lineId;
  final Money taxableAmount;
  final Money cgst;
  final Money sgst;
  final Money igst;
  final Money totalTax;
  final Money totalAmount;
}

final class TaxInvoiceResult {
  const TaxInvoiceResult({
    required this.lineResults,
    required this.subtotal,
    required this.allocatedDiscount,
    required this.totalCgst,
    required this.totalSgst,
    required this.totalIgst,
    required this.totalTax,
    required this.roundOff,
    required this.grandTotal,
  });

  final List<TaxLineResult> lineResults;
  final Money subtotal;
  final Money allocatedDiscount;
  final Money totalCgst;
  final Money totalSgst;
  final Money totalIgst;
  final Money totalTax;
  final Money roundOff; // Positive or negative (e.g. +0.20 or -0.40)
  final Money grandTotal;
}

final class TaxEngine {
  const TaxEngine();

  /// Computes deterministic line taxes and invoice totals according to Indian GST rules.
  TaxInvoiceResult calculateInvoiceTax({
    required List<TaxLineRequest> lines,
    required TaxSupplyType supplyType,
    Money invoiceDiscount = Money.zero,
  }) {
    if (lines.isEmpty) {
      return TaxInvoiceResult(
        lineResults: const [],
        subtotal: Money.zero,
        allocatedDiscount: Money.zero,
        totalCgst: Money.zero,
        totalSgst: Money.zero,
        totalIgst: Money.zero,
        totalTax: Money.zero,
        roundOff: Money.zero,
        grandTotal: Money.zero,
      );
    }

    // Step 1: Calculate raw line extended prices before invoice discount
    final lineRawBases = <Money>[];
    for (final req in lines) {
      final grossRupees = req.unitPrice.inRupees * req.quantity.inUnits;
      final grossPaise = (grossRupees * 100).round();

      if (req.isTaxInclusive && req.taxRate.bps > 0) {
        // Extract taxable base from inclusive gross: Base = Gross / (1 + Rate)
        final rateFactor = 1.0 + (req.taxRate.bps / 10000.0);
        final basePaise = (grossPaise / rateFactor).round();
        final afterLineDisc = basePaise - req.lineDiscount.paise;
        lineRawBases.add(Money.fromPaise(afterLineDisc > 0 ? afterLineDisc : 0));
      } else {
        final afterLineDisc = grossPaise - req.lineDiscount.paise;
        lineRawBases.add(Money.fromPaise(afterLineDisc > 0 ? afterLineDisc : 0));
      }
    }

    // Step 2: Allocate invoice discount proportionally across lines using largest-remainder
    final allocatedDiscounts = Money.allocateProportionally(
      bases: lineRawBases,
      totalDiscount: invoiceDiscount,
    );

    final lineResults = <TaxLineResult>[];
    int sumSubtotalPaise = 0;
    int sumCgstPaise = 0;
    int sumSgstPaise = 0;
    int sumIgstPaise = 0;

    // Step 3: Compute exact GST taxes per line
    for (int i = 0; i < lines.length; i++) {
      final req = lines[i];
      final netTaxablePaise = lineRawBases[i].paise - allocatedDiscounts[i].paise;
      final taxableAmount = Money.fromPaise(netTaxablePaise > 0 ? netTaxablePaise : 0);

      sumSubtotalPaise += taxableAmount.paise;

      final totalTaxPaise = (taxableAmount.paise * req.taxRate.bps / 10000.0).round();

      Money cgst = Money.zero;
      Money sgst = Money.zero;
      Money igst = Money.zero;

      if (supplyType == TaxSupplyType.intraState) {
        final cgstPaise = totalTaxPaise ~/ 2;
        final sgstPaise = totalTaxPaise - cgstPaise; // Guarantees sum == totalTax
        cgst = Money.fromPaise(cgstPaise);
        sgst = Money.fromPaise(sgstPaise);
        sumCgstPaise += cgstPaise;
        sumSgstPaise += sgstPaise;
      } else {
        igst = Money.fromPaise(totalTaxPaise);
        sumIgstPaise += totalTaxPaise;
      }

      final lineTotalAmount = Money.fromPaise(taxableAmount.paise + totalTaxPaise);

      lineResults.add(TaxLineResult(
        lineId: req.lineId,
        taxableAmount: taxableAmount,
        cgst: cgst,
        sgst: sgst,
        igst: igst,
        totalTax: Money.fromPaise(totalTaxPaise),
        totalAmount: lineTotalAmount,
      ));
    }

    final totalTaxSumPaise = sumCgstPaise + sumSgstPaise + sumIgstPaise;
    final exactUnroundedGrandPaise = sumSubtotalPaise + totalTaxSumPaise;

    // Step 4: Round-off to nearest whole rupee
    final roundedGrandPaise = (exactUnroundedGrandPaise / 100.0).round() * 100;
    final roundOffPaise = roundedGrandPaise - exactUnroundedGrandPaise;

    return TaxInvoiceResult(
      lineResults: lineResults,
      subtotal: Money.fromPaise(sumSubtotalPaise),
      allocatedDiscount: invoiceDiscount,
      totalCgst: Money.fromPaise(sumCgstPaise),
      totalSgst: Money.fromPaise(sumSgstPaise),
      totalIgst: Money.fromPaise(sumIgstPaise),
      totalTax: Money.fromPaise(totalTaxSumPaise),
      roundOff: Money.fromPaise(roundOffPaise),
      grandTotal: Money.fromPaise(roundedGrandPaise),
    );
  }
}
