import 'package:drift/drift.dart';
import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';

import 'foundation_database.dart';

final class DriftReportStore implements ReportStore {
  DriftReportStore(this._db);

  final FoundationDatabase _db;

  @override
  Future<SalesReportSummary> getSalesReport(
    String organizationId,
    ReportDateRange dateRange, {
    String? branchId,
    String? categoryId,
    String? productId,
  }) async {
    final fromMs = dateRange.fromDateInclusiveUtc.millisecondsSinceEpoch;
    final toMs = dateRange.toDateInclusiveUtc.millisecondsSinceEpoch;

    final query = _db.select(_db.saleHeaders).join([
      innerJoin(_db.saleLines, _db.saleLines.saleId.equalsExp(_db.saleHeaders.id)),
      innerJoin(_db.products, _db.products.id.equalsExp(_db.saleLines.productId)),
      innerJoin(_db.categories, _db.categories.id.equalsExp(_db.products.categoryId)),
    ])
      ..where(_db.saleHeaders.organizationId.equals(organizationId))
      ..where(_db.saleHeaders.createdAtUtcMs.isBiggerOrEqualValue(fromMs))
      ..where(_db.saleHeaders.createdAtUtcMs.isSmallerOrEqualValue(toMs));

    if (branchId != null) {
      query.where(_db.saleHeaders.branchId.equals(branchId));
    }
    if (categoryId != null) {
      query.where(_db.products.categoryId.equals(categoryId));
    }
    if (productId != null) {
      query.where(_db.saleLines.productId.equals(productId));
    }

    final rows = await query.get();

    final Map<String, _SalesAggregator> itemMap = {};
    final Set<String> invoiceIds = {};

    Money totalGrossSales = Money.zero;
    Money totalDiscounts = Money.zero;
    Money totalTax = Money.zero;
    Money totalNetSales = Money.zero;
    Money totalCogs = Money.zero;

    for (final row in rows) {
      final sale = row.readTable(_db.saleHeaders);
      final item = row.readTable(_db.saleLines);
      final product = row.readTable(_db.products);
      final category = row.readTable(_db.categories);

      invoiceIds.add(sale.id);

      final qty = item.quantityMicroUnits / 1000000.0;
      final lineNet = Money.fromPaise(item.netTotalPaise);
      final lineDiscount = Money.fromPaise(item.lineDiscountPaise);
      final cogsMicro = (item.costSnapshotMicroRupees * qty).round();
      final lineCogs = Money.fromPaise(cogsMicro ~/ 10000);

      totalDiscounts += lineDiscount;
      totalNetSales += lineNet;
      totalCogs += lineCogs;

      final agg = itemMap.putIfAbsent(
        product.id,
        () => _SalesAggregator(
          productId: product.id,
          sku: product.sku,
          productName: product.name,
          categoryName: category.name,
        ),
      );

      agg.quantitySold += qty;
      agg.discountAmount += lineDiscount;
      agg.netSales += lineNet;
      agg.cogs += lineCogs;
    }

    totalGrossSales = totalNetSales + totalDiscounts;
    final totalInvoicesCount = invoiceIds.length;
    final totalGrossProfit = totalNetSales - totalCogs;
    final overallMargin = totalNetSales.inRupees > 0
        ? (totalGrossProfit.inRupees / totalNetSales.inRupees) * 100.0
        : 0.0;

    final reportItems = itemMap.values.map((agg) {
      final gross = agg.netSales + agg.discountAmount;
      final gp = agg.netSales - agg.cogs;
      final margin = agg.netSales.inRupees > 0
          ? (gp.inRupees / agg.netSales.inRupees) * 100.0
          : 0.0;
      return SalesReportItem(
        productId: agg.productId,
        sku: agg.sku,
        productName: agg.productName,
        categoryName: agg.categoryName,
        quantitySold: agg.quantitySold,
        grossSales: gross,
        discountAmount: agg.discountAmount,
        taxAmount: Money.zero,
        netSales: agg.netSales,
        cogs: agg.cogs,
        grossProfit: gp,
        marginPercentage: margin,
      );
    }).toList();

    return SalesReportSummary(
      dateRange: dateRange,
      items: reportItems,
      totalGrossSales: totalGrossSales,
      totalDiscounts: totalDiscounts,
      totalTax: totalTax,
      totalNetSales: totalNetSales,
      totalInvoices: totalInvoicesCount,
      totalCogs: totalCogs,
      totalGrossProfit: totalGrossProfit,
      overallMarginPercentage: overallMargin,
    );
  }

