import 'money.dart';
import 'tax_engine.dart';

enum QuotationStatus {
  draft,
  sent,
  approved,
  rejected,
  superseded,
}

enum ProjectStatus {
  draft,
  planning,
  inProgress,
  completed,
  cancelled,
}

final class QuotationHeader {
  const QuotationHeader({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.quotationNumber,
    required this.revisionNumber,
    required this.customerPartyId,
    required this.customerName,
    required this.validUntil,
    required this.status,
    required this.subtotalPaise,
    required this.allocatedDiscountPaise,
    required this.totalTaxPaise,
    required this.grandTotalPaise,
    required this.installationChargesPaise,
    this.termsSnapshot = 'Standard 1-Year Workmanship & 25-Year Performance Warranty',
    required this.createdAtUtc,
  });

  final String id;
  final String organizationId;
  final String branchId;
  final String quotationNumber;
  final int revisionNumber;
  final String customerPartyId;
  final String customerName;
  final DateTime validUntil;
  final QuotationStatus status;
  final Money subtotalPaise;
  final Money allocatedDiscountPaise;
  final Money totalTaxPaise;
  final Money grandTotalPaise;
  final Money installationChargesPaise;
  final String termsSnapshot;
  final DateTime createdAtUtc;
}

final class QuotationLine {
  const QuotationLine({
    required this.id,
    required this.quotationId,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.hsnCode,
    required this.quantity,
    required this.unitPrice,
    required this.lineDiscountPaise,
    required this.taxSnapshot,
    required this.netTotalPaise,
    this.isServiceLine = false,
    this.bomSnapshotJson = '{}',
  });

  final String id;
  final String quotationId;
  final String productId;
  final String productName;
  final String sku;
  final String hsnCode;
  final Quantity quantity;
  final UnitPrice unitPrice;
  final Money lineDiscountPaise;
  final TaxLineResult taxSnapshot;
  final Money netTotalPaise;
  final bool isServiceLine;
  final String bomSnapshotJson;
}

final class SolarProject {
  const SolarProject({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.projectNumber,
    required this.name,
    required this.customerPartyId,
    required this.customerName,
    required this.siteAddress,
    required this.acceptedQuotationId,
    required this.acceptedQuotationRevision,
    required this.status,
    required this.budgetMaterialsPaise,
    required this.budgetLaborPaise,
    required this.actualMaterialsPaise,
    required this.actualExpensesPaise,
    required this.invoicedPaise,
    required this.wipBalancePaise,
    required this.createdAtUtc,
  });

  final String id;
  final String organizationId;
  final String branchId;
  final String projectNumber;
  final String name;
  final String customerPartyId;
  final String customerName;
  final String siteAddress;
  final String acceptedQuotationId;
  final int acceptedQuotationRevision;
  final ProjectStatus status;
  final Money budgetMaterialsPaise;
  final Money budgetLaborPaise;
  final Money actualMaterialsPaise;
  final Money actualExpensesPaise;
  final Money invoicedPaise;
  final Money wipBalancePaise;
  final DateTime createdAtUtc;
}

final class ProjectMaterialIssueLine {
  const ProjectMaterialIssueLine({
    required this.id,
    required this.issueId,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.costSnapshotMicroRupees,
    this.serials = const [],
  });

  final String id;
  final String issueId;
  final String productId;
  final String productName;
  final String sku;
  final Quantity quantity;
  final int costSnapshotMicroRupees;
  final List<String> serials;

  Money get totalCostPaise {
    final doubleRupees = (costSnapshotMicroRupees / 1000000.0) * quantity.inUnits;
    return Money.fromRupees(doubleRupees);
  }
}

final class ProjectMaterialIssue {
  const ProjectMaterialIssue({
    required this.id,
    required this.organizationId,
    required this.branchId,
    required this.projectId,
    required this.locationId,
    required this.issueDate,
    required this.lines,
    required this.totalCostPaise,
    required this.createdAtUtc,
    this.notes = '',
  });

  final String id;
  final String organizationId;
  final String branchId;
  final String projectId;
  final String locationId;
  final DateTime issueDate;
  final List<ProjectMaterialIssueLine> lines;
  final Money totalCostPaise;
  final DateTime createdAtUtc;
  final String notes;
}

final class ProjectBudgetReport {
  const ProjectBudgetReport({
    required this.projectId,
    required this.projectNumber,
    required this.projectName,
    required this.customerName,
    required this.status,
    required this.budgetMaterialsPaise,
    required this.budgetLaborPaise,
    required this.totalBudgetPaise,
    required this.actualMaterialsPaise,
    required this.actualExpensesPaise,
    required this.totalActualCostPaise,
    required this.wipBalancePaise,
    required this.invoicedPaise,
    required this.estimatedGrossProfitPaise,
    required this.marginPercentage,
  });

  final String projectId;
  final String projectNumber;
  final String projectName;
  final String customerName;
  final ProjectStatus status;
  final Money budgetMaterialsPaise;
  final Money budgetLaborPaise;
  final Money totalBudgetPaise;
  final Money actualMaterialsPaise;
  final Money actualExpensesPaise;
  final Money totalActualCostPaise;
  final Money wipBalancePaise;
  final Money invoicedPaise;
  final Money estimatedGrossProfitPaise;
  final double marginPercentage;
}
