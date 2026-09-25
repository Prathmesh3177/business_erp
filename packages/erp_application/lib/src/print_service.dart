import 'package:erp_domain/erp_domain.dart';
import 'sales_store.dart';

abstract interface class PrintService {
  Future<PrintJob> printInvoice(
    InvoiceViewModel invoice, {
    required String printerName,
    required InvoiceFormat printFormat,
    bool isReprint = false,
  });

  Future<List<PrintJob>> getPrintHistory(String organizationId);
  Future<List<String>> getAvailablePrinters();
}

final class GenerateInvoiceViewModelUseCase {
  const GenerateInvoiceViewModelUseCase({
    required this.salesStore,
  });

  final SalesStore salesStore;

  Future<InvoiceViewModel> call({
    required String saleId,
    required Organization organization,
    required Branch branch,
    Party? customer,
    bool isReprint = false,
    InvoiceLanguage language = InvoiceLanguage.english,
  }) async {
    final saleHeader = await salesStore.getSaleHeader(saleId);
    if (saleHeader == null) {
      throw ValidationFailure('sale_not_found', 'Sales document $saleId not found');
    }

    final lines = await salesStore.getSaleLines(saleId);
    return InvoiceViewModel.fromSale(
      sale: saleHeader,
      lines: lines,
      customer: customer,
      org: organization,
      branch: branch,
      isReprint: isReprint,
      language: language,
    );
  }
}
