import 'package:erp_domain/erp_domain.dart';

import 'catalog_store.dart';
import 'command_context.dart';
import 'dto.dart';

final class CreateProductUseCase {
  const CreateProductUseCase(this._catalogStore);

  final CatalogStore _catalogStore;

  Future<Product> execute(CommandContext context, Product product) async {
    context.requireCapability(Capability.inventoryManage);

    final existing = await _catalogStore.getProductBySku(product.organizationId, product.normalizedSku);
    if (existing != null) {
      throw ConflictFailure('duplicate_sku', 'A product with SKU "${product.normalizedSku}" already exists.');
    }

    await _catalogStore.saveProduct(product);
    return product;
  }
}

final class SearchCatalogUseCase {
  const SearchCatalogUseCase(this._catalogStore);

  final CatalogStore _catalogStore;

  Future<List<Object>> execute(
    CommandContext context,
    String organizationId, {
    String? query,
    String? categoryId,
    String? brandId,
  }) async {
    context.requireCapability(Capability.inventoryManage);

    final products = await _catalogStore.searchProducts(
      organizationId,
      query: query,
      categoryId: categoryId,
      brandId: brandId,
    );

    final hasCostAccess = context.hasCapability(Capability.costDataRead);

    return products.map<Object>((p) {
      final publicDto = PublicProductCatalogDto(
        id: p.id,
        sku: p.sku,
        name: p.name,
        sellingPrice: p.sellingPricePaise / 100.0,
        unit: p.baseUnitId,
      );

      if (hasCostAccess) {
        final cost = p.costPricePaise / 100.0;
        final margin = p.sellingPricePaise > 0
            ? ((p.sellingPricePaise - p.costPricePaise) / p.sellingPricePaise) * 100
            : 0.0;
        return CostSensitiveProductDto(
          publicData: publicDto,
          purchaseCost: cost,
          marginPercentage: margin,
          supplierId: '',
        );
      }
      return publicDto;
    }).toList();
  }
}
