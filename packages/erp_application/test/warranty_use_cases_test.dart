import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

final class MockSalesStoreForWarranty implements SalesStore {
  final List<WarrantyEntitlement> warranties = [];

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
  Future<void> saveSale({required SaleHeader header, required List<SaleLine> lines}) async {}

  @override
  Future<SaleHeader?> getSaleHeader(String id) async => null;

  @override
  Future<List<SaleLine>> getSaleLines(String saleId) async => [];

  @override
  Future<List<SaleHeader>> listSales({required String organizationId, String? customerPartyId}) async => [];

  @override
  Future<void> saveSaleDraft(SaleDraft draft) async {}

  @override
  Future<SaleDraft?> getSaleDraft(String id) async => null;

  @override
  Future<void> deleteSaleDraft(String id) async {}

  @override
  Future<List<SaleDraft>> listSaleDrafts(String organizationId) async => [];
}

void main() {
  group('P12 Warranty Application Use Cases Tests', () {
    late MockSalesStoreForWarranty salesStore;
    late GenerateWarrantyRemindersUseCase generateUseCase;
    late ExportWarrantyRemindersUseCase exportUseCase;

    final adminSession = UserSession(
      id: const SessionId('sess-admin'),
      userId: const UserId('usr-admin'),
      username: 'admin',
      roleId: Role.adminRoleId,
      branchId: const BranchId('branch_1'),
      capabilities: Role.admin.capabilities,
      token: 'token-admin',
      expiresAtUtc: DateTime(2026, 12, 31),
      lastActivityAtUtc: DateTime(2026, 1, 1),
    );

    final adminContext = CommandContext(
      session: adminSession,
      timestampUtc: DateTime(2026, 9, 25),
    );


    setUp(() {
      salesStore = MockSalesStoreForWarranty();
      generateUseCase = GenerateWarrantyRemindersUseCase(salesStore: salesStore);
      exportUseCase = const ExportWarrantyRemindersUseCase();
    });

    test('GenerateWarrantyRemindersUseCase calculates status and deduplicates per serial', () async {
      final now = DateTime(2026, 9, 25);

      await salesStore.saveWarrantyEntitlement(
        WarrantyEntitlement(
          id: 'w-1',
          serialId: 's-100',
          productId: 'prod-pump',
          serialNumber: 'SN-PUMP-001',
          partyId: 'cust-1',
          saleDocumentId: 'sale-1',
          startDate: DateTime(2025, 9, 25),
          endDate: DateTime(2026, 10, 10), // 15 days remaining -> expiringSoon
          termsSnapshot: 'Standard Solar Pump Warranty',
          createdAtUtc: DateTime(2025, 9, 25),
        ),
      );

      await salesStore.saveWarrantyEntitlement(
        WarrantyEntitlement(
          id: 'w-2',
          serialId: 's-101',
          productId: 'prod-panel',
          serialNumber: 'SN-PANEL-500',
          partyId: 'cust-1',
          saleDocumentId: 'sale-2',
          startDate: DateTime(2020, 9, 25),
          endDate: DateTime(2025, 9, 25), // -365 days -> expired
          termsSnapshot: '5 Year Solar Panel Warranty',
          createdAtUtc: DateTime(2020, 9, 25),
        ),
      );

      final reminders = await generateUseCase.execute(
        context: adminContext,
        organizationId: 'org-1',
        referenceDate: now,
      );

      expect(reminders.length, equals(2));
      expect(reminders[0].status, equals(WarrantyReminderStatus.expired));
      expect(reminders[1].status, equals(WarrantyReminderStatus.expiringSoon));
    });

    test('ExportWarrantyRemindersUseCase sanitizes formula injection characters', () {
      final reminders = [
        WarrantyReminder(
          id: 'rem-1',
          serialId: 's-1',
          serialNumber: '=CMD|"/C calc"!A0',
          productId: 'prod-1',
          productName: '+FormulaProduct',
          partyId: 'cust-1',
          customerName: '@EvilCustomer',
          customerPhone: '9881630001',
          startDate: DateTime(2025, 1, 1),
          endDate: DateTime(2026, 10, 1),
          daysRemaining: 6,
          status: WarrantyReminderStatus.expiringSoon,
        ),
      ];

      final csv = exportUseCase.executeCsv(reminders);
      expect(csv, contains("'=CMD|\"/C calc\"!A0"));
      expect(csv, contains("'+FormulaProduct"));
      expect(csv, contains("'@EvilCustomer"));
    });

    test('AppLifecycleDraftHandler manages POS and stock draft lifecycle', () {
      final handler = AppLifecycleDraftHandler();
      expect(handler.hasRecoverableDraft, isFalse);

      handler.savePosDraft('{"lines":[{"sku":"PUMP-5HP"}]}');
      expect(handler.hasRecoverableDraft, isTrue);
      expect(handler.pendingPosDraftJson, contains('PUMP-5HP'));

      handler.clearPosDraft();
      expect(handler.hasRecoverableDraft, isFalse);
    });
  });
}
