import 'package:erp_domain/erp_domain.dart';

import 'accounting_store.dart';
import 'command_context.dart';
import 'inventory_store.dart';
import 'project_store.dart';

final class QuotationLineInput {
  const QuotationLineInput({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.hsnCode,
    required this.quantity,
    required this.unitPrice,
    required this.taxRate,
    this.lineDiscountPaise = Money.zero,
    this.isServiceLine = false,
    this.bomSnapshotJson = '{}',
  });

  final String productId;
  final String productName;
  final String sku;
  final String hsnCode;
  final Quantity quantity;
  final UnitPrice unitPrice;
  final TaxRate taxRate;
  final Money lineDiscountPaise;
  final bool isServiceLine;
  final String bomSnapshotJson;
}

final class IssueMaterialLineInput {
  const IssueMaterialLineInput({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    this.serials = const [],
  });

  final String productId;
  final String productName;
  final String sku;
  final Quantity quantity;
  final List<String> serials;
}

final class CreateQuotationUseCase {
  const CreateQuotationUseCase({
    required this.projectStore,
    required this.accountingStore,
  });

  final ProjectStore projectStore;
  final AccountingStore accountingStore;

  Future<QuotationHeader> execute(
    CommandContext context, {
    required String organizationId,
    required String branchId,
    required String customerPartyId,
    required String customerName,
    required DateTime validUntil,
    required List<QuotationLineInput> lineInputs,
    Money installationChargesPaise = Money.zero,
    String termsSnapshot = 'Standard 1-Year Workmanship & 25-Year Performance Warranty',
  }) async {
    context.requireCapability(Capability.salesCreate);

    final quotationId = 'quote_${DateTime.now().microsecondsSinceEpoch}';
    final seqNumber = await accountingStore.allocateNextDocumentNumber(
      registrationId: organizationId,
      fiscalYear: '2627',
      series: 'QTN',
    );

    Money subtotal = Money.zero;
    Money totalTax = Money.zero;
    final List<QuotationLine> lines = [];
    const taxEngine = TaxEngine();

    for (int i = 0; i < lineInputs.length; i++) {
      final input = lineInputs[i];
      final lineId = '${quotationId}_line_$i';

      final taxable = Money.fromRupees(input.unitPrice.inRupees * input.quantity.inUnits) - input.lineDiscountPaise;
      final invoiceResult = taxEngine.calculateInvoiceTax(
        lines: [
          TaxLineRequest(
            lineId: lineId,
            quantity: input.quantity,
            unitPrice: input.unitPrice,
            taxRate: input.taxRate,
            lineDiscount: input.lineDiscountPaise,
          ),
        ],
        supplyType: TaxSupplyType.intraState,
      );

      final taxResult = invoiceResult.lineResults.first;
      subtotal += taxable;
      totalTax += taxResult.totalTax;

      lines.add(
        QuotationLine(
          id: lineId,
          quotationId: quotationId,
          productId: input.productId,
          productName: input.productName,
          sku: input.sku,
          hsnCode: input.hsnCode,
          quantity: input.quantity,
          unitPrice: input.unitPrice,
          lineDiscountPaise: input.lineDiscountPaise,
          taxSnapshot: taxResult,
          netTotalPaise: taxResult.totalAmount,
          isServiceLine: input.isServiceLine,
          bomSnapshotJson: input.bomSnapshotJson,
        ),
      );
    }

    final grandTotal = subtotal + totalTax + installationChargesPaise;

    final header = QuotationHeader(
      id: quotationId,
      organizationId: organizationId,
      branchId: branchId,
      quotationNumber: seqNumber,
      revisionNumber: 1,
      customerPartyId: customerPartyId,
      customerName: customerName,
      validUntil: validUntil,
      status: QuotationStatus.draft,
      subtotalPaise: subtotal,
      allocatedDiscountPaise: Money.zero,
      totalTaxPaise: totalTax,
      grandTotalPaise: grandTotal,
      installationChargesPaise: installationChargesPaise,
      termsSnapshot: termsSnapshot,
      createdAtUtc: context.timestampUtc,
    );

    await projectStore.saveQuotation(header: header, lines: lines);
    return header;
  }
}

