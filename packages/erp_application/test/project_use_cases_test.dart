import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

final class InMemoryProjectStore implements ProjectStore {
  final Map<String, QuotationHeader> quotationHeaders = {};
  final Map<String, List<QuotationLine>> quotationLines = {};
  final Map<String, SolarProject> projects = {};
  final List<ProjectMaterialIssue> materialIssues = [];

  @override
  Future<void> saveQuotation({
    required QuotationHeader header,
    required List<QuotationLine> lines,
  }) async {
    quotationHeaders[header.id] = header;
    quotationLines[header.id] = lines;
  }

  @override
  Future<QuotationHeader?> getQuotationHeader(String id) async => quotationHeaders[id];

  @override
  Future<List<QuotationLine>> getQuotationLines(String quotationId) async => quotationLines[quotationId] ?? [];

  @override
  Future<List<QuotationHeader>> listQuotations(String organizationId) async =>
      quotationHeaders.values.where((q) => q.organizationId == organizationId).toList();

  @override
  Future<void> saveProject(SolarProject project) async {
    projects[project.id] = project;
  }

  @override
  Future<SolarProject?> getProject(String id) async => projects[id];

  @override
  Future<List<SolarProject>> listProjects(String organizationId) async =>
      projects.values.where((p) => p.organizationId == organizationId).toList();

  @override
  Future<void> saveMaterialIssue({required ProjectMaterialIssue issue}) async {
    materialIssues.add(issue);
  }

  @override
  Future<List<ProjectMaterialIssue>> getMaterialIssues(String projectId) async =>
      materialIssues.where((i) => i.projectId == projectId).toList();
}

final class InMemoryInventoryStoreForProjects implements InventoryStore {
  final Map<String, StockBalance> balances = {};
  final List<StockMovement> movements = [];

  @override
  Future<void> saveLocation(Location location) async {}
  @override
  Future<List<Location>> getLocations(String organizationId, {String? branchId}) async => [];
  @override
  Future<Location?> getLocationById(String id) async => null;

  @override
  Future<void> saveStockMovement(StockMovement movement) async {
    movements.add(movement);
  }

  @override
  Future<List<StockMovement>> getStockMovements(
    String organizationId, {
    String? productId,
    String? locationId,
    int limit = 100,
  }) async => movements;

  @override
  Future<void> saveStockBalance(StockBalance balance) async {
    balances['${balance.productId}_${balance.locationId}'] = balance;
  }

  @override
  Future<StockBalance?> getStockBalance(String productId, String locationId) async {
    return balances['${productId}_$locationId'];
  }

  @override
  Future<List<StockBalance>> getStockBalancesForProduct(String organizationId, String productId) async =>
      balances.values.where((b) => b.productId == productId).toList();

  @override
  Future<List<StockBalance>> getAllStockBalances(String organizationId, {String? locationId}) async =>
      balances.values.toList();

  @override
  Future<List<StockBalance>> rebuildStockBalances(String organizationId) async => balances.values.toList();

  @override
  Future<void> saveSerialRecord(SerialRecord serial) async {}

  @override
  Future<SerialRecord?> getSerialByNumber(String organizationId, String productId, String serialNumber) async => null;

  @override
  Future<List<SerialRecord>> getSerialsForProduct(String organizationId, String productId, {SerialState? state}) async => [];

  @override
  Future<void> saveSerialEvent(SerialEvent event) async {}

  @override
  Future<List<SerialEvent>> getSerialEvents(String serialId) async => [];

  @override
  Future<void> saveBatchRecord(BatchRecord batch) async {}

  @override
  Future<List<BatchRecord>> getBatchesForProduct(String organizationId, String productId) async => [];

  @override
  Future<void> saveReservation(Reservation reservation) async {}

  @override
  Future<List<Reservation>> getActiveReservationsForProduct(String organizationId, String productId) async => [];

  @override
  Future<void> saveStockAdjustment(StockAdjustment adjustment) async {}

  @override
  Future<List<StockAdjustment>> getStockAdjustments(String organizationId, {int limit = 100}) async => [];
}

final class InMemoryAccountingStoreForProjects implements AccountingStore {
  final Map<String, Account> accounts = {};
  final List<JournalEntry> journals = [];
  final Map<String, DocumentHeader> docHeaders = {};
  int seq = 1;

  @override
  Future<void> saveAccount(Account account) async {
    accounts[account.id] = account;
  }

  @override
  Future<List<Account>> getAccounts(String organizationId) async => accounts.values.toList();

  @override
  Future<Account?> getAccountByCode(String organizationId, String code) async {
    return accounts.values.firstWhere((a) => a.code == code, orElse: () {
      return Account(
        id: 'acc_$code',
        organizationId: organizationId,
        code: code,
        name: 'Account $code',
        type: AccountType.asset,
      );
    });
  }

  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {
    journals.add(entry);
  }

