import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:test/test.dart';

final class _MemoryCatalogStore implements CatalogStore {
  final Map<String, Product> _products = {};

  @override
  Future<void> saveProduct(Product product) async {
    _products[product.normalizedSku] = product;
  }

  @override
  Future<Product?> getProductBySku(String organizationId, String sku) async {
    return _products[Product.normalizeSku(sku)];
  }

  @override
  Future<List<Product>> searchProducts(
    String organizationId, {
    String? query,
    String? categoryId,
    String? brandId,
    bool includeInactive = false,
  }) async {
    return _products.values.toList();
  }

  @override
  Future<void> saveBrand(Brand brand) async {}
  @override
  Future<void> saveCategory(Category category) async {}
  @override
  Future<void> saveUnit(Unit unit) async {}
  @override
  Future<void> saveBarcode(Barcode barcode) async {}
  @override
  Future<List<Brand>> getBrands(String organizationId) async => [];
  @override
  Future<List<Category>> getCategories(String organizationId) async => [];
  @override
  Future<Product?> getProductByBarcode(String organizationId, String barcode) async => null;
  @override
  Future<Product?> getProductById(String organizationId, String id) async => null;
  @override
  Future<List<Unit>> getUnits(String organizationId) async => [];
  @override
  Future<void> saveProductSupplierLink(ProductSupplierLink link) async {}
  @override
  Future<List<ProductSupplierLink>> getProductSupplierLinks(String productId) async => [];
}

void main() {
  late _MemoryCatalogStore catalogStore;
  late SearchCatalogUseCase searchUseCase;
  late CsvMasterImportUseCase csvImportUseCase;
  final now = DateTime.now();

  setUp(() {
    catalogStore = _MemoryCatalogStore();
    searchUseCase = SearchCatalogUseCase(catalogStore);
    csvImportUseCase = CsvMasterImportUseCase(catalogStore: catalogStore);
  });

  test('SearchCatalogUseCase filters cost data based on costDataRead capability', () async {
    await catalogStore.saveProduct(Product(
      id: 'prod_1',
      organizationId: 'org_1',
      sku: 'SOLAR-PANEL-540W',
      name: '540W Solar Panel',
      categoryId: 'cat_panels',
      baseUnitId: 'unit_pcs',
      hsnCode: '85414011',
      costPricePaise: 1200000, // 12,000 INR
      sellingPricePaise: 1500000, // 15,000 INR
      createdAt: now,
      updatedAt: now,
    ));

    final counterSession = UserSession(
      id: const SessionId('sess_counter'),
      userId: const UserId('user_counter'),
      username: 'counter',
      roleId: Role.counterRoleId,
      branchId: const BranchId('branch_1'),
      capabilities: {Capability.inventoryManage},
      token: 'tok_counter',
      expiresAtUtc: now.add(const Duration(hours: 8)),
      lastActivityAtUtc: now,
    );

    final adminSession = UserSession(
      id: const SessionId('sess_admin'),
      userId: const UserId('user_admin'),
      username: 'admin',
      roleId: Role.adminRoleId,
      branchId: const BranchId('branch_1'),
      capabilities: {Capability.inventoryManage, Capability.costDataRead},
      token: 'tok_admin',
      expiresAtUtc: now.add(const Duration(hours: 8)),
      lastActivityAtUtc: now,
    );

    final counterContext = CommandContext(session: counterSession, timestampUtc: now);
    final adminContext = CommandContext(session: adminSession, timestampUtc: now);

    final counterResults = await searchUseCase.execute(counterContext, 'org_1');
    expect(counterResults.first, isA<PublicProductCatalogDto>());
    final publicDto = counterResults.first as PublicProductCatalogDto;
    expect(publicDto.sku, equals('SOLAR-PANEL-540W'));

    final adminResults = await searchUseCase.execute(adminContext, 'org_1');
    expect(adminResults.first, isA<CostSensitiveProductDto>());
    final costDto = adminResults.first as CostSensitiveProductDto;
    expect(costDto.purchaseCost, equals(12000.0));
  });

  test('CsvMasterImportUseCase is repeat-safe with importCommandId', () async {
    final adminSession = UserSession(
      id: const SessionId('sess_admin'),
      userId: const UserId('user_admin'),
      username: 'admin',
      roleId: Role.adminRoleId,
      branchId: const BranchId('branch_1'),
      capabilities: {Capability.inventoryManage},
      token: 'tok_admin',
      expiresAtUtc: now.add(const Duration(hours: 8)),
      lastActivityAtUtc: now,
    );
    final adminContext = CommandContext(session: adminSession, timestampUtc: now);

    const csvContent = '''sku,name,category_id,selling_price,cost_price,hsn
SP-330W,330W Poly Panel,cat_panels,9000,7500,85414011
SP-400W,400W Mono Panel,cat_panels,11000,9200,85414011''';

    final firstRun = await csvImportUseCase.importProducts(
      adminContext,
      organizationId: 'org_1',
      importCommandId: 'cmd_import_123',
      csvContent: csvContent,
    );

    expect(firstRun.importedCount, equals(2));
    expect(firstRun.isRepeatExecution, isFalse);

    // Re-import with the exact same importCommandId
    final repeatRun = await csvImportUseCase.importProducts(
      adminContext,
      organizationId: 'org_1',
      importCommandId: 'cmd_import_123',
      csvContent: csvContent,
    );

    expect(repeatRun.isRepeatExecution, isTrue);
    expect(repeatRun.importedCount, equals(0));
  });
}