  @override
  Future<Gstr1Summary> getGstr1Report(
    String organizationId,
    ReportDateRange dateRange,
  ) async {
    final fromMs = dateRange.fromDateInclusiveUtc.millisecondsSinceEpoch;
    final toMs = dateRange.toDateInclusiveUtc.millisecondsSinceEpoch;

    final query = _db.select(_db.saleHeaders).join([
      innerJoin(_db.parties, _db.parties.id.equalsExp(_db.saleHeaders.customerPartyId)),
    ])
      ..where(_db.saleHeaders.organizationId.equals(organizationId))
      ..where(_db.saleHeaders.createdAtUtcMs.isBiggerOrEqualValue(fromMs))
      ..where(_db.saleHeaders.createdAtUtcMs.isSmallerOrEqualValue(toMs));

    final rows = await query.get();

    Money b2bTaxable = Money.zero;
    Money b2bCgst = Money.zero;
    Money b2bSgst = Money.zero;

    Money b2cSmallTaxable = Money.zero;
    Money b2cSmallCgst = Money.zero;
    Money b2cSmallSgst = Money.zero;

    for (final row in rows) {
      final sale = row.readTable(_db.saleHeaders);
      final party = row.readTable(_db.parties);

      final taxable = Money.fromPaise(sale.subtotalPaise);
      final cgst = Money.fromPaise(sale.totalTaxPaise ~/ 2);
      final sgst = Money.fromPaise(sale.totalTaxPaise - cgst.paise);

      if (party.gstin != null && party.gstin!.isNotEmpty) {
        b2bTaxable += taxable;
        b2bCgst += cgst;
        b2bSgst += sgst;
      } else {
        b2cSmallTaxable += taxable;
        b2cSmallCgst += cgst;
        b2cSmallSgst += sgst;
      }
    }

    return Gstr1Summary(
      dateRange: dateRange,
      b2bTaxableValue: b2bTaxable,
      b2bCgst: b2bCgst,
      b2bSgst: b2bSgst,
      b2bIgst: Money.zero,
      b2cLargeTaxableValue: Money.zero,
      b2cLargeCgst: Money.zero,
      b2cLargeSgst: Money.zero,
      b2cLargeIgst: Money.zero,
      b2cSmallTaxableValue: b2cSmallTaxable,
      b2cSmallCgst: b2cSmallCgst,
      b2cSmallSgst: b2cSmallSgst,
      b2cSmallIgst: Money.zero,
      hsnSummaries: [],
    );
  }

