import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

class InMemoryFinanceStore implements FinanceStore {
  final Map<String, SalesReturnHeader> salesReturnHeaders = {};
  final Map<String, List<SalesReturnLine>> salesReturnLines = {};
  final Map<String, PurchaseReturnHeader> purchaseReturnHeaders = {};
  final Map<String, List<PurchaseReturnLine>> purchaseReturnLines = {};
  final Map<String, ExpenseCategory> expenseCategories = {};
  final Map<String, ExpenseEntry> expenseEntries = {};
  final Map<String, CashSession> cashSessions = {};

  @override
  Future<void> saveSalesReturn({
    required SalesReturnHeader header,
    required List<SalesReturnLine> lines,
  }) async {
    salesReturnHeaders[header.id] = header;
    salesReturnLines[header.id] = lines;
  }

  @override
  Future<SalesReturnHeader?> getSalesReturnHeader(String id) async => salesReturnHeaders[id];

  @override
  Future<List<SalesReturnLine>> getSalesReturnLines(String salesReturnId) async =>
      salesReturnLines[salesReturnId] ?? [];

  @override
  Future<List<SalesReturnHeader>> listSalesReturns(String organizationId) async =>
      salesReturnHeaders.values.where((h) => h.organizationId == organizationId).toList();

  @override
  Future<void> savePurchaseReturn({
    required PurchaseReturnHeader header,
    required List<PurchaseReturnLine> lines,
  }) async {
    purchaseReturnHeaders[header.id] = header;
    purchaseReturnLines[header.id] = lines;
  }

  @override
  Future<PurchaseReturnHeader?> getPurchaseReturnHeader(String id) async =>
      purchaseReturnHeaders[id];

  @override
  Future<List<PurchaseReturnLine>> getPurchaseReturnLines(String purchaseReturnId) async =>
      purchaseReturnLines[purchaseReturnId] ?? [];

  @override
  Future<List<PurchaseReturnHeader>> listPurchaseReturns(String organizationId) async =>
      purchaseReturnHeaders.values.where((h) => h.organizationId == organizationId).toList();

  @override
  Future<void> saveExpenseCategory(ExpenseCategory category) async {
    expenseCategories[category.id] = category;
  }

  @override
  Future<List<ExpenseCategory>> getExpenseCategories(String organizationId) async =>
      expenseCategories.values.toList();

  @override
  Future<void> saveExpenseEntry(ExpenseEntry entry) async {
    expenseEntries[entry.id] = entry;
  }

  @override
  Future<List<ExpenseEntry>> listExpenseEntries(String organizationId, {String? categoryId}) async =>
      expenseEntries.values.where((e) => categoryId == null || e.categoryId == categoryId).toList();

  @override
  Future<void> saveCashSession(CashSession session) async {
    cashSessions[session.id] = session;
  }

  @override
  Future<CashSession?> getActiveCashSession(String organizationId, String userId) async {
    for (final s in cashSessions.values) {
      if (s.userId == userId && s.status == CashSessionStatus.open) return s;
    }
    return null;
  }

  @override
  Future<List<CashSession>> listCashSessions(String organizationId) async =>
      cashSessions.values.toList();

  @override
  Future<List<PartyAgingBucket>> getPartyAgingBuckets(String organizationId, {required bool isCustomer}) async => [];
}

class InMemorySalesStore implements SalesStore {
  final Map<String, SaleHeader> headers = {};
  final Map<String, List<SaleLine>> lines = {};

  @override
  Future<void> saveSale({required SaleHeader header, required List<SaleLine> lines}) async {
    headers[header.id] = header;
    this.lines[header.id] = lines;
  }

  @override
  Future<SaleHeader?> getSaleHeader(String id) async => headers[id];

  @override
  Future<List<SaleLine>> getSaleLines(String saleId) async => lines[saleId] ?? [];

  @override
  Future<List<SaleHeader>> listSales({required String organizationId, String? customerPartyId}) async =>
      headers.values.toList();

