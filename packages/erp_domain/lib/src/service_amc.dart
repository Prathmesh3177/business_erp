import 'money.dart';

enum ServiceJobStatus {
  logged,
  assigned,
  inProgress,
  resolved,
  closed,
  cancelled,
}

enum AmcContractStatus {
  active,
  expired,
  renewed,
  cancelled,
}

final class ServiceJob {
  const ServiceJob({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.jobTicketNumber,
    required this.customerPartyId,
    required this.customerName,
    required this.siteAddress,
    required this.equipmentSerialId,
    required this.issueDescription,
    this.assignedTechnicianUserId,
    this.assignedTechnicianName,
    this.isCoveredByWarranty = false,
    this.isCoveredByAmc = false,
    required this.status,
    required this.createdAtUtc,
  });

  final String id;
  final String organizationId;
  final String branchId;
  final String jobTicketNumber;
  final String customerPartyId;
  final String customerName;
  final String siteAddress;
  final String equipmentSerialId;
  final String issueDescription;
  final String? assignedTechnicianUserId;
  final String? assignedTechnicianName;
  final bool isCoveredByWarranty;
  final bool isCoveredByAmc;
  final ServiceJobStatus status;
  final DateTime createdAtUtc;
}

final class ServiceJobSpareItem {
  const ServiceJobSpareItem({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitCostPaise,
  });

  final String productId;
  final String productName;
  final String sku;
  final Quantity quantity;
  final Money unitCostPaise;

  Money get totalCostPaise => Money.fromRupees(unitCostPaise.inRupees * quantity.inUnits);
}

final class ServiceJobVisit {
  const ServiceJobVisit({
    required this.id,
    required this.jobId,
    required this.technicianUserId,
    required this.technicianName,
    required this.visitDate,
    required this.workPerformed,
    required this.travelExpensesPaise,
    required this.laborCostPaise,
    required this.billableAmountPaise,
    this.sparesUsed = const [],
    this.isCompleted = true,
  });

  final String id;
  final String jobId;
  final String technicianUserId;
  final String technicianName;
  final DateTime visitDate;
  final String workPerformed;
  final Money travelExpensesPaise;
  final Money laborCostPaise;
  final Money billableAmountPaise;
  final List<ServiceJobSpareItem> sparesUsed;
  final bool isCompleted;

  Money get totalSparesCostPaise => sparesUsed.fold(
        Money.zero,
        (sum, spare) => sum + spare.totalCostPaise,
      );

  Money get totalInternalCostPaise => travelExpensesPaise + laborCostPaise + totalSparesCostPaise;
}

final class SerialReplacement {
  const SerialReplacement({
    required this.id,
    required this.jobId,
    required this.oldSerialId,
    required this.newSerialId,
    required this.replacementDate,
    required this.reason,
  });

  final String id;
  final String jobId;
  final String oldSerialId;
  final String newSerialId;
  final DateTime replacementDate;
  final String reason;
}

final class AmcContract {
  const AmcContract({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.contractNumber,
    required this.customerPartyId,
    required this.customerName,
    required this.siteAddress,
    required this.startDate,
    required this.endDate,
    required this.contractValuePaise,
    required this.visitLimitPerYear,
    this.visitsCompleted = 0,
    required this.status,
    required this.createdAtUtc,
  });

  final String id;
  final String organizationId;
  final String branchId;
  final String contractNumber;
  final String customerPartyId;
  final String customerName;
  final String siteAddress;
  final DateTime startDate;
  final DateTime endDate;
  final Money contractValuePaise;
  final int visitLimitPerYear;
  final int visitsCompleted;
  final AmcContractStatus status;
  final DateTime createdAtUtc;

  bool get isVisitLimitReached => visitsCompleted >= visitLimitPerYear;

  bool isCoverageActiveAt(DateTime date) {
    if (status != AmcContractStatus.active) return false;
    if (date.isBefore(startDate)) return false;
    if (date.isAfter(endDate)) return false;
    return true;
  }
}

final class AmcReminder {
  const AmcReminder({
    required this.contractId,
    required this.contractNumber,
    required this.customerName,
    required this.dueOrExpiryDate,
    required this.isOverdue,
    required this.description,
  });

  final String contractId;
  final String contractNumber;
  final String customerName;
  final DateTime dueOrExpiryDate;
  final bool isOverdue;
  final String description;
}
