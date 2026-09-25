import 'package:erp_domain/erp_domain.dart';

import 'command_context.dart';
import 'inventory_store.dart';
import 'service_store.dart';

final class CreateServiceJobUseCase {
  const CreateServiceJobUseCase({
    required this.serviceStore,
  });

  final ServiceStore serviceStore;

  Future<ServiceJob> execute(
    CommandContext context, {
    required String organizationId,
    required String branchId,
    required String customerPartyId,
    required String customerName,
    required String siteAddress,
    required String equipmentSerialId,
    required String issueDescription,
    bool isCoveredByWarranty = false,
    bool isCoveredByAmc = false,
  }) async {
    final ticketNumber = 'JOB-${DateTime.now().microsecondsSinceEpoch.toString().substring(7)}';
    final job = ServiceJob(
      id: 'job_${DateTime.now().microsecondsSinceEpoch}',
      organizationId: organizationId,
      branchId: branchId,
      jobTicketNumber: ticketNumber,
      customerPartyId: customerPartyId,
      customerName: customerName,
      siteAddress: siteAddress,
      equipmentSerialId: equipmentSerialId,
      issueDescription: issueDescription,
      isCoveredByWarranty: isCoveredByWarranty,
      isCoveredByAmc: isCoveredByAmc,
      status: ServiceJobStatus.logged,
      createdAtUtc: context.timestampUtc,
    );

    await serviceStore.saveServiceJob(job: job);
    return job;
  }
}

final class AssignTechnicianUseCase {
  const AssignTechnicianUseCase({
    required this.serviceStore,
  });

  final ServiceStore serviceStore;

  Future<ServiceJob> execute(
    CommandContext context, {
    required String jobId,
    required String technicianUserId,
    required String technicianName,
  }) async {
    final existing = await serviceStore.getServiceJob(jobId);
    if (existing == null) {
      throw const ValidationFailure('job_not_found', 'Service job ticket not found');
    }

    final updated = ServiceJob(
      id: existing.id,
      organizationId: existing.organizationId,
      branchId: existing.branchId,
      jobTicketNumber: existing.jobTicketNumber,
      customerPartyId: existing.customerPartyId,
      customerName: existing.customerName,
      siteAddress: existing.siteAddress,
      equipmentSerialId: existing.equipmentSerialId,
      issueDescription: existing.issueDescription,
      assignedTechnicianUserId: technicianUserId,
      assignedTechnicianName: technicianName,
      isCoveredByWarranty: existing.isCoveredByWarranty,
      isCoveredByAmc: existing.isCoveredByAmc,
      status: ServiceJobStatus.assigned,
      createdAtUtc: existing.createdAtUtc,
    );

    final existingVisits = await serviceStore.getServiceJobVisits(jobId);
    await serviceStore.saveServiceJob(job: updated, visits: existingVisits);
    return updated;
  }
}

final class RecordServiceVisitUseCase {
  const RecordServiceVisitUseCase({
    required this.serviceStore,
    required this.inventoryStore,
  });

  final ServiceStore serviceStore;
  final InventoryStore inventoryStore;

