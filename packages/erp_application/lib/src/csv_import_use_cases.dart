import 'package:erp_domain/erp_domain.dart';

import 'catalog_store.dart';
import 'command_context.dart';
import 'party_store.dart';

final class CsvRowError {
  const CsvRowError({required this.rowIndex, required this.field, required this.message});

  final int rowIndex;
  final String field;
  final String message;
}

final class CsvImportResult {
  const CsvImportResult({
    required this.importCommandId,
    required this.totalRows,
    required this.importedCount,
    required this.skippedCount,
    required this.errors,
    this.isRepeatExecution = false,
  });

  final String importCommandId;
  final int totalRows;
  final int importedCount;
  final int skippedCount;
  final List<CsvRowError> errors;
  final bool isRepeatExecution;
}

final class CsvMasterImportUseCase {
  CsvMasterImportUseCase({
    required CatalogStore catalogStore,
    required PartyStore partyStore,
  })  : _catalogStore = catalogStore,
        _partyStore = partyStore;

  final CatalogStore _catalogStore;
  final PartyStore _partyStore;
  final Set<String> _processedImportCommandIds = {};

  Future<CsvImportResult> importProducts(
    CommandContext context, {
    required String organizationId,
    required String importCommandId,
    required String csvContent,
  }) async {
    context.requireCapability(Capability.inventoryManage);

    // Idempotency check: repeat-safe import ID
    if (_processedImportCommandIds.contains(importCommandId)) {
      return CsvImportResult(
        importCommandId: importCommandId,
        totalRows: 0,
        importedCount: 0,
        skippedCount: 0,
        errors: const [],
        isRepeatExecution: true,
      );
    }

    final lines = csvContent.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    if (lines.length <= 1) {
      return CsvImportResult(
        importCommandId: importCommandId,
        totalRows: 0,
        importedCount: 0,
        skippedCount: 0,
        errors: const [CsvRowError(rowIndex: 0, field: 'csv', message: 'CSV file is empty or missing headers')],
      );
    }

    final errors = <CsvRowError>[];
    int imported = 0;
    int skipped = 0;

    final headers = lines.first.toLowerCase().split(',').map((h) => h.trim()).toList();
    final skuIdx = headers.indexOf('sku');
    final nameIdx = headers.indexOf('name');
    final categoryIdx = headers.indexOf('category_id');
    final priceIdx = headers.indexOf('selling_price');
    final costIdx = headers.indexOf('cost_price');
    final hsnIdx = headers.indexOf('hsn');

    if (skuIdx == -1 || nameIdx == -1) {
      return CsvImportResult(
        importCommandId: importCommandId,
        totalRows: lines.length - 1,
        importedCount: 0,
        skippedCount: lines.length - 1,
        errors: const [CsvRowError(rowIndex: 0, field: 'headers', message: 'Required headers missing: sku, name')],
      );
    }

    for (int i = 1; i < lines.length; i++) {
      final cols = lines[i].split(',').map((c) => c.trim()).toList();
      if (cols.length <= skuIdx || cols.length <= nameIdx) {
        errors.add(CsvRowError(rowIndex: i, field: 'row', message: 'Insufficient columns'));
        skipped++;
        continue;
      }

      final sku = cols[skuIdx];
      final name = cols[nameIdx];
      final categoryId = categoryIdx != -1 && cols.length > categoryIdx ? cols[categoryIdx] : 'general';
      final hsn = hsnIdx != -1 && cols.length > hsnIdx ? cols[hsnIdx] : '85414011';
      final sellingPrice = priceIdx != -1 && cols.length > priceIdx ? (double.tryParse(cols[priceIdx]) ?? 0.0) : 0.0;
      final costPrice = costIdx != -1 && cols.length > costIdx ? (double.tryParse(cols[costIdx]) ?? 0.0) : 0.0;

      if (sku.isEmpty) {
        errors.add(CsvRowError(rowIndex: i, field: 'sku', message: 'SKU cannot be empty'));
        skipped++;
        continue;
      }

      final existing = await _catalogStore.getProductBySku(organizationId, Product.normalizeSku(sku));
      if (existing != null) {
        errors.add(CsvRowError(rowIndex: i, field: 'sku', message: 'Duplicate SKU "${Product.normalizeSku(sku)}" ignored'));
        skipped++;
        continue;
      }

      try {
        final product = Product(
          id: 'imp_prod_${DateTime.now().microsecondsSinceEpoch}_$i',
          organizationId: organizationId,
          sku: sku,
          name: name,
          categoryId: categoryId,
          baseUnitId: 'unit_pcs',
          hsnCode: hsn,
          costPricePaise: (costPrice * 100).round(),
          sellingPricePaise: (sellingPrice * 100).round(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _catalogStore.saveProduct(product);
        imported++;
      } catch (e) {
        errors.add(CsvRowError(rowIndex: i, field: 'row', message: e.toString()));
        skipped++;
      }
    }

    _processedImportCommandIds.add(importCommandId);

    return CsvImportResult(
      importCommandId: importCommandId,
      totalRows: lines.length - 1,
      importedCount: imported,
      skippedCount: skipped,
      errors: errors,
    );
  }
}