  @override
  Future<void> saveSaleDraft(SaleDraft draft) async {}
  @override
  Future<SaleDraft?> getSaleDraft(String id) async => null;
  @override
  Future<void> deleteSaleDraft(String id) async {}
  @override
  Future<List<SaleDraft>> listSaleDrafts(String organizationId) async => [];
  @override
  Future<void> saveWarrantyEntitlement(WarrantyEntitlement entitlement) async {}
  @override
  Future<List<WarrantyEntitlement>> getWarrantyEntitlementsForCustomer({required String organizationId, required String partyId}) async => [];
  @override
  Future<List<WarrantyEntitlement>> getAllWarrantyEntitlements({required String organizationId}) async => [];
}


class InMemoryPurchasingStore implements PurchasingStore {
  final Map<String, PurchaseHeader> headers = {};
  final Map<String, List<PurchaseLine>> lines = {};
  final List<Payment> payments = [];

  @override
  Future<void> savePurchase({required PurchaseHeader header, required List<PurchaseLine> lines}) async {
    headers[header.id] = header;
    this.lines[header.id] = lines;
  }

  @override
  Future<PurchaseHeader?> getPurchaseHeader(String id) async => headers[id];

  @override
  Future<List<PurchaseLine>> getPurchaseLines(String purchaseId) async => lines[purchaseId] ?? [];

  @override
  Future<List<PurchaseHeader>> listPurchases({required String organizationId, String? supplierId}) async =>
      headers.values.toList();

  @override
  Future<bool> hasDuplicateSupplierInvoice({required String organizationId, required String supplierId, required String financialYear, required String externalInvoiceNumber}) async => false;

  @override
  Future<void> savePayment({required Payment payment, required List<PaymentAllocation> allocations}) async {
    payments.add(payment);
  }

  @override
  Future<Money> getSupplierOutstandingBalance({required String organizationId, required String supplierId}) async => Money.zero;
}

class InMemoryInventoryStore implements InventoryStore {
  final List<StockMovement> movements = [];
  final Map<String, StockBalance> balances = {};
  final Map<String, SerialRecord> serials = {};

  @override
  Future<void> saveLocation(Location location) async {}
  @override
  Future<List<Location>> getLocations(String organizationId, {String? branchId}) async => [];
  @override
  Future<Location?> getLocationById(String id) async => null;
  @override
  Future<void> saveStockMovement(StockMovement movement) async { movements.add(movement); }
  @override
  Future<List<StockMovement>> getStockMovements(String organizationId, {String? productId, String? locationId, int limit = 100}) async => movements;
  @override
  Future<void> saveStockBalance(StockBalance balance) async { balances['${balance.productId}_${balance.locationId}'] = balance; }
  @override
  Future<StockBalance?> getStockBalance(String productId, String locationId) async => balances['${productId}_$locationId'];
  @override
  Future<List<StockBalance>> getStockBalancesForProduct(String organizationId, String productId) async => balances.values.toList();
  @override
  Future<List<StockBalance>> getAllStockBalances(String organizationId, {String? locationId}) async => balances.values.toList();
  @override
  Future<List<StockBalance>> rebuildStockBalances(String organizationId) async => balances.values.toList();
  @override
  Future<void> saveSerialRecord(SerialRecord serial) async { serials[serial.serialNumber] = serial; }
  @override
  Future<SerialRecord?> getSerialByNumber(String organizationId, String productId, String serialNumber) async => serials[serialNumber];
  @override
  Future<List<SerialRecord>> getSerialsForProduct(String organizationId, String productId, {SerialState? state}) async => serials.values.toList();
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

class InMemoryAccountingStore implements AccountingStore {
  final List<JournalEntry> journals = [];
  final Map<String, DocumentHeader> docHeaders = {};
  int seq = 1;

