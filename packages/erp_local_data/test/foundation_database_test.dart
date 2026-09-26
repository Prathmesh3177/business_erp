import 'dart:io';

import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:erp_local_data/erp_local_data.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  final key = List<int>.generate(32, (index) => index + 1);

  test('encrypted identity persists across a real database restart', () async {
    final directory = Directory.systemTemp.createTempSync('solar-erp-db-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final file = File(
      '${directory.path}${Platform.pathSeparator}foundation.db',
    );
    var database = FoundationDatabase.open(file: file, key: key);
    final expected = await _initialize(database);
    await database.close();

    database = FoundationDatabase.open(file: file, key: key);
    final actual = await database.loadIdentity();
    expect(actual?.organization.id.value, expected.organization.id.value);
    expect(actual?.branch.name, 'Main Branch');
    await database.close();

    final bytes = file.readAsBytesSync();
    expect(String.fromCharCodes(bytes), isNot(contains('Solar Shop Private')));
  });

  test('wrong database key fails closed', () async {
    final directory = Directory.systemTemp.createTempSync('solar-erp-key-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final file = File(
      '${directory.path}${Platform.pathSeparator}foundation.db',
    );
    final database = FoundationDatabase.open(file: file, key: key);
    await _initialize(database);
    await database.close();

    final wrong = FoundationDatabase.open(
      file: file,
      key: List<int>.filled(32, 99),
    );
    await expectLater(wrong.loadIdentity(), throwsA(anything));
    await wrong.close();
  });

  test('unit of work rolls all setup rows back on failure', () async {
    final directory = Directory.systemTemp.createTempSync('solar-erp-uow-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final database = FoundationDatabase.open(
      file: File('${directory.path}${Platform.pathSeparator}foundation.db'),
      key: key,
    );
    await expectLater(
      database.inTransaction<void>((transaction) async {
        await transaction.insertIdentity(_identity());
        throw StateError('deliberate failure');
      }),
      throwsStateError,
    );
    expect(await database.loadIdentity(), isNull);
    await database.close();
  });

  test('schema v0 upgrades to v3 and creates constrained tables', () async {
    final directory = Directory.systemTemp.createTempSync('solar-erp-migrate-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final file = File(
      '${directory.path}${Platform.pathSeparator}foundation.db',
    );
    final raw = sqlite3.open(file.path);
    _keyRaw(raw, key);
    raw.execute('CREATE TABLE legacy_marker(value TEXT NOT NULL);');
    raw.userVersion = 0;
    raw.close();

    final database = FoundationDatabase.open(file: file, key: key);
    expect(await database.loadIdentity(), isNull);
    await _initialize(database);
    expect(
      (await database.loadIdentity())?.branch.organizationId.value,
      'id-1',
    );

    // Verify schema v3 tables seeded
    final units = await database.getUnits('default_org');
    expect(units.length, greaterThanOrEqualTo(5));

    final categories = await database.getCategories('default_org');
    expect(categories.length, greaterThanOrEqualTo(5));

    await database.close();
  });

  test('CatalogStore and PartyStore persist products, parties, and attachments', () async {
    final directory = Directory.systemTemp.createTempSync('solar-erp-cat-test-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final db = FoundationDatabase.open(
      file: File('${directory.path}${Platform.pathSeparator}foundation.db'),
      key: key,
    );

    final now = DateTime.now();

    // 1. Create Product
    final product = Product(
      id: 'prod_100',
      organizationId: 'org_1',
      sku: 'PANEL-540W',
      name: '540W Mono PERC Solar Panel',
      categoryId: 'cat_panels',
      baseUnitId: 'unit_pcs',
      hsnCode: '85414011',
      costPricePaise: 1200000,
      sellingPricePaise: 1500000,
      attributes: {'wattage': '540', 'cell_type': 'Mono PERC'},
      createdAt: now,
      updatedAt: now,
    );

    await db.saveProduct(product);

    final fetchedProd = await db.getProductBySku('org_1', 'panel-540w');
    expect(fetchedProd, isNotNull);
    expect(fetchedProd?.name, equals('540W Mono PERC Solar Panel'));
    expect(fetchedProd?.attributes['wattage'], equals('540'));

    // 2. Create Party (Customer)
    final party = Party(
      id: 'party_100',
      organizationId: 'org_1',
      name: 'Shree Krushna Solar Farm',
      isCustomer: true,
      isSupplier: false,
      gstin: '27AAAAA0000A1Z5',
      creditLimitPaise: 50000000, // 500,000 INR
      createdAt: now,
      updatedAt: now,
    );

    await db.saveParty(party);

    final fetchedParty = await db.getPartyByGstin('org_1', '27AAAAA0000A1Z5');
    expect(fetchedParty, isNotNull);
    expect(fetchedParty?.name, equals('Shree Krushna Solar Farm'));

    // 3. Create Attachment
    final attachment = Attachment(
      id: 'att_100',
      organizationId: 'org_1',
      fileName: 'spec_sheet.pdf',
      mimeType: 'application/pdf',
      fileSizeBytes: 204800,
      sha256Hash: 'hash999',
      storagePath: '/storage/spec_sheet.pdf',
      createdAt: now,
    );

    await db.saveAttachment(attachment);

    final fetchedAtt = await db.getAttachmentByHash('org_1', 'hash999');
    expect(fetchedAtt, isNotNull);
    expect(fetchedAtt?.fileName, equals('spec_sheet.pdf'));

    await db.close();
  });

  test('AccountingStore persists journal entries, accounts, sequences, and command results', () async {
    final directory = Directory.systemTemp.createTempSync('solar-erp-acc-test-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final db = FoundationDatabase.open(
      file: File('${directory.path}${Platform.pathSeparator}foundation.db'),
      key: key,
    );

    final now = DateTime.now();
    const orgId = 'org_acc_1';

    // 1. Verify default accounts seeded
    final seededAccounts = await db.getAccounts('default_org');
    expect(seededAccounts.length, greaterThanOrEqualTo(14));
    final cashAcc = await db.getAccountByCode('default_org', '1010');
    expect(cashAcc, isNotNull);
    expect(cashAcc?.name, equals('Cash in Hand'));

    // 2. Allocate Document Number Sequence
    final docNum1 = await db.allocateNextDocumentNumber(
      registrationId: 'reg_1',
      fiscalYear: '2026-2027',
      series: 'SKS',
    );
    expect(docNum1, equals('SKS/2627/000001'));

    final docNum2 = await db.allocateNextDocumentNumber(
      registrationId: 'reg_1',
      fiscalYear: '2026-2027',
      series: 'SKS',
    );
    expect(docNum2, equals('SKS/2627/000002'));

    // 3. Save Document Header
    final header = DocumentHeader(
      id: 'doc_100',
      organizationId: orgId,
      branchId: 'branch_1',
      kind: DocumentKind.saleInvoice,
      businessDate: now,
      documentNumber: docNum1,
      fiscalYear: '2026-2027',
      sourceCommandId: 'cmd_invoice_1',
      createdAt: now,
    );
    await db.saveDocumentHeader(header);
    final fetchedHeader = await db.getDocumentHeaderById('doc_100');
    expect(fetchedHeader, isNotNull);
    expect(fetchedHeader?.documentNumber, equals('SKS/2627/000001'));

    // 4. Save Balanced Journal Entry with Party Receivable
    final journalEntry = JournalEntry(
      id: 'je_100',
      organizationId: orgId,
      branchId: 'branch_1',
      documentId: 'doc_100',
      postingDate: now,
      memo: 'Sale of Solar Panel System to Shree Krushna Sales customer',
      lines: [
        JournalLine(
          id: 'l_1',
          journalEntryId: 'je_100',
          accountId: 'acc_ar',
          debitPaise: 1180000, // ₹11,800.00
          partyId: 'party_cust_1',
        ),
        JournalLine(
          id: 'l_2',
          journalEntryId: 'je_100',
          accountId: 'acc_sales',
          creditPaise: 1000000, // ₹10,000.00
        ),
        JournalLine(
          id: 'l_3',
          journalEntryId: 'je_100',
          accountId: 'acc_cgst_out',
          creditPaise: 90000, // ₹900.00
        ),
        JournalLine(
          id: 'l_4',
          journalEntryId: 'je_100',
          accountId: 'acc_sgst_out',
          creditPaise: 90000, // ₹900.00
        ),
      ],
      createdAt: now,
    );
    await db.saveJournalEntry(journalEntry);

    // 5. Fetch Journal Entries and check Party Balance
    final entries = await db.getJournalEntries(orgId, partyId: 'party_cust_1');
    expect(entries.length, equals(1));
    expect(entries.first.lines.length, equals(4));

    final balancePaise = await db.getPartyBalancePaise(orgId, 'party_cust_1');
    expect(balancePaise, equals(1180000)); // ₹11,800 debit balance

    // 6. Command Result Storage
    final cmdRecord = CommandResultRecord(
      id: 'res_1',
      commandId: 'cmd_invoice_1',
      payloadHash: 'hash_inv_1',
      resultJson: '{"status":"ok"}',
      createdAt: now,
    );
    await db.saveCommandResult(cmdRecord);
    final fetchedCmd = await db.getCommandResult('cmd_invoice_1');
    expect(fetchedCmd, isNotNull);
    expect(fetchedCmd?.payloadHash, equals('hash_inv_1'));

    await db.close();
  });

  test('InventoryStore persists locations, movements, balances, serials, and executes ledger rebuild', () async {
    final directory = Directory.systemTemp.createTempSync('solar-erp-inv-db-test-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final db = FoundationDatabase.open(
      file: File('${directory.path}${Platform.pathSeparator}foundation.db'),
      key: key,
    );

    final now = DateTime.now();
    const orgId = 'org_inv_1';

    // 1. Check default locations seeded
    final locs = await db.getLocations('default_org');
    expect(locs.length, greaterThanOrEqualTo(2));
    final sellableLoc = locs.firstWhere((l) => l.type == LocationType.sellable);
    expect(sellableLoc.name, contains('Sellable'));

    // 2. Save custom Location
    final customLoc = Location(
      id: 'loc_custom_1',
      organizationId: orgId,
      branchId: 'branch_1',
      name: 'Kalamb Solar Yard Location A',
      type: LocationType.sellable,
    );
    await db.saveLocation(customLoc);
    final fetchedLoc = await db.getLocationById('loc_custom_1');
    expect(fetchedLoc, isNotNull);
    expect(fetchedLoc?.name, equals('Kalamb Solar Yard Location A'));

    // 3. Save Stock Movements
    final m1 = StockMovement(
      id: 'mv_1',
      organizationId: orgId,
      branchId: 'branch_1',
      documentId: 'doc_receipt_1',
      lineId: 'l_1',
      productId: 'prod_panel_540',
      locationId: 'loc_custom_1',
      quantityMicroUnits: 20000000, // 20 units
      valueDeltaPaise: 2400000, // ₹24,000.00
      costSnapshotMicroRupees: 120000000, // ₹120.00
      movementKind: MovementKind.openingStock,
      createdAt: now,
    );
    await db.saveStockMovement(m1);

    final m2 = StockMovement(
      id: 'mv_2',
      organizationId: orgId,
      branchId: 'branch_1',
      documentId: 'doc_issue_1',
      lineId: 'l_2',
      productId: 'prod_panel_540',
      locationId: 'loc_custom_1',
      quantityMicroUnits: -5000000, // -5 units
      valueDeltaPaise: -600000, // -₹6,000.00
      costSnapshotMicroRupees: 120000000,
      movementKind: MovementKind.saleIssue,
      createdAt: now.add(const Duration(minutes: 10)),
    );
    await db.saveStockMovement(m2);

    // 4. Stock Balance Projection
    final bal = StockBalance(
      productId: 'prod_panel_540',
      locationId: 'loc_custom_1',
      quantityMicroUnits: 15000000, // 15 units
      valuePaise: 1800000, // ₹18,000.00
      updatedAt: now,
    );
    await db.saveStockBalance(bal);

    final fetchedBal = await db.getStockBalance('prod_panel_540', 'loc_custom_1');
    expect(fetchedBal?.quantityInUnits, equals(15.0));
    expect(fetchedBal?.valueInRupees, equals(18000.0));

    // 5. Serial Record & Events
    final serial = SerialRecord(
      id: 'sn_record_1',
      organizationId: orgId,
      productId: 'prod_panel_540',
      serialNumber: 'SN-SKS-540-001',
      state: SerialState.inStock,
      locationId: 'loc_custom_1',
      updatedAt: now,
    );
    await db.saveSerialRecord(serial);

    final fetchedSerial = await db.getSerialByNumber(orgId, 'prod_panel_540', 'sn-sks-540-001');
    expect(fetchedSerial, isNotNull);
    expect(fetchedSerial?.serialNumber, equals('SN-SKS-540-001'));

    final event = SerialEvent(
      id: 'se_1',
      serialId: 'sn_record_1',
      fromState: SerialState.inStock,
      toState: SerialState.sold,
      documentId: 'doc_issue_1',
      createdAt: now,
    );
    await db.saveSerialEvent(event);
    final events = await db.getSerialEvents('sn_record_1');
    expect(events.length, equals(1));
    expect(events.first.toState, equals(SerialState.sold));

    // 6. Execute Rebuild Stock Ledger and verify parity
    final rebuilt = await db.rebuildStockBalances(orgId);
    expect(rebuilt.length, equals(1));
    expect(rebuilt.first.quantityInUnits, equals(15.0));
    expect(rebuilt.first.valueInRupees, equals(18000.0));

    await db.close();
  });

  test('PurchasingStore persists purchase headers, lines, payments, and checks duplicate external invoice', () async {
    final directory = Directory.systemTemp.createTempSync('solar-erp-pur-db-test-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final db = FoundationDatabase.open(
      file: File('${directory.path}${Platform.pathSeparator}foundation.db'),
      key: key,
    );

    final now = DateTime.now();
    const orgId = 'org_pur_1';

    final header = PurchaseHeader(
      id: 'pur_100',
      organizationId: orgId,
      branchId: 'branch_1',
      documentHeaderId: 'doc_pur_100',
      supplierId: 'sup_tata',
      supplierName: 'Tata Solar Systems',
      externalInvoiceNumber: 'INV-2026-99',
      normalizedExternalInvoiceNumber: 'INV-2026-99',
      invoiceDate: now,
      locationId: 'MAIN_WH',
      status: PurchaseStatus.posted,
      subtotalPaise: Money.fromPaise(12000000), // ₹1,20,000.00
      landedCostTotalPaise: Money.fromPaise(500000), // ₹5,000.00
      totalTaxPaise: Money.fromPaise(1440000), // ₹14,400.00
      netTotalPaise: Money.fromPaise(13940000), // ₹1,39,400.00
      amountPaidPaise: Money.fromPaise(3940000), // ₹39,400.00
      balanceDuePaise: Money.fromPaise(10000000), // ₹1,00,000.00
      createdAtUtc: now,
    );

    final line = PurchaseLine(
      id: 'pur_line_100',
      purchaseId: 'pur_100',
      productId: 'prod_540',
      productName: 'Solar Panel 540W Mono PERC',
      sku: 'SP-540',
      quantity: Quantity.fromUnits(10.0),
      unitPurchasePrice: UnitPrice.fromRupees(12000.0),
      discountPaise: Money.zero,
      taxSnapshot: TaxLineResult(
        lineId: 'pur_line_100',
        taxableAmount: Money.fromPaise(12000000),
        cgst: Money.fromPaise(720000),
        sgst: Money.fromPaise(720000),
        igst: Money.zero,
        totalTax: Money.fromPaise(1440000),
        totalAmount: Money.fromPaise(13440000),
      ),
      landedCostAllocationPaise: Money.fromPaise(500000),
      netTotalPaise: Money.fromPaise(13940000),
      serials: const ['SN-PERC-01', 'SN-PERC-02'],
    );

    await db.savePurchase(header: header, lines: [line]);

    final fetchedHeader = await db.getPurchaseHeader('pur_100');
    expect(fetchedHeader, isNotNull);
    expect(fetchedHeader?.supplierName, equals('Tata Solar Systems'));
    expect(fetchedHeader?.balanceDuePaise.inRupees, equals(100000.0));

    final fetchedLines = await db.getPurchaseLines('pur_100');
    expect(fetchedLines.length, equals(1));
    expect(fetchedLines.first.productName, equals('Solar Panel 540W Mono PERC'));
    expect(fetchedLines.first.serials.length, equals(2));

    final isDuplicate = await db.hasDuplicateSupplierInvoice(
      organizationId: orgId,
      supplierId: 'sup_tata',
      financialYear: '${now.year}',
      externalInvoiceNumber: 'inv-2026-99',
    );
    expect(isDuplicate, isTrue);

    final outstanding = await db.getSupplierOutstandingBalance(
      organizationId: orgId,
      supplierId: 'sup_tata',
    );
    expect(outstanding.inRupees, equals(100000.0));

    await db.close();
  });

  test('SalesStore persists sales headers, lines, drafts, and warranty entitlements', () async {
    final directory = Directory.systemTemp.createTempSync('solar-erp-sales-test-');
    addTearDown(() => directory.deleteSync(recursive: true));

    final db = FoundationDatabase.open(
      file: File('${directory.path}${Platform.pathSeparator}foundation.db'),
      key: key,
    );

    const orgId = 'org_sales_test';
    const branchId = 'branch_sales_test';
    final now = DateTime.now();

    final header = SaleHeader(
      id: 'sale_101',
      organizationId: orgId,
      branchId: branchId,
      documentHeaderId: 'doc_sale_101',
      customerPartyId: 'cust_rahul',
      customerName: 'Rahul Sharma',
      businessDate: now,
      locationId: 'MAIN_WH',
      status: SaleStatus.posted,
      subtotalPaise: Money.fromPaise(1500000),
      allocatedDiscountPaise: Money.zero,
      totalTaxPaise: Money.fromPaise(270000),
      grandTotalPaise: Money.fromPaise(1770000),
      amountPaidPaise: Money.fromPaise(1770000),
      balanceDuePaise: Money.zero,
      createdAtUtc: now,
      notes: 'Counter POS Sale',
    );

    final line = SaleLine(
      id: 'sale_line_101',
      saleId: 'sale_101',
      productId: 'prod_540',
      productName: 'Solar Panel 540W Mono PERC',
      sku: 'SOL-540',
      hsnCode: '8541',
      baseUnit: 'NOS',
      quantity: Quantity.fromUnits(1.0),
      unitPrice: UnitPrice.fromRupees(15000.0),
      lineDiscountPaise: Money.zero,
      taxSnapshot: TaxLineResult(
        lineId: 'sale_line_101',
        taxableAmount: Money.fromPaise(1500000),
        cgst: Money.fromPaise(135000),
        sgst: Money.fromPaise(135000),
        igst: Money.zero,
        totalTax: Money.fromPaise(270000),
        totalAmount: Money.fromPaise(1770000),
      ),
      costSnapshotMicroRupees: 12000000000,
      netTotalPaise: Money.fromPaise(1770000),
      serials: const ['SN-PERC-999'],
    );

    await db.saveSale(header: header, lines: [line]);

    final fetchedHeader = await db.getSaleHeader('sale_101');
    expect(fetchedHeader, isNotNull);
    expect(fetchedHeader?.customerName, equals('Rahul Sharma'));
    expect(fetchedHeader?.grandTotalPaise.inRupees, equals(17700.0));

    final fetchedLines = await db.getSaleLines('sale_101');
    expect(fetchedLines.length, equals(1));
    expect(fetchedLines.first.productName, equals('Solar Panel 540W Mono PERC'));
    expect(fetchedLines.first.serials.first, equals('SN-PERC-999'));

    final salesList = await db.listSales(organizationId: orgId, customerPartyId: 'cust_rahul');
    expect(salesList.length, equals(1));

    // Test Drafts
    final draft = SaleDraft(
      id: 'draft_1',
      organizationId: orgId,
      branchId: branchId,
      customerPartyId: 'cust_rahul',
      customerName: 'Rahul Sharma',
      linesJson: '[{"productId":"prod_540","qty":1}]',
      updatedAtUtc: now,
    );
    await db.saveSaleDraft(draft);
    final fetchedDraft = await db.getSaleDraft('draft_1');
    expect(fetchedDraft, isNotNull);
    expect(fetchedDraft?.customerName, equals('Rahul Sharma'));

    final draftsList = await db.listSaleDrafts(orgId);
    expect(draftsList.length, equals(1));

    await db.deleteSaleDraft('draft_1');
    final deletedDraft = await db.getSaleDraft('draft_1');
    expect(deletedDraft, isNull);

    // Test Warranty Entitlements
    final warranty = WarrantyEntitlement(
      id: 'war_1',
      serialId: 'sn_999',
      productId: 'prod_540',
      serialNumber: 'SN-PERC-999',
      partyId: 'cust_rahul',
      saleDocumentId: 'sale_101',
      startDate: now,
      endDate: now.add(const Duration(days: 365 * 25)),
      termsSnapshot: '25 Year Manufacturer Performance Warranty',
      createdAtUtc: now,
    );
    await db.saveWarrantyEntitlement(warranty);

    final warranties = await db.getWarrantyEntitlementsForCustomer(
      organizationId: orgId,
      partyId: 'cust_rahul',
    );
    expect(warranties.length, equals(1));
    expect(warranties.first.serialNumber, equals('SN-PERC-999'));

    await db.close();
  });

  test('FinanceStore persists sales returns, purchase returns, expenses, cash sessions, and aging buckets', () async {
    final directory = Directory.systemTemp.createTempSync('solar-erp-fin-db-test-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final db = FoundationDatabase.open(
      file: File('${directory.path}${Platform.pathSeparator}foundation.db'),
      key: key,
    );

    final now = DateTime.now();
    const orgId = 'org_fin_1';
    const branchId = 'branch_main';

    // 1. Sales Return
    final salesHeader = SalesReturnHeader(
      id: 'sr_100',
      organizationId: orgId,
      branchId: branchId,
      documentHeaderId: 'doc_sr_100',
      originalSaleId: 'sale_100',
      customerPartyId: 'party_cust_1',
      customerName: 'Kishor Patil',
      returnDate: now,
      locationId: 'MAIN_WH',
      status: SalesReturnStatus.posted,
      subtotalPaise: Money.fromPaise(500000),
      totalTaxPaise: Money.fromPaise(90000),
      grandTotalPaise: Money.fromPaise(590000),
      refundedAmountPaise: Money.fromPaise(590000),
      createdAtUtc: now,
      reason: 'Defective unit',
    );

    final salesLine = SalesReturnLine(
      id: 'sr_line_100',
      salesReturnId: 'sr_100',
      saleLineId: 'sale_line_100',
      productId: 'prod_inv_100',
      productName: 'Luminous Solar Inverter 3kVA',
      sku: 'INV-3KVA',
      quantity: Quantity.fromUnits(1.0),
      unitPrice: UnitPrice.fromRupees(5000.0),
      lineDiscountPaise: Money.zero,
      taxSnapshot: TaxLineResult(
        lineId: 'sr_line_100',
        taxableAmount: Money.fromPaise(500000),
        cgst: Money.fromPaise(45000),
        sgst: Money.fromPaise(45000),
        igst: Money.zero,
        totalTax: Money.fromPaise(90000),
        totalAmount: Money.fromPaise(590000),
      ),
      costSnapshotMicroRupees: 4000000000,
      netTotalPaise: Money.fromPaise(590000),
      disposition: ReturnDisposition.returnToStock,
    );

    await db.saveSalesReturn(header: salesHeader, lines: [salesLine]);

    final fetchedSrHeader = await db.getSalesReturnHeader('sr_100');
    expect(fetchedSrHeader, isNotNull);
    expect(fetchedSrHeader?.customerName, equals('Kishor Patil'));
    expect(fetchedSrHeader?.grandTotalPaise.paise, equals(590000));

    final fetchedSrLines = await db.getSalesReturnLines('sr_100');
    expect(fetchedSrLines.length, equals(1));
    expect(fetchedSrLines.first.productName, equals('Luminous Solar Inverter 3kVA'));

    final srList = await db.listSalesReturns(orgId);
    expect(srList.length, equals(1));

    // 2. Purchase Return
    final purHeader = PurchaseReturnHeader(
      id: 'pr_100',
      organizationId: orgId,
      branchId: branchId,
      documentHeaderId: 'doc_pr_100',
      originalPurchaseId: 'pur_100',
      supplierId: 'party_sup_1',
      supplierName: 'Tata Solar Distribution',
      returnDate: now,
      locationId: 'MAIN_WH',
      status: PurchaseReturnStatus.posted,
      subtotalPaise: Money.fromPaise(1000000),
      totalTaxPaise: Money.fromPaise(180000),
      grandTotalPaise: Money.fromPaise(1180000),
      createdAtUtc: now,
      reason: 'Wrong SKU delivered',
    );

    final purLine = PurchaseReturnLine(
      id: 'pr_line_100',
      purchaseReturnId: 'pr_100',
      purchaseLineId: 'pur_line_100',
      productId: 'prod_panel_540',
      productName: 'Solar Panel 540W',
      sku: 'SP-540',
      quantity: Quantity.fromUnits(1.0),
      unitPurchasePrice: UnitPrice.fromRupees(10000.0),
      taxSnapshot: TaxLineResult(
        lineId: 'pr_line_100',
        taxableAmount: Money.fromPaise(1000000),
        cgst: Money.fromPaise(90000),
        sgst: Money.fromPaise(90000),
        igst: Money.zero,
        totalTax: Money.fromPaise(180000),
        totalAmount: Money.fromPaise(1180000),
      ),
      netTotalPaise: Money.fromPaise(1180000),
    );

    await db.savePurchaseReturn(header: purHeader, lines: [purLine]);

    final fetchedPrHeader = await db.getPurchaseReturnHeader('pr_100');
    expect(fetchedPrHeader, isNotNull);
    expect(fetchedPrHeader?.supplierName, equals('Tata Solar Distribution'));

    final fetchedPrLines = await db.getPurchaseReturnLines('pr_100');
    expect(fetchedPrLines.length, equals(1));

    // 3. Expenses & Categories
    final categories = await db.getExpenseCategories(orgId);
    expect(categories.isNotEmpty, isTrue);

    final expense = ExpenseEntry(
      id: 'exp_1',
      organizationId: orgId,
      branchId: branchId,
      categoryId: 'exp_cat_rent',
      categoryName: 'Office Rent & Maintenance',
      accountCode: '6100',
      amountPaise: Money.fromPaise(1500000), // ₹15,000.00
      expenseDate: now,
      paymentMethod: 'cash',
      createdAtUtc: now,
      referenceNumber: 'RENT-SEP-2026',
    );

    await db.saveExpenseEntry(expense);
    final expenseList = await db.listExpenseEntries(orgId);
    expect(expenseList.length, equals(1));
    expect(expenseList.first.amountPaise.paise, equals(1500000));

    // 4. Cash Counter Sessions
    final session = CashSession(
      id: 'cs_1',
      organizationId: orgId,
      branchId: branchId,
      userId: 'user_counter_1',
      username: 'cashier1',
      openedAtUtc: now,
      openingCashPaise: Money.fromPaise(500000), // ₹5,000
      expectedCashPaise: Money.fromPaise(1200000), // ₹12,000
      countedCashPaise: Money.fromPaise(1200000),
      variancePaise: Money.zero,
      status: CashSessionStatus.open,
    );

    await db.saveCashSession(session);

    final activeSession = await db.getActiveCashSession(orgId, 'user_counter_1');
    expect(activeSession, isNotNull);
    expect(activeSession?.openingCashPaise.paise, equals(500000));

    final sessions = await db.listCashSessions(orgId);
    expect(sessions.length, equals(1));

    // 5. Party Aging Buckets
    final party = Party(
      id: 'party_cust_1',
      organizationId: orgId,
      name: 'Kishor Patil',
      isCustomer: true,
      isSupplier: false,
      createdAt: now,
      updatedAt: now,
    );
    await db.saveParty(party);

    final aging = await db.getPartyAgingBuckets(orgId, isCustomer: true);
    expect(aging.length, equals(1));
    expect(aging.first.partyId, equals('party_cust_1'));

    await db.close();
  });

  test('FoundationDatabase persists and retrieves isMadeToOrder for products', () async {
    final directory = Directory.systemTemp.createTempSync('solar-erp-mto-test-');
    addTearDown(() => directory.deleteSync(recursive: true));
    final db = FoundationDatabase.open(
      file: File('${directory.path}${Platform.pathSeparator}foundation.db'),
      key: key,
    );

    final now = DateTime.now();

    // 1. Standard product (isMadeToOrder = false)
    final stdProduct = Product(
      id: 'prod_std_db',
      organizationId: 'org_1',
      sku: 'STD-PANEL-300',
      name: 'Standard Panel 300W',
      categoryId: 'cat_panels',
      baseUnitId: 'unit_pcs',
      hsnCode: '85414011',
      isMadeToOrder: false,
      createdAt: now,
      updatedAt: now,
    );
    await db.saveProduct(stdProduct);

    // 2. Made-to-order product (isMadeToOrder = true)
    final mtoProduct = Product(
      id: 'prod_mto_db',
      organizationId: 'org_1',
      sku: 'MTO-ROOF-STRUCTURE',
      name: 'Custom Elevated Roof Structure',
      categoryId: 'mountingStructure',
      baseUnitId: 'unit_set',
      hsnCode: '73089000',
      isMadeToOrder: true,
      createdAt: now,
      updatedAt: now,
    );
    await db.saveProduct(mtoProduct);

    // Retrieve and verify Product isMadeToOrder via getProductById
    final fetchedStd = await db.getProductById('org_1', 'prod_std_db');
    expect(fetchedStd, isNotNull);
    expect(fetchedStd?.isMadeToOrder, isFalse);

    final fetchedMto = await db.getProductById('org_1', 'prod_mto_db');
    expect(fetchedMto, isNotNull);
    expect(fetchedMto?.isMadeToOrder, isTrue);

    // Retrieve and verify Product isMadeToOrder via getProductBySku
    final fetchedMtoBySku = await db.getProductBySku('org_1', 'MTO-ROOF-STRUCTURE');
    expect(fetchedMtoBySku, isNotNull);
    expect(fetchedMtoBySku?.isMadeToOrder, isTrue);

    // Retrieve and verify via searchProducts
    final searchResults = await db.searchProducts('org_1');
    final mtoFromSearch = searchResults.firstWhere((p) => p.id == 'prod_mto_db');
    expect(mtoFromSearch.isMadeToOrder, isTrue);
    final stdFromSearch = searchResults.firstWhere((p) => p.id == 'prod_std_db');
    expect(stdFromSearch.isMadeToOrder, isFalse);

    await db.close();
  });
}

