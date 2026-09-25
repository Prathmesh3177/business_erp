import 'money.dart';

/// Date range query for reports.
final class ReportDateRange {
  const ReportDateRange({
    required this.fromDateInclusiveUtc,
    required this.toDateInclusiveUtc,
  });

  final DateTime fromDateInclusiveUtc;
  final DateTime toDateInclusiveUtc;

  bool contains(DateTime timestampUtc) {
    return (timestampUtc.isAfter(fromDateInclusiveUtc) ||
            timestampUtc.isAtSameMomentAs(fromDateInclusiveUtc)) &&
        (timestampUtc.isBefore(toDateInclusiveUtc) ||
            timestampUtc.isAtSameMomentAs(toDateInclusiveUtc));
  }
}

/// Sales summary report item per product / category / customer.
final class SalesReportItem {
  const SalesReportItem({
    required this.productId,
    required this.sku,
    required this.productName,
    required this.categoryName,
    required this.quantitySold,
    required this.grossSales,
    required this.discountAmount,
    required this.taxAmount,
    required this.netSales,
    this.cogs,
    this.grossProfit,
    this.marginPercentage,
  });

  final String productId;
  final String sku;
  final String productName;
  final String categoryName;
  final double quantitySold;
  final Money grossSales;
  final Money discountAmount;
  final Money taxAmount;
  final Money netSales;
  final Money? cogs;
  final Money? grossProfit;
  final double? marginPercentage;
}

/// Overall Sales Report aggregate summary.
final class SalesReportSummary {
  const SalesReportSummary({
    required this.dateRange,
    required this.items,
    required this.totalGrossSales,
    required this.totalDiscounts,
    required this.totalTax,
    required this.totalNetSales,
    required this.totalInvoices,
    this.totalCogs,
    this.totalGrossProfit,
    this.overallMarginPercentage,
  });

  final ReportDateRange dateRange;
  final List<SalesReportItem> items;
  final Money totalGrossSales;
  final Money totalDiscounts;
  final Money totalTax;
  final Money totalNetSales;
  final int totalInvoices;
  final Money? totalCogs;
  final Money? totalGrossProfit;
  final double? overallMarginPercentage;
}

/// GSTR-1 Summary for Indian GST Filing (Outward Supplies).
final class Gstr1Summary {
  const Gstr1Summary({
    required this.dateRange,
    required this.b2bTaxableValue,
    required this.b2bCgst,
    required this.b2bSgst,
    required this.b2bIgst,
    required this.b2cLargeTaxableValue,
    required this.b2cLargeCgst,
    required this.b2cLargeSgst,
    required this.b2cLargeIgst,
    required this.b2cSmallTaxableValue,
    required this.b2cSmallCgst,
    required this.b2cSmallSgst,
    required this.b2cSmallIgst,
    required this.hsnSummaries,
  });

  final ReportDateRange dateRange;
  final Money b2bTaxableValue;
  final Money b2bCgst;
  final Money b2bSgst;
  final Money b2bIgst;
  final Money b2cLargeTaxableValue;
  final Money b2cLargeCgst;
  final Money b2cLargeSgst;
  final Money b2cLargeIgst;
  final Money b2cSmallTaxableValue;
  final Money b2cSmallCgst;
  final Money b2cSmallSgst;
  final Money b2cSmallIgst;
  final List<HsnSummaryItem> hsnSummaries;
}

final class HsnSummaryItem {
  const HsnSummaryItem({
    required this.hsnSacCode,
    required this.description,
    required this.uqc,
    required this.totalQuantity,
    required this.taxableValue,
    required this.cgst,
    required this.sgst,
    required this.igst,
  });

  final String hsnSacCode;
  final String description;
  final String uqc;
  final double totalQuantity;
  final Money taxableValue;
  final Money cgst;
  final Money sgst;
  final Money igst;
}

