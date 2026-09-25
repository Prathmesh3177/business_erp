import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

void main() {
  group('P09 InvoiceViewModel & PrintJob Domain Tests', () {
    final now = DateTime.now();

    final org = Organization(
      id: const OrganizationId('org_sks'),
      legalName: 'Shree Krushna Sales Private Limited',
      displayName: 'Shree Krushna Sales',
      createdAtUtc: now,
    );

    final branch = Branch(
      id: const BranchId('branch_kalamb'),
      organizationId: const OrganizationId('org_sks'),
      name: 'Kalamb Main Branch',
      timeZone: 'Asia/Kolkata',
      locale: 'en',
      createdAtUtc: now,
    );

    final customer = Party(
      id: 'party_100',
      organizationId: 'org_sks',
      name: 'Rahul Deshmukh',
      gstin: '27ABCDE1234F1Z5',
      isCustomer: true,
      createdAt: now,
      updatedAt: now,
    );

    final saleHeader = SaleHeader(
      id: 'sale_100',
      organizationId: 'org_sks',
      branchId: 'branch_kalamb',
      documentHeaderId: 'SKS/2627/000001',
      customerPartyId: 'party_100',
      customerName: 'Rahul Deshmukh',
      businessDate: now,
      locationId: 'MAIN_WH',
      status: SaleStatus.posted,
      subtotalPaise: Money.fromPaise(5000000), // ₹50,000.00
      allocatedDiscountPaise: Money.fromPaise(200000), // ₹2,000.00
      totalTaxPaise: Money.fromPaise(864000), // ₹8,640.00
      grandTotalPaise: Money.fromPaise(5664000), // ₹56,640.00
      amountPaidPaise: Money.fromPaise(5664000),
      balanceDuePaise: Money.zero,
      createdAtUtc: now,
    );

    final line1 = SaleLine(
      id: 'line_1',
      saleId: 'sale_100',
      productId: 'prod_pump_5hp',
      productName: 'Solar Water Pump 5HP',
      sku: 'PUMP-5HP',
      hsnCode: '84137010',
      baseUnit: 'NOS',
      quantity: Quantity.fromUnits(1.0),
      unitPrice: UnitPrice.fromRupees(50000.0),
      lineDiscountPaise: Money.fromPaise(200000),
      taxSnapshot: TaxLineResult(
        lineId: 'line_1',
        taxableAmount: Money.fromPaise(4800000),
        cgst: Money.fromPaise(432000),
        sgst: Money.fromPaise(432000),
        igst: Money.zero,
        totalTax: Money.fromPaise(864000),
        totalAmount: Money.fromPaise(5664000),
      ),
      costSnapshotMicroRupees: 40000000000,
      netTotalPaise: Money.fromPaise(5664000),
      serials: const ['SN-PUMP-5HP-001'],
    );

    test('InvoiceViewModel.fromSale freezes all header, line, tax, and serial details', () {
      final vm = InvoiceViewModel.fromSale(
        sale: saleHeader,
        lines: [line1],
        customer: customer,
        org: org,
        branch: branch,
        isReprint: false,
        language: InvoiceLanguage.marathi,
      );

      expect(vm.invoiceNumber, equals('SKS/2627/000001'));
      expect(vm.sellerDisplayName, equals('Shree Krushna Sales'));
      expect(vm.customerName, equals('Rahul Deshmukh'));
      expect(vm.customerGstin, equals('27ABCDE1234F1Z5'));
      expect(vm.lineItems.length, equals(1));
      expect(vm.lineItems.first.hsnCode, equals('84137010'));
      expect(vm.lineItems.first.serials, equals(['SN-PUMP-5HP-001']));
      expect(vm.grandTotalPaise.paise, equals(5664000));
      expect(vm.paymentStatus, equals('PAID'));
      expect(vm.serialsAppendix, equals(['SN-PUMP-5HP-001']));
      expect(vm.isReprint, isFalse);
      expect(vm.language, equals(InvoiceLanguage.marathi));
    });

    test('Reprint copy flag is explicitly preserved on InvoiceViewModel', () {
      final vmReprint = InvoiceViewModel.fromSale(
        sale: saleHeader,
        lines: [line1],
        customer: customer,
        org: org,
        branch: branch,
        isReprint: true,
      );

      expect(vmReprint.isReprint, isTrue);
    });

    test('PrintJob tracks lifecycle states and delivery-unknown distinction', () {
      final job = PrintJob(
        id: 'job_1',
        organizationId: 'org_sks',
        branchId: 'branch_kalamb',
        documentId: 'SKS/2627/000001',
        printerName: 'EPSON TM-T88VI',
        printFormat: InvoiceFormat.thermal80,
        status: PrintStatus.queued,
        isReprint: false,
        printedAtUtc: now,
      );

      expect(job.status, equals(PrintStatus.queued));

      final sendingJob = job.copyWith(status: PrintStatus.sending);
      expect(sendingJob.status, equals(PrintStatus.sending));

      final acceptedJob = sendingJob.copyWith(status: PrintStatus.accepted);
      expect(acceptedJob.status, equals(PrintStatus.accepted));

      final unknownJob = sendingJob.copyWith(
        status: PrintStatus.unknown,
        errorMessage: 'Printer spooler response timed out',
      );
      expect(unknownJob.status, equals(PrintStatus.unknown));
      expect(unknownJob.errorMessage, contains('timed out'));
    });
  });
}
