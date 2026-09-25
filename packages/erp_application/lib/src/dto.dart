import 'package:erp_domain/erp_domain.dart';

import 'command_context.dart';

final class PublicProductCatalogDto {
  const PublicProductCatalogDto({
    required this.id,
    required this.sku,
    required this.name,
    required this.sellingPrice,
    required this.unit,
  });

  final String id;
  final String sku;
  final String name;
  final double sellingPrice;
  final String unit;
}

final class CostSensitiveProductDto {
  const CostSensitiveProductDto({
    required this.publicData,
    required this.purchaseCost,
    required this.marginPercentage,
    required this.supplierId,
  });

  final PublicProductCatalogDto publicData;
  final double purchaseCost;
  final double marginPercentage;
  final String supplierId;

  static CostSensitiveProductDto build({
    required CommandContext context,
    required PublicProductCatalogDto publicData,
    required double purchaseCost,
    required double marginPercentage,
    required String supplierId,
  }) {
    context.requireCapability(Capability.costDataRead);
    return CostSensitiveProductDto(
      publicData: publicData,
      purchaseCost: purchaseCost,
      marginPercentage: marginPercentage,
      supplierId: supplierId,
    );
  }
}
