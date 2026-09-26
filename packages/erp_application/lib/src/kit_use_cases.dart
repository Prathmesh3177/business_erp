import 'dart:convert';

import 'package:erp_domain/erp_domain.dart';

import 'accounting_store.dart';
import 'catalog_store.dart';
import 'command_context.dart';
import 'kit_store.dart';
import 'project_store.dart';
import 'project_use_cases.dart';

/// Creates a quotation from a saved kit after resolving every line against the
/// current catalog. Missing or inactive products make the operation fail.
final class CreateKitQuotationUseCase {
  const CreateKitQuotationUseCase({
    required this.kitStore,
    required this.catalogStore,
    required this.projectStore,
    required this.accountingStore,
  });

  final KitStore kitStore;
  final CatalogStore catalogStore;
  final ProjectStore projectStore;
  final AccountingStore accountingStore;

  Future<QuotationHeader> execute(
    CommandContext context, {
    required String organizationId,
    required String branchId,
    required String customerPartyId,
    required String customerName,
    required String kitId,
    required DateTime validUntil,
  }) async {
    final kit = await kitStore.getKit(organizationId, kitId);
    if (kit == null || !kit.active) {
      throw const ValidationFailure('kit_not_found', 'The selected kit is unavailable.');
    }
    final kitLines = await kitStore.getKitLines(kit.id);
    if (kitLines.isEmpty) {
      throw const ValidationFailure('kit_empty', 'The selected kit has no material lines.');
    }

    final inputs = <QuotationLineInput>[];
    for (final kitLine in kitLines) {
      final product = await catalogStore.getProductById(
        organizationId,
        kitLine.productId,
      );
      if (product == null || !product.active) {
        throw ValidationFailure(
          'kit_product_unavailable',
          'Kit "${kit.name}" references an unavailable catalog product (ID: ${kitLine.productId}).',
        );
      }
      inputs.add(
        QuotationLineInput(
          productId: product.id,
          productName: product.name,
          sku: product.sku,
          hsnCode: product.hsnCode,
          quantity: kitLine.quantity,
          unitPrice: UnitPrice.fromRupees(product.sellingPricePaise / 100),
          taxRate: TaxRate.fromBps(product.defaultTaxRateBps),
          bomSnapshotJson: jsonEncode({'kitId': kit.id, 'kitLineId': kitLine.id}),
        ),
      );
    }

    return CreateQuotationUseCase(
      projectStore: projectStore,
      accountingStore: accountingStore,
    ).execute(
      context,
      organizationId: organizationId,
      branchId: branchId,
      customerPartyId: customerPartyId,
      customerName: customerName,
      validUntil: validUntil,
      installationChargesPaise: kit.installationChargesPaise,
      lineInputs: inputs,
    );
  }
}
