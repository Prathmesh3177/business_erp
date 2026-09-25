import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

void main() {
  group('P10 Reports Domain Tests', () {
    test('ReorderAlertItem.calculateReorderPoint computes deterministic formula', () {
      final point = ReorderAlertItem.calculateReorderPoint(
        avgDailyUsage: 5.0,
        leadTimeDays: 7,
        safetyStock: 10.0,
      );
      // (5.0 * 7) + 10.0 = 45.0
      expect(point, equals(45.0));
    });

    test('ReportDateRange.contains verifies inclusive boundaries', () {
      final from = DateTime.utc(2026, 1, 1);
      final to = DateTime.utc(2026, 1, 31, 23, 59, 59);
      final range = ReportDateRange(fromDateInclusiveUtc: from, toDateInclusiveUtc: to);

      expect(range.contains(from), isTrue);
      expect(range.contains(to), isTrue);
      expect(range.contains(DateTime.utc(2026, 1, 15)), isTrue);
      expect(range.contains(DateTime.utc(2025, 12, 31)), isFalse);
      expect(range.contains(DateTime.utc(2026, 2, 1)), isFalse);
    });

    test('SalesReportItem holds optional cost and gross profit when authorized', () {
      final item = SalesReportItem(
        productId: 'p1',
        sku: 'PUMP-5HP',
        productName: 'Solar Water Pump 5HP',
        categoryName: 'Pumps',
        quantitySold: 2.0,
        grossSales: Money.fromRupees(50000.0),
        discountAmount: Money.zero,
        taxAmount: Money.fromRupees(9000.0),
        netSales: Money.fromRupees(59000.0),
        cogs: Money.fromRupees(38000.0),
        grossProfit: Money.fromRupees(12000.0),
        marginPercentage: 24.0,
      );

      expect(item.cogs, equals(Money.fromRupees(38000.0)));
      expect(item.grossProfit, equals(Money.fromRupees(12000.0)));
      expect(item.marginPercentage, equals(24.0));
    });

    test('SalesReportItem masks cost data when cogs is omitted', () {
      final item = SalesReportItem(
        productId: 'p1',
        sku: 'PUMP-5HP',
        productName: 'Solar Water Pump 5HP',
        categoryName: 'Pumps',
        quantitySold: 2.0,
        grossSales: Money.fromRupees(50000.0),
        discountAmount: Money.zero,
        taxAmount: Money.fromRupees(9000.0),
        netSales: Money.fromRupees(59000.0),
      );

      expect(item.cogs, isNull);
      expect(item.grossProfit, isNull);
      expect(item.marginPercentage, isNull);
    });
  });
}
