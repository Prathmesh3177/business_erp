import 'package:erp_domain/erp_domain.dart';

abstract interface class PurchasingStore {
  Future<void> savePurchase({
    required PurchaseHeader header,
    required List<PurchaseLine> lines,
  });

  Future<PurchaseHeader?> getPurchaseHeader(String id);

  Future<List<PurchaseLine>> getPurchaseLines(String purchaseId);

  Future<List<PurchaseHeader>> listPurchases({
    required String organizationId,
    String? supplierId,
  });

  Future<bool> hasDuplicateSupplierInvoice({
    required String organizationId,
    required String supplierId,
    required String financialYear,
    required String externalInvoiceNumber,
  });

  Future<void> savePayment({
    required Payment payment,
    required List<PaymentAllocation> allocations,
  });

  Future<Money> getSupplierOutstandingBalance({
    required String organizationId,
    required String supplierId,
  });
}