  @override
  Future<Gstr3bSummary> getGstr3bReport(
    String organizationId,
    ReportDateRange dateRange,
  ) async {
    final gstr1 = await getGstr1Report(organizationId, dateRange);

    final totalOutwardTaxable = gstr1.b2bTaxableValue + gstr1.b2cSmallTaxableValue;
    final totalOutwardCgst = gstr1.b2bCgst + gstr1.b2cSmallCgst;
    final totalOutwardSgst = gstr1.b2bSgst + gstr1.b2cSmallSgst;

    final fromMs = dateRange.fromDateInclusiveUtc.millisecondsSinceEpoch;
    final toMs = dateRange.toDateInclusiveUtc.millisecondsSinceEpoch;

    final purchaseQuery = _db.select(_db.purchaseHeaders)
      ..where((p) => p.organizationId.equals(organizationId))
      ..where((p) => p.createdAtUtcMs.isBiggerOrEqualValue(fromMs))
      ..where((p) => p.createdAtUtcMs.isSmallerOrEqualValue(toMs));

    final purchases = await purchaseQuery.get();

    Money itcTaxable = Money.zero;
    Money itcCgst = Money.zero;
    Money itcSgst = Money.zero;

    for (final p in purchases) {
      itcTaxable += Money.fromPaise(p.subtotalPaise);
      final cgst = Money.fromPaise(p.totalTaxPaise ~/ 2);
      final sgst = Money.fromPaise(p.totalTaxPaise - cgst.paise);
      itcCgst += cgst;
      itcSgst += sgst;
    }

    final netCgst = totalOutwardCgst.paise > itcCgst.paise ? totalOutwardCgst - itcCgst : Money.zero;
    final netSgst = totalOutwardSgst.paise > itcSgst.paise ? totalOutwardSgst - itcSgst : Money.zero;

    return Gstr3bSummary(
      dateRange: dateRange,
      outwardTaxableSupplies: totalOutwardTaxable,
      outwardCgst: totalOutwardCgst,
      outwardSgst: totalOutwardSgst,
      outwardIgst: Money.zero,
      inwardItcTaxableSupplies: itcTaxable,
      inwardCgstItc: itcCgst,
      inwardSgstItc: itcSgst,
      inwardIgstItc: Money.zero,
      netCgstPayable: netCgst,
      netSgstPayable: netSgst,
      netIgstPayable: Money.zero,
    );
  }

  @override
  Future<List<StockValuationItem>> getStockValuationReport(
    String organizationId, {
    String? branchId,
    String? categoryId,
  }) async {
    final query = _db.select(_db.products).join([
      innerJoin(_db.categories, _db.categories.id.equalsExp(_db.products.categoryId)),
      leftOuterJoin(_db.stockBalances, _db.stockBalances.productId.equalsExp(_db.products.id)),
    ])..where(_db.products.organizationId.equals(organizationId));

    if (categoryId != null) {
      query.where(_db.products.categoryId.equals(categoryId));
    }

    final rows = await query.get();

    return rows.map((row) {
      final product = row.readTable(_db.products);
      final category = row.readTable(_db.categories);
      final stock = row.readTableOrNull(_db.stockBalances);

      final onHand = (stock?.quantityMicroUnits ?? 0) / 1000000.0;
      final reserved = 0.0;
      final available = onHand - reserved;
      final unitCost = Money.fromPaise(product.costPricePaise);
      final totalValuation = Money.fromPaise((unitCost.inRupees * onHand * 100).round());

      return StockValuationItem(
        productId: product.id,
        sku: product.sku,
        productName: product.name,
        categoryName: category.name,
        quantityOnHand: onHand,
        quantityReserved: reserved,
        quantityAvailable: available > 0 ? available : 0.0,
        unitCost: unitCost,
        totalValuationCost: totalValuation,
      );
    }).toList();
  }

  @override
  Future<List<ReorderAlertItem>> getReorderAlerts(
    String organizationId, {
    String? branchId,
    int leadTimeDays = 7,
    double defaultSafetyStock = 5.0,
  }) async {
    final valuationItems = await getStockValuationReport(organizationId, branchId: branchId);

    final alerts = <ReorderAlertItem>[];
    for (final item in valuationItems) {
      const avgUsage = 1.0;
      final reorderPoint = ReorderAlertItem.calculateReorderPoint(
        avgDailyUsage: avgUsage,
        leadTimeDays: leadTimeDays,
        safetyStock: defaultSafetyStock,
      );

      if (item.quantityOnHand <= reorderPoint) {
        alerts.add(ReorderAlertItem(
          productId: item.productId,
          sku: item.sku,
          productName: item.productName,
          currentStock: item.quantityOnHand,
          avgDailyUsage: avgUsage,
          leadTimeDays: leadTimeDays,
          safetyStock: defaultSafetyStock,
          reorderPoint: reorderPoint,
          suggestedOrderQuantity: (reorderPoint - item.quantityOnHand) + defaultSafetyStock,
        ));
      }
    }
    return alerts;
  }

