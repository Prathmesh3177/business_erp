import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/auth_controller.dart';
import '../../app/bootstrap.dart';
import '../common/erp_shell.dart';

final financeCategoriesProvider = FutureProvider.autoDispose<List<ExpenseCategory>>((ref) async {
  final runtime = await ref.watch(runtimeProvider.future);
  final store = runtime.database;
  final identity = runtime.identity!;
  return store.getExpenseCategories(identity.organization.id.value);
});

final financeExpenseEntriesProvider = FutureProvider.autoDispose<List<ExpenseEntry>>((ref) async {
  final runtime = await ref.watch(runtimeProvider.future);
  final store = runtime.database;
  final identity = runtime.identity!;
  return store.listExpenseEntries(identity.organization.id.value);
});

final financeSalesReturnsProvider = FutureProvider.autoDispose<List<SalesReturnHeader>>((ref) async {
  final runtime = await ref.watch(runtimeProvider.future);
  final store = runtime.database;
  final identity = runtime.identity!;
  return store.listSalesReturns(identity.organization.id.value);
});

final financePurchaseReturnsProvider = FutureProvider.autoDispose<List<PurchaseReturnHeader>>((ref) async {
  final runtime = await ref.watch(runtimeProvider.future);
  final store = runtime.database;
  final identity = runtime.identity!;
  return store.listPurchaseReturns(identity.organization.id.value);
});

final financeCashSessionsProvider = FutureProvider.autoDispose<List<CashSession>>((ref) async {
  final runtime = await ref.watch(runtimeProvider.future);
  final store = runtime.database;
  final identity = runtime.identity!;
  return store.listCashSessions(identity.organization.id.value);
});

final financeActiveCashSessionProvider = FutureProvider.autoDispose<CashSession?>((ref) async {
  final runtime = await ref.watch(runtimeProvider.future);
  final store = runtime.database;
  final identity = runtime.identity!;
  final session = ref.watch(authProvider);
  if (session == null) return null;
  return store.getActiveCashSession(identity.organization.id.value, session.userId.value);
});

final financeCustomerAgingProvider = FutureProvider.autoDispose<List<PartyAgingBucket>>((ref) async {
  final runtime = await ref.watch(runtimeProvider.future);
  final store = runtime.database;
  final identity = runtime.identity!;
  return store.getPartyAgingBuckets(identity.organization.id.value, isCustomer: true);
});

final financeSupplierAgingProvider = FutureProvider.autoDispose<List<PartyAgingBucket>>((ref) async {
  final runtime = await ref.watch(runtimeProvider.future);
  final store = runtime.database;
  final identity = runtime.identity!;
  return store.getPartyAgingBuckets(identity.organization.id.value, isCustomer: false);
});

final class FinancePage extends ConsumerStatefulWidget {
  const FinancePage({super.key});

  @override
  ConsumerState<FinancePage> createState() => _FinancePageState();
}

