import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/auth_controller.dart';
import '../../app/bootstrap.dart';

final projectQuotationsProvider = FutureProvider.autoDispose<List<QuotationHeader>>((ref) async {
  final runtime = await ref.watch(runtimeProvider.future);
  final store = runtime.database;
  final identity = runtime.identity!;
  return store.listQuotations(identity.organization.id.value);
});

final projectsListProvider = FutureProvider.autoDispose<List<SolarProject>>((ref) async {
  final runtime = await ref.watch(runtimeProvider.future);
  final store = runtime.database;
  final identity = runtime.identity!;
  return store.listProjects(identity.organization.id.value);
});

final class ProjectsPage extends ConsumerStatefulWidget {
  const ProjectsPage({super.key});

  @override
  ConsumerState<ProjectsPage> createState() => _ProjectsPageState();
}

final class _ProjectsPageState extends ConsumerState<ProjectsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solar Projects & Quotations'),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.description), text: 'Quotations'),
            Tab(icon: Icon(Icons.solar_power), text: 'Solar Projects'),
            Tab(icon: Icon(Icons.analytics), text: 'Budget & Costing BI'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _QuotationsTabView(),
          _ProjectsTabView(),
          _BudgetReportTabView(),
        ],
      ),
    );
  }
}

final class _QuotationsTabView extends ConsumerWidget {
  const _QuotationsTabView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotationsAsync = ref.watch(projectQuotationsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE65100),
        onPressed: () => _showCreateQuotationDialog(context, ref),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Solar Quotation', style: TextStyle(color: Colors.white)),
      ),
      body: quotationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading quotations: $err')),
        data: (quotations) {
          if (quotations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.description_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No solar quotations recorded yet.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: quotations.length,
            itemBuilder: (context, index) {
              final q = quotations[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _statusColor(q.status),
                    child: const Icon(Icons.description, color: Colors.white),
                  ),
                  title: Text('${q.quotationNumber} (Rev ${q.revisionNumber}) - ${q.customerName}'),
                  subtitle: Text('Grand Total: ${q.grandTotalPaise} | Status: ${q.status.name.toUpperCase()}'),
                  trailing: q.status == QuotationStatus.draft
                      ? FilledButton.tonal(
                          onPressed: () => _approveQuotation(context, ref, q),
                          child: const Text('Approve & Accept'),
                        )
                      : Chip(
                          label: Text(q.status.name.toUpperCase()),
                          backgroundColor: _statusColor(q.status).withValues(alpha: 0.2),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _statusColor(QuotationStatus status) {
    switch (status) {
      case QuotationStatus.draft:
        return Colors.orange;
      case QuotationStatus.sent:
        return Colors.blue;
      case QuotationStatus.approved:
        return Colors.green;
      case QuotationStatus.rejected:
        return Colors.red;
      case QuotationStatus.superseded:
        return Colors.grey;
    }
  }

  Future<void> _showCreateQuotationDialog(BuildContext context, WidgetRef ref) async {
    final customerCtrl = TextEditingController(text: 'Residential Customer');
    final installationCtrl = TextEditingController(text: '500000'); // ₹5000
    final validDaysCtrl = TextEditingController(text: '15');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Solar Quotation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: customerCtrl,
              decoration: const InputDecoration(labelText: 'Customer Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: installationCtrl,
              decoration: const InputDecoration(labelText: 'Installation Charges (in Paise)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: validDaysCtrl,
              decoration: const InputDecoration(labelText: 'Validity Period (Days)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final runtime = await ref.read(runtimeProvider.future);
                final store = runtime.database;
                final identity = runtime.identity!;
                final cmdCtx = CommandContext(session: _getEffectiveSession(ref), timestampUtc: DateTime.now());
                final useCase = CreateQuotationUseCase(
                  projectStore: store,
                  accountingStore: store,
                );

                await useCase.execute(
                  cmdCtx,
                  organizationId: identity.organization.id.value,
                  branchId: identity.branch.id.value,
                  customerPartyId: 'cust_demo',
                  customerName: customerCtrl.text,
                  validUntil: DateTime.now().add(Duration(days: int.parse(validDaysCtrl.text))),
                  installationChargesPaise: Money.fromPaise(int.parse(installationCtrl.text)),
                  lineInputs: [
                    QuotationLineInput(
                      productId: 'prod_panel_540',
                      productName: '540W Mono PERC Solar Panel',
                      sku: 'SOL-PNL-540',
                      hsnCode: '85414011',
                      quantity: Quantity.fromUnits(10.0),
                      unitPrice: UnitPrice.fromRupees(15000.0),
                      taxRate: TaxRate.gst18,
                      isServiceLine: false,
                    ),
                  ],
                );
                ref.invalidate(projectQuotationsProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create quotation: $e')),
                  );
                }
              }
            },
            child: const Text('Create Quotation'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveQuotation(BuildContext context, WidgetRef ref, QuotationHeader quotation) async {
    try {
      final runtime = await ref.read(runtimeProvider.future);
      final store = runtime.database;
      final cmdCtx = CommandContext(session: _getEffectiveSession(ref), timestampUtc: DateTime.now());
      final useCase = ApproveQuotationUseCase(
        projectStore: store,
        accountingStore: store,
      );

      await useCase.execute(
        cmdCtx,
        quotationId: quotation.id,
        projectName: 'Solar Rooftop Installation - ${quotation.customerName}',
        siteAddress: 'Plot 42, Green Energy Park, Kalamb',
      );
      ref.invalidate(projectQuotationsProvider);
      ref.invalidate(projectsListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quotation Approved! Solar Project site created successfully.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve quotation: $e')),
        );
      }
    }
  }
}

UserSession _getEffectiveSession(WidgetRef ref) {
  final session = ref.read(authProvider);
  return session ?? UserSession(
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

final class _ProjectsTabView extends ConsumerWidget {
  const _ProjectsTabView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsListProvider);

    return projectsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading projects: $err')),
      data: (projects) {
        if (projects.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.solar_power_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No active solar projects found. Accept a quotation to create a project site.', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final p = projects[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${p.projectNumber} - ${p.name}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Chip(
                          label: Text(p.status.name.toUpperCase()),
                          backgroundColor: Colors.blue.withValues(alpha: 0.2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Customer: ${p.customerName} | Site: ${p.siteAddress}'),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _metricColumn('WIP Balance (Account 1400)', p.wipBalancePaise.toString()),
                        _metricColumn('Budget Materials', p.budgetMaterialsPaise.toString()),
                        _metricColumn('Actual Materials', p.actualMaterialsPaise.toString()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OverflowBar(
                      spacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showIssueMaterialsDialog(context, ref, p),
                          icon: const Icon(Icons.outbox),
                          label: const Text('Issue Site Materials (WIP 1400 Dr)'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _showReturnMaterialsDialog(context, ref, p),
                          icon: const Icon(Icons.inbox),
                          label: const Text('Return Unused Materials (WIP 1400 Cr)'),
                        ),
                        if (p.status != ProjectStatus.completed)
                          FilledButton.icon(
                            style: FilledButton.styleFrom(backgroundColor: Colors.green),
                            onPressed: () => _postProjectInvoice(context, ref, p),
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Complete & Post Final Invoice'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _metricColumn(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Future<void> _showIssueMaterialsDialog(BuildContext context, WidgetRef ref, SolarProject project) async {
    final locationCtrl = TextEditingController(text: 'loc_main');
    final qtyCtrl = TextEditingController(text: '5');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Issue Materials to ${project.projectNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: locationCtrl,
              decoration: const InputDecoration(labelText: 'From Storage Location ID'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyCtrl,
              decoration: const InputDecoration(labelText: 'Panel Quantity'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final runtime = await ref.read(runtimeProvider.future);
                final db = runtime.database;
                final cmdCtx = CommandContext(session: _getEffectiveSession(ref), timestampUtc: DateTime.now());
                final useCase = IssueProjectMaterialsUseCase(
                  projectStore: db,
                  inventoryStore: db,
                  accountingStore: db,
                );

                await useCase.execute(
                  cmdCtx,
                  projectId: project.id,
                  locationId: locationCtrl.text,
                  issueDate: DateTime.now(),
                  lineInputs: [
                    IssueMaterialLineInput(
                      productId: 'prod_panel_540',
                      productName: '540W Mono PERC Solar Panel',
                      sku: 'SOL-PNL-540',
                      quantity: Quantity.fromUnits(double.parse(qtyCtrl.text)),
                    ),
                  ],
                );

                ref.invalidate(projectsListProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Materials issued to site! Stock reduced and 1400 WIP debited.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Issue failed: $e')),
                  );
                }
              }
            },
            child: const Text('Issue Materials'),
          ),
        ],
      ),
    );
  }

  Future<void> _showReturnMaterialsDialog(BuildContext context, WidgetRef ref, SolarProject project) async {
    final locationCtrl = TextEditingController(text: 'loc_main');
    final qtyCtrl = TextEditingController(text: '1');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Return Unused Materials from ${project.projectNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: locationCtrl,
              decoration: const InputDecoration(labelText: 'To Storage Location ID'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyCtrl,
              decoration: const InputDecoration(labelText: 'Returned Panel Quantity'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final runtime = await ref.read(runtimeProvider.future);
                final db = runtime.database;
                final cmdCtx = CommandContext(session: _getEffectiveSession(ref), timestampUtc: DateTime.now());
                final useCase = ReturnProjectMaterialsUseCase(
                  projectStore: db,
                  inventoryStore: db,
                  accountingStore: db,
                );

                await useCase.execute(
                  cmdCtx,
                  projectId: project.id,
                  locationId: locationCtrl.text,
                  productId: 'prod_panel_540',
                  quantity: Quantity.fromUnits(double.parse(qtyCtrl.text)),
                  unitCostPaise: Money.fromRupees(12000.0),
                );

                ref.invalidate(projectsListProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Unused materials returned! Stock restored and 1400 WIP credited.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Return failed: $e')),
                  );
                }
              }
            },
            child: const Text('Return Materials'),
          ),
        ],
      ),
    );
  }

  Future<void> _postProjectInvoice(BuildContext context, WidgetRef ref, SolarProject project) async {
    try {
      final runtime = await ref.read(runtimeProvider.future);
      final db = runtime.database;
      final cmdCtx = CommandContext(session: _getEffectiveSession(ref), timestampUtc: DateTime.now());
      final useCase = PostProjectInvoiceUseCase(
        projectStore: db,
        accountingStore: db,
      );

      await useCase.execute(
        cmdCtx,
        projectId: project.id,
        invoiceAmountPaise: project.wipBalancePaise.paise > 0
            ? project.wipBalancePaise
            : Money.fromRupees(500000.0),
        invoiceDate: DateTime.now(),
      );

      ref.invalidate(projectsListProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project Invoice posted successfully! WIP transferred to COGS.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post project invoice: $e')),
        );
      }
    }
  }
}

final class _BudgetReportTabView extends ConsumerWidget {
  const _BudgetReportTabView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsListProvider);

    return projectsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading report: $err')),
      data: (projects) {
        if (projects.isEmpty) {
          return const Center(child: Text('No solar projects available for BI reporting.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final p = projects[index];
            final db = ref.watch(runtimeProvider).asData!.value.database;
            final cmdCtx = CommandContext(session: _getEffectiveSession(ref), timestampUtc: DateTime.now());
            final reportUseCase = GenerateProjectBudgetReportUseCase(projectStore: db);
            return FutureBuilder<ProjectBudgetReport?>(
              future: reportUseCase.execute(cmdCtx, projectId: p.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const SizedBox();
                }
                final r = snapshot.data!;
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${r.projectNumber} - ${r.projectName}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text('Customer: ${r.customerName} | Status: ${r.status.name.toUpperCase()}'),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _reportTile('Total Budget', r.totalBudgetPaise.toString(), Colors.blue),
                            _reportTile('Actual Material Cost', r.actualMaterialsPaise.toString(), Colors.orange),
                            _reportTile('Actual Expenses', r.actualExpensesPaise.toString(), Colors.purple),
                            _reportTile('WIP Balance (1400)', r.wipBalancePaise.toString(), Colors.brown),
                            _reportTile('Invoiced Sales', r.invoicedPaise.toString(), Colors.teal),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: r.marginPercentage >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Estimated Gross Profit: ${r.estimatedGrossProfitPaise}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: r.marginPercentage >= 0 ? Colors.green.shade900 : Colors.red.shade900,
                                ),
                              ),
                              Text(
                                'Gross Margin: ${r.marginPercentage.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: r.marginPercentage >= 0 ? Colors.green.shade900 : Colors.red.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _reportTile(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
      ],
    );
  }
}