  @override
  Future<List<JournalEntry>> getJournalEntries(String organizationId, {String? partyId, int limit = 100}) async => journals;

  @override
  Future<int> getPartyBalancePaise(String organizationId, String partyId) async => 0;

  @override
  Future<void> saveDocumentHeader(DocumentHeader header) async {
    docHeaders[header.id] = header;
  }

  @override
  Future<DocumentHeader?> getDocumentHeaderById(String id) async => docHeaders[id];

  @override
  Future<String> allocateNextDocumentNumber({
    required String registrationId,
    required String fiscalYear,
    required String series,
  }) async {
    return '$series/2627/${(seq++).toString().padLeft(6, '0')}';
  }

  @override
  Future<CommandResultRecord?> getCommandResult(String commandId) async => null;

  @override
  Future<void> saveCommandResult(CommandResultRecord record) async {}
}

void main() {
  group('P15 Solar Projects & BOM Application Use Cases Tests', () {
    late InMemoryProjectStore projectStore;
    late InMemoryInventoryStoreForProjects inventoryStore;
    late InMemoryAccountingStoreForProjects accountingStore;

    late CreateQuotationUseCase createQuotationUseCase;
    late ApproveQuotationUseCase approveQuotationUseCase;
    late IssueProjectMaterialsUseCase issueMaterialsUseCase;
    late ReturnProjectMaterialsUseCase returnMaterialsUseCase;
    late PostProjectInvoiceUseCase postInvoiceUseCase;
    late GenerateProjectBudgetReportUseCase reportUseCase;

    final adminSession = UserSession(
      id: const SessionId('sess_admin'),
      userId: const UserId('usr_admin'),
      username: 'admin',
      roleId: Role.adminRoleId,
      branchId: const BranchId('branch_1'),
      capabilities: Role.admin.capabilities,
      token: 'tok_admin',
      expiresAtUtc: DateTime.now().add(const Duration(hours: 8)),
      lastActivityAtUtc: DateTime.now(),
    );

    final adminContext = CommandContext(
      session: adminSession,
      timestampUtc: DateTime.now(),
    );

    setUp(() async {
      projectStore = InMemoryProjectStore();
      inventoryStore = InMemoryInventoryStoreForProjects();
      accountingStore = InMemoryAccountingStoreForProjects();

      createQuotationUseCase = CreateQuotationUseCase(
        projectStore: projectStore,
        accountingStore: accountingStore,
      );

      approveQuotationUseCase = ApproveQuotationUseCase(
        projectStore: projectStore,
        accountingStore: accountingStore,
      );

      issueMaterialsUseCase = IssueProjectMaterialsUseCase(
        projectStore: projectStore,
        inventoryStore: inventoryStore,
        accountingStore: accountingStore,
      );

      returnMaterialsUseCase = ReturnProjectMaterialsUseCase(
        projectStore: projectStore,
        inventoryStore: inventoryStore,
        accountingStore: accountingStore,
      );

      postInvoiceUseCase = PostProjectInvoiceUseCase(
        projectStore: projectStore,
        accountingStore: accountingStore,
      );

      reportUseCase = GenerateProjectBudgetReportUseCase(
        projectStore: projectStore,
      );

      // Seed default accounts
      for (final acc in Account.defaultAccounts('org_1')) {
        await accountingStore.saveAccount(acc);
      }

      // Seed stock balance (20 panels @ ₹12,000 unit cost = ₹2,40,000)
      await inventoryStore.saveStockBalance(
        StockBalance(
          productId: 'prod_panel',
          locationId: 'MAIN_WH',
          quantityMicroUnits: 20000000, // 20 units
          valuePaise: 24000000,
          updatedAt: DateTime.now(),
        ),
      );
    });

    test('Full Solar Project Lifecycle: Quote -> Approve -> Issue -> Return -> Invoice -> Report (No Double Stock Issue)', () async {
      // 1. Create Quotation Revision 1
      final quote = await createQuotationUseCase.execute(
        adminContext,
        organizationId: 'org_1',
        branchId: 'branch_1',
        customerPartyId: 'cust_1',
        customerName: 'Ramesh Patil',
        validUntil: DateTime.now().add(const Duration(days: 30)),
        installationChargesPaise: Money.fromRupees(20000.0),
        lineInputs: [
          QuotationLineInput(
            productId: 'prod_panel',
            productName: 'Solar Panel 540W',
            sku: 'SP-540',
            hsnCode: '8541',
            quantity: Quantity.fromUnits(10.0),
            unitPrice: UnitPrice.fromRupees(15000.0), // ₹1,50,000 subtotal
            taxRate: TaxRate.fromBps(1800), // 18% GST = ₹27,000 tax
          ),
        ],
      );

      expect(quote.status, equals(QuotationStatus.draft));
      expect(quote.revisionNumber, equals(1));
      expect(quote.grandTotalPaise.inRupees, equals(197000.0)); // ₹1.5L + ₹27K tax + ₹20K labor = ₹1,97,000

      // 2. Approve Quotation -> Creates Solar Project
      final project = await approveQuotationUseCase.execute(
        adminContext,
        quotationId: quote.id,
        projectName: '5kW Rooftop Solar Installation',
        siteAddress: 'Rajmata Jijau Chowk, Kalamb',
      );

      expect(project.status, equals(ProjectStatus.planning));
      expect(project.budgetMaterialsPaise.inRupees, equals(177000.0)); // ₹1.5L + ₹27K tax
      expect(project.budgetLaborPaise.inRupees, equals(20000.0));
      expect(project.wipBalancePaise, equals(Money.zero));

      // 3. Issue Materials to Site (Issues stock to WIP Asset 1400)
      final issue = await issueMaterialsUseCase.execute(
        adminContext,
        projectId: project.id,
        locationId: 'MAIN_WH',
        issueDate: DateTime.now(),
        lineInputs: [
          IssueMaterialLineInput(
            productId: 'prod_panel',
            productName: 'Solar Panel 540W',
            sku: 'SP-540',
            quantity: Quantity.fromUnits(10.0),
          ),

        ],
      );

      expect(issue.totalCostPaise.inRupees, equals(120000.0)); // 10 * ₹12,000 = ₹1,20,000

      // Stock balance reduced from 20 to 10 units
      final balanceAfterIssue = await inventoryStore.getStockBalance('prod_panel', 'MAIN_WH');
      expect(balanceAfterIssue?.quantityMicroUnits, equals(10000000)); // 10 units remaining

      // Updated WIP balance on project
      final projectInWip = await projectStore.getProject(project.id);
      expect(projectInWip?.wipBalancePaise.inRupees, equals(120000.0));
      expect(projectInWip?.status, equals(ProjectStatus.inProgress));

      // Check Journal posted: 1400 WIP Dr ₹1,20,000, 1200 Inventory Cr ₹1,20,000
      expect(accountingStore.journals.length, equals(1));
      final wipJournal = accountingStore.journals.first;
      expect(wipJournal.lines.first.debitPaise, equals(12000000));
      expect(wipJournal.lines.last.creditPaise, equals(12000000));

      // 4. Return Unused Material (1 panel returned to stock @ ₹12,000)
      await returnMaterialsUseCase.execute(
        adminContext,
        projectId: project.id,
        locationId: 'MAIN_WH',
        productId: 'prod_panel',
        quantity: Quantity.fromUnits(1.0),
        unitCostPaise: Money.fromRupees(12000.0),
      );

      final balanceAfterReturn = await inventoryStore.getStockBalance('prod_panel', 'MAIN_WH');
      expect(balanceAfterReturn?.quantityMicroUnits, equals(11000000)); // 11 units

      final projectAfterReturn = await projectStore.getProject(project.id);
      expect(projectAfterReturn?.wipBalancePaise.inRupees, equals(108000.0)); // ₹1,20,000 - ₹12,000 = ₹1,08,000

      // 5. Post Project Invoice (Recognizes Revenue & transfers WIP to COGS without issuing physical stock again)
      await postInvoiceUseCase.execute(
        adminContext,
        projectId: project.id,
        invoiceAmountPaise: Money.fromRupees(197000.0),
        invoiceDate: DateTime.now(),
      );

      final completedProject = await projectStore.getProject(project.id);
      expect(completedProject?.status, equals(ProjectStatus.completed));
      expect(completedProject?.wipBalancePaise, equals(Money.zero));
      expect(completedProject?.invoicedPaise.inRupees, equals(197000.0));

      // Verify stock was NOT issued again (remains 11 units)
      final balanceAfterInvoice = await inventoryStore.getStockBalance('prod_panel', 'MAIN_WH');
      expect(balanceAfterInvoice?.quantityMicroUnits, equals(11000000));

      // 6. Generate Project Budget vs Actual BI Report
      final report = await reportUseCase.execute(adminContext, projectId: project.id);
      expect(report.invoicedPaise.inRupees, equals(197000.0));
      expect(report.totalActualCostPaise.inRupees, equals(108000.0));
      expect(report.estimatedGrossProfitPaise.inRupees, equals(89000.0)); // ₹1,97,000 - ₹1,08,000 = ₹89,000
      expect(report.marginPercentage, greaterThan(45.0));
    });
  });
}
