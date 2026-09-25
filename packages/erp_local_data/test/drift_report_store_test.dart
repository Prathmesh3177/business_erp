import 'dart:io';

import 'package:erp_domain/erp_domain.dart';
import 'package:erp_local_data/erp_local_data.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late FoundationDatabase db;
  late DriftReportStore reportStore;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('solar-erp-report-test-');
    final dbFile = File('${tempDir.path}${Platform.pathSeparator}test.db');
    db = FoundationDatabase.open(file: dbFile, key: const []);
    reportStore = DriftReportStore(db);
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('P10 DriftReportStore Integration Tests', () {
    test('getSalesReport returns empty summary on fresh database', () async {
      final range = ReportDateRange(
        fromDateInclusiveUtc: DateTime.utc(2026, 1, 1),
        toDateInclusiveUtc: DateTime.utc(2026, 12, 31),
      );

      final report = await reportStore.getSalesReport('org_1', range);

      expect(report.totalInvoices, equals(0));
      expect(report.items, isEmpty);
      expect(report.totalNetSales, equals(Money.zero));
    });

    test('getGstr1Report and getGstr3bReport return empty summaries on fresh database', () async {
      final range = ReportDateRange(
        fromDateInclusiveUtc: DateTime.utc(2026, 1, 1),
        toDateInclusiveUtc: DateTime.utc(2026, 12, 31),
      );

      final gstr1 = await reportStore.getGstr1Report('org_1', range);
      expect(gstr1.b2bTaxableValue, equals(Money.zero));
      expect(gstr1.b2cSmallTaxableValue, equals(Money.zero));

      final gstr3b = await reportStore.getGstr3bReport('org_1', range);
      expect(gstr3b.outwardTaxableSupplies, equals(Money.zero));
      expect(gstr3b.inwardItcTaxableSupplies, equals(Money.zero));
    });

    test('getDashboardMetrics aggregates today sales and collections on fresh database', () async {
      final metrics = await reportStore.getDashboardMetrics('org_1');

      expect(metrics.todaySales, equals(Money.zero));
      expect(metrics.todayCollections, equals(Money.zero));
      expect(metrics.lowStockCount, equals(0));
    });
  });
}
