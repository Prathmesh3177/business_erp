import 'package:erp_domain/erp_domain.dart';

import 'command_context.dart';
import 'report_store.dart';

/// CSV Formula Injection Sanitizer.
/// Any string beginning with `=`, `+`, `-`, `@`, `\t`, or `\r` is escaped with a leading `'`
/// to prevent malicious formula execution in Excel/Calc spreadsheets.
String sanitizeCsvCell(String cellValue) {
  if (cellValue.isEmpty) return cellValue;
  final firstChar = cellValue[0];
  if (firstChar == '=' ||
      firstChar == '+' ||
      firstChar == '-' ||
      firstChar == '@' ||
      firstChar == '\t' ||
      firstChar == '\r') {
    return "'$cellValue";
  }
  return cellValue;
}

final class GenerateSalesReportUseCase {
  const GenerateSalesReportUseCase(this._reportStore);

  final ReportStore _reportStore;

  Future<SalesReportSummary> execute({
    required CommandContext context,
    required String organizationId,
    required ReportDateRange dateRange,
    String? branchId,
    String? categoryId,
    String? productId,
  }) async {
    context.requireCapability(Capability.salesCreate);
    final rawSummary = await _reportStore.getSalesReport(
      organizationId,
      dateRange,
      branchId: branchId,
      categoryId: categoryId,
      productId: productId,
    );

    final canReadCost = context.hasCapability(Capability.costDataRead);
    if (canReadCost) {
      return rawSummary;
    }

    // Mask COGS and gross profit for unauthorized roles
    final maskedItems = rawSummary.items.map((item) {
      return SalesReportItem(
        productId: item.productId,
        sku: item.sku,
        productName: item.productName,
        categoryName: item.categoryName,
        quantitySold: item.quantitySold,
        grossSales: item.grossSales,
        discountAmount: item.discountAmount,
        taxAmount: item.taxAmount,
        netSales: item.netSales,
        cogs: null,
        grossProfit: null,
        marginPercentage: null,
      );
    }).toList();

    return SalesReportSummary(
      dateRange: rawSummary.dateRange,
      items: maskedItems,
      totalGrossSales: rawSummary.totalGrossSales,
      totalDiscounts: rawSummary.totalDiscounts,
      totalTax: rawSummary.totalTax,
      totalNetSales: rawSummary.totalNetSales,
      totalInvoices: rawSummary.totalInvoices,
      totalCogs: null,
      totalGrossProfit: null,
      overallMarginPercentage: null,
    );
  }
}

final class GenerateGstrReportUseCase {
  const GenerateGstrReportUseCase(this._reportStore);

  final ReportStore _reportStore;

  Future<Gstr1Summary> getGstr1({
    required CommandContext context,
    required String organizationId,
    required ReportDateRange dateRange,
  }) async {
    context.requireCapability(Capability.salesCreate);
    return _reportStore.getGstr1Report(organizationId, dateRange);
  }

  Future<Gstr3bSummary> getGstr3b({
    required CommandContext context,
    required String organizationId,
    required ReportDateRange dateRange,
  }) async {
    context.requireCapability(Capability.salesCreate);
    return _reportStore.getGstr3bReport(organizationId, dateRange);
  }
}

final class GenerateStockValuationReportUseCase {
  const GenerateStockValuationReportUseCase(this._reportStore);

  final ReportStore _reportStore;

  Future<List<StockValuationItem>> execute({
    required CommandContext context,
    required String organizationId,
    String? branchId,
    String? categoryId,
  }) async {
    context.requireCapability(Capability.inventoryManage);
    final rawItems = await _reportStore.getStockValuationReport(
      organizationId,
      branchId: branchId,
      categoryId: categoryId,
    );

    final canReadCost = context.hasCapability(Capability.costDataRead);
    if (canReadCost) {
      return rawItems;
    }

    return rawItems.map((item) {
      return StockValuationItem(
        productId: item.productId,
        sku: item.sku,
        productName: item.productName,
        categoryName: item.categoryName,
        quantityOnHand: item.quantityOnHand,
        quantityReserved: item.quantityReserved,
        quantityAvailable: item.quantityAvailable,
        unitCost: null,
        totalValuationCost: null,
      );
    }).toList();
  }
}

final class GenerateReorderAlertsUseCase {
  const GenerateReorderAlertsUseCase(this._reportStore);

  final ReportStore _reportStore;

  Future<List<ReorderAlertItem>> execute({
    required CommandContext context,
    required String organizationId,
    String? branchId,
    int leadTimeDays = 7,
    double defaultSafetyStock = 5.0,
  }) async {
    context.requireCapability(Capability.inventoryManage);
    return _reportStore.getReorderAlerts(
      organizationId,
      branchId: branchId,
      leadTimeDays: leadTimeDays,
      defaultSafetyStock: defaultSafetyStock,
    );
  }
}

final class GeneratePartyAgeingReportUseCase {
  const GeneratePartyAgeingReportUseCase(this._reportStore);

  final ReportStore _reportStore;

  Future<List<PartyAgeingBucket>> execute({
    required CommandContext context,
    required String organizationId,
    required bool isCustomer,
  }) async {
    context.requireCapability(Capability.salesCreate);
    return _reportStore.getPartyAgeingReport(organizationId, isCustomer: isCustomer);
  }
}

final class GenerateFinancialSummaryUseCase {
  const GenerateFinancialSummaryUseCase(this._reportStore);

  final ReportStore _reportStore;

  Future<FinancialSummaryReport> execute({
    required CommandContext context,
    required String organizationId,
    required DateTime asOfDateUtc,
  }) async {
    context.requireCapability(Capability.costDataRead);
    return _reportStore.getFinancialSummary(organizationId, asOfDateUtc);
  }
}

final class GenerateDashboardMetricsUseCase {
  const GenerateDashboardMetricsUseCase(this._reportStore);

  final ReportStore _reportStore;

  Future<DashboardMetrics> execute({
    required CommandContext context,
    required String organizationId,
    String? branchId,
  }) async {
    return _reportStore.getDashboardMetrics(organizationId, branchId: branchId);
  }
}

final class ExportReportToCsvUseCase {
  const ExportReportToCsvUseCase();

  String generateCsv({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    final buffer = StringBuffer();
    // Headers
    buffer.writeln(headers.map((h) => _formatCsvCell(h)).join(','));
    // Rows
    for (final row in rows) {
      final sanitizedRow = row.map((cell) => _formatCsvCell(sanitizeCsvCell(cell)));
      buffer.writeln(sanitizedRow.join(','));
    }
    return buffer.toString();
  }

  String _formatCsvCell(String cell) {
    if (cell.contains(',') || cell.contains('"') || cell.contains('\n')) {
      final escaped = cell.replaceAll('"', '""');
      return '"$escaped"';
    }
    return cell;
  }
}
