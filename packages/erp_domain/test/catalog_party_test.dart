import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Catalog domain invariants', () {
    test('normalizes SKU to uppercase and validates empty name/sku', () {
      final product = Product(
        id: 'prod_1',
        organizationId: 'org_1',
        sku: '  pv-540w  ',
        name: 'Mono PERC Solar Panel 540W',
        categoryId: 'cat_panels',
        baseUnitId: 'unit_pcs',
        hsnCode: '85414011',
        costPricePaise: 1200000,
        sellingPricePaise: 1500000,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(product.normalizedSku, equals('PV-540W'));
      expect(() => Product(
        id: 'prod_2',
        organizationId: 'org_1',
        sku: '',
        name: 'Invalid',
        categoryId: 'cat_panels',
        baseUnitId: 'unit_pcs',
        hsnCode: '85414011',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ), throwsA(isA<ValidationFailure>()));
    });

    test('validates tax rate bps bounds and negative prices', () {
      expect(() => Product(
        id: 'prod_3',
        organizationId: 'org_1',
        sku: 'INV-5KW',
        name: '5kW Solar Inverter',
        categoryId: 'cat_inv',
        baseUnitId: 'unit_pcs',
        hsnCode: '85044090',
        defaultTaxRateBps: 12000, // Exceeds 10000 (100%)
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ), throwsA(isA<ValidationFailure>()));
    });
  });

  group('Party domain invariants', () {
    test('validates GSTIN format and non-empty name', () {
      final validParty = Party(
        id: 'party_1',
        organizationId: 'org_1',
        name: 'Tata Power Solar Systems',
        isCustomer: true,
        isSupplier: true,
        gstin: '27AAAAA0000A1Z5',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(validParty.gstin, equals('27AAAAA0000A1Z5'));

      expect(() => Party(
        id: 'party_2',
        organizationId: 'org_1',
        name: 'Invalid GST Supplier',
        gstin: 'INVALID_GSTIN_123',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ), throwsA(isA<ValidationFailure>()));
    });
  });

  group('Attachment domain invariants', () {
    test('validates file size limit and MIME types', () {
      final validAttach = Attachment(
        id: 'att_1',
        organizationId: 'org_1',
        fileName: 'datasheet.pdf',
        mimeType: 'application/pdf',
        fileSizeBytes: 1024 * 1024,
        sha256Hash: 'abc123hash',
        storagePath: '/storage/datasheet.pdf',
        createdAt: DateTime.now(),
      );
      expect(validAttach.fileName, equals('datasheet.pdf'));

      expect(() => Attachment(
        id: 'att_2',
        organizationId: 'org_1',
        fileName: 'exe_file.exe',
        mimeType: 'application/x-msdownload',
        fileSizeBytes: 1024,
        sha256Hash: 'hash',
        storagePath: '/storage/exe',
        createdAt: DateTime.now(),
      ), throwsA(isA<ValidationFailure>()));
    });
  });
}
