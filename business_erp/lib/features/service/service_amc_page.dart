import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/auth_controller.dart';
import '../../app/bootstrap.dart';

final serviceJobsProvider = FutureProvider.autoDispose<List<ServiceJob>>((
  ref,
) async {
  final runtime = await ref.watch(runtimeProvider.future);
  final store = runtime.database;
  final identity = runtime.identity!;
  return store.listServiceJobs(organizationId: identity.organization.id.value);
});

final amcContractsProvider = FutureProvider.autoDispose<List<AmcContract>>((
  ref,
) async {
  final runtime = await ref.watch(runtimeProvider.future);
  final store = runtime.database;
  final identity = runtime.identity!;
  return store.listAmcContracts(identity.organization.id.value);
});

final amcRemindersProvider = FutureProvider.autoDispose<List<AmcReminder>>((
  ref,
) async {
  final runtime = await ref.watch(runtimeProvider.future);
  final store = runtime.database;
  final identity = runtime.identity!;
  final cmdCtx = CommandContext(
    session: _getEffectiveSession(ref),
    timestampUtc: DateTime.now(),
  );
  final useCase = GenerateAmcRemindersUseCase(serviceStore: store);
  return useCase.execute(
    cmdCtx,
    organizationId: identity.organization.id.value,
  );
});

final class ServiceAmcPage extends ConsumerStatefulWidget {
  const ServiceAmcPage({super.key});

  @override
  ConsumerState<ServiceAmcPage> createState() => _ServiceAmcPageState();
}

final class _ServiceAmcPageState extends ConsumerState<ServiceAmcPage>
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
        title: const Text('Service & AMC Workflows'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.build), text: 'Service Tickets'),
            Tab(icon: Icon(Icons.assignment), text: 'AMC Contracts'),
            Tab(
              icon: Icon(Icons.notifications_active),
              text: 'Reminders & My Jobs',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ServiceTicketsTabView(),
          _AmcContractsTabView(),
          _RemindersTabView(),
        ],
      ),
    );
  }
}