final class ApproveQuotationUseCase {
  const ApproveQuotationUseCase({
    required this.projectStore,
    required this.accountingStore,
  });

  final ProjectStore projectStore;
  final AccountingStore accountingStore;

  Future<SolarProject> execute(
    CommandContext context, {
    required String quotationId,
    required String projectName,
    required String siteAddress,
  }) async {
    context.requireCapability(Capability.salesCreate);

    final quote = await projectStore.getQuotationHeader(quotationId);
    if (quote == null) {
      throw const ValidationFailure('quotation_not_found', 'Quotation record not found');
    }

    final lines = await projectStore.getQuotationLines(quotationId);

    // Update quote status to approved
    final approvedHeader = QuotationHeader(
      id: quote.id,
      organizationId: quote.organizationId,
      branchId: quote.branchId,
      quotationNumber: quote.quotationNumber,
      revisionNumber: quote.revisionNumber,
      customerPartyId: quote.customerPartyId,
      customerName: quote.customerName,
      validUntil: quote.validUntil,
      status: QuotationStatus.approved,
      subtotalPaise: quote.subtotalPaise,
      allocatedDiscountPaise: quote.allocatedDiscountPaise,
      totalTaxPaise: quote.totalTaxPaise,
      grandTotalPaise: quote.grandTotalPaise,
      installationChargesPaise: quote.installationChargesPaise,
      termsSnapshot: quote.termsSnapshot,
      createdAtUtc: quote.createdAtUtc,
    );
    await projectStore.saveQuotation(header: approvedHeader, lines: lines);

    // Calculate budget snapshots
    Money budgetMaterials = Money.zero;
    Money budgetLabor = quote.installationChargesPaise;

    for (final l in lines) {
      if (l.isServiceLine) {
        budgetLabor += l.netTotalPaise;
      } else {
        budgetMaterials += l.netTotalPaise;
      }
    }

    final projectId = 'proj_${DateTime.now().microsecondsSinceEpoch}';
    final projectNumber = await accountingStore.allocateNextDocumentNumber(
      registrationId: quote.organizationId,
      fiscalYear: '2627',
      series: 'PRJ',
    );

    final project = SolarProject(
      id: projectId,
      organizationId: quote.organizationId,
      branchId: quote.branchId,
      projectNumber: projectNumber,
      name: projectName,
      customerPartyId: quote.customerPartyId,
      customerName: quote.customerName,
      siteAddress: siteAddress,
      acceptedQuotationId: quote.id,
      acceptedQuotationRevision: quote.revisionNumber,
      status: ProjectStatus.planning,
      budgetMaterialsPaise: budgetMaterials,
      budgetLaborPaise: budgetLabor,
      actualMaterialsPaise: Money.zero,
      actualExpensesPaise: Money.zero,
      invoicedPaise: Money.zero,
      wipBalancePaise: Money.zero,
      createdAtUtc: context.timestampUtc,
    );

    await projectStore.saveProject(project);
    return project;
  }
}

final class IssueProjectMaterialsUseCase {
  const IssueProjectMaterialsUseCase({
    required this.projectStore,
    required this.inventoryStore,
    required this.accountingStore,
  });

  final ProjectStore projectStore;
  final InventoryStore inventoryStore;
  final AccountingStore accountingStore;

