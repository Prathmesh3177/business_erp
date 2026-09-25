import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

class InMemoryPurchasingStore implements PurchasingStore {
  final Map<String, PurchaseHeader> headers = {};
  final Map<String, List<PurchaseLine>> lines = {};
  final Map<String, Payment> payments = {};
  final Map<String, List<PaymentAllocation>> allocations = {};

  @override
  Future<void> savePurchase({
    required PurchaseHeader header,
    required List<PurchaseLine> lines,
  }) async {
    headers[header.id] = header;
    this.lines[header.id] = lines;
  }

  @override
  Future<PurchaseHeader?> getPurchaseHeader(String id) async => headers[id];

  @override
  Future<List<PurchaseLine>> getPurchaseLines(String purchaseId) async => lines[purchaseId] ?? [];

  @override
  Future<List<PurchaseHeader>> listPurchases({
    required String organizationId,
    String? supplierId,
  }) async {
    return headers.values.where((h) {
      if (h.organizationId != organizationId) return false;
      if (supplierId != null && h.supplierId != supplierId) return false;
      return true;
    }).toList();
  }

  @override
  Future<bool> hasDuplicateSupplierInvoice({
    required String organizationId,
    required String supplierId,
    required String financialYear,
    required String externalInvoiceNumber,
  }) async {
    final norm = PurchaseHeader.normalizeExternalInvoiceNumber(externalInvoiceNumber);
    return headers.values.any((h) =>
        h.organizationId == organizationId &&
        h.supplierId == supplierId &&
        h.normalizedExternalInvoiceNumber == norm);
  }

  @override
  Future<void> savePayment({
    required Payment payment,
    required List<PaymentAllocation> allocations,
  }) async {
    payments[payment.id] = payment;
    this.allocations[payment.id] = allocations;
  }

  @override
  Future<Money> getSupplierOutstandingBalance({
    required String organizationId,
    required String supplierId,
  }) async {
    var balance = 0;
    for (final h in headers.values) {
      if (h.organizationId == organizationId && h.supplierId == supplierId) {
        balance += h.balanceDuePaise.paise;
      }
    }
    return Money.fromPaise(balance);
  }
}

class InMemoryInventoryStore implements InventoryStore {
  final Map<String, Location> locations = {};
  final List<StockMovement> movements = [];
  final Map<String, StockBalance> balances = {};
  final Map<String, SerialRecord> serials = {};
  final List<SerialEvent> serialEvents = [];

  @override
  Future<void> saveLocation(Location location) async {
    locations[location.id] = location;
  }

  @override
  Future<List<Location>> getLocations(String organizationId, {String? branchId}) async => locations.values.toList();

  @override
  Future<Location?> getLocationById(String id) async => locations[id];

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
  Future<List<StockBalance>> getStockBalancesForProduct(String organizationId, String productId) async {
    return balances.values.where((b) => b.productId == productId).toList();
  }

  @override
  Future<List<StockBalance>> getAllStockBalances(String organizationId, {String? locationId}) async {
    return balances.values.where((b) => locationId == null || b.locationId == locationId).toList();
  }

  @override
  Future<List<StockBalance>> rebuildStockBalances(String organizationId) async => balances.values.toList();

  @override
  Future<void> saveSerialRecord(SerialRecord serial) async {
    serials['${serial.productId}_${serial.serialNumber}'] = serial;
  }

  @override
  Future<SerialRecord?> getSerialByNumber(String organizationId, String productId, String serialNumber) async {
    return serials['${productId}_${SerialRecord.normalizeSerialNumber(serialNumber)}'];
  }

  @override
  Future<List<SerialRecord>> getSerialsForProduct(String organizationId, String productId, {SerialState? state}) async {
    return serials.values.where((s) => s.productId == productId && (state == null || s.state == state)).toList();
  }

  @override
  Future<void> saveSerialEvent(SerialEvent event) async {
    serialEvents.add(event);
  }

  @override
  Future<List<SerialEvent>> getSerialEvents(String serialId) async {
    return serialEvents.where((e) => e.serialId == serialId).toList();
  }

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
  final Map<String, Account> accounts = {};
  final Map<String, JournalEntry> journals = {};
  final Map<String, DocumentHeader> docHeaders = {};
  int seqCounter = 1;

  @override
  Future<void> saveAccount(Account account) async {
    accounts[account.id] = account;
  }

  @override
  Future<List<Account>> getAccounts(String organizationId) async => accounts.values.toList();

  @override
  Future<Account?> getAccountByCode(String organizationId, String code) async =>
      accounts.values.firstWhere((a) => a.code == code);

  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {
    journals[entry.id] = entry;
  }

  @override
  Future<List<JournalEntry>> getJournalEntries(String organizationId, {String? partyId, int limit = 100}) async =>
      journals.values.toList();

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
    final numStr = seqCounter.toString().padLeft(6, '0');
    seqCounter++;
    return 'PUR/2627/$numStr';
  }

  @override
  Future<CommandResultRecord?> getCommandResult(String commandId) async => null;

  @override
  Future<void> saveCommandResult(CommandResultRecord record) async {}
}

