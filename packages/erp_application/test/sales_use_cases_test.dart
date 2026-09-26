import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

class InMemorySalesStore implements SalesStore {
  final Map<String, SaleHeader> headers = {};
  final Map<String, List<SaleLine>> lines = {};
  final Map<String, SaleDraft> drafts = {};
  final List<WarrantyEntitlement> warranties = [];

  @override
  Future<void> saveSale({
    required SaleHeader header,
    required List<SaleLine> lines,
  }) async {
    headers[header.id] = header;
    this.lines[header.id] = lines;
  }

  @override
  Future<SaleHeader?> getSaleHeader(String id) async => headers[id];

  @override
  Future<List<SaleLine>> getSaleLines(String saleId) async =>
      lines[saleId] ?? [];

  @override
  Future<List<SaleHeader>> listSales({
    required String organizationId,
    String? customerPartyId,
  }) async {
    return headers.values.where((h) {
      if (h.organizationId != organizationId) {
        return false;
      }
      if (customerPartyId != null && h.customerPartyId != customerPartyId) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<void> saveSaleDraft(SaleDraft draft) async {
    drafts[draft.id] = draft;
  }

  @override
  Future<SaleDraft?> getSaleDraft(String id) async => drafts[id];

  @override
  Future<void> deleteSaleDraft(String id) async {
    drafts.remove(id);
  }

  @override
  Future<List<SaleDraft>> listSaleDrafts(String organizationId) async {
    return drafts.values
        .where((d) => d.organizationId == organizationId)
        .toList();
  }

  @override
  Future<void> saveWarrantyEntitlement(WarrantyEntitlement entitlement) async {
    warranties.add(entitlement);
  }

  @override
  Future<List<WarrantyEntitlement>> getWarrantyEntitlementsForCustomer({
    required String organizationId,
    required String partyId,
  }) async {
    return warranties.where((w) => w.partyId == partyId).toList();
  }

  @override
  Future<List<WarrantyEntitlement>> getAllWarrantyEntitlements({
    required String organizationId,
  }) async {
    return warranties;
  }

  @override
  Future<void> saveSaleOrder({
    required SaleOrder order,
    required List<SaleOrderLine> lines,
  }) async {}
  @override
  Future<SaleOrder?> getSaleOrder(String id) async => null;
  @override
  Future<List<SaleOrderLine>> getSaleOrderLines(String orderId) async => [];
  @override
  Future<List<SaleOrder>> listSaleOrders({
    required String organizationId,
    OrderStatus? status,
  }) async => [];
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
  Future<List<Location>> getLocations(
    String organizationId, {
    String? branchId,
  }) async => locations.values.toList();

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
  Future<StockBalance?> getStockBalance(
    String productId,
    String locationId,
  ) async {
    return balances['${productId}_$locationId'];
  }

  @override
  Future<List<StockBalance>> getStockBalancesForProduct(
    String organizationId,
    String productId,
  ) async {
    return balances.values.where((b) => b.productId == productId).toList();
  }

  @override
  Future<List<StockBalance>> getAllStockBalances(
    String organizationId, {
    String? locationId,
  }) async {
    return balances.values
        .where((b) => locationId == null || b.locationId == locationId)
        .toList();
  }

  @override
  Future<List<StockBalance>> rebuildStockBalances(
    String organizationId,
  ) async => balances.values.toList();

  @override
  Future<void> saveSerialRecord(SerialRecord serial) async {
    serials['${serial.productId}_${serial.serialNumber}'] = serial;
  }

  @override
  Future<SerialRecord?> getSerialByNumber(
    String organizationId,
    String productId,
    String serialNumber,
  ) async {
    return serials['${productId}_${SerialRecord.normalizeSerialNumber(serialNumber)}'];
  }

  @override
  Future<List<SerialRecord>> getSerialsForProduct(
    String organizationId,
    String productId, {
    SerialState? state,
  }) async {
    return serials.values
        .where(
          (s) =>
              s.productId == productId && (state == null || s.state == state),
        )
        .toList();
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
  Future<List<BatchRecord>> getBatchesForProduct(
    String organizationId,
    String productId,
  ) async => [];

  @override
  Future<void> saveReservation(Reservation reservation) async {}

  @override
  Future<List<Reservation>> getActiveReservationsForProduct(
    String organizationId,
    String productId,
  ) async => [];

  @override
  Future<void> saveStockAdjustment(StockAdjustment adjustment) async {}

  @override
  Future<List<StockAdjustment>> getStockAdjustments(
    String organizationId, {
    int limit = 100,
  }) async => [];
}

class InMemoryAccountingStore implements AccountingStore {
  final Map<String, Account> accounts = {};
  final Map<String, JournalEntry> journals = {};
  final Map<String, DocumentHeader> docHeaders = {};
  final Map<String, CommandResultRecord> commandResults = {};
  int seqCounter = 1;

  @override
  Future<void> saveAccount(Account account) async {
    accounts[account.id] = account;
  }

  @override
  Future<List<Account>> getAccounts(String organizationId) async =>
      accounts.values.toList();

  @override
  Future<Account?> getAccountByCode(String organizationId, String code) async =>
      accounts.values.firstWhere((a) => a.code == code);

  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {
    journals[entry.id] = entry;
  }

  @override
  Future<List<JournalEntry>> getJournalEntries(
    String organizationId, {
    String? partyId,
    int limit = 100,
  }) async => journals.values.toList();

  @override
  Future<int> getPartyBalancePaise(
    String organizationId,
    String partyId,
  ) async => 0;

  @override
  Future<void> saveDocumentHeader(DocumentHeader header) async {
    docHeaders[header.id] = header;
  }

  @override
  Future<DocumentHeader?> getDocumentHeaderById(String id) async =>
      docHeaders[id];

  @override
  Future<String> allocateNextDocumentNumber({
    required String registrationId,
    required String fiscalYear,
    required String series,
  }) async {
    final numStr = seqCounter.toString().padLeft(6, '0');
    seqCounter++;
    return '$series/2627/$numStr';
  }

  @override
  Future<CommandResultRecord?> getCommandResult(String commandId) async =>
      commandResults[commandId];

  @override
  Future<void> saveCommandResult(CommandResultRecord record) async {
    commandResults[record.commandId] = record;
  }
}

class InMemoryPartyStore implements PartyStore {
  final Map<String, Party> parties = {};

  @override
  Future<void> saveParty(
    Party party, {
    List<PartyAddress>? addresses,
    List<PartyContact>? contacts,
  }) async {
    parties[party.id] = party;
  }

  @override
  Future<Party?> getPartyById(String organizationId, String id) async =>
      parties[id];

  @override
  Future<Party?> getPartyByGstin(String organizationId, String gstin) async =>
      null;

  @override
  Future<List<Party>> searchParties(
    String organizationId, {
    String? query,
    bool? isCustomer,
    bool? isSupplier,
    bool includeInactive = false,
  }) async => parties.values.toList();

  @override
  Future<List<PartyAddress>> getPartyAddresses(String partyId) async => [];

  @override
  Future<List<PartyContact>> getPartyContacts(String partyId) async => [];
}

void main() {
  late InMemorySalesStore salesStore;
  late InMemoryInventoryStore inventoryStore;
  late InMemoryAccountingStore accountingStore;
  late InMemoryPartyStore partyStore;
  late PostSaleUseCase postSaleUseCase;

  final counterSession = UserSession(
    id: const SessionId('sess_1'),
    userId: const UserId('u_1'),
    username: 'counter',
    roleId: Role.counterRoleId,
    branchId: const BranchId('branch_1'),
    capabilities: {Capability.salesCreate, Capability.salesRead},
    token: 'tok_1',
    expiresAtUtc: DateTime.now().add(const Duration(hours: 8)),
    lastActivityAtUtc: DateTime.now(),
  );

  final unauthorizedSession = UserSession(
    id: const SessionId('sess_2'),
    userId: const UserId('u_2'),
    username: 'nobody',
    roleId: 'role_guest',
    branchId: const BranchId('branch_1'),
    capabilities: const {},
    token: 'tok_2',
    expiresAtUtc: DateTime.now().add(const Duration(hours: 8)),
    lastActivityAtUtc: DateTime.now(),
  );

  setUp(() async {
    salesStore = InMemorySalesStore();
    inventoryStore = InMemoryInventoryStore();
    accountingStore = InMemoryAccountingStore();
    partyStore = InMemoryPartyStore();

    postSaleUseCase = PostSaleUseCase(
      salesStore: salesStore,
      inventoryStore: inventoryStore,
      accountingStore: accountingStore,
      partyStore: partyStore,
    );

    // Seed opening stock (10 units Panel 540W @ ₹12,000 unit cost)
    await inventoryStore.saveStockBalance(
      StockBalance(
        productId: 'prod_1',
        locationId: 'MAIN_WH',
        quantityMicroUnits: 10000000, // 10 units
        valuePaise: 12000000, // ₹1,20,000
        updatedAt: DateTime.now(),
      ),
    );

    // Seed active serial
    await inventoryStore.saveSerialRecord(
      SerialRecord(
        id: 'sn_1',
        organizationId: 'org_1',
        productId: 'prod_1',
        serialNumber: 'SN-PERC-100',
        state: SerialState.inStock,
        locationId: 'MAIN_WH',
        updatedAt: DateTime.now(),
      ),
    );
  });

  group('Sale Use Cases Invariants & Authorization', () {
    test('Denies sale posting if user lacks salesCreate capability', () async {
      final context = CommandContext(
        session: unauthorizedSession,
        timestampUtc: DateTime.now(),
      );

      expect(
        () => postSaleUseCase.execute(
          context,
          organizationId: 'org_1',
          branchId: 'branch_1',
          customerPartyId: 'cust_1',
          customerName: 'Rahul Sharma',
          businessDate: DateTime.now(),
          locationId: 'MAIN_WH',
          supplyType: TaxSupplyType.intraState,
          lineInputs: [
            SaleLineInput(
              productId: 'prod_1',
              productName: 'Panel 540W',
              sku: 'P-540',
              hsnCode: '8541',
              baseUnit: 'NOS',
              quantity: Quantity.fromUnits(1.0),
              unitPrice: UnitPrice.fromRupees(15000.0),
              taxRate: TaxRate.fromBps(1800),
            ),
          ],
          tenderLines: [
            TenderLine(
              method: TenderMethod.cash,
              amountPaise: Money.fromPaise(1770000),
            ),
          ],
          commandId: 'cmd_sale_001',
        ),
        throwsA(isA<AuthorizationFailure>()),
      );
    });

    test('Posts sale, stock issue, serial state sold, warranty, and balanced journals', () async {
      final context = CommandContext(
        session: counterSession,
        timestampUtc: DateTime.now(),
      );

      final header = await postSaleUseCase.execute(
        context,
        organizationId: 'org_1',
        branchId: 'branch_1',
        customerPartyId: 'cust_1',
        customerName: 'Rahul Sharma',
        businessDate: DateTime.now(),
        locationId: 'MAIN_WH',
        supplyType: TaxSupplyType.intraState,
        lineInputs: [
          SaleLineInput(
            productId: 'prod_1',
            productName: 'Panel 540W',
            sku: 'P-540',
            hsnCode: '8541',
            baseUnit: 'NOS',
            quantity: Quantity.fromUnits(1.0),
            unitPrice: UnitPrice.fromRupees(15000.0),
            taxRate: TaxRate.fromBps(1800),
            serials: const ['SN-PERC-100'],
          ),
        ],
        tenderLines: [
          TenderLine(
            method: TenderMethod.cash,
            amountPaise: Money.fromPaise(1770000),
          ),
        ],
        commandId: 'cmd_sale_002',
      );

      expect(header.customerName, equals('Rahul Sharma'));
      expect(header.status, equals(SaleStatus.posted));

      // Stock balance reduced from 10 to 9 units
      final balance = await inventoryStore.getStockBalance('prod_1', 'MAIN_WH');
      expect(balance?.quantityMicroUnits, equals(9000000)); // 9 units

      // Serial updated to sold
      final serial = await inventoryStore.getSerialByNumber(
        'org_1',
        'prod_1',
        'SN-PERC-100',
      );
      expect(serial?.state, equals(SerialState.sold));

      // Warranty entitlement created
      final warranties = await salesStore.getWarrantyEntitlementsForCustomer(
        organizationId: 'org_1',
        partyId: 'cust_1',
      );
      expect(warranties.length, equals(1));
      expect(warranties.first.serialNumber, equals('SN-PERC-100'));

      // Verify Revenue & COGS journals posted and balanced
      final journals = accountingStore.journals.values.toList();
      expect(journals.length, equals(2));

      final revJournal = journals.first;
      final sumRevDebit = revJournal.lines.fold<int>(
        0,
        (sum, l) => sum + l.debitPaise,
      );
      final sumRevCredit = revJournal.lines.fold<int>(
        0,
        (sum, l) => sum + l.creditPaise,
      );
      expect(sumRevDebit, equals(sumRevCredit));

      final cogsJournal = journals.last;
      final sumCogsDebit = cogsJournal.lines.fold<int>(
        0,
        (sum, l) => sum + l.debitPaise,
      );
      final sumCogsCredit = cogsJournal.lines.fold<int>(
        0,
        (sum, l) => sum + l.creditPaise,
      );
      expect(sumCogsDebit, equals(sumCogsCredit));
    });

    test(
      'Idempotently returns existing committed invoice on duplicate commandId',
      () async {
        final context = CommandContext(
          session: counterSession,
          timestampUtc: DateTime.now(),
        );

        final header1 = await postSaleUseCase.execute(
          context,
          organizationId: 'org_1',
          branchId: 'branch_1',
          customerPartyId: 'cust_1',
          customerName: 'Rahul Sharma',
          businessDate: DateTime.now(),
          locationId: 'MAIN_WH',
          supplyType: TaxSupplyType.intraState,
          lineInputs: [
            SaleLineInput(
              productId: 'prod_1',
              productName: 'Panel 540W',
              sku: 'P-540',
              hsnCode: '8541',
              baseUnit: 'NOS',
              quantity: Quantity.fromUnits(1.0),
              unitPrice: UnitPrice.fromRupees(15000.0),
              taxRate: TaxRate.fromBps(1800),
            ),
          ],
          tenderLines: [
            TenderLine(
              method: TenderMethod.cash,
              amountPaise: Money.fromPaise(1770000),
            ),
          ],
          commandId: 'cmd_sale_repeat',
        );

        final header2 = await postSaleUseCase.execute(
          context,
          organizationId: 'org_1',
          branchId: 'branch_1',
          customerPartyId: 'cust_1',
          customerName: 'Rahul Sharma',
          businessDate: DateTime.now(),
          locationId: 'MAIN_WH',
          supplyType: TaxSupplyType.intraState,
          lineInputs: [
            SaleLineInput(
              productId: 'prod_1',
              productName: 'Panel 540W',
              sku: 'P-540',
              hsnCode: '8541',
              baseUnit: 'NOS',
              quantity: Quantity.fromUnits(1.0),
              unitPrice: UnitPrice.fromRupees(15000.0),
              taxRate: TaxRate.fromBps(1800),
            ),
          ],
          tenderLines: [
            TenderLine(
              method: TenderMethod.cash,
              amountPaise: Money.fromPaise(1770000),
            ),
          ],
          commandId: 'cmd_sale_repeat',
        );

        expect(header1.id, equals(header2.id));
      },
    );

    test('Rejects sale when available stock is insufficient', () async {
      final context = CommandContext(
        session: counterSession,
        timestampUtc: DateTime.now(),
      );

      expect(
        () => postSaleUseCase.execute(
          context,
          organizationId: 'org_1',
          branchId: 'branch_1',
          customerPartyId: 'cust_1',
          customerName: 'Rahul Sharma',
          businessDate: DateTime.now(),
          locationId: 'MAIN_WH',
          supplyType: TaxSupplyType.intraState,
          lineInputs: [
            SaleLineInput(
              productId: 'prod_1',
              productName: 'Panel 540W',
              sku: 'P-540',
              hsnCode: '8541',
              baseUnit: 'NOS',
              quantity: Quantity.fromUnits(
                500.0,
              ), // Exceeds available stock of 10
              unitPrice: UnitPrice.fromRupees(15000.0),
              taxRate: TaxRate.fromBps(1800),
            ),
          ],
          tenderLines: [
            TenderLine(
              method: TenderMethod.cash,
              amountPaise: Money.fromPaise(885000000),
            ),
          ],
          commandId: 'cmd_sale_excess_stock',
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('Made-to-order products bypass stock check and post successfully with zero stock, while standard products are rejected', () async {
      final context = CommandContext(
        session: counterSession,
        timestampUtc: DateTime.now(),
      );

      // 1. Standard product with zero stock is rejected
      expect(
        () => postSaleUseCase.execute(
          context,
          organizationId: 'org_1',
          branchId: 'branch_1',
          customerPartyId: 'cust_1',
          customerName: 'Rahul Sharma',
          businessDate: DateTime.now(),
          locationId: 'MAIN_WH',
          supplyType: TaxSupplyType.intraState,
          lineInputs: [
            SaleLineInput(
              productId: 'prod_std_no_stock',
              productName: 'Standard Inverter (No Stock)',
              sku: 'INV-NOSTOCK',
              hsnCode: '8504',
              baseUnit: 'NOS',
              quantity: Quantity.fromUnits(1.0),
              unitPrice: UnitPrice.fromRupees(50000.0),
              taxRate: TaxRate.fromBps(1800),
              isMadeToOrder: false,
            ),
          ],
          tenderLines: [
            TenderLine(
              method: TenderMethod.cash,
              amountPaise: Money.fromPaise(5900000),
            ),
          ],
          commandId: 'cmd_std_zero_stock',
        ),
        throwsA(isA<ValidationFailure>()),
      );

      // 2. Made-to-order product with zero stock posts successfully
      final header = await postSaleUseCase.execute(
        context,
        organizationId: 'org_1',
        branchId: 'branch_1',
        customerPartyId: 'cust_1',
        customerName: 'Rahul Sharma',
        businessDate: DateTime.now(),
        locationId: 'MAIN_WH',
        supplyType: TaxSupplyType.intraState,
        lineInputs: [
          SaleLineInput(
            productId: 'prod_mto_structure',
            productName: 'Custom Fabricated Structure',
            sku: 'STR-MTO-001',
            hsnCode: '7308',
            baseUnit: 'SET',
            quantity: Quantity.fromUnits(2.0),
            unitPrice: UnitPrice.fromRupees(10000.0),
            taxRate: TaxRate.fromBps(1800),
            isMadeToOrder: true,
          ),
        ],
        tenderLines: [
          TenderLine(
            method: TenderMethod.cash,
            amountPaise: Money.fromPaise(2360000),
          ),
        ],
        commandId: 'cmd_mto_zero_stock_success',
      );

      expect(header.id, isNotEmpty);
      expect(header.status, equals(SaleStatus.posted));

      // Verify line is saved with isMadeToOrder = true
      final lines = await salesStore.getSaleLines(header.id);
      expect(lines.length, equals(1));
      expect(lines.first.isMadeToOrder, isTrue);

      // Verify no stock movements were created for made-to-order product
      final mtoMovements = inventoryStore.movements
          .where((m) => m.productId == 'prod_mto_structure')
          .toList();
      expect(mtoMovements, isEmpty);
    });
  });
}