final class _ServiceTicketsTabView extends ConsumerWidget {
  const _ServiceTicketsTabView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(serviceJobsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogTicketDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Log Service Ticket'),
      ),
      body: jobsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error loading tickets: $err')),
        data: (jobs) {
          if (jobs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.build_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No service tickets logged yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _jobStatusColor(job.status),
                    child: const Icon(Icons.build, color: Colors.white),
                  ),
                  title: Text('${job.jobTicketNumber} - ${job.customerName}'),
                  subtitle: Text(
                    'Status: ${job.status.name.toUpperCase()} | '
                    'Warranty: ${job.isCoveredByWarranty ? "YES" : "NO"} | '
                    'AMC: ${job.isCoveredByAmc ? "YES" : "NO"}',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Site Address: ${job.siteAddress}'),
                          Text('Equipment Serial ID: ${job.equipmentSerialId}'),
                          Text('Issue Description: ${job.issueDescription}'),
                          if (job.assignedTechnicianName != null)
                            Text(
                              'Assigned Technician: ${job.assignedTechnicianName}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(height: 12),
                          OverflowBar(
                            spacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _showAssignTechDialog(context, ref, job),
                                icon: const Icon(Icons.person_add),
                                label: const Text('Assign Technician'),
                              ),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _showRecordVisitDialog(context, ref, job),
                                icon: const Icon(Icons.check_circle_outline),
                                label: const Text(
                                  'Record Visit & Deduct Spares',
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrange,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () =>
                                    _showReplaceSerialDialog(context, ref, job),
                                icon: const Icon(Icons.swap_horiz),
                                label: const Text('Replace Serial Component'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _jobStatusColor(ServiceJobStatus status) {
    switch (status) {
      case ServiceJobStatus.logged:
        return Colors.orange;
      case ServiceJobStatus.assigned:
        return Colors.blue;
      case ServiceJobStatus.inProgress:
        return Colors.purple;
      case ServiceJobStatus.resolved:
      case ServiceJobStatus.closed:
        return Colors.green;
      case ServiceJobStatus.cancelled:
        return Colors.grey;
    }
  }

  Future<void> _showLogTicketDialog(BuildContext context, WidgetRef ref) async {
    final customerCtrl = TextEditingController(text: 'Customer Solar Site');
    final addressCtrl = TextEditingController(
      text: 'Plot 10, Industrial Estate, Kalamb',
    );
    final serialCtrl = TextEditingController(text: 'SN-INV-5KW-9001');
    final issueCtrl = TextEditingController(
      text: 'Inverter error code E04 (Overheating)',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log New Service Ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: customerCtrl,
              decoration: const InputDecoration(labelText: 'Customer Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(labelText: 'Site Address'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: serialCtrl,
              decoration: const InputDecoration(
                labelText: 'Equipment Serial ID / Number',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: issueCtrl,
              decoration: const InputDecoration(labelText: 'Issue Description'),
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
                final db = runtime.database;
                final identity = runtime.identity!;
                final cmdCtx = CommandContext(
                  session: _getEffectiveSession(ref),
                  timestampUtc: DateTime.now(),
                );
                final useCase = CreateServiceJobUseCase(serviceStore: db);

                await useCase.execute(
                  cmdCtx,
                  organizationId: identity.organization.id.value,
                  branchId: identity.branch.id.value,
                  customerPartyId: 'cust_demo',
                  customerName: customerCtrl.text,
                  siteAddress: addressCtrl.text,
                  equipmentSerialId: serialCtrl.text,
                  issueDescription: issueCtrl.text,
                  isCoveredByWarranty: true,
                );

                ref.invalidate(serviceJobsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Service Ticket logged and warranty/AMC coverage evaluated successfully!',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to log ticket: $e')),
                  );
                }
              }
            },
            child: const Text('Log Ticket'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAssignTechDialog(
    BuildContext context,
    WidgetRef ref,
    ServiceJob job,
  ) async {
    final techIdCtrl = TextEditingController(text: 'tech_usr_01');
    final techNameCtrl = TextEditingController(text: 'Rajesh Sharma');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign Technician to ${job.jobTicketNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: techIdCtrl,
              decoration: const InputDecoration(
                labelText: 'Technician User ID',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: techNameCtrl,
              decoration: const InputDecoration(labelText: 'Technician Name'),
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
                final db = runtime.database;
                final cmdCtx = CommandContext(
                  session: _getEffectiveSession(ref),
                  timestampUtc: DateTime.now(),
                );
                final useCase = AssignTechnicianUseCase(serviceStore: db);

                await useCase.execute(
                  cmdCtx,
                  jobId: job.id,
                  technicianUserId: techIdCtrl.text,
                  technicianName: techNameCtrl.text,
                );

                ref.invalidate(serviceJobsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Technician assigned successfully!'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Assignment failed: $e')),
                  );
                }
              }
            },
            child: const Text('Assign Technician'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRecordVisitDialog(
    BuildContext context,
    WidgetRef ref,
    ServiceJob job,
  ) async {
    final workCtrl = TextEditingController(
      text: 'Replaced DC fuse and calibrated inverter solar input.',
    );
    final travelCtrl = TextEditingController(text: '20000'); // ₹200
    final laborCtrl = TextEditingController(text: '50000'); // ₹500
    final billableCtrl = TextEditingController(
      text: job.isCoveredByWarranty || job.isCoveredByAmc ? '0' : '70000',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Visit for ${job.jobTicketNumber}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: workCtrl,
                decoration: const InputDecoration(labelText: 'Work Performed'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: travelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Travel Expense (in Paise)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: laborCtrl,
                decoration: const InputDecoration(
                  labelText: 'Labor Cost (in Paise)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: billableCtrl,
                decoration: const InputDecoration(
                  labelText: 'Billable Amount to Customer (Paise)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
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
                final db = runtime.database;
                final cmdCtx = CommandContext(
                  session: _getEffectiveSession(ref),
                  timestampUtc: DateTime.now(),
                );
                final useCase = RecordServiceVisitUseCase(
                  serviceStore: db,
                  inventoryStore: db,
                );

                await useCase.execute(
                  cmdCtx,
                  jobId: job.id,
                  technicianUserId:
                      job.assignedTechnicianUserId ?? 'tech_usr_01',
                  technicianName: job.assignedTechnicianName ?? 'Rajesh Sharma',
                  visitDate: DateTime.now(),
                  workPerformed: workCtrl.text,
                  travelExpensesPaise: Money.fromPaise(
                    int.parse(travelCtrl.text),
                  ),
                  laborCostPaise: Money.fromPaise(int.parse(laborCtrl.text)),
                  billableAmountPaise: Money.fromPaise(
                    int.parse(billableCtrl.text),
                  ),
                  sparesUsed: [
                    ServiceJobSpareItem(
                      productId: 'prod_fuse_10a',
                      productName: '10A DC Fuse Component',
                      sku: 'SP-FUSE-10A',
                      quantity: Quantity.fromUnits(1.0),
                      unitCostPaise: Money.fromPaise(15000),
                    ),
                  ],
                  storageLocationId: 'loc_main',
                  isJobResolved: true,
                );

                ref.invalidate(serviceJobsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Service visit recorded! Spares stock deducted & job marked resolved.',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Record visit failed: $e')),
                  );
                }
              }
            },
            child: const Text('Record Visit'),
          ),
        ],
      ),
    );
  }

  Future<void> _showReplaceSerialDialog(
    BuildContext context,
    WidgetRef ref,
    ServiceJob job,
  ) async {
    final oldSerialCtrl = TextEditingController(text: job.equipmentSerialId);
    final newSerialCtrl = TextEditingController(text: 'SN-INV-5KW-9999');
    final reasonCtrl = TextEditingController(
      text: 'Internal inverter coil short under warranty',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Replace Component Serial for ${job.jobTicketNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldSerialCtrl,
              decoration: const InputDecoration(
                labelText: 'Faulty Serial Number',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newSerialCtrl,
              decoration: const InputDecoration(labelText: 'New Serial Number'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Replacement Reason',
              ),
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
                final db = runtime.database;
                final identity = runtime.identity!;
                final cmdCtx = CommandContext(
                  session: _getEffectiveSession(ref),
                  timestampUtc: DateTime.now(),
                );
                final useCase = ReplaceSerializedComponentUseCase(
                  serviceStore: db,
                  inventoryStore: db,
                );

                await useCase.execute(
                  cmdCtx,
                  organizationId: identity.organization.id.value,
                  productId: 'prod_inverter',
                  jobId: job.id,
                  oldSerialNumber: oldSerialCtrl.text,
                  newSerialNumber: newSerialCtrl.text,
                  replacementDate: DateTime.now(),
                  reason: reasonCtrl.text,
                );

                ref.invalidate(serviceJobsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Serial replacement logged! Lineage tracked & inventory serial states updated.',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Replacement failed: $e')),
                  );
                }
              }
            },
            child: const Text('Replace Serial'),
          ),
        ],
      ),
    );
  }
}

