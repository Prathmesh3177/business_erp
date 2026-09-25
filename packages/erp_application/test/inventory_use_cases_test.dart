import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Inventory Use Cases Invariants & Authorization', () {
    late _InMemoryInventoryStore inventoryStore;
    late _InMemoryAccountingStore accountingStore;

    final adminContext = CommandContext(
      session: UserSession(
        id: const SessionId('sess_admin'),
        userId: const UserId('user_admin'),
        username: 'admin',
        roleId: Role.admin.id,
        branchId: const BranchId('branch_1'),
        capabilities: Role.admin.capabilities,
        token: 'token_123',
        expiresAtUtc: DateTime.now().add(const Duration(hours: 1)),
        lastActivityAtUtc: DateTime.now(),
      ),
      timestampUtc: DateTime.now(),
    );

    final counterContext = CommandContext(
      session: UserSession(
        id: const SessionId('sess_counter'),
        userId: const UserId('user_counter'),
        username: 'counter',
        roleId: Role.counter.id,
        branchId: const BranchId('branch_1'),
        capabilities: const {Capability.salesCreate, Capability.salesRead}, // Lacks inventoryManage
        token: 'token_456',
        expiresAtUtc: DateTime.now().add(const Duration(hours: 1)),
        lastActivityAtUtc: DateTime.now(),
      ),
      timestampUtc: DateTime.now(),
    );

    setUp(() {
      inventoryStore = _InMemoryInventoryStore();
      accountingStore = _InMemoryAccountingStore();
    });

    test('T02: Denies inventory use cases if user lacks inventoryManage capability', () async {
      final openingUseCase = PostOpeningStockUseCase(
        inventoryStore: inventoryStore,
        accountingStore: accountingStore,
      );

      expect(
        () => openingUseCase.execute(
          counterContext,
          organizationId: 'org_1',
          branchId: 'branch_1',
          productId: 'prod_panel_1',
          locationId: 'loc_sellable',
          quantity: Quantity.fromUnits(10.0),
          totalValue: Money.fromRupees(10000.0),
          commandId: 'cmd_1',
        ),
        throwsA(isA<AuthorizationFailure>()),
      );
    });

    test('PostOpeningStockUseCase posts movement, stock balance, serials, and balanced journal', () async {
      final openingUseCase = PostOpeningStockUseCase(
        inventoryStore: inventoryStore,
        accountingStore: accountingStore,
      );

      final bal = await openingUseCase.execute(
        adminContext,
        organizationId: 'org_1',
        branchId: 'branch_1',
        productId: 'prod_panel_1',
        locationId: 'loc_sellable',
        quantity: Quantity.fromUnits(10.0),
        totalValue: Money.fromRupees(10000.0),
        serialNumbers: ['SN-001', 'SN-002'],
        commandId: 'cmd_opening_1',
      );

      expect(bal.quantityInUnits, equals(10.0));
      expect(bal.valueInRupees, equals(10000.0));

      // Check Movements
      final movements = await inventoryStore.getStockMovements('org_1', productId: 'prod_panel_1');
      expect(movements.length, equals(1));
      expect(movements.first.movementKind, equals(MovementKind.openingStock));

      // Check Serials registered
      final sn1 = await inventoryStore.getSerialByNumber('org_1', 'prod_panel_1', 'SN-001');
      expect(sn1, isNotNull);
      expect(sn1?.state, equals(SerialState.inStock));

      // Check Journal Entry created (Dr acc_inv ₹10,000, Cr acc_equity ₹10,000)
      expect(accountingStore.savedJournalEntries.length, equals(1));
      final je = accountingStore.savedJournalEntries.first;
      expect(je.lines.length, equals(2));
      expect(je.lines.first.debitPaise, equals(1000000));
      expect(je.lines.last.creditPaise, equals(1000000));
    });

    test('PostOpeningStockUseCase rejects duplicate serial number with ConflictFailure', () async {
      final openingUseCase = PostOpeningStockUseCase(
        inventoryStore: inventoryStore,
        accountingStore: accountingStore,
      );

      await openingUseCase.execute(
        adminContext,
        organizationId: 'org_1',
        branchId: 'branch_1',
        productId: 'prod_panel_1',
        locationId: 'loc_sellable',
        quantity: Quantity.fromUnits(5.0),
        totalValue: Money.fromRupees(5000.0),
        serialNumbers: ['SN-UNIQUE-100'],
        commandId: 'cmd_1',
      );

      // Duplicate serial attempt
      expect(
        () => openingUseCase.execute(
          adminContext,
          organizationId: 'org_1',
          branchId: 'branch_1',
          productId: 'prod_panel_1',
          locationId: 'loc_sellable',
          quantity: Quantity.fromUnits(5.0),
          totalValue: Money.fromRupees(5000.0),
          serialNumbers: ['SN-UNIQUE-100'],
          commandId: 'cmd_2',
        ),
        throwsA(isA<ConflictFailure>()),
      );
    });

    test('TransferStockUseCase transfers stock between locations and updates serial location', () async {
      final openingUseCase = PostOpeningStockUseCase(
        inventoryStore: inventoryStore,
        accountingStore: accountingStore,
      );
      final transferUseCase = TransferStockUseCase(inventoryStore);

      // Seed 10 units in loc_sellable
      await openingUseCase.execute(
        adminContext,
        organizationId: 'org_1',
        branchId: 'branch_1',
        productId: 'prod_inv_1',
        locationId: 'loc_sellable',
        quantity: Quantity.fromUnits(10.0),
        totalValue: Money.fromRupees(10000.0),
        serialNumbers: ['SN-TRF-1'],
        commandId: 'cmd_seed',
      );

      // Transfer 4 units from loc_sellable to loc_quarantine
      await transferUseCase.execute(
        adminContext,
        organizationId: 'org_1',
        branchId: 'branch_1',
        productId: 'prod_inv_1',
        fromLocationId: 'loc_sellable',
        toLocationId: 'loc_quarantine',
        quantity: Quantity.fromUnits(4.0),
        serialNumbers: ['SN-TRF-1'],
      );

      final sellableBal = await inventoryStore.getStockBalance('prod_inv_1', 'loc_sellable');
      final quarantineBal = await inventoryStore.getStockBalance('prod_inv_1', 'loc_quarantine');

      expect(sellableBal?.quantityInUnits, equals(6.0));
      expect(quarantineBal?.quantityInUnits, equals(4.0));

      final sn = await inventoryStore.getSerialByNumber('org_1', 'prod_inv_1', 'SN-TRF-1');
      expect(sn?.locationId, equals('loc_quarantine'));
    });

    test('ReserveStockUseCase checks availability and blocks excessive reservation', () async {
      final openingUseCase = PostOpeningStockUseCase(
        inventoryStore: inventoryStore,
        accountingStore: accountingStore,
      );
      final reserveUseCase = ReserveStockUseCase(inventoryStore);

      // Seed 10 units
      await openingUseCase.execute(
        adminContext,
        organizationId: 'org_1',
        branchId: 'branch_1',
        productId: 'prod_res_1',
        locationId: 'loc_sellable',
        quantity: Quantity.fromUnits(10.0),
        totalValue: Money.fromRupees(10000.0),
        commandId: 'cmd_seed',
      );

      // Reserve 8 units
      final res1 = await reserveUseCase.execute(
        adminContext,
        organizationId: 'org_1',
        branchId: 'branch_1',
        productId: 'prod_res_1',
        quantity: Quantity.fromUnits(8.0),
      );
      expect(res1.quantityInUnits, equals(8.0));

      // Attempt to reserve 5 more units -> Available is only 2 (10 - 8), so should fail!
      expect(
        () => reserveUseCase.execute(
          adminContext,
          organizationId: 'org_1',
          branchId: 'branch_1',
          productId: 'prod_res_1',
          quantity: Quantity.fromUnits(5.0),
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('RebuildStockLedgerUseCase maintains parity with historical stock movements', () async {
      final openingUseCase = PostOpeningStockUseCase(
        inventoryStore: inventoryStore,
        accountingStore: accountingStore,
      );
      final adjustmentUseCase = PostStockAdjustmentUseCase(
        inventoryStore: inventoryStore,
        accountingStore: accountingStore,
      );
      final rebuildUseCase = RebuildStockLedgerUseCase(inventoryStore);

      await openingUseCase.execute(
        adminContext,
        organizationId: 'org_1',
        branchId: 'branch_1',
        productId: 'prod_reb_1',
        locationId: 'loc_sellable',
        quantity: Quantity.fromUnits(20.0),
        totalValue: Money.fromRupees(20000.0),
        commandId: 'cmd_reb_1',
      );

      await adjustmentUseCase.execute(
        adminContext,
        organizationId: 'org_1',
        branchId: 'branch_1',
        productId: 'prod_reb_1',
        locationId: 'loc_sellable',
        quantityDeltaMicroUnits: -5000000, // -5 units
        reason: 'Damaged in transit',
        approvedByUserId: 'user_admin',
      );

      final rebuiltBalances = await rebuildUseCase.execute(adminContext, organizationId: 'org_1');
      expect(rebuiltBalances.length, equals(1));
      expect(rebuiltBalances.first.quantityInUnits, equals(15.0));
      expect(rebuiltBalances.first.valueInRupees, equals(15000.0));
    });
  });
}

class _InMemoryInventoryStore implements InventoryStore {
  final Map<String, Location> _locations = {};
  final List<StockMovement> _movements = [];
  final Map<String, StockBalance> _balances = {};
  final Map<String, SerialRecord> _serials = {};
  final List<SerialEvent> _serialEvents = [];
  final Map<String, BatchRecord> _batches = {};
  final List<Reservation> _reservations = [];
  final List<StockAdjustment> _adjustments = [];

  @override
  Future<void> saveLocation(Location location) async {
    _locations[location.id] = location;
  }

  @override
  Future<List<Location>> getLocations(String organizationId, {String? branchId}) async {
    return _locations.values
        .where((l) => l.organizationId == organizationId && (branchId == null || l.branchId == branchId))
        .toList();
  }

  @override
  Future<Location?> getLocationById(String id) async => _locations[id];

  @override
  Future<void> saveStockMovement(StockMovement movement) async {
    _movements.add(movement);
  }

  @override
  Future<List<StockMovement>> getStockMovements(
    String organizationId, {
    String? productId,
    String? locationId,
    int limit = 100,
  }) async {
    return _movements
        .where((m) =>
            m.organizationId == organizationId &&
            (productId == null || m.productId == productId) &&
            (locationId == null || m.locationId == locationId))
        .take(limit)
        .toList();
  }

  @override
  Future<void> saveStockBalance(StockBalance balance) async {
    _balances['${balance.productId}_${balance.locationId}'] = balance;
  }

  @override
  Future<StockBalance?> getStockBalance(String productId, String locationId) async {
    return _balances['${productId}_$locationId'];
  }

  @override
  Future<List<StockBalance>> getStockBalancesForProduct(String organizationId, String productId) async {
    return _balances.values.where((b) => b.productId == productId).toList();
  }

  @override
  Future<List<StockBalance>> getAllStockBalances(String organizationId, {String? locationId}) async {
    return _balances.values.where((b) => locationId == null || b.locationId == locationId).toList();
  }

  @override
  Future<List<StockBalance>> rebuildStockBalances(String organizationId) async {
    final map = <String, StockBalance>{};
    for (final m in _movements.where((m) => m.organizationId == organizationId)) {
      final key = '${m.productId}_${m.locationId}';
      final current = map[key] ??
          StockBalance(
            productId: m.productId,
            locationId: m.locationId,
            quantityMicroUnits: 0,
            valuePaise: 0,
            updatedAt: m.createdAt,
          );
      map[key] = current.applyMovement(movement: m, updatedAt: m.createdAt);
    }
    _balances.clear();
    _balances.addAll(map);
    return map.values.toList();
  }

  @override
  Future<void> saveSerialRecord(SerialRecord serial) async {
    _serials['${serial.organizationId}_${serial.productId}_${serial.serialNumber}'] = serial;
  }

  @override
  Future<SerialRecord?> getSerialByNumber(String organizationId, String productId, String serialNumber) async {
    return _serials['${organizationId}_${productId}_$serialNumber'];
  }

  @override
  Future<List<SerialRecord>> getSerialsForProduct(String organizationId, String productId, {SerialState? state}) async {
    return _serials.values
        .where((s) =>
            s.organizationId == organizationId &&
            s.productId == productId &&
            (state == null || s.state == state))
        .toList();
  }

  @override
  Future<void> saveSerialEvent(SerialEvent event) async {
    _serialEvents.add(event);
  }

  @override
  Future<List<SerialEvent>> getSerialEvents(String serialId) async {
    return _serialEvents.where((e) => e.serialId == serialId).toList();
  }

  @override
  Future<void> saveBatchRecord(BatchRecord batch) async {
    _batches[batch.id] = batch;
  }

  @override
  Future<List<BatchRecord>> getBatchesForProduct(String organizationId, String productId) async {
    return _batches.values.where((b) => b.organizationId == organizationId && b.productId == productId).toList();
  }

  @override
  Future<void> saveReservation(Reservation reservation) async {
    _reservations.add(reservation);
  }

  @override
  Future<List<Reservation>> getActiveReservationsForProduct(String organizationId, String productId) async {
    return _reservations
        .where((r) =>
            r.organizationId == organizationId &&
            r.productId == productId &&
            r.status == ReservationStatus.active)
        .toList();
  }

  @override
  Future<void> saveStockAdjustment(StockAdjustment adjustment) async {
    _adjustments.add(adjustment);
  }

  @override
  Future<List<StockAdjustment>> getStockAdjustments(String organizationId, {int limit = 100}) async {
    return _adjustments.where((a) => a.organizationId == organizationId).take(limit).toList();
  }
}

class _InMemoryAccountingStore implements AccountingStore {
  final List<JournalEntry> savedJournalEntries = [];

  @override
  Future<void> saveJournalEntry(JournalEntry entry) async {
    savedJournalEntries.add(entry);
  }

  @override
  Future<void> saveAccount(Account account) async {}

  @override
  Future<List<Account>> getAccounts(String organizationId) async => [];

  @override
  Future<Account?> getAccountByCode(String organizationId, String code) async => null;

  @override
  Future<List<JournalEntry>> getJournalEntries(String organizationId, {String? partyId, int limit = 100}) async => [];

  @override
  Future<int> getPartyBalancePaise(String organizationId, String partyId) async => 0;

  @override
  Future<void> saveDocumentHeader(DocumentHeader header) async {}

  @override
  Future<DocumentHeader?> getDocumentHeaderById(String id) async => null;

  @override
  Future<String> allocateNextDocumentNumber({required String registrationId, required String fiscalYear, required String series}) async => 'SKS/2627/000001';

  @override
  Future<void> saveCommandResult(CommandResultRecord result) async {}

  @override
  Future<CommandResultRecord?> getCommandResult(String commandId) async => null;
}