  Future<ProjectMaterialIssue> execute(
    CommandContext context, {
    required String projectId,
    required String locationId,
    required DateTime issueDate,
    required List<IssueMaterialLineInput> lineInputs,
    String notes = '',
  }) async {
    context.requireCapability(Capability.inventoryManage);

    final project = await projectStore.getProject(projectId);
    if (project == null) {
      throw const ValidationFailure('project_not_found', 'Solar project not found');
    }

    final issueId = 'mat_iss_${DateTime.now().microsecondsSinceEpoch}';
    Money totalIssueCost = Money.zero;
    final List<ProjectMaterialIssueLine> lines = [];

    for (int i = 0; i < lineInputs.length; i++) {
      final input = lineInputs[i];
      final balance = await inventoryStore.getStockBalance(input.productId, locationId);
      final currentMicro = balance?.quantityMicroUnits ?? 0;
      final requiredMicro = input.quantity.microUnits;

      if (currentMicro < requiredMicro) {
        throw ValidationFailure(
          'insufficient_stock',
          'Insufficient stock for product ${input.productName}. Required: ${input.quantity.inUnits}, Available: ${currentMicro / 1000000.0}',
        );
      }

      // Calculate unit cost from perpetual weighted average
      final unitCostMicroRupees = balance != null && balance.quantityMicroUnits > 0
          ? ((balance.valuePaise * 10000) / (balance.quantityMicroUnits / 1000000.0)).round()
          : 0;

      final issueLine = ProjectMaterialIssueLine(
        id: '${issueId}_line_$i',
        issueId: issueId,
        productId: input.productId,
        productName: input.productName,
        sku: input.sku,
        quantity: input.quantity,
        costSnapshotMicroRupees: unitCostMicroRupees,
        serials: input.serials,
      );

      lines.add(issueLine);
      totalIssueCost += issueLine.totalCostPaise;

      // Update inventory balance (reduce stock on hand)
      final newValuePaise = (balance!.valuePaise - issueLine.totalCostPaise.paise).clamp(0, 999999999999);
      await inventoryStore.saveStockBalance(
        StockBalance(
          productId: input.productId,
          locationId: locationId,
          quantityMicroUnits: currentMicro - requiredMicro,
          valuePaise: newValuePaise,
          updatedAt: context.timestampUtc,
        ),
      );

      // Record stock movement (negative issue)
      await inventoryStore.saveStockMovement(
        StockMovement(
          id: '${issueId}_mov_$i',
          organizationId: project.organizationId,
          branchId: project.branchId,
          documentId: issueId,
          lineId: issueLine.id,
          productId: input.productId,
          locationId: locationId,
          movementKind: MovementKind.adjustmentOut,
          quantityMicroUnits: -requiredMicro,
          valueDeltaPaise: -issueLine.totalCostPaise.paise,
          costSnapshotMicroRupees: unitCostMicroRupees,
          createdAt: context.timestampUtc,

        ),
      );
    }

    final issue = ProjectMaterialIssue(
      id: issueId,
      organizationId: project.organizationId,
      branchId: project.branchId,
      projectId: projectId,
      locationId: locationId,
      issueDate: issueDate,
      lines: lines,
      totalCostPaise: totalIssueCost,
      createdAtUtc: context.timestampUtc,
      notes: notes,
    );

    await projectStore.saveMaterialIssue(issue: issue);

    // Save atomic WIP Journal: 1400 Work in Progress Dr, 1200 Inventory Cr
    final docHeaderId = 'doc_${DateTime.now().microsecondsSinceEpoch}';
    final docNumber = await accountingStore.allocateNextDocumentNumber(
      registrationId: project.organizationId,
      fiscalYear: '2627',
      series: 'WIP',
    );

    final docHeader = DocumentHeader(
      id: docHeaderId,
      organizationId: project.organizationId,
      branchId: project.branchId,
      kind: DocumentKind.journal,
      status: DocumentStatus.posted,
      businessDate: issueDate,
      documentNumber: docNumber,
      fiscalYear: '2627',
      sourceCommandId: 'cmd_$issueId',
      createdAt: context.timestampUtc,
    );
    await accountingStore.saveDocumentHeader(docHeader);

    final wipAccount = await accountingStore.getAccountByCode(project.organizationId, Account.codeWip);
    final invAccount = await accountingStore.getAccountByCode(project.organizationId, Account.codeInventory);

    final journalId = 'jnl_${DateTime.now().microsecondsSinceEpoch}';
    final journal = JournalEntry(
      id: journalId,
      organizationId: project.organizationId,
      branchId: project.branchId,
      documentId: docHeaderId,
      postingDate: issueDate,
      memo: 'Project Material Issue to WIP for ${project.name}',
      createdAt: context.timestampUtc,
      lines: [
        JournalLine(
          id: '${journalId}_1',
          journalEntryId: journalId,
          accountId: wipAccount?.id ?? 'acc_wip',
          debitPaise: totalIssueCost.paise,
          projectId: projectId,
        ),
        JournalLine(
          id: '${journalId}_2',
          journalEntryId: journalId,
          accountId: invAccount?.id ?? 'acc_inv',
          creditPaise: totalIssueCost.paise,
        ),
      ],
    );
    await accountingStore.saveJournalEntry(journal);

    // Update project actual materials & WIP balance
    final updatedProject = SolarProject(
      id: project.id,
      organizationId: project.organizationId,
      branchId: project.branchId,
      projectNumber: project.projectNumber,
      name: project.name,
      customerPartyId: project.customerPartyId,
      customerName: project.customerName,
      siteAddress: project.siteAddress,
      acceptedQuotationId: project.acceptedQuotationId,
      acceptedQuotationRevision: project.acceptedQuotationRevision,
      status: ProjectStatus.inProgress,
      budgetMaterialsPaise: project.budgetMaterialsPaise,
      budgetLaborPaise: project.budgetLaborPaise,
      actualMaterialsPaise: project.actualMaterialsPaise + totalIssueCost,
      actualExpensesPaise: project.actualExpensesPaise,
      invoicedPaise: project.invoicedPaise,
      wipBalancePaise: project.wipBalancePaise + totalIssueCost,
      createdAtUtc: project.createdAtUtc,
    );
    await projectStore.saveProject(updatedProject);

    return issue;
  }
}