final class _AmcContractsTabView extends ConsumerWidget {
  const _AmcContractsTabView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(amcContractsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0288D1),
        onPressed: () => _showCreateAmcDialog(context, ref),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create AMC Contract',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: contractsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error loading contracts: $err')),
        data: (contracts) {
          if (contracts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No AMC contracts registered.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contracts.length,
            itemBuilder: (context, index) {
              final c = contracts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: c.status == AmcContractStatus.active
                        ? Colors.green
                        : Colors.grey,
                    child: const Icon(Icons.assignment, color: Colors.white),
                  ),
                  title: Text('${c.contractNumber} - ${c.customerName}'),
                  subtitle: Text(
                    'Valid: ${c.startDate.toString().split(' ').first} to ${c.endDate.toString().split(' ').first} | '
                    'Visits: ${c.visitsCompleted}/${c.visitLimitPerYear} | Value: ${c.contractValuePaise}',
                  ),
                  trailing: c.status == AmcContractStatus.active
                      ? FilledButton.tonal(
                          onPressed: () => _showRenewAmcDialog(context, ref, c),
                          child: const Text('Renew AMC'),
                        )
                      : Chip(label: Text(c.status.name.toUpperCase())),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showCreateAmcDialog(BuildContext context, WidgetRef ref) async {
    final customerCtrl = TextEditingController(text: 'Commercial Solar Client');
    final addressCtrl = TextEditingController(
      text: 'Plot 42, Solar Park, Kalamb',
    );
    final valCtrl = TextEditingController(text: '2500000'); // ₹25,000
    final visitsCtrl = TextEditingController(text: '4');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New AMC Contract'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: customerCtrl,
              decoration: const InputDecoration(labelText: 'Customer Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(labelText: 'Site Address'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valCtrl,
              decoration: const InputDecoration(
                labelText: 'Contract Value (in Paise)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: visitsCtrl,
              decoration: const InputDecoration(
                labelText: 'Visit Limit / Year',
              ),
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
                final db = runtime.database;
                final identity = runtime.identity!;
                final cmdCtx = CommandContext(
                  session: _getEffectiveSession(ref),
                  timestampUtc: DateTime.now(),
                );
                final useCase = CreateAmcContractUseCase(serviceStore: db);

                await useCase.execute(
                  cmdCtx,
                  organizationId: identity.organization.id.value,
                  branchId: identity.branch.id.value,
                  customerPartyId: 'cust_demo',
                  customerName: customerCtrl.text,
                  siteAddress: addressCtrl.text,
                  startDate: DateTime.now(),
                  endDate: DateTime.now().add(const Duration(days: 365)),
                  contractValuePaise: Money.fromPaise(int.parse(valCtrl.text)),
                  visitLimitPerYear: int.parse(visitsCtrl.text),
                );

                ref.invalidate(amcContractsProvider);
                ref.invalidate(amcRemindersProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('AMC Contract created successfully!'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('AMC creation failed: $e')),
                  );
                }
              }
            },
            child: const Text('Create Contract'),
          ),
        ],
      ),
    );
  }

  Future<void> _showRenewAmcDialog(
    BuildContext context,
    WidgetRef ref,
    AmcContract contract,
  ) async {
    final valCtrl = TextEditingController(text: '3000000'); // ₹30,000

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Renew AMC Contract ${contract.contractNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: valCtrl,
              decoration: const InputDecoration(
                labelText: 'Renewal Value (in Paise)',
              ),
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
                final db = runtime.database;
                final cmdCtx = CommandContext(
                  session: _getEffectiveSession(ref),
                  timestampUtc: DateTime.now(),
                );
                final useCase = RenewAmcContractUseCase(serviceStore: db);

                final now = DateTime.now();
                await useCase.execute(
                  cmdCtx,
                  contractId: contract.id,
                  newEndDate: now.add(const Duration(days: 365)),
                  renewalValuePaise: Money.fromPaise(int.parse(valCtrl.text)),
                );

                ref.invalidate(amcContractsProvider);
                ref.invalidate(amcRemindersProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'AMC Contract renewed successfully! New contract period active.',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Renewal failed: $e')));
                }
              }
            },
            child: const Text('Renew Contract'),
          ),
        ],
      ),
    );
  }
}

final class _RemindersTabView extends ConsumerWidget {
  const _RemindersTabView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(amcRemindersProvider);

    return remindersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Center(child: Text('Error loading reminders: $err')),
      data: (reminders) {
        if (reminders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No pending AMC contract reminders or due visits.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final r = reminders[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: r.isOverdue ? Colors.red.shade50 : Colors.amber.shade50,
              child: ListTile(
                leading: Icon(
                  r.isOverdue
                      ? Icons.warning_amber
                      : Icons.notifications_active,
                  color: r.isOverdue ? Colors.red : Colors.amber.shade900,
                ),
                title: Text('${r.contractNumber} - ${r.customerName}'),
                subtitle: Text(r.description),
                trailing: Text(
                  r.dueOrExpiryDate.toString().split(' ').first,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: r.isOverdue ? Colors.red : Colors.amber.shade900,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

UserSession _getEffectiveSession(dynamic ref) {
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
