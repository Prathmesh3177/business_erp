import 'package:business_erp/features/dashboard/dashboard_page.dart';
import 'package:business_erp/features/reports/reports_page.dart';
import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final class _DummyReportStore implements ReportStore {
  @override
  Future<SalesReportSummary> getSalesReport(
    String organizationId,
    ReportDateRange dateRange, {
    String? branchId,
    String? categoryId,
    String? productId,
  }) async {
    return SalesReportSummary(
      dateRange: dateRange,
      items: [],
      totalGrossSales: Money.zero,
      totalDiscounts: Money.zero,
      totalTax: Money.zero,
      totalNetSales: Money.zero,
      totalInvoices: 0,
    );
  }

  @override
  Future<Gstr1Summary> getGstr1Report(
    String organizationId,
    ReportDateRange dateRange,
  ) async {
    return Gstr1Summary(
      dateRange: dateRange,
      b2bTaxableValue: Money.zero,
      b2bCgst: Money.zero,
      b2bSgst: Money.zero,
      b2bIgst: Money.zero,
      b2cLargeTaxableValue: Money.zero,
      b2cLargeCgst: Money.zero,
      b2cLargeSgst: Money.zero,
      b2cLargeIgst: Money.zero,
      b2cSmallTaxableValue: Money.zero,
      b2cSmallCgst: Money.zero,
      b2cSmallSgst: Money.zero,
      b2cSmallIgst: Money.zero,
      hsnSummaries: [],
    );
  }

  @override
  Future<Gstr3bSummary> getGstr3bReport(
    String organizationId,
    ReportDateRange dateRange,
  ) async {
    return Gstr3bSummary(
      dateRange: dateRange,
      outwardTaxableSupplies: Money.zero,
      outwardCgst: Money.zero,
      outwardSgst: Money.zero,
      outwardIgst: Money.zero,
      inwardItcTaxableSupplies: Money.zero,
      inwardCgstItc: Money.zero,
      inwardSgstItc: Money.zero,
      inwardIgstItc: Money.zero,
      netCgstPayable: Money.zero,
      netSgstPayable: Money.zero,
      netIgstPayable: Money.zero,
    );
  }

  @override
  Future<List<StockValuationItem>> getStockValuationReport(
    String organizationId, {
    String? branchId,
    String? categoryId,
  }) async =>
      [];

  @override
  Future<List<ReorderAlertItem>> getReorderAlerts(
    String organizationId, {
    String? branchId,
    int leadTimeDays = 7,
    double defaultSafetyStock = 5.0,
  }) async =>
      [];

  @override
  Future<List<PartyAgeingBucket>> getPartyAgeingReport(
    String organizationId, {
    required bool isCustomer,
  }) async =>
      [];

  @override
  Future<FinancialSummaryReport> getFinancialSummary(
    String organizationId,
    DateTime asOfDateUtc,
  ) async {
    return FinancialSummaryReport(
      asOfDateUtc: asOfDateUtc,
      totalRevenue: Money.zero,
      totalCogs: Money.zero,
      grossProfit: Money.zero,
      totalExpenses: Money.zero,
      netProfit: Money.zero,
      totalAssets: Money.zero,
      totalLiabilities: Money.zero,
      totalEquity: Money.zero,
    );
  }

  @override
  Future<DashboardMetrics> getDashboardMetrics(
    String organizationId, {
    String? branchId,
  }) async {
    return DashboardMetrics(
      todaySales: Money.zero,
      todayCollections: Money.zero,
      lowStockCount: 0,
      totalReceivables: Money.zero,
      totalPayables: Money.zero,
      recentReorderAlerts: [],
    );
  }
}

void main() {
  testWidgets('DashboardPage renders KPI cards and reorder section', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reportStoreProvider.overrideWithValue(_DummyReportStore()),
        ],
        child: const MaterialApp(
          home: DashboardPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Executive Dashboard & BI Overview'), findsOneWidget);
    expect(find.text("Today's Sales"), findsOneWidget);
    expect(find.text("Today's Collections"), findsOneWidget);
    expect(find.text('Low Stock Items'), findsOneWidget);
    expect(find.text('Outstanding Receivables'), findsOneWidget);
  });

  testWidgets('ReportsPage renders tab bar and filter bar', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reportStoreProvider.overrideWithValue(_DummyReportStore()),
        ],
        child: const MaterialApp(
          home: ReportsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reports & Business Intelligence'), findsOneWidget);
    expect(find.text('Sales Summary'), findsOneWidget);
    expect(find.text('GST Returns'), findsOneWidget);
    expect(find.text('Stock Valuation'), findsOneWidget);
    expect(find.text('Party Ageing'), findsOneWidget);
  });
}