final class ReturnProjectMaterialsUseCase {
  const ReturnProjectMaterialsUseCase({
    required this.projectStore,
    required this.inventoryStore,
    required this.accountingStore,
  });

  final ProjectStore projectStore;
  final InventoryStore inventoryStore;
  final AccountingStore accountingStore;

  Future<void> execute(
    CommandContext context, {
    required String projectId,
    required String locationId,
    required String productId,
    required Quantity quantity,
    required Money unitCostPaise,
  }) async {
    context.requireCapability(Capability.inventoryManage);

    final project = await projectStore.getProject(projectId);
    if (project == null) {
      throw const ValidationFailure('project_not_found', 'Solar project not found');
    }

    final returnCost = Money.fromRupees(unitCostPaise.inRupees * quantity.inUnits);

    // Restore inventory balance
    final balance = await inventoryStore.getStockBalance(productId, locationId);
    final currentMicro = balance?.quantityMicroUnits ?? 0;
    final currentVal = balance?.valuePaise ?? 0;

    await inventoryStore.saveStockBalance(
      StockBalance(
        productId: productId,
        locationId: locationId,
        quantityMicroUnits: currentMicro + quantity.microUnits,
        valuePaise: currentVal + returnCost.paise,
        updatedAt: context.timestampUtc,
      ),
    );

    // Save Journal: 1200 Inventory Dr, 1400 Work in Progress Cr
    final docHeaderId = 'doc_${DateTime.now().microsecondsSinceEpoch}';
    final docNumber = await accountingStore.allocateNextDocumentNumber(
      registrationId: project.organizationId,
      fiscalYear: '2627',
      series: 'WIP-RET',
    );

    final docHeader = DocumentHeader(
      id: docHeaderId,
      organizationId: project.organizationId,
      branchId: project.branchId,
      kind: DocumentKind.journal,
      status: DocumentStatus.posted,
      businessDate: context.timestampUtc,
      documentNumber: docNumber,
      fiscalYear: '2627',
      sourceCommandId: 'cmd_$docHeaderId',
      createdAt: context.timestampUtc,
    );
    await accountingStore.saveDocumentHeader(docHeader);

    final wipAccount = await accountingStore.getAccountByCode(project.organizationId, Account.codeWip);
    final invAccount = await accountingStore.getAccountByCode(project.organizationId, Account.codeInventory);

    final journalId = 'jnl_${DateTime.now().microsecondsSinceEpoch}';
    final journal = JournalEntry(
      id: journalId,
      organizationId: project.organizationId,
      branchId: project.branchId,
      documentId: docHeaderId,
      postingDate: context.timestampUtc,
      memo: 'Unused Material Return from Project WIP for ${project.name}',
      createdAt: context.timestampUtc,
      lines: [
        JournalLine(
          id: '${journalId}_1',
          journalEntryId: journalId,
          accountId: invAccount?.id ?? 'acc_inv',
          debitPaise: returnCost.paise,
        ),
        JournalLine(
          id: '${journalId}_2',
          journalEntryId: journalId,
          accountId: wipAccount?.id ?? 'acc_wip',
          creditPaise: returnCost.paise,
          projectId: projectId,
        ),
      ],
    );
    await accountingStore.saveJournalEntry(journal);

    // Reduce project WIP balance
    final newWipPaise = (project.wipBalancePaise - returnCost).paise.clamp(0, 999999999999);
    final newActualPaise = (project.actualMaterialsPaise - returnCost).paise.clamp(0, 999999999999);

    final updatedProject = SolarProject(
      id: project.id,
      organizationId: project.organizationId,
      branchId: project.branchId,
      projectNumber: project.projectNumber,
      name: project.name,
      customerPartyId: project.customerPartyId,
      customerName: project.customerName,
      siteAddress: project.siteAddress,
      acceptedQuotationId: project.acceptedQuotationId,
      acceptedQuotationRevision: project.acceptedQuotationRevision,
      status: project.status,
      budgetMaterialsPaise: project.budgetMaterialsPaise,
      budgetLaborPaise: project.budgetLaborPaise,
      actualMaterialsPaise: Money.fromPaise(newActualPaise),
      actualExpensesPaise: project.actualExpensesPaise,
      invoicedPaise: project.invoicedPaise,
      wipBalancePaise: Money.fromPaise(newWipPaise),
      createdAtUtc: project.createdAtUtc,
    );
    await projectStore.saveProject(updatedProject);
  }
}

