import 'package:erp_domain/erp_domain.dart';

abstract interface class SalesStore {
  Future<void> saveSale({
    required SaleHeader header,
    required List<SaleLine> lines,
  });

  Future<SaleHeader?> getSaleHeader(String id);

  Future<List<SaleLine>> getSaleLines(String saleId);

  Future<List<SaleHeader>> listSales({
    required String organizationId,
    String? customerPartyId,
  });

  Future<void> saveSaleDraft(SaleDraft draft);

  Future<SaleDraft?> getSaleDraft(String id);

  Future<void> deleteSaleDraft(String id);

  Future<List<SaleDraft>> listSaleDrafts(String organizationId);

  Future<void> saveSaleOrder({
    required SaleOrder order,
    required List<SaleOrderLine> lines,
  }) => throw UnimplementedError();

  Future<SaleOrder?> getSaleOrder(String id) => throw UnimplementedError();

  Future<List<SaleOrderLine>> getSaleOrderLines(String orderId) =>
      throw UnimplementedError();

  Future<List<SaleOrder>> listSaleOrders({
    required String organizationId,
    OrderStatus? status,
  }) => throw UnimplementedError();

  Future<void> saveWarrantyEntitlement(WarrantyEntitlement entitlement);

  Future<List<WarrantyEntitlement>> getWarrantyEntitlementsForCustomer({
    required String organizationId,
    required String partyId,
  });

  Future<List<WarrantyEntitlement>> getAllWarrantyEntitlements({
    required String organizationId,
  });
}
