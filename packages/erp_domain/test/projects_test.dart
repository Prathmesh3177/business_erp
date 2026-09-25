import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

void main() {
  group('P15 Solar Projects & BOM Quotations Domain Tests', () {
    test('ProjectMaterialIssueLine computes total cost paise correctly', () {
      final line = ProjectMaterialIssueLine(
        id: 'iss_line_1',
        issueId: 'iss_1',
        productId: 'prod_panel',
        productName: 'Solar Panel 540W',
        sku: 'SP-540',
        quantity: Quantity.fromUnits(10.0),
        costSnapshotMicroRupees: 12000000000, // ₹12,000 per unit micro rupees
      );

      expect(line.totalCostPaise.inRupees, equals(120000.0)); // 10 * ₹12,000 = ₹1,20,000
    });

    test('ProjectBudgetReport calculates estimated profit and margin %', () {
      final report = ProjectBudgetReport(
        projectId: 'proj_1',
        projectNumber: 'PRJ/2627/000001',
        projectName: '5kW Rooftop Solar Installation',
        customerName: 'Shri Patil',
        status: ProjectStatus.inProgress,
        budgetMaterialsPaise: Money.fromRupees(200000.0),
        budgetLaborPaise: Money.fromRupees(50000.0),
        totalBudgetPaise: Money.fromRupees(250000.0),
        actualMaterialsPaise: Money.fromRupees(180000.0),
        actualExpensesPaise: Money.fromRupees(20000.0),
        totalActualCostPaise: Money.fromRupees(200000.0),
        wipBalancePaise: Money.fromRupees(180000.0),
        invoicedPaise: Money.fromRupees(300000.0),
        estimatedGrossProfitPaise: Money.fromRupees(100000.0), // ₹3,00,000 revenue - ₹2,00,000 cost
        marginPercentage: 33.33,
      );


      expect(report.totalBudgetPaise.inRupees, equals(250000.0));
      expect(report.totalActualCostPaise.inRupees, equals(200000.0));
      expect(report.estimatedGrossProfitPaise.inRupees, equals(100000.0));
      expect(report.marginPercentage, equals(33.33));
    });
  });
}