void main() {
  late InMemoryPurchasingStore purchasingStore;
  late InMemoryInventoryStore inventoryStore;
  late InMemoryAccountingStore accountingStore;
  late PostPurchaseUseCase postPurchaseUseCase;

  final adminSession = UserSession(
    id: const SessionId('sess_1'),
    userId: const UserId('u_1'),
    username: 'admin',
    roleId: Role.adminRoleId,
    branchId: const BranchId('branch_1'),
    capabilities: {Capability.purchaseManage},
    token: 'tok_1',
    expiresAtUtc: DateTime.now().add(const Duration(hours: 8)),
    lastActivityAtUtc: DateTime.now(),
  );

  final counterSession = UserSession(
    id: const SessionId('sess_2'),
    userId: const UserId('u_2'),
    username: 'counter',
    roleId: Role.counterRoleId,
    branchId: const BranchId('branch_1'),
    capabilities: {Capability.salesCreate, Capability.salesRead},
    token: 'tok_2',
    expiresAtUtc: DateTime.now().add(const Duration(hours: 8)),
    lastActivityAtUtc: DateTime.now(),
  );

  setUp(() {
    purchasingStore = InMemoryPurchasingStore();
    inventoryStore = InMemoryInventoryStore();
    accountingStore = InMemoryAccountingStore();
    postPurchaseUseCase = PostPurchaseUseCase(
      purchasingStore: purchasingStore,
      inventoryStore: inventoryStore,
      accountingStore: accountingStore,
    );
  });

  group('Purchase Use Cases Invariants & Authorization', () {
    test('Denies purchase posting if user lacks purchaseManage capability', () async {
      final context = CommandContext(session: counterSession, timestampUtc: DateTime.now());

      expect(
        () => postPurchaseUseCase.execute(
          context,
          organizationId: 'org_1',
          branchId: 'branch_1',
          supplierId: 'sup_1',
          supplierName: 'Tata Solar',
          externalInvoiceNumber: 'INV-101',
          invoiceDate: DateTime.now(),
          locationId: 'MAIN_WH',
          supplyType: TaxSupplyType.intraState,
          lineInputs: [
            PurchaseLineInput(
              productId: 'prod_1',
              productName: 'Panel 540W',
              sku: 'P-540',
              quantity: Quantity.fromUnits(10.0),
              unitPurchasePrice: UnitPrice.fromRupees(12000.0),
              taxRate: TaxRate.fromBps(1200),
            ),
          ],
        ),
        throwsA(isA<AuthorizationFailure>()),
      );
    });

    test('Posts purchase, stock receipt, landed cost, serials, and balanced journal', () async {
      final context = CommandContext(session: adminSession, timestampUtc: DateTime.now());

      final header = await postPurchaseUseCase.execute(
        context,
        organizationId: 'org_1',
        branchId: 'branch_1',
        supplierId: 'sup_1',
        supplierName: 'Tata Solar Power',
        externalInvoiceNumber: 'INV-8899',
        invoiceDate: DateTime.now(),
        locationId: 'MAIN_WH',
        supplyType: TaxSupplyType.intraState,
        landedCostTotal: Money.fromPaise(500000), // 5,000 INR
        lineInputs: [
          PurchaseLineInput(
            productId: 'prod_1',
            productName: 'Panel 540W',
            sku: 'P-540',
            quantity: Quantity.fromUnits(2.0),
            unitPurchasePrice: UnitPrice.fromRupees(12000.0),
            taxRate: TaxRate.fromBps(1200),
            serials: const ['SN-PANEL-001', 'SN-PANEL-002'],
          ),
        ],
      );

      expect(header.supplierName, equals('Tata Solar Power'));
      expect(header.status, equals(PurchaseStatus.posted));

      // Verify stock balance updated
      final balance = await inventoryStore.getStockBalance('prod_1', 'MAIN_WH');

      expect(balance, isNotNull);
      expect(balance!.quantityMicroUnits, equals(2000000)); // 2.0 units

      // Verify serials registered
      final serial1 = await inventoryStore.getSerialByNumber('org_1', 'prod_1', 'SN-PANEL-001');
      expect(serial1, isNotNull);
      expect(serial1!.state, equals(SerialState.inStock));

      // Verify double-entry journal created and balanced
      final journal = accountingStore.journals.values.first;
      final sumDebit = journal.lines.fold<int>(0, (sum, l) => sum + l.debitPaise);
      final sumCredit = journal.lines.fold<int>(0, (sum, l) => sum + l.creditPaise);

      expect(sumDebit, equals(sumCredit));
      expect(sumDebit, greaterThan(0));
    });

    test('Rejects duplicate external supplier invoice with ConflictFailure', () async {
      final context = CommandContext(session: adminSession, timestampUtc: DateTime.now());

      await postPurchaseUseCase.execute(
        context,
        organizationId: 'org_1',
        branchId: 'branch_1',
        supplierId: 'sup_1',
        supplierName: 'Tata Solar',
        externalInvoiceNumber: 'INV-101',
        invoiceDate: DateTime.now(),
        locationId: 'MAIN_WH',
        supplyType: TaxSupplyType.intraState,
        lineInputs: [
          PurchaseLineInput(
            productId: 'prod_1',
            productName: 'Panel 540W',
            sku: 'P-540',
            quantity: Quantity.fromUnits(1.0),
            unitPurchasePrice: UnitPrice.fromRupees(12000.0),
            taxRate: TaxRate.fromBps(1200),
          ),
        ],
      );

      expect(
        () => postPurchaseUseCase.execute(
          context,
          organizationId: 'org_1',
          branchId: 'branch_1',
          supplierId: 'sup_1',
          supplierName: 'Tata Solar',
          externalInvoiceNumber: 'INV-101',
          invoiceDate: DateTime.now(),
          locationId: 'MAIN_WH',
          supplyType: TaxSupplyType.intraState,
          lineInputs: [
            PurchaseLineInput(
              productId: 'prod_1',
              productName: 'Panel 540W',
              sku: 'P-540',
              quantity: Quantity.fromUnits(1.0),
              unitPurchasePrice: UnitPrice.fromRupees(12000.0),
              taxRate: TaxRate.fromBps(1200),
            ),
          ],
        ),
        throwsA(isA<ConflictFailure>()),
      );
    });
  });
}
