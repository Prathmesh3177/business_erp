import 'package:erp_domain/erp_domain.dart';

abstract interface class ReportStore {
  Future<SalesReportSummary> getSalesReport(
    String organizationId,
    ReportDateRange dateRange, {
    String? branchId,
    String? categoryId,
    String? productId,
  });

  Future<Gstr1Summary> getGstr1Report(
    String organizationId,
    ReportDateRange dateRange,
  );

  Future<Gstr3bSummary> getGstr3bReport(
    String organizationId,
    ReportDateRange dateRange,
  );

  Future<List<StockValuationItem>> getStockValuationReport(
    String organizationId, {
    String? branchId,
    String? categoryId,
  });

  Future<List<ReorderAlertItem>> getReorderAlerts(
    String organizationId, {
    String? branchId,
    int leadTimeDays = 7,
    double defaultSafetyStock = 5.0,
  });

  Future<List<PartyAgeingBucket>> getPartyAgeingReport(
    String organizationId, {
    required bool isCustomer,
  });

  Future<FinancialSummaryReport> getFinancialSummary(
    String organizationId,
    DateTime asOfDateUtc,
  );

  Future<DashboardMetrics> getDashboardMetrics(
    String organizationId, {
    String? branchId,
  });
}
