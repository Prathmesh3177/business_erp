import 'money.dart';
import 'organization.dart';
import 'party.dart';
import 'sales.dart';

enum InvoiceLanguage { english, marathi, bilingual }
enum InvoiceFormat { a4, thermal58, thermal80 }

final class InvoiceLineViewModel {
  const InvoiceLineViewModel({
    required this.lineId,
    required this.productName,
    required this.sku,
    required this.hsnCode,
    required this.quantityUnits,
    required this.unitPriceRupees,
    required this.discountPaise,
    required this.taxableAmountPaise,
    required this.taxRatePercentage,
    required this.cgstPaise,
    required this.sgstPaise,
    required this.igstPaise,
    required this.totalTaxPaise,
    required this.lineTotalPaise,
    this.serials = const [],
  });

  final String lineId;
  final String productName;
  final String sku;
  final String hsnCode;
  final double quantityUnits;
  final double unitPriceRupees;
  final Money discountPaise;
  final Money taxableAmountPaise;
  final double taxRatePercentage;
  final Money cgstPaise;
  final Money sgstPaise;
  final Money igstPaise;
  final Money totalTaxPaise;
  final Money lineTotalPaise;
  final List<String> serials;
}

final class InvoiceViewModel {
  const InvoiceViewModel({
    required this.invoiceNumber,
    required this.businessDate,
    required this.originalSaleId,
    required this.sellerLegalName,
    required this.sellerDisplayName,
    required this.sellerAddress,
    required this.sellerPhone,
    this.sellerGstin,
    required this.sellerStateCode,
    required this.customerPartyId,
    required this.customerName,
    this.customerAddress,
    this.customerGstin,
    this.customerStateCode,
    this.customerPhone,
    required this.lineItems,
    required this.subtotalPaise,
    required this.totalDiscountPaise,
    required this.taxableAmountPaise,
    required this.cgstPaise,
    required this.sgstPaise,
    required this.igstPaise,
    required this.totalTaxPaise,
    required this.roundOffPaise,
    required this.grandTotalPaise,
    required this.amountPaidPaise,
    required this.balanceDuePaise,
    required this.paymentStatus,
    this.serialsAppendix = const [],
    this.termsAndConditions = const [
      'Goods once sold will not be taken back or exchanged.',
      'Warranty is subject to manufacturer terms.',
      'Subject to Kalamb jurisdiction.',
    ],
    this.templateVersion = 'v1.0',
    this.language = InvoiceLanguage.english,
    this.isReprint = false,
    this.sha256Checksum,
  });

  factory InvoiceViewModel.fromSale({
    required SaleHeader sale,
    required List<SaleLine> lines,
    Party? customer,
    required Organization org,
    required Branch branch,
    bool isReprint = false,
    InvoiceLanguage language = InvoiceLanguage.english,
  }) {
    final lineVms = lines.map((l) {
      final taxable = l.taxSnapshot.taxableAmount;
      final totalTax = l.taxSnapshot.totalTax;
      final ratePct = taxable.paise > 0 ? (totalTax.paise * 100.0 / taxable.paise) : 0.0;

      return InvoiceLineViewModel(
        lineId: l.id,
        productName: l.productName,
        sku: l.sku,
        hsnCode: l.hsnCode,
        quantityUnits: l.quantity.inUnits,
        unitPriceRupees: l.unitPrice.inRupees,
        discountPaise: l.lineDiscountPaise,
        taxableAmountPaise: taxable,
        taxRatePercentage: ratePct,
        cgstPaise: l.taxSnapshot.cgst,
        sgstPaise: l.taxSnapshot.sgst,
        igstPaise: l.taxSnapshot.igst,
        totalTaxPaise: totalTax,
        lineTotalPaise: l.netTotalPaise,
        serials: l.serials,
      );
    }).toList();

    final allSerials = lines.expand((l) => l.serials).toList();
    final statusStr = sale.balanceDuePaise.paise == 0
        ? 'PAID'
        : (sale.amountPaidPaise.paise > 0 ? 'PARTIAL' : 'UNPAID');

    int totalCgst = 0;
    int totalSgst = 0;
    int totalIgst = 0;
    int totalTax = 0;
    int totalTaxable = 0;

    for (final l in lines) {
      totalCgst += l.taxSnapshot.cgst.paise;
      totalSgst += l.taxSnapshot.sgst.paise;
      totalIgst += l.taxSnapshot.igst.paise;
      totalTax += l.taxSnapshot.totalTax.paise;
      totalTaxable += l.taxSnapshot.taxableAmount.paise;
    }

    return InvoiceViewModel(
      invoiceNumber: sale.documentHeaderId,
      businessDate: sale.businessDate,
      originalSaleId: sale.id,
      sellerLegalName: org.legalName,
      sellerDisplayName: org.displayName,
      sellerAddress: 'Rajmata Jijau Chowk, Jantre Plaza, Dhoki Road, Kalamb- 413507',
      sellerPhone: '7020422291 / 9881630001',
      sellerGstin: '27AAAAA0000A1Z5',
      sellerStateCode: '27-Maharashtra',
      customerPartyId: sale.customerPartyId,
      customerName: sale.customerName,
      customerGstin: customer?.gstin,
      customerPhone: null,
      lineItems: lineVms,
      subtotalPaise: sale.subtotalPaise,
      totalDiscountPaise: sale.allocatedDiscountPaise,
      taxableAmountPaise: Money.fromPaise(totalTaxable),
      cgstPaise: Money.fromPaise(totalCgst),
      sgstPaise: Money.fromPaise(totalSgst),
      igstPaise: Money.fromPaise(totalIgst),
      totalTaxPaise: Money.fromPaise(totalTax),
      roundOffPaise: Money.zero,
      grandTotalPaise: sale.grandTotalPaise,
      amountPaidPaise: sale.amountPaidPaise,
      balanceDuePaise: sale.balanceDuePaise,
      paymentStatus: statusStr,
      serialsAppendix: allSerials,
      language: language,
      isReprint: isReprint,
    );
  }

  final String invoiceNumber;
  final DateTime businessDate;
  final String originalSaleId;
  final String sellerLegalName;
  final String sellerDisplayName;
  final String sellerAddress;
  final String sellerPhone;
  final String? sellerGstin;
  final String sellerStateCode;
  final String customerPartyId;
  final String customerName;
  final String? customerAddress;
  final String? customerGstin;
  final String? customerStateCode;
  final String? customerPhone;
  final List<InvoiceLineViewModel> lineItems;
  final Money subtotalPaise;
  final Money totalDiscountPaise;
  final Money taxableAmountPaise;
  final Money cgstPaise;
  final Money sgstPaise;
  final Money igstPaise;
  final Money totalTaxPaise;
  final Money roundOffPaise;
  final Money grandTotalPaise;
  final Money amountPaidPaise;
  final Money balanceDuePaise;
  final String paymentStatus;
  final List<String> serialsAppendix;
  final List<String> termsAndConditions;
  final String templateVersion;
  final InvoiceLanguage language;
  final bool isReprint;
  final String? sha256Checksum;
}
