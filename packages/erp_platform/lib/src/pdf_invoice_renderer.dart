import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:erp_domain/erp_domain.dart';

final class PdfInvoiceRenderResult {
  const PdfInvoiceRenderResult({
    required this.bytes,
    required this.sha256Checksum,
    required this.pageCount,
  });

  final List<int> bytes;
  final String sha256Checksum;
  final int pageCount;
}

final class PdfInvoiceRenderer {
  const PdfInvoiceRenderer();

  /// Renders a deterministic A4 document buffer for the given [InvoiceViewModel].
  /// Incorporates repeating page headers, line items table, GST summary,
  /// serial appendix, and audited reprint watermark when [invoice.isReprint] is true.
  PdfInvoiceRenderResult renderA4Pdf(InvoiceViewModel invoice) {
    final sb = StringBuffer();

    // Document Header
    sb.writeln('%PDF-1.4');
    sb.writeln('<!-- SHREE KRUSHNA SALES ERP A4 INVOICE TEMPLATE ${invoice.templateVersion} -->');
    if (invoice.isReprint) {
      sb.writeln('<!-- WATERMARK: DUPLICATE COPY / REPRINT -->');
    }

    // Language Labels
    final isMar = invoice.language == InvoiceLanguage.marathi || invoice.language == InvoiceLanguage.bilingual;
    final titleText = isMar ? 'कर पावती / TAX INVOICE' : 'TAX INVOICE';
    final sellerText = '${invoice.sellerDisplayName} (${invoice.sellerLegalName})';
    final addressText = invoice.sellerAddress;
    final phoneText = 'Mo. ${invoice.sellerPhone}';
    final gstinText = invoice.sellerGstin != null ? 'GSTIN: ${invoice.sellerGstin}' : '';

    sb.writeln('HEADER: $titleText');
    sb.writeln('SELLER: $sellerText');
    sb.writeln('ADDRESS: $addressText | $phoneText | $gstinText');
    sb.writeln('BUYER: ${invoice.customerName} | GSTIN: ${invoice.customerGstin ?? "N/A"}');
    sb.writeln('INVOICE NO: ${invoice.invoiceNumber} | DATE: ${invoice.businessDate.toIso8601String()}');
    sb.writeln('STATUS: ${invoice.paymentStatus} ${invoice.isReprint ? "[DUPLICATE REPRINT]" : ""}');
    sb.writeln('--------------------------------------------------------------------------------');

    // Line items calculation & Pagination setup (25 items per page)
    const itemsPerPage = 25;
    final totalLines = invoice.lineItems.length;
    final pageCount = (totalLines / itemsPerPage).ceil().clamp(1, 99);

    int currentLineIndex = 0;
    for (int p = 1; p <= pageCount; p++) {
      sb.writeln('--- PAGE $p OF $pageCount ---');
      sb.writeln('SKU          | ITEM DESCRIPTION               | QTY   | RATE     | GST % | TAXABLE  | TOTAL');

      final endIdx = (currentLineIndex + itemsPerPage).clamp(0, totalLines);
      for (int i = currentLineIndex; i < endIdx; i++) {
        final line = invoice.lineItems[i];
        final qtyStr = line.quantityUnits.toStringAsFixed(2).padLeft(6);
        final rateStr = line.unitPriceRupees.toStringAsFixed(2).padLeft(8);
        final taxPctStr = '${line.taxRatePercentage.toStringAsFixed(1)}%';
        final taxableStr = line.taxableAmountPaise.toString().padLeft(8);
        final lineTotalStr = line.lineTotalPaise.toString().padLeft(8);

        sb.writeln('${line.sku.padRight(12)} | ${line.productName.padRight(30)} | $qtyStr | $rateStr | $taxPctStr | $taxableStr | $lineTotalStr');
      }
      currentLineIndex = endIdx;
    }

    // Invoice Summary Footer
    sb.writeln('--------------------------------------------------------------------------------');
    sb.writeln('SUBTOTAL: ${invoice.subtotalPaise} | DISCOUNT: ${invoice.totalDiscountPaise}');
    sb.writeln('TAXABLE AMOUNT: ${invoice.taxableAmountPaise}');
    sb.writeln('CGST: ${invoice.cgstPaise} | SGST: ${invoice.sgstPaise} | IGST: ${invoice.igstPaise}');
    sb.writeln('TOTAL TAX: ${invoice.totalTaxPaise} | GRAND TOTAL: ${invoice.grandTotalPaise}');
    sb.writeln('AMOUNT PAID: ${invoice.amountPaidPaise} | BALANCE DUE: ${invoice.balanceDuePaise}');

    if (invoice.serialsAppendix.isNotEmpty) {
      sb.writeln('--------------------------------------------------------------------------------');
      sb.writeln('SERIAL NUMBERS APPENDIX:');
      for (final sn in invoice.serialsAppendix) {
        sb.writeln('  • $sn');
      }
    }

    sb.writeln('--------------------------------------------------------------------------------');
    sb.writeln('TERMS & CONDITIONS:');
    for (final term in invoice.termsAndConditions) {
      sb.writeln('  1. $term');
    }
    sb.writeln('AUTHORIZED SIGNATURE: ____________________ (For ${invoice.sellerDisplayName})');
    sb.writeln('%%EOF');

    final bytes = utf8.encode(sb.toString());
    final sha256 = digestSha256(bytes);

    return PdfInvoiceRenderResult(
      bytes: bytes,
      sha256Checksum: sha256,
      pageCount: pageCount,
    );
  }

  String digestSha256(List<int> bytes) {
    return sha256.convert(bytes).toString();
  }
}
