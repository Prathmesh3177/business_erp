import 'dart:io';

import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/auth_controller.dart';
import '../../app/bootstrap.dart';
import '../common/erp_shell.dart';
import 'projects_page.dart' show projectsListProvider;

final _projectDetailProvider = FutureProvider.autoDispose
    .family<_ProjectDetailData, String>((ref, id) async {
      final runtime = await ref.watch(runtimeProvider.future);
      final db = runtime.database;
      final project = await db.getProject(id);
      if (project == null) throw StateError('Project no longer exists.');
      final quotationLines = await db.getQuotationLines(
        project.acceptedQuotationId,
      );
      final issues = await db.getMaterialIssues(id);
      final expenses = (await db.listExpenseEntries(project.organizationId))
          .where((entry) => entry.referenceNumber == 'project:$id')
          .toList();
      final documents = await db.getAttachmentsForEntity('solar_project', id);
      return _ProjectDetailData(
        project: project,
        quotationLines: quotationLines,
        issues: issues,
        expenses: expenses,
        documents: documents,
      );
    });

final class ProjectDetailPage extends ConsumerWidget {
  const ProjectDetailPage({super.key, required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(_projectDetailProvider(projectId));
    return ErpFeatureScaffold(
      appBar: AppBar(title: const Text('Project workspace')),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Unable to load project: $error')),
        data: (data) => _ProjectDetailTabs(data: data),
      ),
    );
  }
}

final class _ProjectDetailData {
  const _ProjectDetailData({
    required this.project,
    required this.quotationLines,
    required this.issues,
    required this.expenses,
    required this.documents,
  });

  final SolarProject project;
  final List<QuotationLine> quotationLines;
  final List<ProjectMaterialIssue> issues;
  final List<ExpenseEntry> expenses;
  final List<Attachment> documents;
}

final class _ProjectDetailTabs extends ConsumerWidget {
  const _ProjectDetailTabs({required this.data});

