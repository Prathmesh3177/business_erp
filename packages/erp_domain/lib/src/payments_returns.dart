import 'money.dart';
import 'tax_engine.dart';

enum SalesReturnStatus { posted, cancelled }
enum PurchaseReturnStatus { posted, cancelled }
enum ReturnDisposition { returnToStock, quarantine }

final class SalesReturnLine {
  const SalesReturnLine({
    required this.id,
    required this.salesReturnId,
    required this.saleLineId,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.lineDiscountPaise,
    required this.taxSnapshot,
    required this.costSnapshotMicroRupees,
    required this.netTotalPaise,
    this.serials = const [],
    this.disposition = ReturnDisposition.returnToStock,
  });

  final String id;
  final String salesReturnId;
  final String saleLineId;
  final String productId;
  final String productName;
  final String sku;
  final Quantity quantity;
  final UnitPrice unitPrice;
  final Money lineDiscountPaise;
  final TaxLineResult taxSnapshot;
  final int costSnapshotMicroRupees;
  final Money netTotalPaise;
  final List<String> serials;
  final ReturnDisposition disposition;

  Money get lineCogsReversalPaise =>
      Money.fromPaise((costSnapshotMicroRupees * quantity.microUnits) ~/ 10000000000);
}

final class SalesReturnHeader {
  const SalesReturnHeader({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.documentHeaderId,
    required this.originalSaleId,
    required this.customerPartyId,
    required this.customerName,
    required this.returnDate,
    required this.locationId,
    required this.status,
    required this.subtotalPaise,
    required this.totalTaxPaise,
    required this.grandTotalPaise,
    required this.refundedAmountPaise,
    required this.createdAtUtc,
    this.reason,
    this.notes,
  });

  final String id;
  final String organizationId;
  final String branchId;
  final String documentHeaderId;
  final String originalSaleId;
  final String customerPartyId;
  final String customerName;
  final DateTime returnDate;
  final String locationId;
  final SalesReturnStatus status;
  final Money subtotalPaise;
  final Money totalTaxPaise;
  final Money grandTotalPaise;
  final Money refundedAmountPaise;
  final DateTime createdAtUtc;
  final String? reason;
  final String? notes;
}

final class PurchaseReturnLine {
  const PurchaseReturnLine({
    required this.id,
    required this.purchaseReturnId,
    required this.purchaseLineId,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPurchasePrice,
    required this.taxSnapshot,
    required this.netTotalPaise,
    this.serials = const [],
  });

  final String id;
  final String purchaseReturnId;
  final String purchaseLineId;
  final String productId;
  final String productName;
  final String sku;
  final Quantity quantity;
  final UnitPrice unitPurchasePrice;
  final TaxLineResult taxSnapshot;
  final Money netTotalPaise;
  final List<String> serials;
}

final class PurchaseReturnHeader {
  const PurchaseReturnHeader({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.documentHeaderId,
    required this.originalPurchaseId,
    required this.supplierId,
    required this.supplierName,
    required this.returnDate,
    required this.locationId,
    required this.status,
    required this.subtotalPaise,
    required this.totalTaxPaise,
    required this.grandTotalPaise,
    required this.createdAtUtc,
    this.reason,
    this.notes,
  });

  final String id;
  final String organizationId;
  final String branchId;
  final String documentHeaderId;
  final String originalPurchaseId;
  final String supplierId;
  final String supplierName;
  final DateTime returnDate;
  final String locationId;
  final PurchaseReturnStatus status;
  final Money subtotalPaise;
  final Money totalTaxPaise;
  final Money grandTotalPaise;
  final DateTime createdAtUtc;
  final String? reason;
  final String? notes;
}

final class PartyAgingBucket {
  const PartyAgingBucket({
    required this.partyId,
    required this.partyName,
    required this.days0To30,
    required this.days31To60,
    required this.days61To90,
    required this.days90Plus,
  });

  final String partyId;
  final String partyName;
  final Money days0To30;
  final Money days31To60;
  final Money days61To90;
  final Money days90Plus;

  Money get totalOutstanding =>
      days0To30 + days31To60 + days61To90 + days90Plus;
}
