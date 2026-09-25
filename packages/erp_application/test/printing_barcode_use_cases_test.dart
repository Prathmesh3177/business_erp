import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

final class _MockSalesStore implements SalesStore {
  SaleHeader? headerToReturn;
  List<SaleLine> linesToReturn = [];

  @override
  Future<void> saveSale({required SaleHeader header, required List<SaleLine> lines, List<TenderLine> tenderLines = const []}) async {}

  @override
  Future<SaleHeader?> getSaleHeader(String id) async => headerToReturn?.id == id ? headerToReturn : null;

  @override
  Future<List<SaleLine>> getSaleLines(String saleId) async => linesToReturn;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('P09 GenerateInvoiceViewModelUseCase Tests', () {
    final now = DateTime.now();

    final org = Organization(
      id: const OrganizationId('org_sks'),
      legalName: 'Shree Krushna Sales',
      displayName: 'Shree Krushna Sales',
      createdAtUtc: now,
    );

    final branch = Branch(
      id: const BranchId('branch_kalamb'),
      organizationId: const OrganizationId('org_sks'),
      name: 'Kalamb Branch',
      timeZone: 'Asia/Kolkata',
      locale: 'en',
      createdAtUtc: now,
    );

    test('GenerateInvoiceViewModelUseCase throws ValidationFailure if sale does not exist', () async {
      final salesStore = _MockSalesStore();
      final useCase = GenerateInvoiceViewModelUseCase(salesStore: salesStore);

      expect(
        () => useCase.call(
          saleId: 'non_existent',
          organization: org,
          branch: branch,
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('GenerateInvoiceViewModelUseCase builds frozen InvoiceViewModel for existing sale', () async {
      final salesStore = _MockSalesStore();
      salesStore.headerToReturn = SaleHeader(
        id: 'sale_200',
        organizationId: 'org_sks',
        branchId: 'branch_kalamb',
        documentHeaderId: 'SKS/2627/000002',
        customerPartyId: 'cust_1',
        customerName: 'Sanjay Shinde',
        businessDate: now,
        locationId: 'MAIN_WH',
        status: SaleStatus.posted,
        subtotalPaise: Money.fromPaise(100000),
        allocatedDiscountPaise: Money.zero,
        totalTaxPaise: Money.fromPaise(18000),
        grandTotalPaise: Money.fromPaise(118000),
        amountPaidPaise: Money.fromPaise(118000),
        balanceDuePaise: Money.zero,
        createdAtUtc: now,
      );

      salesStore.linesToReturn = [
        SaleLine(
          id: 'l_1',
          saleId: 'sale_200',
          productId: 'p_1',
          productName: 'Solar Cable 4sqmm',
          sku: 'CABLE-4SQMM',
          hsnCode: '85444999',
          baseUnit: 'MTR',
          quantity: Quantity.fromUnits(10.0),
          unitPrice: UnitPrice.fromRupees(100.0),
          lineDiscountPaise: Money.zero,
          taxSnapshot: TaxLineResult(
            lineId: 'l_1',
            taxableAmount: Money.fromPaise(100000),
            cgst: Money.fromPaise(9000),
            sgst: Money.fromPaise(9000),
            igst: Money.zero,
            totalTax: Money.fromPaise(18000),
            totalAmount: Money.fromPaise(118000),
          ),
          costSnapshotMicroRupees: 80000000,
          netTotalPaise: Money.fromPaise(118000),
        ),
      ];

      final useCase = GenerateInvoiceViewModelUseCase(salesStore: salesStore);
      final vm = await useCase.call(
        saleId: 'sale_200',
        organization: org,
        branch: branch,
      );

      expect(vm.invoiceNumber, equals('SKS/2627/000002'));
      expect(vm.customerName, equals('Sanjay Shinde'));
      expect(vm.lineItems.first.sku, equals('CABLE-4SQMM'));
    });
  });
}