final class _FinancePageState extends ConsumerState<FinancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authProvider);
    final canManageFinance = session?.hasCapability(Capability.financeManage) ?? false;
    final canManageExpenses = session?.hasCapability(Capability.expensesManage) ?? false;
    final canManageCash = session?.hasCapability(Capability.cashSessionManage) ?? false;

    return ErpFeatureScaffold(
      appBar: AppBar(
        title: const Text('Finance, Returns & Expenses'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.pie_chart), text: 'Payments & Aging'),
            Tab(icon: Icon(Icons.assignment_return), text: 'Sales & Purchase Returns'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Expense Vouchers'),
            Tab(icon: Icon(Icons.point_of_sale), text: 'Cash Counter Sessions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PaymentsAndAgingView(canManage: canManageFinance),
          _ReturnsView(canManage: canManageFinance),
          _ExpensesView(canManage: canManageExpenses),
          _CashSessionsView(canManage: canManageCash),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// 1. Payments & Aging View
// ---------------------------------------------------------------------

final class _PaymentsAndAgingView extends ConsumerWidget {
  const _PaymentsAndAgingView({required this.canManage});
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final custAging = ref.watch(financeCustomerAgingProvider);
    final suppAging = ref.watch(financeSupplierAgingProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Party Outstanding & Aging Analysis',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF990000),
                ),
              ),
              if (canManage)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF004D40),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _showRecordPaymentDialog(context, ref),
                  icon: const Icon(Icons.payment),
                  label: const Text('Record Payment / Receipt'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer Receivables Aging',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF004D40),
                    ),
                  ),
                  const SizedBox(height: 12),
                  custAging.when(
                    data: (buckets) => _buildAgingTable(context, buckets, isCustomer: true),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Text('Error loading aging: $err'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Supplier Payables Aging',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF990000),
                    ),
                  ),
                  const SizedBox(height: 12),
                  suppAging.when(
                    data: (buckets) => _buildAgingTable(context, buckets, isCustomer: false),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Text('Error loading aging: $err'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgingTable(BuildContext context, List<PartyAgingBucket> buckets, {required bool isCustomer}) {
    if (buckets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            isCustomer ? 'No customer parties registered.' : 'No supplier parties registered.',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Party Name')),
          DataColumn(label: Text('0-30 Days')),
          DataColumn(label: Text('31-60 Days')),
          DataColumn(label: Text('61-90 Days')),
          DataColumn(label: Text('90+ Days')),
          DataColumn(label: Text('Total Outstanding')),
        ],
        rows: buckets.map((b) {
          return DataRow(
            cells: [
              DataCell(Text(b.partyName, style: const TextStyle(fontWeight: FontWeight.bold))),
              DataCell(Text(b.days0To30.toString())),
              DataCell(Text(b.days31To60.toString())),
              DataCell(Text(b.days61To90.toString())),
              DataCell(Text(b.days90Plus.toString(), style: TextStyle(color: b.days90Plus.paise > 0 ? Colors.red : Colors.black))),
              DataCell(Text(b.totalOutstanding.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          );
        }).toList(),
      ),
    );
  }

  Future<void> _showRecordPaymentDialog(BuildContext context, WidgetRef ref) async {
    final amountController = TextEditingController();
    final partyIdController = TextEditingController();
    final partyNameController = TextEditingController(text: 'Customer / Supplier');
    String mode = 'receipt';
    String paymentMethodStr = 'bank_transfer';

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              title: const Text('Record Payment / Receipt Voucher'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: mode,
                      decoration: const InputDecoration(labelText: 'Voucher Type'),
                      items: const [
                        DropdownMenuItem(value: 'receipt', child: Text('Customer Receipt (Inflow)')),
                        DropdownMenuItem(value: 'payment', child: Text('Supplier Payment (Outflow)')),
                      ],
                      onChanged: (val) => setDlgState(() => mode = val!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: partyIdController,
                      decoration: const InputDecoration(labelText: 'Party ID'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: partyNameController,
                      decoration: const InputDecoration(labelText: 'Party Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Amount (₹)'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: paymentMethodStr,
                      decoration: const InputDecoration(labelText: 'Payment Method'),
                      items: const [
                        DropdownMenuItem(value: 'cash', child: Text('Cash')),
                        DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer (NEFT/RTGS)')),
                        DropdownMenuItem(value: 'upi', child: Text('UPI / QR')),
                        DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                      ],
                      onChanged: (val) => setDlgState(() => paymentMethodStr = val!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF990000)),
                  onPressed: () async {
                    final amountRupees = double.tryParse(amountController.text) ?? 0;
                    if (amountRupees <= 0) return;
                    final runtime = await ref.read(runtimeProvider.future);
                    final identity = runtime.identity!;
                    final session = ref.read(authProvider)!;
                    final cmdCtx = CommandContext(session: session, timestampUtc: DateTime.now());

                    final useCase = PostPaymentUseCase(
                      purchasingStore: runtime.database,
                      accountingStore: runtime.database,
                    );

                    PaymentMethod methodEnum = PaymentMethod.bankTransfer;
                    if (paymentMethodStr == 'cash') methodEnum = PaymentMethod.cash;
                    if (paymentMethodStr == 'upi') methodEnum = PaymentMethod.upi;
                    if (paymentMethodStr == 'cheque') methodEnum = PaymentMethod.cheque;

                    try {
                      await useCase.execute(
                        cmdCtx,
                        organizationId: identity.organization.id.value,
                        branchId: identity.branch.id.value,
                        partyId: partyIdController.text.trim().isEmpty ? 'party_gen' : partyIdController.text.trim(),
                        partyName: partyNameController.text.trim().isEmpty ? 'General Party' : partyNameController.text.trim(),
                        direction: mode == 'receipt' ? PaymentDirection.inbound : PaymentDirection.outbound,
                        paymentMethod: methodEnum,
                        amountPaise: Money.fromRupees(amountRupees),
                        paymentDate: DateTime.now(),
                      );
                      ref.invalidate(financeCustomerAgingProvider);
                      ref.invalidate(financeSupplierAgingProvider);
                      if (ctx.mounted) Navigator.of(ctx).pop();
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Error recording payment: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Post Voucher'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------
// 2. Returns View (Sales & Purchase Returns)
// ---------------------------------------------------------------------

final class _ReturnsView extends ConsumerWidget {
  const _ReturnsView({required this.canManage});
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesReturns = ref.watch(financeSalesReturnsProvider);
    final purchaseReturns = ref.watch(financePurchaseReturnsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer & Supplier Returns',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF990000),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sales Returns (Customer Returns)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF004D40),
                    ),
                  ),
                  const SizedBox(height: 12),
                  salesReturns.when(
                    data: (list) {
                      if (list.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: Text('No sales returns recorded.', style: TextStyle(color: Colors.grey))),
                        );
                      }
                      return DataTable(
                        columns: const [
                          DataColumn(label: Text('Return ID')),
                          DataColumn(label: Text('Customer')),
                          DataColumn(label: Text('Return Date')),
                          DataColumn(label: Text('Total Tax')),
                          DataColumn(label: Text('Grand Total')),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: list.map((sr) {
                          return DataRow(
                            cells: [
                              DataCell(Text(sr.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(sr.customerName)),
                              DataCell(Text('${sr.returnDate.day}/${sr.returnDate.month}/${sr.returnDate.year}')),
                              DataCell(Text(sr.totalTaxPaise.toString())),
                              DataCell(Text(sr.grandTotalPaise.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Chip(label: Text(sr.status.name), backgroundColor: Colors.green.shade100)),
                            ],
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Text('Error: $err'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Purchase Returns (Supplier Debit Notes)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF990000),
                    ),
                  ),
                  const SizedBox(height: 12),
                  purchaseReturns.when(
                    data: (list) {
                      if (list.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: Text('No purchase returns recorded.', style: TextStyle(color: Colors.grey))),
                        );
                      }
                      return DataTable(
                        columns: const [
                          DataColumn(label: Text('Return ID')),
                          DataColumn(label: Text('Supplier')),
                          DataColumn(label: Text('Return Date')),
                          DataColumn(label: Text('Total Tax')),
                          DataColumn(label: Text('Grand Total')),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: list.map((pr) {
                          return DataRow(
                            cells: [
                              DataCell(Text(pr.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(pr.supplierName)),
                              DataCell(Text('${pr.returnDate.day}/${pr.returnDate.month}/${pr.returnDate.year}')),
                              DataCell(Text(pr.totalTaxPaise.toString())),
                              DataCell(Text(pr.grandTotalPaise.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Chip(label: Text(pr.status.name), backgroundColor: Colors.orange.shade100)),
                            ],
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Text('Error: $err'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// 3. Expenses View
// ---------------------------------------------------------------------

final class _ExpensesView extends ConsumerWidget {
  const _ExpensesView({required this.canManage});
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(financeExpenseEntriesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Direct & Indirect Expense Vouchers',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF990000),
                ),
              ),
              if (canManage)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF990000),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _showRecordExpenseDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Record Expense Voucher'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expense Register History',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF004D40),
                    ),
                  ),
                  const SizedBox(height: 12),
                  expenses.when(
                    data: (list) {
                      if (list.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: Text('No expense vouchers recorded yet.', style: TextStyle(color: Colors.grey))),
                        );
                      }
                      return DataTable(
                        columns: const [
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Category')),
                          DataColumn(label: Text('Account Code')),
                          DataColumn(label: Text('Amount')),
                          DataColumn(label: Text('Payment Method')),
                          DataColumn(label: Text('Reference / Notes')),
                        ],
                        rows: list.map((e) {
                          return DataRow(
                            cells: [
                              DataCell(Text('${e.expenseDate.day}/${e.expenseDate.month}/${e.expenseDate.year}')),
                              DataCell(Text(e.categoryName, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(e.accountCode)),
                              DataCell(Text(e.amountPaise.toString(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
                              DataCell(Chip(label: Text(e.paymentMethod.toUpperCase()), backgroundColor: Colors.grey.shade200)),
                              DataCell(Text(e.referenceNumber ?? e.notes ?? '-')),
                            ],
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Text('Error loading expenses: $err'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRecordExpenseDialog(BuildContext context, WidgetRef ref) async {
    final amountController = TextEditingController();
    final refController = TextEditingController();
    final notesController = TextEditingController();
    String categoryId = 'exp_cat_rent';
    String categoryName = 'Office Rent & Maintenance';
    String accountCode = '6100';
    String paymentMethod = 'cash';

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            final catAsync = ref.watch(financeCategoriesProvider);
            return AlertDialog(
              title: const Text('Record New Expense Voucher'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    catAsync.when(
                      data: (cats) {
                        return DropdownButtonFormField<String>(
                          initialValue: categoryId,
                          decoration: const InputDecoration(labelText: 'Expense Category'),
                          items: cats.map((c) {
                            return DropdownMenuItem(
                              value: c.id,
                              child: Text('${c.name} (${c.accountCode})'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            final sel = cats.firstWhere((c) => c.id == val);
                            setDlgState(() {
                              categoryId = sel.id;
                              categoryName = sel.name;
                              accountCode = sel.accountCode;
                            });
                          },
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (err, _) => Text('Error loading categories: $err'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Expense Amount (₹)'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: paymentMethod,
                      decoration: const InputDecoration(labelText: 'Payment Account'),
                      items: const [
                        DropdownMenuItem(value: 'cash', child: Text('1000 — Cash in Till')),
                        DropdownMenuItem(value: 'bank', child: Text('1010 — Bank Account')),
                        DropdownMenuItem(value: 'upi', child: Text('1020 — UPI Wallet')),
                      ],
                      onChanged: (val) => setDlgState(() => paymentMethod = val!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: refController,
                      decoration: const InputDecoration(labelText: 'Reference Number / Bill No.'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Voucher Notes'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF990000)),
                  onPressed: () async {
                    final amountRupees = double.tryParse(amountController.text) ?? 0;
                    if (amountRupees <= 0) return;
                    final runtime = await ref.read(runtimeProvider.future);
                    final identity = runtime.identity!;
                    final session = ref.read(authProvider)!;
                    final cmdCtx = CommandContext(session: session, timestampUtc: DateTime.now());

                    final useCase = PostExpenseUseCase(
                      financeStore: runtime.database,
                      accountingStore: runtime.database,
                    );

                    try {
                      await useCase.execute(
                        cmdCtx,
                        organizationId: identity.organization.id.value,
                        branchId: identity.branch.id.value,
                        categoryId: categoryId,
                        categoryName: categoryName,
                        accountCode: accountCode,
                        amountPaise: Money.fromRupees(amountRupees),
                        expenseDate: DateTime.now(),
                        paymentMethod: paymentMethod,
                        referenceNumber: refController.text.trim().isEmpty ? null : refController.text.trim(),
                        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                      );
                      ref.invalidate(financeExpenseEntriesProvider);
                      if (ctx.mounted) Navigator.of(ctx).pop();
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Error posting expense: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Post Expense'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------
// 4. Cash Sessions View
// ---------------------------------------------------------------------

final class _CashSessionsView extends ConsumerWidget {
  const _CashSessionsView({required this.canManage});
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(financeActiveCashSessionProvider);
    final allSessions = ref.watch(financeCashSessionsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'POS Cash Register Counter Sessions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF990000),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          activeSession.when(
            data: (session) {
              if (session == null) {
                return Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange),
                            SizedBox(width: 8),
                            Text(
                              'No Active Cash Register Session',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('Open a counter session before performing cash sales or till reconciliations.'),
                        const SizedBox(height: 16),
                        if (canManage)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF004D40),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _showOpenSessionDialog(context, ref),
                            icon: const Icon(Icons.lock_open),
                            label: const Text('Open Cash Register Session'),
                          ),
                      ],
                    ),
                  ),
                );
              }
              return Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green),
                              const SizedBox(width: 8),
                              Text(
                                'Active Counter Session: ${session.username}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ],
                          ),
                          Chip(label: const Text('OPEN'), backgroundColor: Colors.green.shade200),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _statTile('Opening Float', session.openingCashPaise.toString()),
                          _statTile('Expected Cash in Till', session.expectedCashPaise.toString()),
                          _statTile('Opened At', '${session.openedAtUtc.hour}:${session.openedAtUtc.minute.toString().padLeft(2, '0')}'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (canManage)
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF990000),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _showCloseSessionDialog(context, ref, session),
                            icon: const Icon(Icons.lock),
                            label: const Text('Reconcile & Close Counter Session'),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error loading session: $err'),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cash Counter Session History & Audit Trail',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF004D40),
                    ),
                  ),
                  const SizedBox(height: 12),
                  allSessions.when(
                    data: (list) {
                      if (list.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: Text('No past counter sessions found.', style: TextStyle(color: Colors.grey))),
                        );
                      }
                      return DataTable(
                        columns: const [
                          DataColumn(label: Text('User')),
                          DataColumn(label: Text('Opened At')),
                          DataColumn(label: Text('Closed At')),
                          DataColumn(label: Text('Opening Cash')),
                          DataColumn(label: Text('Expected Cash')),
                          DataColumn(label: Text('Counted Cash')),
                          DataColumn(label: Text('Variance')),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: list.map((s) {
                          final varPaise = s.variancePaise.paise;
                          Color varColor = Colors.black;
                          if (varPaise < 0) varColor = Colors.red;
                          if (varPaise > 0) varColor = Colors.green;

                          return DataRow(
                            cells: [
                              DataCell(Text(s.username, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text('${s.openedAtUtc.day}/${s.openedAtUtc.month} ${s.openedAtUtc.hour}:${s.openedAtUtc.minute}')),
                              DataCell(Text(s.closedAtUtc != null ? '${s.closedAtUtc!.day}/${s.closedAtUtc!.month} ${s.closedAtUtc!.hour}:${s.closedAtUtc!.minute}' : '-')),
                              DataCell(Text(s.openingCashPaise.toString())),
                              DataCell(Text(s.expectedCashPaise.toString())),
                              DataCell(Text(s.countedCashPaise.toString())),
                              DataCell(Text(s.variancePaise.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: varColor))),
                              DataCell(Chip(
                                label: Text(s.status.name.toUpperCase()),
                                backgroundColor: s.status == CashSessionStatus.open ? Colors.green.shade100 : Colors.grey.shade200,
                              )),
                            ],
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Text('Error: $err'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statTile(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF004D40))),
      ],
    );
  }

  Future<void> _showOpenSessionDialog(BuildContext context, WidgetRef ref) async {
    final floatController = TextEditingController(text: '1000');

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Open Cash Register Counter Session'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: floatController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Opening Cash Float (₹)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF004D40)),
              onPressed: () async {
                final openingRupees = double.tryParse(floatController.text) ?? 0;
                final runtime = await ref.read(runtimeProvider.future);
                final identity = runtime.identity!;
                final session = ref.read(authProvider)!;
                final cmdCtx = CommandContext(session: session, timestampUtc: DateTime.now());

                final useCases = CashSessionUseCases(
                  financeStore: runtime.database,
                  accountingStore: runtime.database,
                );

                try {
                  await useCases.startSession(
                    cmdCtx,
                    organizationId: identity.organization.id.value,
                    branchId: identity.branch.id.value,
                    openingCashPaise: Money.fromRupees(openingRupees),
                  );
                  ref.invalidate(financeActiveCashSessionProvider);
                  ref.invalidate(financeCashSessionsProvider);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Error opening session: $e')),
                    );
                  }
                }
              },
              child: const Text('Start Counter Session'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCloseSessionDialog(BuildContext context, WidgetRef ref, CashSession session) async {
    final countedController = TextEditingController(text: session.expectedCashPaise.inRupees.toStringAsFixed(2));
    final notesController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Reconcile & Close Cash Counter Session'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Expected Cash in Till: ${session.expectedCashPaise}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextField(
                  controller: countedController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Actual Physical Counted Cash (₹)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Closing Notes / Discrepancy Reason'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF990000)),
              onPressed: () async {
                final countedRupees = double.tryParse(countedController.text) ?? 0;
                final runtime = await ref.read(runtimeProvider.future);
                final authSession = ref.read(authProvider)!;
                final cmdCtx = CommandContext(session: authSession, timestampUtc: DateTime.now());

                final useCases = CashSessionUseCases(
                  financeStore: runtime.database,
                  accountingStore: runtime.database,
                );

                try {
                  await useCases.closeSession(
                    cmdCtx,
                    sessionId: session.id,
                    expectedCashPaise: session.expectedCashPaise,
                    countedCashPaise: Money.fromRupees(countedRupees),
                    notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                  );
                  ref.invalidate(financeActiveCashSessionProvider);
                  ref.invalidate(financeCashSessionsProvider);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Error closing session: $e')),
                    );
                  }
                }
              },
              child: const Text('Post Variance & Close Session'),
            ),
          ],
        );
      },
    );
  }
}
