import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

void main() {
  group('P16 Service & AMC Domain Invariants Tests', () {
    test('ServiceJobSpareItem and ServiceJobVisit calculate costs correctly', () {
      final spare = ServiceJobSpareItem(
        productId: 'sp_fuse_20a',
        productName: '20A DC Fuse Unit',
        sku: 'ELE-FUS-20A',
        quantity: Quantity.fromUnits(2.0),
        unitCostPaise: Money.fromRupees(250.0), // ₹250 each
      );

      expect(spare.totalCostPaise, Money.fromRupees(500.0));

      final visit = ServiceJobVisit(
        id: 'vis_101',
        jobId: 'job_101',
        technicianUserId: 'tech_rajesh',
        technicianName: 'Rajesh Sharma',
        visitDate: DateTime.now(),
        workPerformed: 'Replaced DC fuses and cleaned inverter heat sink',
        travelExpensesPaise: Money.fromRupees(150.0),
        laborCostPaise: Money.fromRupees(500.0),
        billableAmountPaise: Money.fromRupees(0), // Covered under AMC
        sparesUsed: [spare],
      );

      // Total internal cost = ₹150 travel + ₹500 labor + ₹500 spares = ₹1150
      expect(visit.totalSparesCostPaise, Money.fromRupees(500.0));
      expect(visit.totalInternalCostPaise, Money.fromRupees(1150.0));
    });

    test('AmcContract checks visit limits and active date coverage boundaries', () {
      final now = DateTime.now();
      final contract = AmcContract(
        id: 'amc_2026_01',
        organizationId: 'org_1',
        branchId: 'br_1',
        contractNumber: 'AMC-2026-001',
        customerPartyId: 'cust_solar_site',
        customerName: 'Kalamb Solar Farm',
        siteAddress: 'Industrial Zone, Kalamb',
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 335)),
        contractValuePaise: Money.fromRupees(12000.0),
        visitLimitPerYear: 4,
        visitsCompleted: 4,
        status: AmcContractStatus.active,
        createdAtUtc: now,
      );

      expect(contract.isVisitLimitReached, isTrue);

      expect(contract.isCoverageActiveAt(now), isTrue);
      expect(contract.isCoverageActiveAt(now.subtract(const Duration(days: 40))), isFalse);
      expect(contract.isCoverageActiveAt(now.add(const Duration(days: 400))), isFalse);
    });
  });
}