Future<FoundationIdentity> _initialize(FoundationStore store) {
  return InitializeFoundation(
    store: store,
    clock: _FixedClock(),
    ids: _SequenceIds(),
  ).call(
    FirstRunSetup.validate(
      legalName: 'Solar Shop Private',
      displayName: 'Solar Shop',
      branchName: 'Main Branch',
      timeZone: 'Asia/Kolkata',
      locale: 'en',
      financialYearStartsOn: DateTime.utc(2026, 4),
      financialYearEndsOn: DateTime.utc(2027, 3, 31),
    ),
  );
}

FoundationIdentity _identity() => FoundationIdentity(
  organization: Organization(
    id: const OrganizationId('rollback-org'),
    legalName: 'Rollback',
    displayName: 'Rollback',
    createdAtUtc: DateTime.utc(2026),
  ),
  branch: Branch(
    id: const BranchId('rollback-branch'),
    organizationId: const OrganizationId('rollback-org'),
    name: 'Rollback',
    timeZone: 'Asia/Kolkata',
    locale: 'en',
    createdAtUtc: DateTime.utc(2026),
  ),
  financialPeriod: FinancialPeriod(
    id: const FinancialPeriodId('rollback-period'),
    organizationId: const OrganizationId('rollback-org'),
    branchId: const BranchId('rollback-branch'),
    startsOn: DateTime.utc(2026, 4),
    endsOn: DateTime.utc(2027, 3, 31),
    createdAtUtc: DateTime.utc(2026),
  ),
);

void _keyRaw(Database database, List<int> key) {
  final hex = key.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  database.execute('PRAGMA key = "x\'$hex\'";');
}

final class _FixedClock implements Clock {
  @override
  DateTime nowUtc() => DateTime.utc(2026, 9, 25, 12);
}

final class _SequenceIds implements IdGenerator {
  var _next = 0;

  @override
  String next() => 'id-${++_next}';
}