final class PostProjectInvoiceUseCase {
  const PostProjectInvoiceUseCase({
    required this.projectStore,
    required this.accountingStore,
  });

  final ProjectStore projectStore;
  final AccountingStore accountingStore;

  Future<void> execute(
    CommandContext context, {
    required String projectId,
    required Money invoiceAmountPaise,
    required DateTime invoiceDate,
  }) async {
    context.requireCapability(Capability.salesCreate);

    final project = await projectStore.getProject(projectId);
    if (project == null) {
      throw const ValidationFailure('project_not_found', 'Solar project not found');
    }

    final docHeaderId = 'doc_${DateTime.now().microsecondsSinceEpoch}';
    final docNumber = await accountingStore.allocateNextDocumentNumber(
      registrationId: project.organizationId,
      fiscalYear: '2627',
      series: 'INV',
    );

    final docHeader = DocumentHeader(
      id: docHeaderId,
      organizationId: project.organizationId,
      branchId: project.branchId,
      kind: DocumentKind.saleInvoice,
      status: DocumentStatus.posted,
      businessDate: invoiceDate,
      documentNumber: docNumber,
      fiscalYear: '2627',
      sourceCommandId: 'cmd_$docHeaderId',
      createdAt: context.timestampUtc,
    );
    await accountingStore.saveDocumentHeader(docHeader);

    final arAccount = await accountingStore.getAccountByCode(project.organizationId, Account.codeReceivable);
    final salesAccount = await accountingStore.getAccountByCode(project.organizationId, Account.codeSalesRevenue);
    final cogsAccount = await accountingStore.getAccountByCode(project.organizationId, Account.codeCogs);
    final wipAccount = await accountingStore.getAccountByCode(project.organizationId, Account.codeWip);

    // Revenue Journal: 1100 AR Dr, 4010 Revenue Cr
    final revJournalId = 'jnl_rev_${DateTime.now().microsecondsSinceEpoch}';
    final revJournal = JournalEntry(
      id: revJournalId,
      organizationId: project.organizationId,
      branchId: project.branchId,
      documentId: docHeaderId,
      postingDate: invoiceDate,
      memo: 'Project Invoicing Revenue for ${project.name}',
      createdAt: context.timestampUtc,
      lines: [
        JournalLine(
          id: '${revJournalId}_1',
          journalEntryId: revJournalId,
          accountId: arAccount?.id ?? 'acc_ar',
          debitPaise: invoiceAmountPaise.paise,
          partyId: project.customerPartyId,
          projectId: projectId,
        ),
        JournalLine(
          id: '${revJournalId}_2',
          journalEntryId: revJournalId,
          accountId: salesAccount?.id ?? 'acc_sales',
          creditPaise: invoiceAmountPaise.paise,
        ),
      ],
    );
    await accountingStore.saveJournalEntry(revJournal);

    // WIP Transfer to COGS Journal (if WIP balance > 0)
    if (project.wipBalancePaise.paise > 0) {
      final cogsJournalId = 'jnl_cogs_${DateTime.now().microsecondsSinceEpoch}';
      final cogsJournal = JournalEntry(
        id: cogsJournalId,
        organizationId: project.organizationId,
        branchId: project.branchId,
        documentId: docHeaderId,
        postingDate: invoiceDate,
        memo: 'Project WIP Transfer to COGS for ${project.name}',
        createdAt: context.timestampUtc,
        lines: [
          JournalLine(
            id: '${cogsJournalId}_1',
            journalEntryId: cogsJournalId,
            accountId: cogsAccount?.id ?? 'acc_cogs',
            debitPaise: project.wipBalancePaise.paise,
            projectId: projectId,
          ),
          JournalLine(
            id: '${cogsJournalId}_2',
            journalEntryId: cogsJournalId,
            accountId: wipAccount?.id ?? 'acc_wip',
            creditPaise: project.wipBalancePaise.paise,
            projectId: projectId,
          ),
        ],
      );
      await accountingStore.saveJournalEntry(cogsJournal);
    }

    // Mark project completed and set WIP balance to 0
    final updatedProject = SolarProject(
      id: project.id,
      organizationId: project.organizationId,
      branchId: project.branchId,
      projectNumber: project.projectNumber,
      name: project.name,
      customerPartyId: project.customerPartyId,
      customerName: project.customerName,
      siteAddress: project.siteAddress,
      acceptedQuotationId: project.acceptedQuotationId,
      acceptedQuotationRevision: project.acceptedQuotationRevision,
      status: ProjectStatus.completed,
      budgetMaterialsPaise: project.budgetMaterialsPaise,
      budgetLaborPaise: project.budgetLaborPaise,
      actualMaterialsPaise: project.actualMaterialsPaise,
      actualExpensesPaise: project.actualExpensesPaise,
      invoicedPaise: project.invoicedPaise + invoiceAmountPaise,
      wipBalancePaise: Money.zero,
      createdAtUtc: project.createdAtUtc,
    );
    await projectStore.saveProject(updatedProject);
  }
}