  final _ProjectDetailData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = data.project;
    return DefaultTabController(
      length: 6,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${p.projectNumber} · ${p.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text('${p.customerName} · ${p.siteAddress}'),
                  const SizedBox(height: 10),
                  const TabBar(
                    isScrollable: true,
                    tabs: [
                      Tab(text: 'Overview'),
                      Tab(text: 'BOM & stock'),
                      Tab(text: 'Expenses'),
                      Tab(text: 'Documents'),
                      Tab(text: 'Timeline'),
                      Tab(text: 'Subsidy'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _OverviewTab(data: data),
                _BomStockTab(data: data),
                _ExpensesTab(data: data),
                _DocumentsTab(data: data),
                _TimelineTab(data: data),
                _SubsidyTab(data: data),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.data});
  final _ProjectDetailData data;

  @override
  Widget build(BuildContext context) {
    final p = data.project;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Chip(label: Text(p.status.name.toUpperCase())),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _metric('Materials budget', p.budgetMaterialsPaise),
            _metric('Labour budget', p.budgetLaborPaise),
            _metric('Materials issued', p.actualMaterialsPaise),
            _metric('Site expenses', p.actualExpensesPaise),
            _metric('WIP balance', p.wipBalancePaise),
            _metric('Invoiced', p.invoicedPaise),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Accepted quotation revision ${p.acceptedQuotationRevision}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Text('Created ${_date(p.createdAtUtc)}'),
      ],
    );
  }

  Widget _metric(String label, Money value) => SizedBox(
    width: 180,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label),
            const SizedBox(height: 6),
            Text(
              _money(value),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BomStockTab extends ConsumerWidget {
  const _BomStockTab({required this.data});
  final _ProjectDetailData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialLines = data.quotationLines
        .where((line) => !line.isServiceLine)
        .toList();
    if (materialLines.isEmpty) {
      return const Center(
        child: Text('No material BOM was saved with the accepted quotation.'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: materialLines.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        final line = materialLines[index];
        return FutureBuilder<List<StockBalance>>(
          future: ref
              .read(runtimeProvider.future)
              .then(
                (runtime) => runtime.database.getStockBalancesForProduct(
                  data.project.organizationId,
                  line.productId,
                ),
              ),
          builder: (context, snapshot) {
            final balances = snapshot.data ?? const <StockBalance>[];
            final available = balances.fold<double>(
              0,
              (sum, item) => sum + item.quantityMicroUnits / 1000000,
            );
            final issued = data.issues
                .expand((issue) => issue.lines)
                .where((issuedLine) => issuedLine.productId == line.productId)
                .fold<double>(
                  0,
                  (sum, issuedLine) => sum + issuedLine.quantity.inUnits,
                );
            final shortfall = available < line.quantity.inUnits;
            return ListTile(
              leading: Icon(
                shortfall
                    ? Icons.warning_amber_rounded
                    : Icons.inventory_2_outlined,
                color: shortfall ? Colors.orange : null,
              ),
              title: Text(line.productName),
              subtitle: Text(
                'Planned ${line.quantity.inUnits} · Issued $issued · Available ${available.toStringAsFixed(2)}',
              ),
              trailing: Text(
                shortfall ? 'SHORT' : 'READY',
                style: TextStyle(
                  color: shortfall
                      ? Colors.orange.shade800
                      : Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ExpensesTab extends ConsumerWidget {
  const _ExpensesTab({required this.data});
  final _ProjectDetailData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = data.expenses.fold(
      Money.zero,
      (sum, expense) => sum + expense.amountPaise,
    );
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _recordExpense(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Record expense'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('Recorded project expenses'),
              trailing: Text(
                _money(total),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (data.expenses.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No project expenses recorded.')),
            )
          else
            ...data.expenses.map(
              (expense) => ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: Text(expense.categoryName),
                subtitle: Text(
                  '${_date(expense.expenseDate)}${expense.notes == null || expense.notes!.isEmpty ? '' : ' · ${expense.notes}'}',
                ),
                trailing: Text(_money(expense.amountPaise)),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _recordExpense(BuildContext context, WidgetRef ref) async {
    final runtime = await ref.read(runtimeProvider.future);
    final categories = await runtime.database.getExpenseCategories(
      data.project.organizationId,
    );
    if (!context.mounted) return;
    final amount = TextEditingController();
    final notes = TextEditingController();
    ExpenseCategory? category = categories.isEmpty ? null : categories.first;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Record project expense'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<ExpenseCategory>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
                  onChanged: (item) => setState(() => category = item),
                ),
                TextField(
                  controller: amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Amount (₹)'),
                ),
                TextField(
                  controller: notes,
                  decoration: const InputDecoration(
                    labelText: 'Note / supplier reference',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: category == null
                  ? null
                  : () async {
                      final rupees = double.tryParse(amount.text);
                      if (rupees == null || rupees <= 0) return;
                      try {
                        final contextData = CommandContext(
                          session: _effectiveSession(ref),
                          timestampUtc: DateTime.now(),
                        );
                        await PostExpenseUseCase(
                          financeStore: runtime.database,
                          accountingStore: runtime.database,
                        ).execute(
                          contextData,
                          organizationId: data.project.organizationId,
                          branchId: data.project.branchId,
                          categoryId: category!.id,
                          categoryName: category!.name,
                          accountCode: category!.accountCode,
                          amountPaise: Money.fromRupees(rupees),
                          expenseDate: DateTime.now(),
                          paymentMethod: 'cash',
                          referenceNumber: 'project:${data.project.id}',
                          notes: notes.text.trim().isEmpty
                              ? null
                              : notes.text.trim(),
                        );
                        final increment = Money.fromRupees(rupees);
                        await runtime.database.saveProject(
                          _withExpenses(data.project, increment),
                        );
                        ref.invalidate(_projectDetailProvider(data.project.id));
                        ref.invalidate(projectsListProvider);
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                      } catch (error) {
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text('Unable to record expense: $error'),
                            ),
                          );
                        }
                      }
                    },
              child: const Text('Post expense'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentsTab extends ConsumerWidget {
  const _DocumentsTab({required this.data});
  final _ProjectDetailData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _linkDocument(context, ref),
      icon: const Icon(Icons.attach_file),
      label: const Text('Link document'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Accepted quotation'),
            subtitle: Text(
              'Revision ${data.project.acceptedQuotationRevision} · ${data.project.acceptedQuotationId}',
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (data.documents.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No site documents linked. Add a PDF or image file path.',
              ),
            ),
          )
        else
          ...data.documents.map(
            (document) => ListTile(
              leading: Icon(
                document.mimeType == 'application/pdf'
                    ? Icons.picture_as_pdf_outlined
                    : Icons.image_outlined,
              ),
              title: Text(document.fileName),
              subtitle: Text(document.storagePath),
              trailing: Text(_date(document.createdAt)),
            ),
          ),
      ],
    ),
  );

  Future<void> _linkDocument(BuildContext context, WidgetRef ref) async {
    final path = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Link project document'),
        content: TextField(
          controller: path,
          decoration: const InputDecoration(
            labelText: 'Local PDF/image file path',
            hintText: '/path/to/site-photo.jpg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = path.text.trim();
              final file = File(value);
              if (value.isEmpty || !file.existsSync()) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Enter an existing local file path.'),
                  ),
                );
                return;
              }
              final length = await file.length();
              if (length <= 0 || length > Attachment.maxSizeBytes) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Documents must be between 1 byte and 10 MB.',
                      ),
                    ),
                  );
                }
                return;
              }
              final extension = value.toLowerCase().split('.').last;
              final mime = switch (extension) {
                'pdf' => 'application/pdf',
                'png' => 'image/png',
                'webp' => 'image/webp',
                _ => 'image/jpeg',
              };
              final now = DateTime.now();
              final runtime = await ref.read(runtimeProvider.future);
              final id = 'project_doc_${now.microsecondsSinceEpoch}';
              try {
                await runtime.database.saveAttachment(
                  Attachment(
                    id: id,
                    organizationId: data.project.organizationId,
                    fileName: value.split('/').last,
                    mimeType: mime,
                    fileSizeBytes: length,
                    sha256Hash: '$value-$length',
                    storagePath: value,
                    createdAt: now,
                  ),
                );
                await runtime.database.linkAttachment(
                  AttachmentLink(
                    id: '${id}_link',
                    attachmentId: id,
                    entityType: 'solar_project',
                    entityId: data.project.id,
                    createdAt: now,
                  ),
                );
                ref.invalidate(_projectDetailProvider(data.project.id));
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              } catch (error) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('Unable to link document: $error')),
                  );
                }
              }
            },
            child: const Text('Link document'),
          ),
        ],
      ),
    );
  }
}