/// GSTR-3B Summary for Indian GST Filing.
final class Gstr3bSummary {
  const Gstr3bSummary({
    required this.dateRange,
    required this.outwardTaxableSupplies,
    required this.outwardCgst,
    required this.outwardSgst,
    required this.outwardIgst,
    required this.inwardItcTaxableSupplies,
    required this.inwardCgstItc,
    required this.inwardSgstItc,
    required this.inwardIgstItc,
    required this.netCgstPayable,
    required this.netSgstPayable,
    required this.netIgstPayable,
  });

  final ReportDateRange dateRange;
  final Money outwardTaxableSupplies;
  final Money outwardCgst;
  final Money outwardSgst;
  final Money outwardIgst;
  final Money inwardItcTaxableSupplies;
  final Money inwardCgstItc;
  final Money inwardSgstItc;
  final Money inwardIgstItc;
  final Money netCgstPayable;
  final Money netSgstPayable;
  final Money netIgstPayable;
}

/// Stock Valuation Item.
final class StockValuationItem {
  const StockValuationItem({
    required this.productId,
    required this.sku,
    required this.productName,
    required this.categoryName,
    required this.quantityOnHand,
    required this.quantityReserved,
    required this.quantityAvailable,
    this.unitCost,
    this.totalValuationCost,
  });

  final String productId;
  final String sku;
  final String productName;
  final String categoryName;
  final double quantityOnHand;
  final double quantityReserved;
  final double quantityAvailable;
  final Money? unitCost;
  final Money? totalValuationCost;
}

/// Reorder Alert Item with transparent calculation formula.
final class ReorderAlertItem {
  const ReorderAlertItem({
    required this.productId,
    required this.sku,
    required this.productName,
    required this.currentStock,
    required this.avgDailyUsage,
    required this.leadTimeDays,
    required this.safetyStock,
    required this.reorderPoint,
    required this.suggestedOrderQuantity,
  });

  final String productId;
  final String sku;
  final String productName;
  final double currentStock;
  final double avgDailyUsage;
  final int leadTimeDays;
  final double safetyStock;
  final double reorderPoint;
  final double suggestedOrderQuantity;

  /// Deterministic Reorder Point calculation formula:
  /// Reorder Point = (Average Daily Usage * Lead Time Days) + Safety Stock
  static double calculateReorderPoint({
    required double avgDailyUsage,
    required int leadTimeDays,
    required double safetyStock,
  }) {
    return (avgDailyUsage * leadTimeDays) + safetyStock;
  }
}

/// Party Ageing Bucket (Accounts Receivable / Accounts Payable).
final class PartyAgeingBucket {
  const PartyAgeingBucket({
    required this.partyId,
    required this.partyName,
    required this.isCustomer,
    required this.currentAmount,
    required this.days1To30,
    required this.days31To60,
    required this.days61To90,
    required this.daysOver90,
    required this.totalOutstanding,
  });

  final String partyId;
  final String partyName;
  final bool isCustomer;
  final Money currentAmount;
  final Money days1To30;
  final Money days31To60;
  final Money days61To90;
  final Money daysOver90;
  final Money totalOutstanding;
}

/// Financial Summary Report (Trial Balance & Profit & Loss).
final class FinancialSummaryReport {
  const FinancialSummaryReport({
    required this.asOfDateUtc,
    required this.totalRevenue,
    required this.totalCogs,
    required this.grossProfit,
    required this.totalExpenses,
    required this.netProfit,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.totalEquity,
  });

  final DateTime asOfDateUtc;
  final Money totalRevenue;
  final Money totalCogs;
  final Money grossProfit;
  final Money totalExpenses;
  final Money netProfit;
  final Money totalAssets;
  final Money totalLiabilities;
  final Money totalEquity;
}

/// Dashboard Executive Summary metrics.
final class DashboardMetrics {
  const DashboardMetrics({
    required this.todaySales,
    required this.todayCollections,
    required this.lowStockCount,
    required this.totalReceivables,
    required this.totalPayables,
    required this.recentReorderAlerts,
  });

  final Money todaySales;
  final Money todayCollections;
  final int lowStockCount;
  final Money totalReceivables;
  final Money totalPayables;
  final List<ReorderAlertItem> recentReorderAlerts;
}
