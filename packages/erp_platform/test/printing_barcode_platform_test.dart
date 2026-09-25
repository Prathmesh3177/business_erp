import 'package:erp_domain/erp_domain.dart';
import 'package:erp_platform/erp_platform.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('P09 Platform Printing & Barcode Scanner Tests', () {
    final now = DateTime.now();

    final invoice = InvoiceViewModel(
      invoiceNumber: 'SKS/2627/000001',
      businessDate: now,
      originalSaleId: 'sale_100',
      sellerLegalName: 'Shree Krushna Sales Private Limited',
      sellerDisplayName: 'Shree Krushna Sales',
      sellerAddress: 'Rajmata Jijau Chowk, Jantre Plaza, Kalamb',
      sellerPhone: '7020422291',
      sellerStateCode: '27-Maharashtra',
      customerPartyId: 'party_1',
      customerName: 'Kishor Patil',
      lineItems: [
        InvoiceLineViewModel(
          lineId: 'l1',
          productName: 'Solar Panel 540W Mono PERC',
          sku: 'SP-540',
          hsnCode: '85414011',
          quantityUnits: 10.0,
          unitPriceRupees: 12000.0,
          discountPaise: Money.zero,
          taxableAmountPaise: Money.fromPaise(12000000),
          taxRatePercentage: 12.0,
          cgstPaise: Money.fromPaise(720000),
          sgstPaise: Money.fromPaise(720000),
          igstPaise: Money.zero,
          totalTaxPaise: Money.fromPaise(1440000),
          lineTotalPaise: Money.fromPaise(13440000),
          serials: const ['SN-SP540-001', 'SN-SP540-002'],
        ),
      ],
      subtotalPaise: Money.fromPaise(12000000),
      totalDiscountPaise: Money.zero,
      taxableAmountPaise: Money.fromPaise(12000000),
      cgstPaise: Money.fromPaise(720000),
      sgstPaise: Money.fromPaise(720000),
      igstPaise: Money.zero,
      totalTaxPaise: Money.fromPaise(1440000),
      roundOffPaise: Money.zero,
      grandTotalPaise: Money.fromPaise(13440000),
      amountPaidPaise: Money.fromPaise(13440000),
      balanceDuePaise: Money.zero,
      paymentStatus: 'PAID',
      serialsAppendix: const ['SN-SP540-001', 'SN-SP540-002'],
      isReprint: false,
    );

    test('PdfInvoiceRenderer renders A4 PDF bytes and sha256 checksum', () {
      const renderer = PdfInvoiceRenderer();
      final result = renderer.renderA4Pdf(invoice);

      expect(result.bytes.isNotEmpty, isTrue);
      expect(result.sha256Checksum.length, equals(64));
      expect(result.pageCount, equals(1));
    });

    test('PdfInvoiceRenderer includes duplicate copy watermark when isReprint is true', () {
      const renderer = PdfInvoiceRenderer();
      final reprintInvoice = InvoiceViewModel(
        invoiceNumber: invoice.invoiceNumber,
        businessDate: invoice.businessDate,
        originalSaleId: invoice.originalSaleId,
        sellerLegalName: invoice.sellerLegalName,
        sellerDisplayName: invoice.sellerDisplayName,
        sellerAddress: invoice.sellerAddress,
        sellerPhone: invoice.sellerPhone,
        sellerStateCode: invoice.sellerStateCode,
        customerPartyId: invoice.customerPartyId,
        customerName: invoice.customerName,
        lineItems: invoice.lineItems,
        subtotalPaise: invoice.subtotalPaise,
        totalDiscountPaise: invoice.totalDiscountPaise,
        taxableAmountPaise: invoice.taxableAmountPaise,
        cgstPaise: invoice.cgstPaise,
        sgstPaise: invoice.sgstPaise,
        igstPaise: invoice.igstPaise,
        totalTaxPaise: invoice.totalTaxPaise,
        roundOffPaise: invoice.roundOffPaise,
        grandTotalPaise: invoice.grandTotalPaise,
        amountPaidPaise: invoice.amountPaidPaise,
        balanceDuePaise: invoice.balanceDuePaise,
        paymentStatus: invoice.paymentStatus,
        isReprint: true,
      );

      final result = renderer.renderA4Pdf(reprintInvoice);
      final text = String.fromCharCodes(result.bytes);
      expect(text, contains('DUPLICATE COPY / REPRINT'));
    });

    test('ThermalInvoiceRenderer formats 58mm and 80mm thermal text', () {
      const renderer = ThermalInvoiceRenderer();

      final text58 = renderer.renderThermalText(invoice, format: InvoiceFormat.thermal58);
      expect(text58, contains('Shree Krushna Sales'));
      expect(text58, contains('SKS/2627/000001'));
      expect(text58, contains('Solar Panel'));

      final text80 = renderer.renderThermalText(invoice, format: InvoiceFormat.thermal80);
      expect(text80, contains('Shree Krushna Sales'));
      expect(text80, contains('GRAND TOTAL:'));
    });

    test('DesktopPrintAdapter spools job and handles offline printer failure', () async {
      final adapter = DesktopPrintAdapter();

      final jobOk = await adapter.printInvoice(
        invoice,
        printerName: 'HP LaserJet Pro A4 (Office)',
        printFormat: InvoiceFormat.a4,
      );
      expect(jobOk.status, equals(PrintStatus.accepted));

      final jobFail = await adapter.printInvoice(
        invoice,
        printerName: 'Offline Test Printer (Simulated Fail)',
        printFormat: InvoiceFormat.a4,
      );
      expect(jobFail.status, equals(PrintStatus.failed));
      expect(jobFail.errorMessage, contains('offline'));

      final history = await adapter.getPrintHistory('org_sks');
      expect(history.length, equals(2));
    });

    test('BarcodeScannerBuffer accumulates fast keystrokes and debounces duplicates', () {
      final buffer = BarcodeScannerBuffer(debounceWindowMs: 500);

      // Simulate fast scanning of "SP-540" + Enter
      buffer.processKeyInput('S');
      buffer.processKeyInput('P');
      buffer.processKeyInput('-');
      buffer.processKeyInput('5');
      buffer.processKeyInput('4');
      buffer.processKeyInput('0');
      final result = buffer.processKeyInput('', isEnterKey: true);

      expect(result, isNotNull);
      expect(result?.barcode, equals('SP-540'));
      expect(result?.isHardwareScanner, isTrue);

      // Immediate duplicate scan should be debounced and return null
      buffer.processKeyInput('S');
      buffer.processKeyInput('P');
      buffer.processKeyInput('-');
      buffer.processKeyInput('5');
      buffer.processKeyInput('4');
      buffer.processKeyInput('0');
      final dupResult = buffer.processKeyInput('', isEnterKey: true);

      expect(dupResult, isNull);
    });
  });
}