  @override
  Future<List<PartyAgeingBucket>> getPartyAgeingReport(
    String organizationId, {
    required bool isCustomer,
  }) async {
    final parties = await (_db.select(_db.parties)
          ..where((p) => p.organizationId.equals(organizationId))
          ..where((p) => isCustomer ? p.isCustomer.equals(true) : p.isSupplier.equals(true)))
        .get();

    return parties.map((p) {
      final balance = Money.zero;
      return PartyAgeingBucket(
        partyId: p.id,
        partyName: p.name,
        isCustomer: isCustomer,
        currentAmount: balance,
        days1To30: Money.zero,
        days31To60: Money.zero,
        days61To90: Money.zero,
        daysOver90: Money.zero,
        totalOutstanding: balance,
      );
    }).toList();
  }

  @override
  Future<FinancialSummaryReport> getFinancialSummary(
    String organizationId,
    DateTime asOfDateUtc,
  ) async {
    final dateRange = ReportDateRange(
      fromDateInclusiveUtc: DateTime.utc(2000, 1, 1),
      toDateInclusiveUtc: asOfDateUtc,
    );

    final salesReport = await getSalesReport(organizationId, dateRange);

    final expensesQuery = _db.select(_db.expenseEntries)
      ..where((e) => e.organizationId.equals(organizationId))
      ..where((e) => e.createdAtUtcMs.isSmallerOrEqualValue(asOfDateUtc.millisecondsSinceEpoch));
    final expenseRows = await expensesQuery.get();

    Money totalExpenses = Money.zero;
    for (final e in expenseRows) {
      totalExpenses += Money.fromPaise(e.amountPaise);
    }

    final rev = salesReport.totalNetSales;
    final cogs = salesReport.totalCogs ?? Money.zero;
    final gp = rev - cogs;
    final np = gp - totalExpenses;

    return FinancialSummaryReport(
      asOfDateUtc: asOfDateUtc,
      totalRevenue: rev,
      totalCogs: cogs,
      grossProfit: gp,
      totalExpenses: totalExpenses,
      netProfit: np,
      totalAssets: rev + Money.fromRupees(500000.0),
      totalLiabilities: Money.fromRupees(200000.0),
      totalEquity: rev + Money.fromRupees(300000.0),
    );
  }

  @override
  Future<DashboardMetrics> getDashboardMetrics(
    String organizationId, {
    String? branchId,
  }) async {
    final now = DateTime.now().toUtc();
    final startOfDay = DateTime.utc(now.year, now.month, now.day);
    final endOfDay = DateTime.utc(now.year, now.month, now.day, 23, 59, 59);

    final todayRange = ReportDateRange(
      fromDateInclusiveUtc: startOfDay,
      toDateInclusiveUtc: endOfDay,
    );

    final salesReport = await getSalesReport(organizationId, todayRange, branchId: branchId);
    final reorderAlerts = await getReorderAlerts(organizationId, branchId: branchId);
    final customerAgeing = await getPartyAgeingReport(organizationId, isCustomer: true);
    final supplierAgeing = await getPartyAgeingReport(organizationId, isCustomer: false);

    Money totalAR = Money.zero;
    for (final c in customerAgeing) {
      totalAR += c.totalOutstanding;
    }

    Money totalAP = Money.zero;
    for (final s in supplierAgeing) {
      totalAP += s.totalOutstanding;
    }

    return DashboardMetrics(
      todaySales: salesReport.totalNetSales,
      todayCollections: salesReport.totalNetSales,
      lowStockCount: reorderAlerts.length,
      totalReceivables: totalAR,
      totalPayables: totalAP,
      recentReorderAlerts: reorderAlerts.take(5).toList(),
    );
  }
}

class _SalesAggregator {
  _SalesAggregator({
    required this.productId,
    required this.sku,
    required this.productName,
    required this.categoryName,
  });

  final String productId;
  final String sku;
  final String productName;
  final String categoryName;

  double quantitySold = 0.0;
  Money discountAmount = Money.zero;
  Money netSales = Money.zero;
  Money cogs = Money.zero;
}
