import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

final class _MockReportStore implements ReportStore {
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
      items: [
        SalesReportItem(
          productId: 'prod_1',
          sku: 'SOLAR-PANEL-540W',
          productName: 'Mono PERC Solar Panel 540W',
          categoryName: 'Panels',
          quantitySold: 10.0,
          grossSales: Money.fromRupees(150000.0),
          discountAmount: Money.zero,
          taxAmount: Money.fromRupees(18000.0),
          netSales: Money.fromRupees(168000.0),
          cogs: Money.fromRupees(120000.0),
          grossProfit: Money.fromRupees(30000.0),
          marginPercentage: 20.0,
        ),
      ],
      totalGrossSales: Money.fromRupees(150000.0),
      totalDiscounts: Money.zero,
      totalTax: Money.fromRupees(18000.0),
      totalNetSales: Money.fromRupees(168000.0),
      totalInvoices: 1,
      totalCogs: Money.fromRupees(120000.0),
      totalGrossProfit: Money.fromRupees(30000.0),
      overallMarginPercentage: 20.0,
    );
  }

  @override
  Future<Gstr1Summary> getGstr1Report(
    String organizationId,
    ReportDateRange dateRange,
  ) async {
    return Gstr1Summary(
      dateRange: dateRange,
      b2bTaxableValue: Money.fromRupees(100000.0),
      b2bCgst: Money.fromRupees(9000.0),
      b2bSgst: Money.fromRupees(9000.0),
      b2bIgst: Money.zero,
      b2cLargeTaxableValue: Money.zero,
      b2cLargeCgst: Money.zero,
      b2cLargeSgst: Money.zero,
      b2cLargeIgst: Money.zero,
      b2cSmallTaxableValue: Money.fromRupees(50000.0),
      b2cSmallCgst: Money.fromRupees(4500.0),
      b2cSmallSgst: Money.fromRupees(4500.0),
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
      outwardTaxableSupplies: Money.fromRupees(150000.0),
      outwardCgst: Money.fromRupees(13500.0),
      outwardSgst: Money.fromRupees(13500.0),
      outwardIgst: Money.zero,
      inwardItcTaxableSupplies: Money.fromRupees(100000.0),
      inwardCgstItc: Money.fromRupees(9000.0),
      inwardSgstItc: Money.fromRupees(9000.0),
      inwardIgstItc: Money.zero,
      netCgstPayable: Money.fromRupees(4500.0),
      netSgstPayable: Money.fromRupees(4500.0),
      netIgstPayable: Money.zero,
    );
  }

  @override
  Future<List<StockValuationItem>> getStockValuationReport(
    String organizationId, {
    String? branchId,
    String? categoryId,
  }) async {
    return [
      StockValuationItem(
        productId: 'prod_1',
        sku: 'SOLAR-PANEL-540W',
        productName: 'Mono PERC Solar Panel 540W',
        categoryName: 'Panels',
        quantityOnHand: 25.0,
        quantityReserved: 5.0,
        quantityAvailable: 20.0,
        unitCost: Money.fromRupees(12000.0),
        totalValuationCost: Money.fromRupees(300000.0),
      ),
    ];
  }

  @override
  Future<List<ReorderAlertItem>> getReorderAlerts(
    String organizationId, {
    String? branchId,
    int leadTimeDays = 7,
    double defaultSafetyStock = 5.0,
  }) async {
    return [
      ReorderAlertItem(
        productId: 'prod_1',
        sku: 'SOLAR-PANEL-540W',
        productName: 'Mono PERC Solar Panel 540W',
        currentStock: 3.0,
        avgDailyUsage: 2.0,
        leadTimeDays: leadTimeDays,
        safetyStock: defaultSafetyStock,
        reorderPoint: 19.0, // (2.0 * 7) + 5.0
        suggestedOrderQuantity: 20.0,
      ),
    ];
  }

  @override
  Future<List<PartyAgeingBucket>> getPartyAgeingReport(
    String organizationId, {
    required bool isCustomer,
  }) async {
    return [
      PartyAgeingBucket(
        partyId: 'party_1',
        partyName: 'Rahul Renewable Systems',
        isCustomer: isCustomer,
        currentAmount: Money.fromRupees(10000.0),
        days1To30: Money.fromRupees(5000.0),
        days31To60: Money.zero,
        days61To90: Money.zero,
        daysOver90: Money.zero,
        totalOutstanding: Money.fromRupees(15000.0),
      ),
    ];
  }

  @override
  Future<FinancialSummaryReport> getFinancialSummary(
    String organizationId,
    DateTime asOfDateUtc,
  ) async {
    return FinancialSummaryReport(
      asOfDateUtc: asOfDateUtc,
      totalRevenue: Money.fromRupees(500000.0),
      totalCogs: Money.fromRupees(350000.0),
      grossProfit: Money.fromRupees(150000.0),
      totalExpenses: Money.fromRupees(30000.0),
      netProfit: Money.fromRupees(120000.0),
      totalAssets: Money.fromRupees(1000000.0),
      totalLiabilities: Money.fromRupees(300000.0),
      totalEquity: Money.fromRupees(700000.0),
    );
  }

  @override
  Future<DashboardMetrics> getDashboardMetrics(
    String organizationId, {
    String? branchId,
  }) async {
    return DashboardMetrics(
      todaySales: Money.fromRupees(45000.0),
      todayCollections: Money.fromRupees(40000.0),
      lowStockCount: 2,
      totalReceivables: Money.fromRupees(150000.0),
      totalPayables: Money.fromRupees(80000.0),
      recentReorderAlerts: [],
    );
  }
}