  Future<ServiceJobVisit> execute(
    CommandContext context, {
    required String jobId,
    required String technicianUserId,
    required String technicianName,
    required DateTime visitDate,
    required String workPerformed,
    required Money travelExpensesPaise,
    required Money laborCostPaise,
    required Money billableAmountPaise,
    List<ServiceJobSpareItem> sparesUsed = const [],
    String? storageLocationId,
    bool isJobResolved = false,
  }) async {
    final job = await serviceStore.getServiceJob(jobId);
    if (job == null) {
      throw const ValidationFailure('job_not_found', 'Service job ticket not found');
    }

    // Process spares stock deduction if spares were consumed
    if (sparesUsed.isNotEmpty && storageLocationId != null) {
      for (final spare in sparesUsed) {
        final balance = await inventoryStore.getStockBalance(spare.productId, storageLocationId);
        final currentMicro = balance?.quantityMicroUnits ?? 0;
        final requiredMicro = spare.quantity.microUnits;
        if (currentMicro < requiredMicro) {
          throw ValidationFailure(
            'insufficient_spare_stock',
            'Insufficient stock for spare part ${spare.productName}',
          );
        }

        final newMicro = currentMicro - requiredMicro;
        final newVal = (balance?.valuePaise ?? 0) - spare.totalCostPaise.paise;
        await inventoryStore.saveStockBalance(
          StockBalance(
            productId: spare.productId,
            locationId: storageLocationId,
            quantityMicroUnits: newMicro,
            valuePaise: newVal < 0 ? 0 : newVal,
            updatedAt: context.timestampUtc,
          ),
        );
      }
    }

    final visit = ServiceJobVisit(
      id: 'vis_${DateTime.now().microsecondsSinceEpoch}',
      jobId: jobId,
      technicianUserId: technicianUserId,
      technicianName: technicianName,
      visitDate: visitDate,
      workPerformed: workPerformed,
      travelExpensesPaise: travelExpensesPaise,
      laborCostPaise: laborCostPaise,
      billableAmountPaise: billableAmountPaise,
      sparesUsed: sparesUsed,
      isCompleted: true,
    );

    final existingVisits = await serviceStore.getServiceJobVisits(jobId);
    final updatedVisits = [...existingVisits, visit];

    final updatedJob = ServiceJob(
      id: job.id,
      organizationId: job.organizationId,
      branchId: job.branchId,
      jobTicketNumber: job.jobTicketNumber,
      customerPartyId: job.customerPartyId,
      customerName: job.customerName,
      siteAddress: job.siteAddress,
      equipmentSerialId: job.equipmentSerialId,
      issueDescription: job.issueDescription,
      assignedTechnicianUserId: technicianUserId,
      assignedTechnicianName: technicianName,
      isCoveredByWarranty: job.isCoveredByWarranty,
      isCoveredByAmc: job.isCoveredByAmc,
      status: isJobResolved ? ServiceJobStatus.resolved : ServiceJobStatus.inProgress,
      createdAtUtc: job.createdAtUtc,
    );

    await serviceStore.saveServiceJob(job: updatedJob, visits: updatedVisits);
    return visit;
  }
}

final class ReplaceSerializedComponentUseCase {
  const ReplaceSerializedComponentUseCase({
    required this.serviceStore,
    required this.inventoryStore,
  });

  final ServiceStore serviceStore;
  final InventoryStore inventoryStore;

  Future<SerialReplacement> execute(
    CommandContext context, {
    required String organizationId,
    required String productId,
    required String jobId,
    required String oldSerialNumber,
    required String newSerialNumber,
    required DateTime replacementDate,
    required String reason,
  }) async {
    final replacement = SerialReplacement(
      id: 'rep_${DateTime.now().microsecondsSinceEpoch}',
      jobId: jobId,
      oldSerialId: oldSerialNumber,
      newSerialId: newSerialNumber,
      replacementDate: replacementDate,
      reason: reason,
    );

    // Update old serial status to defective/scrapped
    final oldSerial = await inventoryStore.getSerialByNumber(organizationId, productId, oldSerialNumber);
    if (oldSerial != null) {
      await inventoryStore.saveSerialRecord(
        SerialRecord(
          id: oldSerial.id,
          organizationId: oldSerial.organizationId,
          productId: oldSerial.productId,
          serialNumber: oldSerial.serialNumber,
          state: SerialState.scrapped, // marked scrapped/defective
          locationId: oldSerial.locationId,
          batchId: oldSerial.batchId,
          updatedAt: context.timestampUtc,
        ),
      );
    }

    // Update new serial status to sold/installed
    final newSerial = await inventoryStore.getSerialByNumber(organizationId, productId, newSerialNumber);
    if (newSerial != null) {
      await inventoryStore.saveSerialRecord(
        SerialRecord(
          id: newSerial.id,
          organizationId: newSerial.organizationId,
          productId: newSerial.productId,
          serialNumber: newSerial.serialNumber,
          state: SerialState.sold, // installed at site
          locationId: newSerial.locationId,
          batchId: newSerial.batchId,
          updatedAt: context.timestampUtc,
        ),
      );
    }

    await serviceStore.saveSerialReplacement(replacement);
    return replacement;
  }
}

