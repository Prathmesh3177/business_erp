import 'money.dart';
import 'tax_engine.dart';

enum SaleStatus {
  posted,
  cancelled,
}

enum TenderMethod {
  cash,
  bankTransfer,
  upi,
  card,
  customerCredit,
}

final class TenderLine {
  const TenderLine({
    required this.method,
    required this.amountPaise,
  });

  final TenderMethod method;
  final Money amountPaise;
}

final class SaleLine {
  const SaleLine({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.hsnCode,
    required this.baseUnit,
    required this.quantity,
    required this.unitPrice,
    required this.lineDiscountPaise,
    required this.taxSnapshot,
    required this.costSnapshotMicroRupees,
    required this.netTotalPaise,
    this.serials = const [],
    this.batchLot,
    this.isMadeToOrder = false,
  });

  final String id;
  final String saleId;
  final String productId;
  final String productName;
  final String sku;
  final String hsnCode;
  final String baseUnit;
  final Quantity quantity;
  final UnitPrice unitPrice;
  final Money lineDiscountPaise;
  final TaxLineResult taxSnapshot;
  final int costSnapshotMicroRupees;
  final Money netTotalPaise;
  final List<String> serials;
  final String? batchLot;
  final bool isMadeToOrder;

  /// Line subtotal before discount
  Money get subtotalBeforeDiscountPaise =>
      Money.fromPaise((unitPrice.microRupees * quantity.microUnits) ~/ 10000000000);

  /// Line taxable base amount after discount
  Money get taxableAmountPaise => subtotalBeforeDiscountPaise - lineDiscountPaise;

  /// Total COGS value for this line item based on weighted average cost snapshot
  Money get lineCogsPaise =>
      Money.fromPaise((costSnapshotMicroRupees * quantity.microUnits) ~/ 10000000000);
}

final class SaleHeader {
  const SaleHeader({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.documentHeaderId,
    required this.customerPartyId,
    required this.customerName,
    required this.businessDate,
    required this.locationId,
    required this.status,
    required this.subtotalPaise,
    required this.allocatedDiscountPaise,
    required this.totalTaxPaise,
    required this.grandTotalPaise,
    required this.amountPaidPaise,
    required this.balanceDuePaise,
    required this.createdAtUtc,
    this.notes,
  });

  final String id;
  final String organizationId;
  final String branchId;
  final String documentHeaderId;
  final String customerPartyId;
  final String customerName;
  final DateTime businessDate;
  final String locationId;
  final SaleStatus status;
  final Money subtotalPaise;
  final Money allocatedDiscountPaise;
  final Money totalTaxPaise;
  final Money grandTotalPaise;
  final Money amountPaidPaise;
  final Money balanceDuePaise;
  final DateTime createdAtUtc;
  final String? notes;
}

final class SaleDraft {
  const SaleDraft({
    required this.id,
    required this.organizationId,
    required this.branchId,
    this.customerPartyId,
    required this.customerName,
    required this.linesJson,
    required this.updatedAtUtc,
    this.notes,
  });

  final String id;
  final String organizationId;
  final String branchId;
  final String? customerPartyId;
  final String customerName;
  final String linesJson;
  final DateTime updatedAtUtc;
  final String? notes;
}

final class WarrantyEntitlement {
  const WarrantyEntitlement({
    required this.id,
    required this.serialId,
    required this.productId,
    required this.serialNumber,
    required this.partyId,
    required this.saleDocumentId,
    required this.startDate,
    required this.endDate,
    required this.termsSnapshot,
    required this.createdAtUtc,
  });

  final String id;
  final String serialId;
  final String productId;
  final String serialNumber;
  final String partyId;
  final String saleDocumentId;
  final DateTime startDate;
  final DateTime endDate;
  final String termsSnapshot;
  final DateTime createdAtUtc;
}