final class GenerateProjectBudgetReportUseCase {
  const GenerateProjectBudgetReportUseCase({
    required this.projectStore,
  });

  final ProjectStore projectStore;

  Future<ProjectBudgetReport> execute(
    CommandContext context, {
    required String projectId,
  }) async {
    context.requireCapability(Capability.salesRead);

    final project = await projectStore.getProject(projectId);
    if (project == null) {
      throw const ValidationFailure('project_not_found', 'Solar project not found');
    }

    final totalBudget = project.budgetMaterialsPaise + project.budgetLaborPaise;
    final totalActualCost = project.actualMaterialsPaise + project.actualExpensesPaise;

    Money estProfit;
    double margin = 0.0;

    if (project.invoicedPaise.paise > 0) {
      estProfit = project.invoicedPaise - totalActualCost;
      margin = (estProfit.inRupees / project.invoicedPaise.inRupees) * 100.0;
    } else if (totalBudget.paise > 0) {
      estProfit = totalBudget - totalActualCost;
      margin = (estProfit.inRupees / totalBudget.inRupees) * 100.0;
    } else {
      estProfit = Money.zero;
    }

    return ProjectBudgetReport(
      projectId: project.id,
      projectNumber: project.projectNumber,
      projectName: project.name,
      customerName: project.customerName,
      status: project.status,
      budgetMaterialsPaise: project.budgetMaterialsPaise,
      budgetLaborPaise: project.budgetLaborPaise,
      totalBudgetPaise: totalBudget,
      actualMaterialsPaise: project.actualMaterialsPaise,
      actualExpensesPaise: project.actualExpensesPaise,
      totalActualCostPaise: totalActualCost,
      wipBalancePaise: project.wipBalancePaise,
      invoicedPaise: project.invoicedPaise,
      estimatedGrossProfitPaise: estProfit,
      marginPercentage: margin,
    );
  }
}