  @override
  Future<void> saveAccount(Account account) async {}
  @override
  Future<List<Account>> getAccounts(String organizationId) async => [];
  @override
  Future<Account?> getAccountByCode(String organizationId, String code) async => null;
  @override
  Future<void> saveJournalEntry(JournalEntry entry) async { journals.add(entry); }
  @override
  Future<List<JournalEntry>> getJournalEntries(String organizationId, {String? partyId, int limit = 100}) async => journals;
  @override
  Future<int> getPartyBalancePaise(String organizationId, String partyId) async => 0;
  @override
  Future<void> saveDocumentHeader(DocumentHeader header) async { docHeaders[header.id] = header; }
  @override
  Future<DocumentHeader?> getDocumentHeaderById(String id) async => docHeaders[id];
  @override
  Future<String> allocateNextDocumentNumber({required String registrationId, required String fiscalYear, required String series}) async =>
      '$series/2627/${(seq++).toString().padLeft(6, '0')}';
  @override
  Future<CommandResultRecord?> getCommandResult(String commandId) async => null;
  @override
  Future<void> saveCommandResult(CommandResultRecord record) async {}
}

class InMemoryPartyStore implements PartyStore {
  @override
  Future<void> saveParty(Party party, {List<PartyAddress>? addresses, List<PartyContact>? contacts}) async {}
  @override
  Future<Party?> getPartyById(String organizationId, String id) async => null;
  @override
  Future<Party?> getPartyByGstin(String organizationId, String gstin) async => null;
  @override
  Future<List<Party>> searchParties(String organizationId, {String? query, bool? isCustomer, bool? isSupplier, bool includeInactive = false}) async => [];
  @override
  Future<List<PartyAddress>> getPartyAddresses(String partyId) async => [];
  @override
  Future<List<PartyContact>> getPartyContacts(String partyId) async => [];
}

void main() {
  late InMemoryFinanceStore financeStore;
  late InMemorySalesStore salesStore;
  late InMemoryPurchasingStore purchasingStore;
  late InMemoryInventoryStore inventoryStore;
  late InMemoryAccountingStore accountingStore;
  late InMemoryPartyStore partyStore;

  late PostSalesReturnUseCase salesReturnUseCase;
  late PostExpenseUseCase expenseUseCase;
  late CashSessionUseCases cashSessionUseCases;

  final adminSession = UserSession(
    id: const SessionId('sess_admin'),
    userId: const UserId('u_admin'),
    username: 'admin',
    roleId: Role.adminRoleId,
    branchId: const BranchId('branch_1'),
    capabilities: Role.admin.capabilities,
    token: 'tok_admin',
    expiresAtUtc: DateTime.now().add(const Duration(hours: 8)),
    lastActivityAtUtc: DateTime.now(),
  );

  setUp(() async {
    financeStore = InMemoryFinanceStore();
    salesStore = InMemorySalesStore();
    purchasingStore = InMemoryPurchasingStore();
    inventoryStore = InMemoryInventoryStore();
    accountingStore = InMemoryAccountingStore();
    partyStore = InMemoryPartyStore();

    salesReturnUseCase = PostSalesReturnUseCase(
      salesStore: salesStore,
      financeStore: financeStore,
      inventoryStore: inventoryStore,
      accountingStore: accountingStore,
      partyStore: partyStore,
    );

    expenseUseCase = PostExpenseUseCase(
      financeStore: financeStore,
      accountingStore: accountingStore,
    );

    cashSessionUseCases = CashSessionUseCases(
      financeStore: financeStore,
      accountingStore: accountingStore,
    );

    // Seed original sale invoice
    final origSaleHeader = SaleHeader(
      id: 'sale_100',
      organizationId: 'org_1',
      branchId: 'branch_1',
      documentHeaderId: 'doc_100',
      customerPartyId: 'cust_1',
      customerName: 'Rahul Sharma',
      businessDate: DateTime.now(),
      locationId: 'MAIN_WH',
      status: SaleStatus.posted,
      subtotalPaise: Money.fromPaise(1500000),
      allocatedDiscountPaise: Money.zero,
      totalTaxPaise: Money.fromPaise(270000),
      grandTotalPaise: Money.fromPaise(1770000),
      amountPaidPaise: Money.fromPaise(1770000),
      balanceDuePaise: Money.zero,
      createdAtUtc: DateTime.now(),
    );

    final origSaleLine = SaleLine(
      id: 'sale_line_100',
      saleId: 'sale_100',
      productId: 'prod_1',
      productName: 'Panel 540W',
      sku: 'SOL-540',
      hsnCode: '8541',
      baseUnit: 'NOS',
      quantity: Quantity.fromUnits(2.0),
      unitPrice: UnitPrice.fromRupees(7500.0),
      lineDiscountPaise: Money.zero,
      taxSnapshot: TaxLineResult(
        lineId: 'sale_line_100',
        taxableAmount: Money.fromPaise(1500000),
        cgst: Money.fromPaise(135000),
        sgst: Money.fromPaise(135000),
        igst: Money.zero,
        totalTax: Money.fromPaise(270000),
        totalAmount: Money.fromPaise(1770000),
      ),
      costSnapshotMicroRupees: 6000000000,
      netTotalPaise: Money.fromPaise(1770000),
      serials: ['SN-101', 'SN-102'],
    );

    await salesStore.saveSale(header: origSaleHeader, lines: [origSaleLine]);

    // Seed serial records
    await inventoryStore.saveSerialRecord(SerialRecord(
      id: 'sn_rec_101',
      organizationId: 'org_1',
      productId: 'prod_1',
      serialNumber: 'SN-101',
      state: SerialState.sold,
      locationId: 'MAIN_WH',
      updatedAt: DateTime.now(),
    ));
  });

  group('P08 Payments, Returns & Expenses Use Cases', () {
    test('Posts sales return, reverses COGS, returns serial to stock, and balances Credit Note journal', () async {
      final context = CommandContext(session: adminSession, timestampUtc: DateTime.now());

      final retHeader = await salesReturnUseCase.execute(
        context,
        organizationId: 'org_1',
        branchId: 'branch_1',
        originalSaleId: 'sale_100',
        returnDate: DateTime.now(),
        locationId: 'MAIN_WH',
        lineInputs: [
          SalesReturnLineInput(
            saleLineId: 'sale_line_100',
            quantity: Quantity.fromUnits(1.0),
            serials: const ['SN-101'],
            disposition: ReturnDisposition.returnToStock,
          ),
        ],
      );

      expect(retHeader.grandTotalPaise.inRupees, equals(8850.0));

      // Serial status returned to inStock
      final serial = await inventoryStore.getSerialByNumber('org_1', 'prod_1', 'SN-101');
      expect(serial?.state, equals(SerialState.inStock));

      // 2 Journal entries posted (Credit Note & COGS Reversal)
      expect(accountingStore.journals.length, equals(2));
      final crnJournal = accountingStore.journals.first;
      final sumDebit = crnJournal.lines.fold<int>(0, (sum, l) => sum + l.debitPaise);
      final sumCredit = crnJournal.lines.fold<int>(0, (sum, l) => sum + l.creditPaise);
      expect(sumDebit, equals(sumCredit));
    });

    test('Rejects return if cumulative quantity exceeds original line quantity', () async {
      final context = CommandContext(session: adminSession, timestampUtc: DateTime.now());

      expect(
        () => salesReturnUseCase.execute(
          context,
          organizationId: 'org_1',
          branchId: 'branch_1',
          originalSaleId: 'sale_100',
          returnDate: DateTime.now(),
          locationId: 'MAIN_WH',
          lineInputs: [
            SalesReturnLineInput(
              saleLineId: 'sale_line_100',
              quantity: Quantity.fromUnits(10.0), // Exceeds original 2.0
            ),
          ],
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('Posts expense entry and balanced double-entry journal', () async {
      final context = CommandContext(session: adminSession, timestampUtc: DateTime.now());

      final entry = await expenseUseCase.execute(
        context,
        organizationId: 'org_1',
        branchId: 'branch_1',
        categoryId: 'exp_rent',
        categoryName: 'Office Rent',
        accountCode: '6100',
        amountPaise: Money.fromRupees(15000.0),
        expenseDate: DateTime.now(),
        paymentMethod: 'cash',
      );

      expect(entry.amountPaise.inRupees, equals(15000.0));
      expect(accountingStore.journals.length, equals(1));
      expect(accountingStore.journals.first.lines.first.debitPaise, equals(1500000));
    });

    test('Closes cash session and posts variance journal on cash shortage', () async {
      final context = CommandContext(session: adminSession, timestampUtc: DateTime.now());

      final session = await cashSessionUseCases.closeSession(
        context,
        sessionId: 'csess_1',
        expectedCashPaise: Money.fromRupees(10000.0),
        countedCashPaise: Money.fromRupees(9800.0), // ₹200 shortage
      );

      expect(session.variancePaise.inRupees, equals(-200.0));
      expect(accountingStore.journals.length, equals(1));
      expect(accountingStore.journals.first.lines.first.accountId, equals('acc_6900'));
    });
  });
}