final class CreateAmcContractUseCase {
  const CreateAmcContractUseCase({
    required this.serviceStore,
  });

  final ServiceStore serviceStore;

  Future<AmcContract> execute(
    CommandContext context, {
    required String organizationId,
    required String branchId,
    required String customerPartyId,
    required String customerName,
    required String siteAddress,
    required DateTime startDate,
    required DateTime endDate,
    required Money contractValuePaise,
    required int visitLimitPerYear,
  }) async {
    final contractNumber = 'AMC-${DateTime.now().microsecondsSinceEpoch.toString().substring(7)}';
    final contract = AmcContract(
      id: 'amc_${DateTime.now().microsecondsSinceEpoch}',
      organizationId: organizationId,
      branchId: branchId,
      contractNumber: contractNumber,
      customerPartyId: customerPartyId,
      customerName: customerName,
      siteAddress: siteAddress,
      startDate: startDate,
      endDate: endDate,
      contractValuePaise: contractValuePaise,
      visitLimitPerYear: visitLimitPerYear,
      visitsCompleted: 0,
      status: AmcContractStatus.active,
      createdAtUtc: context.timestampUtc,
    );

    await serviceStore.saveAmcContract(contract);
    return contract;
  }
}

final class RenewAmcContractUseCase {
  const RenewAmcContractUseCase({
    required this.serviceStore,
  });

  final ServiceStore serviceStore;

  Future<AmcContract> execute(
    CommandContext context, {
    required String contractId,
    required DateTime newEndDate,
    required Money renewalValuePaise,
  }) async {
    final existing = await serviceStore.getAmcContract(contractId);
    if (existing == null) {
      throw const ValidationFailure('amc_not_found', 'AMC Contract not found');
    }

    final renewed = AmcContract(
      id: existing.id,
      organizationId: existing.organizationId,
      branchId: existing.branchId,
      contractNumber: existing.contractNumber,
      customerPartyId: existing.customerPartyId,
      customerName: existing.customerName,
      siteAddress: existing.siteAddress,
      startDate: existing.startDate,
      endDate: newEndDate,
      contractValuePaise: existing.contractValuePaise + renewalValuePaise,
      visitLimitPerYear: existing.visitLimitPerYear + 4, // Extend visit limit
      visitsCompleted: existing.visitsCompleted,
      status: AmcContractStatus.renewed,
      createdAtUtc: existing.createdAtUtc,
    );

    await serviceStore.saveAmcContract(renewed);
    return renewed;
  }
}

final class GenerateAmcRemindersUseCase {
  const GenerateAmcRemindersUseCase({
    required this.serviceStore,
  });

  final ServiceStore serviceStore;

  Future<List<AmcReminder>> execute(
    CommandContext context, {
    required String organizationId,
  }) async {
    final contracts = await serviceStore.listAmcContracts(organizationId);
    final reminders = <AmcReminder>[];
    final now = DateTime.now();

    for (final c in contracts) {
      if (c.status != AmcContractStatus.active && c.status != AmcContractStatus.renewed) {
        continue;
      }

      // Check visit limit alert
      if (c.isVisitLimitReached) {
        reminders.add(
          AmcReminder(
            contractId: c.id,
            contractNumber: c.contractNumber,
            customerName: c.customerName,
            dueOrExpiryDate: c.endDate,
            isOverdue: false,
            description: 'Visit limit reached (${c.visitsCompleted}/${c.visitLimitPerYear})',
          ),
        );
      }

      // Check contract expiry alert (within 30 days or overdue)
      final daysUntilExpiry = c.endDate.difference(now).inDays;
      if (daysUntilExpiry <= 30) {
        reminders.add(
          AmcReminder(
            contractId: c.id,
            contractNumber: c.contractNumber,
            customerName: c.customerName,
            dueOrExpiryDate: c.endDate,
            isOverdue: daysUntilExpiry < 0,
            description: daysUntilExpiry < 0
                ? 'AMC Contract Expired (${c.endDate.year}-${c.endDate.month.toString().padLeft(2, '0')}-${c.endDate.day.toString().padLeft(2, '0')})'
                : 'AMC Contract Expiring in $daysUntilExpiry days',
          ),
        );
      }
    }

    return reminders;
  }
}