void main() {
  final store = _MockReportStore();
  final now = DateTime.utc(2026, 9, 25);

  final adminSession = UserSession(
    id: const SessionId('sess_admin'),
    userId: const UserId('user_admin'),
    username: 'admin',
    roleId: 'admin',
    branchId: const BranchId('branch_1'),
    capabilities: {
      Capability.salesCreate,
      Capability.inventoryManage,
      Capability.costDataRead,
    },
    token: 'tok_admin',
    expiresAtUtc: now.add(const Duration(hours: 8)),
    lastActivityAtUtc: now,
  );

  final counterSession = UserSession(
    id: const SessionId('sess_counter'),
    userId: const UserId('user_counter'),
    username: 'counter',
    roleId: 'counter',
    branchId: const BranchId('branch_1'),
    capabilities: {
      Capability.salesCreate,
      Capability.inventoryManage,
    },
    token: 'tok_counter',
    expiresAtUtc: now.add(const Duration(hours: 8)),
    lastActivityAtUtc: now,
  );

  final adminContext = CommandContext(session: adminSession, timestampUtc: now);
  final counterContext = CommandContext(session: counterSession, timestampUtc: now);
  final dateRange = ReportDateRange(
    fromDateInclusiveUtc: DateTime.utc(2026, 9, 1),
    toDateInclusiveUtc: DateTime.utc(2026, 9, 30),
  );

  group('P10 Report Use Cases Tests', () {
    test('GenerateSalesReportUseCase provides cost data to Admin and masks cost data for Counter', () async {
      final useCase = GenerateSalesReportUseCase(store);

      final adminReport = await useCase.execute(
        context: adminContext,
        organizationId: 'org_1',
        dateRange: dateRange,
      );
      expect(adminReport.totalCogs, equals(Money.fromRupees(120000.0)));
      expect(adminReport.items.first.cogs, equals(Money.fromRupees(120000.0)));

      final counterReport = await useCase.execute(
        context: counterContext,
        organizationId: 'org_1',
        dateRange: dateRange,
      );
      expect(counterReport.totalCogs, isNull);
      expect(counterReport.totalGrossProfit, isNull);
      expect(counterReport.items.first.cogs, isNull);
      expect(counterReport.items.first.grossProfit, isNull);
    });

    test('GenerateStockValuationReportUseCase masks unit cost and valuation for Counter staff', () async {
      final useCase = GenerateStockValuationReportUseCase(store);

      final adminValuation = await useCase.execute(
        context: adminContext,
        organizationId: 'org_1',
      );
      expect(adminValuation.first.unitCost, equals(Money.fromRupees(12000.0)));

      final counterValuation = await useCase.execute(
        context: counterContext,
        organizationId: 'org_1',
      );
      expect(counterValuation.first.unitCost, isNull);
      expect(counterValuation.first.totalValuationCost, isNull);
    });

    test('GenerateFinancialSummaryUseCase denies access if lacking costDataRead capability', () async {
      final useCase = GenerateFinancialSummaryUseCase(store);

      expect(
        () => useCase.execute(
          context: counterContext,
          organizationId: 'org_1',
          asOfDateUtc: now,
        ),
        throwsA(isA<AuthorizationFailure>()),
      );

      final result = await useCase.execute(
        context: adminContext,
        organizationId: 'org_1',
        asOfDateUtc: now,
      );
      expect(result.netProfit, equals(Money.fromRupees(120000.0)));
    });

    test('ExportReportToCsvUseCase sanitizes malicious formula injection cells', () {
      const exportUseCase = ExportReportToCsvUseCase();
      final headers = ['Product', 'FormulaTest1', 'FormulaTest2'];
      final rows = [
        ['Solar Inverter', '=SUM(A1:A10)', '@cmd|"/C calc"!A0'],
        ['Solar Battery', '+100', '-500'],
      ];

      final csvOutput = exportUseCase.generateCsv(headers: headers, rows: rows);

      expect(csvOutput, contains("'=SUM(A1:A10)"));
      expect(csvOutput, contains("'@cmd|"));
      expect(csvOutput, contains("'+100"));
      expect(csvOutput, contains("'-500"));
    });
  });
}
