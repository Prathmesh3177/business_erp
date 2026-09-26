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
    tempDir = Directory.systemTemp.createTempSync('project-store-test-');
    dbFile = File('${tempDir.path}${Platform.pathSeparator}test.db');
    db = FoundationDatabase.open(file: dbFile, key: key);
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('ProjectStore persists and retrieves quotations, lines, solar projects, and material issues', () async {
    final now = DateTime.now();

    // 1. Save and retrieve Quotation
    final header = QuotationHeader(
      id: 'q_100',
      organizationId: 'org_1',
      branchId: 'br_1',
      quotationNumber: 'QUO-2026-001',
      revisionNumber: 1,
      customerPartyId: 'cust_1',
      customerName: 'Solar Residential Client',
      validUntil: now.add(const Duration(days: 15)),
      status: QuotationStatus.approved,
      subtotalPaise: Money.fromPaise(50000000),
      allocatedDiscountPaise: Money.fromPaise(2000000),
      totalTaxPaise: Money.fromPaise(8640000),
      grandTotalPaise: Money.fromPaise(56640000),
      installationChargesPaise: Money.fromPaise(5000000),
      createdAtUtc: now,
    );

    final line = QuotationLine(
      id: 'ql_100',
      quotationId: 'q_100',
      productId: 'prod_panel',
      productName: '540W Mono PERC Panel',
      sku: 'SOL-PNL-540W',
      hsnCode: '85414011',
      quantity: Quantity.fromUnits(10.0),
      unitPrice: UnitPrice.fromRupees(15000.0),
      lineDiscountPaise: Money.fromPaise(0),
      taxSnapshot: TaxLineResult(
        lineId: 'ql_100',
        taxableAmount: Money.fromPaise(15000000),
        cgst: Money.fromPaise(900000),
        sgst: Money.fromPaise(900000),
        igst: Money.fromPaise(0),
        totalTax: Money.fromPaise(1800000),
        totalAmount: Money.fromPaise(16800000),
      ),
      netTotalPaise: Money.fromPaise(15000000),
      isServiceLine: false,
    );

    await db.saveQuotation(header: header, lines: [line]);

    final fetchedHeader = await db.getQuotationHeader('q_100');
    expect(fetchedHeader, isNotNull);
    expect(fetchedHeader!.quotationNumber, 'QUO-2026-001');
    expect(fetchedHeader.status, QuotationStatus.approved);
    expect(fetchedHeader.grandTotalPaise, Money.fromPaise(56640000));

    final fetchedLines = await db.getQuotationLines('q_100');
    expect(fetchedLines.length, 1);
    expect(fetchedLines.first.productName, '540W Mono PERC Panel');

    final orgQuotations = await db.listQuotations('org_1');
    expect(orgQuotations.length, 1);

    // 2. Save and retrieve SolarProject
    final project = SolarProject(
      id: 'proj_100',
      organizationId: 'org_1',
      branchId: 'br_1',
      projectNumber: 'PRJ-2026-001',
      name: '5kW Rooftop Solar Installation',
      customerPartyId: 'cust_1',
      customerName: 'Solar Residential Client',
      siteAddress: '123 Tech Park, Solar City',
      acceptedQuotationId: 'q_100',
      acceptedQuotationRevision: 1,
      status: ProjectStatus.inProgress,
      budgetMaterialsPaise: Money.fromPaise(40000000),
      budgetLaborPaise: Money.fromPaise(500000),
      actualMaterialsPaise: Money.fromPaise(35000000),
      actualExpensesPaise: Money.fromPaise(200000),
      invoicedPaise: Money.fromPaise(0),
      wipBalancePaise: Money.fromPaise(35000000),
      createdAtUtc: now,
    );

    await db.saveProject(project);

    final fetchedProject = await db.getProject('proj_100');
    expect(fetchedProject, isNotNull);
    expect(fetchedProject!.projectNumber, 'PRJ-2026-001');
    expect(fetchedProject.status, ProjectStatus.inProgress);
    expect(fetchedProject.wipBalancePaise, Money.fromPaise(35000000));

    final orgProjects = await db.listProjects('org_1');
    expect(orgProjects.length, 1);

    // 3. Save and retrieve ProjectMaterialIssue
    final issueLine = ProjectMaterialIssueLine(
      id: 'pmi_line_100',
      issueId: 'pmi_100',
      productId: 'prod_panel',
      productName: '540W Mono PERC Panel',
      sku: 'SOL-PNL-540W',
      quantity: Quantity.fromUnits(10.0),
      costSnapshotMicroRupees: 12000000000,
      serials: const ['SN-PNL-001', 'SN-PNL-002'],
    );

    final issue = ProjectMaterialIssue(
      id: 'pmi_100',
      organizationId: 'org_1',
      branchId: 'br_1',
      projectId: 'proj_100',
      locationId: 'loc_main',
      issueDate: now,
      lines: [issueLine],
      totalCostPaise: Money.fromPaise(12000000),
      createdAtUtc: now,
      notes: 'Issued 10 solar panels to site',
    );

    await db.saveMaterialIssue(issue: issue);

    final fetchedIssues = await db.getMaterialIssues('proj_100');
    expect(fetchedIssues.length, 1);
    expect(fetchedIssues.first.notes, 'Issued 10 solar panels to site');
    expect(fetchedIssues.first.lines.length, 1);
    expect(fetchedIssues.first.lines.first.serials, ['SN-PNL-001', 'SN-PNL-002']);
  });

  test('KitStore persists kit lines by catalog product ID and replaces lines on update', () async {
    final now = DateTime.now().toUtc();
    final kit = Kit(
      id: 'kit_1',
      organizationId: 'org_1',
      name: '3kW rooftop',
      category: 'residential_rooftop',
      capacityKw: 3,
      installationChargesPaise: Money.fromRupees(12000),
      active: true,
      createdAtUtc: now,
      updatedAtUtc: now,
    );
    final firstLine = KitLine(
      id: 'kit_1_line_1',
      kitId: kit.id,
      productId: 'product_panel_540',
      quantity: Quantity.fromUnits(6),
      sortOrder: 0,
    );

    await db.saveKit(kit: kit, lines: [firstLine]);
    expect((await db.listKits('org_1')).single.name, '3kW rooftop');
    expect((await db.getKitLines(kit.id)).single.productId, 'product_panel_540');

    final replacement = KitLine(
      id: 'kit_1_line_2',
      kitId: kit.id,
      productId: 'product_inverter_3kw',
      quantity: Quantity.fromUnits(1),
      sortOrder: 0,
    );
    await db.saveKit(kit: kit, lines: [replacement]);
    final lines = await db.getKitLines(kit.id);
    expect(lines, hasLength(1));
    expect(lines.single.productId, 'product_inverter_3kw');
  });
}
