import 'dart:io';

import 'package:erp_domain/erp_domain.dart';
import 'package:erp_local_data/erp_local_data.dart';
import 'package:test/test.dart';

void main() {
  final key = List<int>.generate(32, (index) => index + 1);

  late Directory tempDir;
  late File dbFile;
  late FoundationDatabase db;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('service-store-test-');
    dbFile = File('${tempDir.path}${Platform.pathSeparator}test.db');
    db = FoundationDatabase.open(file: dbFile, key: key);
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('ServiceStore persists and retrieves service jobs, visits, AMC contracts, and serial replacements', () async {
    final now = DateTime.now();

    // 1. Service Job
    final job = ServiceJob(
      id: 'job_100',
      organizationId: 'org_1',
      branchId: 'br_1',
      jobTicketNumber: 'SRV-2026-001',
      customerPartyId: 'cust_1',
      customerName: 'Acro Solar Park',
      siteAddress: 'Plot 42, Green Energy Zone',
      equipmentSerialId: 'ser_100',
      issueDescription: 'Inverter error code E04',
      assignedTechnicianUserId: 'tech_1',
      assignedTechnicianName: 'Rajesh Sharma',
      status: ServiceJobStatus.assigned,
      createdAtUtc: now,
      isCoveredByWarranty: true,
      isCoveredByAmc: true,
    );

    await db.saveServiceJob(job: job);

    final fetchedJob = await db.getServiceJob('job_100');
    expect(fetchedJob, isNotNull);
    expect(fetchedJob!.jobTicketNumber, 'SRV-2026-001');
    expect(fetchedJob.status, ServiceJobStatus.assigned);
    expect(fetchedJob.assignedTechnicianUserId, 'tech_1');
    expect(fetchedJob.isCoveredByWarranty, isTrue);

    final orgJobs = await db.listServiceJobs(organizationId: 'org_1');
    expect(orgJobs.length, 1);

    // 2. Service Job Visit
    final visit = ServiceJobVisit(
      id: 'visit_100',
      jobId: 'job_100',
      technicianUserId: 'tech_1',
      technicianName: 'Rajesh Sharma',
      visitDate: now,
      workPerformed: 'Replaced cooling fan fuse and recalibrated solar inverter',
      travelExpensesPaise: Money.fromPaise(50000),
      laborCostPaise: Money.fromPaise(100000),
      billableAmountPaise: Money.fromPaise(0),
      sparesUsed: [
        ServiceJobSpareItem(
          productId: 'prod_fuse',
          productName: '10A Inverter Fuse',
          sku: 'SP-FUSE-10A',
          quantity: Quantity.fromUnits(2),
          unitCostPaise: Money.fromPaise(15000),
        ),
      ],
      isCompleted: true,
    );

    await db.saveServiceJob(job: job, visits: [visit]);

    final fetchedVisits = await db.getServiceJobVisits('job_100');
    expect(fetchedVisits.length, 1);
    expect(fetchedVisits.first.workPerformed, contains('recalibrated solar inverter'));
    expect(fetchedVisits.first.sparesUsed.length, 1);
    expect(fetchedVisits.first.sparesUsed.first.productName, '10A Inverter Fuse');

    // 3. Serial Replacement Lineage
    final replacement = SerialReplacement(
      id: 'rep_100',
      jobId: 'job_100',
      oldSerialId: 'ser_old_001',
      newSerialId: 'ser_new_002',
      replacementDate: now,
      reason: 'PCB component failure under warranty',
    );

    await db.saveSerialReplacement(replacement);

    final fetchedReplacements = await db.getSerialReplacements('ser_old_001');
    expect(fetchedReplacements.length, 1);
    expect(fetchedReplacements.first.oldSerialId, 'ser_old_001');
    expect(fetchedReplacements.first.newSerialId, 'ser_new_002');

    // 4. AMC Contract
    final contract = AmcContract(
      id: 'amc_100',
      organizationId: 'org_1',
      branchId: 'br_1',
      contractNumber: 'AMC-2026-001',
      customerPartyId: 'cust_1',
      customerName: 'Acro Solar Park',
      siteAddress: 'Plot 42, Green Energy Zone',
      startDate: now,
      endDate: now.add(const Duration(days: 365)),
      contractValuePaise: Money.fromPaise(2500000),
      visitLimitPerYear: 4,
      visitsCompleted: 1,
      status: AmcContractStatus.active,
      createdAtUtc: now,
    );

    await db.saveAmcContract(contract);

    final fetchedContract = await db.getAmcContract('amc_100');
    expect(fetchedContract, isNotNull);
    expect(fetchedContract!.contractNumber, 'AMC-2026-001');
    expect(fetchedContract.visitsCompleted, 1);

    final orgContracts = await db.listAmcContracts('org_1');
    expect(orgContracts.length, 1);
  });
}
