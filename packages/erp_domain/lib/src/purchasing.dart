import 'money.dart';
import 'tax_engine.dart';

enum PurchaseStatus {
  draft,
  posted,
  cancelled,
}

enum LandedCostAllocationType {
  byValue,
  byQuantity,
}

enum PaymentDirection {
  inbound,  // Customer payment
  outbound, // Supplier payment
}

enum PaymentMethod {
  cash,
  bankTransfer,
  upi,
  cheque,
}

final class PurchaseLine {
  const PurchaseLine({
    required this.id,
    required this.purchaseId,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPurchasePrice,
    required this.discountPaise,
    required this.taxSnapshot,
    required this.landedCostAllocationPaise,
    required this.netTotalPaise,
    this.serials = const [],
    this.batchLot,
    this.expiryDate,
  });

  final String id;
  final String purchaseId;
  final String productId;
  final String productName;
  final String sku;
  final Quantity quantity;
  final UnitPrice unitPurchasePrice;
  final Money discountPaise;
  final TaxLineResult taxSnapshot;
  final Money landedCostAllocationPaise;
  final Money netTotalPaise;
  final List<String> serials;
  final String? batchLot;
  final DateTime? expiryDate;

  /// Line subtotal before discount & tax
  Money get subtotalBeforeDiscountPaise =>
      Money.fromPaise((unitPurchasePrice.microRupees * quantity.microUnits) ~/ 10000000000);

  /// Line taxable amount after discount
  Money get taxableAmountPaise => subtotalBeforeDiscountPaise - discountPaise;

  /// Total inventory acquisition cost for this line (Taxable amount + Landed cost)
  Money get inventoryValuePaise => taxableAmountPaise + landedCostAllocationPaise;

  PurchaseLine copyWith({
    String? id,
    String? purchaseId,
    String? productId,
    String? productName,
    String? sku,
    Quantity? quantity,
    UnitPrice? unitPurchasePrice,
    Money? discountPaise,
    TaxLineResult? taxSnapshot,
    Money? landedCostAllocationPaise,
    Money? netTotalPaise,
    List<String>? serials,
    String? batchLot,
    DateTime? expiryDate,
  }) {
    return PurchaseLine(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      quantity: quantity ?? this.quantity,
      unitPurchasePrice: unitPurchasePrice ?? this.unitPurchasePrice,
      discountPaise: discountPaise ?? this.discountPaise,
      taxSnapshot: taxSnapshot ?? this.taxSnapshot,
      landedCostAllocationPaise: landedCostAllocationPaise ?? this.landedCostAllocationPaise,
      netTotalPaise: netTotalPaise ?? this.netTotalPaise,
      serials: serials ?? this.serials,
      batchLot: batchLot ?? this.batchLot,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }
}

final class PurchaseHeader {
  const PurchaseHeader({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.documentHeaderId,
    required this.supplierId,
    required this.supplierName,
    required this.externalInvoiceNumber,
    required this.normalizedExternalInvoiceNumber,
    required this.invoiceDate,
    required this.locationId,
    required this.status,
    required this.subtotalPaise,
    required this.landedCostTotalPaise,
    required this.totalTaxPaise,
    required this.netTotalPaise,
    required this.amountPaidPaise,
    required this.balanceDuePaise,
    required this.createdAtUtc,
    this.paymentTerms,
    this.notes,
  });

  final String id;
  final String organizationId;
  final String branchId;
  final String documentHeaderId;
  final String supplierId;
  final String supplierName;
  final String externalInvoiceNumber;
  final String normalizedExternalInvoiceNumber;
  final DateTime invoiceDate;
  final String locationId;
  final PurchaseStatus status;
  final Money subtotalPaise;
  final Money landedCostTotalPaise;
  final Money totalTaxPaise;
  final Money netTotalPaise;
  final Money amountPaidPaise;
  final Money balanceDuePaise;
  final DateTime createdAtUtc;
  final String? paymentTerms;
  final String? notes;

  static String normalizeExternalInvoiceNumber(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), '').toUpperCase();
  }
}

final class Payment {
  const Payment({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.partyId,
    required this.partyName,
    required this.direction,
    required this.paymentMethod,
    required this.amountPaise,
    required this.paymentDate,
    required this.createdAtUtc,
    this.referenceNumber,
    this.notes,
  });

  final String id;
  final String organizationId;
  final String branchId;
  final String partyId;
  final String partyName;
  final PaymentDirection direction;
  final PaymentMethod paymentMethod;
  final Money amountPaise;
  final DateTime paymentDate;
  final DateTime createdAtUtc;
  final String? referenceNumber;
  final String? notes;
}

final class PaymentAllocation {
  const PaymentAllocation({
    required this.id,
    required this.paymentId,
    required this.documentId,
    required this.allocatedAmountPaise,
    required this.createdAtUtc,
  });

  final String id;
  final String paymentId;
  final String documentId;
  final Money allocatedAmountPaise;
  final DateTime createdAtUtc;
}

/// Helper utility for distributing landed costs across purchase lines.
final class LandedCostAllocator {
  static List<Money> allocate({
    required Money totalLandedCost,
    required List<PurchaseLine> lines,
    required LandedCostAllocationType allocationType,
  }) {
    if (lines.isEmpty || totalLandedCost.paise == 0) {
      return List.filled(lines.length, Money.zero);
    }

    final totalPaise = totalLandedCost.paise;
    final allocated = List<int>.filled(lines.length, 0);

    if (allocationType == LandedCostAllocationType.byValue) {
      final totalValuePaise = lines.fold<int>(0, (sum, l) => sum + l.taxableAmountPaise.paise);
      if (totalValuePaise <= 0) {
        return _equalDistribute(totalPaise, lines.length);
      }
      var allocatedSum = 0;
      for (var i = 0; i < lines.length; i++) {
        final share = (lines[i].taxableAmountPaise.paise * totalPaise) ~/ totalValuePaise;
        allocated[i] = share;
        allocatedSum += share;
      }
      var remainder = totalPaise - allocatedSum;
      var idx = 0;
      while (remainder > 0) {
        allocated[idx % lines.length]++;
        remainder--;
        idx++;
      }
    } else {
      // By quantity
      final totalQtyMicro = lines.fold<int>(0, (sum, l) => sum + l.quantity.microUnits);
      if (totalQtyMicro <= 0) {
        return _equalDistribute(totalPaise, lines.length);
      }
      var allocatedSum = 0;
      for (var i = 0; i < lines.length; i++) {
        final share = (lines[i].quantity.microUnits * totalPaise) ~/ totalQtyMicro;
        allocated[i] = share;
        allocatedSum += share;
      }
      var remainder = totalPaise - allocatedSum;
      var idx = 0;
      while (remainder > 0) {
        allocated[idx % lines.length]++;
        remainder--;
        idx++;
      }
    }

    return allocated.map((p) => Money.fromPaise(p)).toList();
  }

  static List<Money> _equalDistribute(int totalPaise, int count) {
    final base = totalPaise ~/ count;
    var rem = totalPaise % count;
    final res = <Money>[];
    for (var i = 0; i < count; i++) {
      res.add(Money.fromPaise(base + (rem > 0 ? 1 : 0)));
      if (rem > 0) rem--;
    }
    return res;
  }
}