class _TimelineTab extends StatelessWidget {
  const _TimelineTab({required this.data});
  final _ProjectDetailData data;

  @override
  Widget build(BuildContext context) {
    final events = <_TimelineEvent>[
      _TimelineEvent(
        data.project.createdAtUtc,
        'Project created',
        data.project.projectNumber,
      ),
      ...data.issues.map(
        (issue) => _TimelineEvent(
          issue.issueDate,
          'Materials issued',
          '${issue.lines.length} line(s) · ${_money(issue.totalCostPaise)}',
        ),
      ),
      ...data.expenses.map(
        (expense) => _TimelineEvent(
          expense.expenseDate,
          'Expense posted',
          '${expense.categoryName} · ${_money(expense.amountPaise)}',
        ),
      ),
      ...data.documents.map(
        (document) => _TimelineEvent(
          document.createdAt,
          'Document linked',
          document.fileName,
        ),
      ),
    ]..sort((a, b) => b.when.compareTo(a.when));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (_, index) {
        final event = events[index];
        return ListTile(
          leading: const Icon(Icons.timeline),
          title: Text(event.title),
          subtitle: Text('${_date(event.when)} · ${event.detail}'),
        );
      },
    );
  }
}

class _SubsidyTab extends StatefulWidget {
  const _SubsidyTab({required this.data});
  final _ProjectDetailData data;
  @override
  State<_SubsidyTab> createState() => _SubsidyTabState();
}

