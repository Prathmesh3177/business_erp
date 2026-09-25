import 'errors.dart';

enum SolarCategoryType {
  solarPanel,
  solarInverter,
  solarBattery,
  solarCable,
  solarPump,
  other,
}

final class Category {
  const Category({
    required this.id,
    required this.organizationId,
    required this.name,
    this.parentCategoryId,
    this.type = SolarCategoryType.other,
    this.active = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String organizationId;
  final String name;
  final String? parentCategoryId;
  final SolarCategoryType type;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class Brand {
  const Brand({
    required this.id,
    required this.organizationId,
    required this.name,
    this.active = true,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String organizationId;
  final String name;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
}

final class Unit {
  const Unit({
    required this.id,
    required this.organizationId,
    required this.code,
    required this.name,
    this.precisionScale = 0,
    this.active = true,
  });

  final String id;
  final String organizationId;
  final String code;
  final String name;
  final int precisionScale; // 0 to 6
  final bool active;
}

final class ProductUnitConversion {
  const ProductUnitConversion({
    required this.id,
    required this.productId,
    required this.unitId,
    required this.conversionFactor,
    this.active = true,
  });

  final String id;
  final String productId;
  final String unitId;
  final double conversionFactor; // Must be > 0
  final bool active;
}

enum SerialPolicy { none, single, batch }
enum BatchPolicy { none, fifo }

final class Barcode {
  const Barcode({
    required this.id,
    required this.productId,
    required this.code,
    this.active = true,
  });

  final String id;
  final String productId;
  final String code;
  final bool active;
}

final class ProductSupplierLink {
  const ProductSupplierLink({
    required this.id,
    required this.productId,
    required this.partyId,
    this.supplierProductCode,
    this.isPrimary = false,
  });

  final String id;
  final String productId;
  final String partyId;
  final String? supplierProductCode;
  final bool isPrimary;
}

final class Product {
  Product({
    required this.id,
    required this.organizationId,
    required this.sku,
    required this.name,
    required this.categoryId,
    this.brandId,
    this.model,
    required this.baseUnitId,
    this.serialPolicy = SerialPolicy.none,
    this.batchPolicy = BatchPolicy.none,
    this.minStock = 0,
    required this.hsnCode,
    this.defaultTaxRateBps = 1800, // 18.00% GST default
    this.costPricePaise = 0,
    this.sellingPricePaise = 0,
    this.active = true,
    Map<String, String>? attributes,
    required this.createdAt,
    required this.updatedAt,
  })  : normalizedSku = normalizeSku(sku),
        attributes = attributes ?? const {} {
    if (normalizedSku.isEmpty) {
      throw const ValidationFailure('invalid_sku', 'SKU cannot be empty');
    }
    if (name.trim().isEmpty) {
      throw const ValidationFailure('invalid_name', 'Product name cannot be empty');
    }
    if (costPricePaise < 0 || sellingPricePaise < 0) {
      throw const ValidationFailure('invalid_price', 'Prices cannot be negative');
    }
    if (defaultTaxRateBps < 0 || defaultTaxRateBps > 10000) {
      throw const ValidationFailure('invalid_tax_rate', 'Tax rate bps must be between 0 and 10000');
    }
  }

  final String id;
  final String organizationId;
  final String sku;
  final String normalizedSku;
  final String name;
  final String categoryId;
  final String? brandId;
  final String? model;
  final String baseUnitId;
  final SerialPolicy serialPolicy;
  final BatchPolicy batchPolicy;
  final double minStock;
  final String hsnCode;
  final int defaultTaxRateBps;
  final int costPricePaise;
  final int sellingPricePaise;
  final bool active;
  final Map<String, String> attributes;
  final DateTime createdAt;
  final DateTime updatedAt;

  static String normalizeSku(String rawSku) {
    return rawSku.trim().toUpperCase();
  }

  static String normalizeBarcode(String rawBarcode) {
    return rawBarcode.trim().toUpperCase();
  }
}
