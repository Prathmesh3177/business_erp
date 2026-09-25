import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

final class InMemoryServiceStore implements ServiceStore {
  final Map<String, ServiceJob> jobs = {};
  final Map<String, List<ServiceJobVisit>> visits = {};
  final Map<String, AmcContract> amcContracts = {};
  final Map<String, List<SerialReplacement>> serialReplacements = {};

  @override
  Future<void> saveServiceJob({
    required ServiceJob job,
    List<ServiceJobVisit> visits = const [],
  }) async {
    jobs[job.id] = job;
    this.visits[job.id] = visits;
  }

  @override
  Future<ServiceJob?> getServiceJob(String id) async => jobs[id];

  @override
  Future<List<ServiceJobVisit>> getServiceJobVisits(String jobId) async =>
      visits[jobId] ?? [];

  @override
  Future<List<ServiceJob>> listServiceJobs({
    required String organizationId,
    String? assignedTechnicianUserId,
    String? customerPartyId,
  }) async {
    return jobs.values.where((j) {
      if (j.organizationId != organizationId) return false;
      if (assignedTechnicianUserId != null && j.assignedTechnicianUserId != assignedTechnicianUserId) {
        return false;
      }
      if (customerPartyId != null && j.customerPartyId != customerPartyId) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Future<void> saveAmcContract(AmcContract contract) async {
    amcContracts[contract.id] = contract;
  }

  @override
  Future<AmcContract?> getAmcContract(String id) async => amcContracts[id];

  @override
  Future<List<AmcContract>> listAmcContracts(String organizationId) async {
    return amcContracts.values.where((c) => c.organizationId == organizationId).toList();
  }

  @override
  Future<void> saveSerialReplacement(SerialReplacement replacement) async {
    serialReplacements.putIfAbsent(replacement.oldSerialId, () => []).add(replacement);
    serialReplacements.putIfAbsent(replacement.newSerialId, () => []).add(replacement);
  }

  @override
  Future<List<SerialReplacement>> getSerialReplacements(String serialId) async {
    return serialReplacements[serialId] ?? [];
  }
}

final class InMemoryInventoryStoreForService implements InventoryStore {
  final Map<String, StockBalance> balances = {};
  final Map<String, SerialRecord> serials = {};

  @override
  Future<StockBalance?> getStockBalance(String productId, String locationId) async {
    return balances['${productId}_$locationId'];
  }

  @override
  Future<void> saveStockBalance(StockBalance balance) async {
    balances['${balance.productId}_${balance.locationId}'] = balance;
  }

  @override
  Future<SerialRecord?> getSerialByNumber(String organizationId, String productId, String serialNumber) async {
    return serials['${productId}_$serialNumber'];
  }

  @override
  Future<void> saveSerialRecord(SerialRecord serial) async {
    serials['${serial.productId}_${serial.serialNumber}'] = serial;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('P16 Service & AMC Application Use Cases Tests', () {
    late InMemoryServiceStore serviceStore;
    late InMemoryInventoryStoreForService inventoryStore;
    late CommandContext cmdCtx;

    setUp(() {
      serviceStore = InMemoryServiceStore();
      inventoryStore = InMemoryInventoryStoreForService();

      final session = UserSession(
        id: const SessionId('sess_admin'),
        userId: const UserId('usr_admin'),
        username: 'admin',
        roleId: Role.adminRoleId,
        branchId: const BranchId('br_1'),
        capabilities: Capability.values.toSet(),
        token: 'tok_admin',
        expiresAtUtc: DateTime.now().add(const Duration(hours: 8)),
        lastActivityAtUtc: DateTime.now(),
      );
      cmdCtx = CommandContext(session: session, timestampUtc: DateTime.now());
    });

    test('Full Service Job Ticket, Visit Logging & Serial Replacement Lifecycle', () async {
      // 1. Create Service Job Ticket
      final createUseCase = CreateServiceJobUseCase(serviceStore: serviceStore);
      final job = await createUseCase.execute(
        cmdCtx,
        organizationId: 'org_1',
        branchId: 'br_1',
        customerPartyId: 'cust_farm',
        customerName: 'Kalamb Solar Farm',
        siteAddress: 'Industrial Zone, Kalamb',
        equipmentSerialId: 'SN-INV-5000-OLD',
        issueDescription: '5kW Inverter showing error code E-04 (Grid Overvoltage)',
        isCoveredByWarranty: true,
        isCoveredByAmc: true,
      );

      expect(job.status, ServiceJobStatus.logged);
      expect(job.isCoveredByWarranty, isTrue);

      // 2. Assign Technician
      final assignUseCase = AssignTechnicianUseCase(serviceStore: serviceStore);
      final assignedJob = await assignUseCase.execute(
        cmdCtx,
        jobId: job.id,
        technicianUserId: 'usr_tech_rajesh',
        technicianName: 'Rajesh Sharma',
      );

      expect(assignedJob.status, ServiceJobStatus.assigned);
      expect(assignedJob.assignedTechnicianName, 'Rajesh Sharma');

      // 3. Record Service Visit with Spares Stock Deduction
      await inventoryStore.saveStockBalance(
        StockBalance(
          productId: 'sp_fuse_20a',
          locationId: 'loc_main',
          quantityMicroUnits: 10000000, // 10 units available
          valuePaise: 250000, // ₹2500
          updatedAt: DateTime.now(),
        ),
      );

      final visitUseCase = RecordServiceVisitUseCase(
        serviceStore: serviceStore,
        inventoryStore: inventoryStore,
      );

      final visit = await visitUseCase.execute(
        cmdCtx,
        jobId: job.id,
        technicianUserId: 'usr_tech_rajesh',
        technicianName: 'Rajesh Sharma',
        visitDate: DateTime.now(),
        workPerformed: 'Replaced DC fuse and reconfigured grid protection thresholds',
        travelExpensesPaise: Money.fromRupees(200.0),
        laborCostPaise: Money.fromRupees(500.0),
        billableAmountPaise: Money.fromRupees(0), // Free under warranty
        sparesUsed: [
          SpareItemInput(
            productId: 'sp_fuse_20a',
            productName: '20A DC Fuse Unit',
            sku: 'ELE-FUS-20A',
            quantity: Quantity.fromUnits(2.0),
            unitCostPaise: Money.fromRupees(250.0),
          ).toSpareItem(),
        ],
        storageLocationId: 'loc_main',
        isJobResolved: true,
      );

      expect(visit.isCompleted, isTrue);

      // Verify inventory stock balance reduced by 2 units
      final updatedBalance = await inventoryStore.getStockBalance('sp_fuse_20a', 'loc_main');
      expect(updatedBalance?.quantityMicroUnits, 8000000); // 8 units remaining

      // Verify job status updated to resolved
      final resolvedJob = await serviceStore.getServiceJob(job.id);
      expect(resolvedJob?.status, ServiceJobStatus.resolved);

      // 4. Perform Serial Component Replacement Swap
      await inventoryStore.saveSerialRecord(
        SerialRecord(
          id: 's_old',
          organizationId: 'org_1',
          productId: 'prod_inv_5kw',
          serialNumber: 'SN-INV-5000-OLD',
          state: SerialState.sold,
          updatedAt: DateTime.now(),
        ),
      );

      await inventoryStore.saveSerialRecord(
        SerialRecord(
          id: 's_new',
          organizationId: 'org_1',
          productId: 'prod_inv_5kw',
          serialNumber: 'SN-INV-5000-NEW',
          state: SerialState.inStock,
          updatedAt: DateTime.now(),
        ),
      );

      final replaceUseCase = ReplaceSerializedComponentUseCase(
        serviceStore: serviceStore,
        inventoryStore: inventoryStore,
      );

      final replacement = await replaceUseCase.execute(
        cmdCtx,
        organizationId: 'org_1',
        productId: 'prod_inv_5kw',
        jobId: job.id,
        oldSerialNumber: 'SN-INV-5000-OLD',
        newSerialNumber: 'SN-INV-5000-NEW',
        replacementDate: DateTime.now(),
        reason: 'Internal board failure under warranty',
      );

      expect(replacement.oldSerialId, 'SN-INV-5000-OLD');
      expect(replacement.newSerialId, 'SN-INV-5000-NEW');

      final oldSerial = await inventoryStore.getSerialByNumber('org_1', 'prod_inv_5kw', 'SN-INV-5000-OLD');
      expect(oldSerial?.state, SerialState.scrapped);

      final newSerial = await inventoryStore.getSerialByNumber('org_1', 'prod_inv_5kw', 'SN-INV-5000-NEW');
      expect(newSerial?.state, SerialState.sold);

      final lineage = await serviceStore.getSerialReplacements('SN-INV-5000-OLD');
      expect(lineage.length, 1);
    });

    test('AMC Contract Creation, Renewal, and Reminder Generation', () async {
      final now = DateTime.now();
      final createAmcUseCase = CreateAmcContractUseCase(serviceStore: serviceStore);

      final contract = await createAmcUseCase.execute(
        cmdCtx,
        organizationId: 'org_1',
        branchId: 'br_1',
        customerPartyId: 'cust_farm',
        customerName: 'Kalamb Solar Farm',
        siteAddress: 'Industrial Zone, Kalamb',
        startDate: now.subtract(const Duration(days: 350)),
        endDate: now.add(const Duration(days: 15)), // Expiring in 15 days
        contractValuePaise: Money.fromRupees(15000.0),
        visitLimitPerYear: 4,
      );

      expect(contract.status, AmcContractStatus.active);

      // Generate Reminders
      final reminderUseCase = GenerateAmcRemindersUseCase(serviceStore: serviceStore);
      final reminders = await reminderUseCase.execute(cmdCtx, organizationId: 'org_1');

      expect(reminders.length, 1);
      expect(reminders.first.contractNumber, contract.contractNumber);
      expect(reminders.first.description, contains('Expiring in'));

      // Renew Contract
      final renewUseCase = RenewAmcContractUseCase(serviceStore: serviceStore);
      final renewed = await renewUseCase.execute(
        cmdCtx,
        contractId: contract.id,
        newEndDate: now.add(const Duration(days: 380)),
        renewalValuePaise: Money.fromRupees(15000.0),
      );

      expect(renewed.status, AmcContractStatus.renewed);
      expect(renewed.contractValuePaise, Money.fromRupees(30000.0));
    });
  });
}

class SpareItemInput {
  SpareItemInput({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitCostPaise,
  });

  final String productId;
  final String productName;
  final String sku;
  final Quantity quantity;
  final Money unitCostPaise;

  ServiceJobSpareItem toSpareItem() {
    return ServiceJobSpareItem(
      productId: productId,
      productName: productName,
      sku: sku,
      quantity: quantity,
      unitCostPaise: unitCostPaise,
    );
  }
}