class _SubsidyTabState extends State<_SubsidyTab> {
  late final TextEditingController _capacity = TextEditingController(text: '3');
  late SubsidyScheme _scheme = SubsidyScheme.pmSuryaGhar;

  @override
  void dispose() {
    _capacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectCost =
        widget.data.project.budgetMaterialsPaise +
        widget.data.project.budgetLaborPaise;
    final result = calculateSubsidy(
      scheme: _scheme,
      capacityKw: double.tryParse(_capacity.text) ?? 0,
      projectCost: projectCost,
    );
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<SubsidyScheme>(
          initialValue: _scheme,
          decoration: const InputDecoration(labelText: 'Scheme'),
          items:
              [
                    SubsidyScheme.pmSuryaGhar,
                    SubsidyScheme.pmKusumSmallFarmer,
                    SubsidyScheme.pmKusumOtherFarmer,
                  ]
                  .map(
                    (item) =>
                        DropdownMenuItem(value: item, child: Text(item.name)),
                  )
                  .toList(),
          onChanged: (item) => setState(() => _scheme = item!),
        ),
        TextField(
          controller: _capacity,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(labelText: 'System capacity (kW)'),
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _scheme.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text('Project cost basis: ${_money(projectCost)}'),
                const Divider(),
                Text(
                  'Eligible subsidy: ${_money(result.subsidy)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Customer payable: ${_money(result.customerPayable)}'),
                const SizedBox(height: 8),
                Text(
                  'Category: ${_scheme.category.name} · State: ${_scheme.state}',
                ),
                Text('Effective from ${_date(_scheme.effectiveFrom)}'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final class _TimelineEvent {
  const _TimelineEvent(this.when, this.title, this.detail);
  final DateTime when;
  final String title;
  final String detail;
}

SolarProject _withExpenses(SolarProject p, Money amount) => SolarProject(
  id: p.id,
  organizationId: p.organizationId,
  branchId: p.branchId,
  projectNumber: p.projectNumber,
  name: p.name,
  customerPartyId: p.customerPartyId,
  customerName: p.customerName,
  siteAddress: p.siteAddress,
  acceptedQuotationId: p.acceptedQuotationId,
  acceptedQuotationRevision: p.acceptedQuotationRevision,
  status: p.status,
  budgetMaterialsPaise: p.budgetMaterialsPaise,
  budgetLaborPaise: p.budgetLaborPaise,
  actualMaterialsPaise: p.actualMaterialsPaise,
  actualExpensesPaise: p.actualExpensesPaise + amount,
  invoicedPaise: p.invoicedPaise,
  wipBalancePaise: p.wipBalancePaise + amount,
  createdAtUtc: p.createdAtUtc,
);

String _money(Money value) => '₹${value.inRupees.toStringAsFixed(2)}';
String _date(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

UserSession _effectiveSession(WidgetRef ref) {
  final session = ref.read(authProvider);
  return session ??
      UserSession(
        id: const SessionId('sess_admin'),
        userId: const UserId('usr_admin'),
        username: 'admin',
        roleId: Role.adminRoleId,
        branchId: const BranchId('br_1'),
        capabilities: Capability.values.toSet(),
        token: 'tok_admin',
        expiresAtUtc: DateTime.now().add(const Duration(hours: 8)),
        lastActivityAtUtc: DateTime.now(),
      );
}
