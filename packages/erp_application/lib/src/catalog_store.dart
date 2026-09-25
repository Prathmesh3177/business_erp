import 'package:erp_domain/erp_domain.dart';

abstract interface class CatalogStore {
  Future<void> saveCategory(Category category);
  Future<List<Category>> getCategories(String organizationId);

  Future<void> saveBrand(Brand brand);
  Future<List<Brand>> getBrands(String organizationId);

  Future<void> saveUnit(Unit unit);
  Future<List<Unit>> getUnits(String organizationId);

  Future<void> saveProduct(Product product);
  Future<Product?> getProductById(String organizationId, String id);
  Future<Product?> getProductBySku(String organizationId, String sku);
  Future<List<Product>> searchProducts(
    String organizationId, {
    String? query,
    String? categoryId,
    String? brandId,
    bool includeInactive = false,
  });

  Future<void> saveBarcode(Barcode barcode);
  Future<Product?> getProductByBarcode(String organizationId, String barcode);
}
