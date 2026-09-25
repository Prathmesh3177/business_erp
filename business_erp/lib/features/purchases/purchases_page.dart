import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/auth_controller.dart';
import '../../app/bootstrap.dart';

final class PurchasesPage extends ConsumerStatefulWidget {
  const PurchasesPage({super.key});

  @override
  ConsumerState<PurchasesPage> createState() => _PurchasesPageState();
}

final class _PurchasesPageState extends ConsumerState<PurchasesPage>
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
        title: const Text('Supplier Purchasing & Receipt Posting'),
        backgroundColor: const Color(0xFF990000),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.receipt_long), text: 'Purchase Invoices'),
            Tab(icon: Icon(Icons.add_shopping_cart), text: 'New Purchase Bill'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Supplier Payables & Returns'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PurchaseInvoicesTab(
            onNavigateToNewBill: () => _tabController.animateTo(1),
          ),
          _NewPurchaseBillTab(
            onPostedSuccess: () => _tabController.animateTo(0),
          ),
          const _SupplierPayablesTab(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Tab 1: Purchase Invoices History
// ---------------------------------------------------------------------

class _PurchaseInvoicesTab extends ConsumerStatefulWidget {
  const _PurchaseInvoicesTab({required this.onNavigateToNewBill});

  final VoidCallback onNavigateToNewBill;

  @override
  ConsumerState<_PurchaseInvoicesTab> createState() => _PurchaseInvoicesTabState();
}

class _PurchaseInvoicesTabState extends ConsumerState<_PurchaseInvoicesTab> {
  List<PurchaseHeader> _purchases = [];
  bool _loading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    setState(() => _loading = true);
    final runtime = await ref.read(runtimeProvider.future);
    final orgId = runtime.identity?.organization.id.value ?? 'default_org';
    final items = await runtime.database.listPurchases(organizationId: orgId);
    if (mounted) {
      setState(() {
        _purchases = items;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _purchases.where((p) {
      final query = _searchQuery.toLowerCase();
      return p.supplierName.toLowerCase().contains(query) ||
          p.externalInvoiceNumber.toLowerCase().contains(query);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search by Supplier or Bill No.',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _loadPurchases,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF990000),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: widget.onNavigateToNewBill,
                icon: const Icon(Icons.add),
                label: const Text('New Purchase Bill'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No purchase invoices recorded yet.'))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final item = filtered[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF990000),
                            child: Icon(Icons.inventory, color: Colors.white),
                          ),
                          title: Text(
                            '${item.supplierName} — Bill #${item.externalInvoiceNumber}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Date: ${item.invoiceDate.toLocal().toString().split(' ')[0]} | Net Total: ₹${item.netTotalPaise.inRupees.toStringAsFixed(2)} | Paid: ₹${item.amountPaidPaise.inRupees.toStringAsFixed(2)}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Chip(
                                label: Text(
                                  item.status.name.toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 10),
                                ),
                                backgroundColor: item.status == PurchaseStatus.posted
                                    ? Colors.green[700]
                                    : Colors.grey,
                                visualDensity: VisualDensity.compact,
                              ),
                              Text(
                                'Due: ₹${item.balanceDuePaise.inRupees.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: item.balanceDuePaise.paise > 0 ? Colors.red : Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _showInvoiceDetails(item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showInvoiceDetails(PurchaseHeader header) async {
    final runtime = await ref.read(runtimeProvider.future);
    final lines = await runtime.database.getPurchaseLines(header.id);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Purchase Invoice Details — Bill #${header.externalInvoiceNumber}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Supplier: ${header.supplierName}'),
              Text('Date: ${header.invoiceDate.toLocal().toString().split(' ')[0]}'),
              Text('Landed Costs: ₹${header.landedCostTotalPaise.inRupees.toStringAsFixed(2)}'),
              const Divider(height: 24),
              const Text('Line Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: lines.length,
                  itemBuilder: (c, i) {
                    final l = lines[i];
                    return ListTile(
                      dense: true,
                      title: Text('${l.productName} (${l.sku})'),
                      subtitle: Text(
                        'Qty: ${l.quantity.inUnits} | Price: ₹${l.unitPurchasePrice.inRupees.toStringAsFixed(2)} | Landed: ₹${l.landedCostAllocationPaise.inRupees.toStringAsFixed(2)}\nSerials: ${l.serials.isEmpty ? "None" : l.serials.join(", ")}',
                      ),
                      trailing: Text(
                        '₹${l.netTotalPaise.inRupees.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Bill Amount: ₹${header.netTotalPaise.inRupees.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------
// Tab 2: New Purchase Bill Wizard
// ---------------------------------------------------------------------

class _NewPurchaseBillTab extends ConsumerStatefulWidget {
  const _NewPurchaseBillTab({required this.onPostedSuccess});

  final VoidCallback onPostedSuccess;

  @override
  ConsumerState<_NewPurchaseBillTab> createState() => _NewPurchaseBillTabState();
}

class _NewPurchaseBillTabState extends ConsumerState<_NewPurchaseBillTab> {
  final _formKey = GlobalKey<FormState>();

  Party? _selectedSupplier;
  final _extInvoiceNoController = TextEditingController();
  final _invoiceDate = DateTime.now();
  String _selectedLocationId = 'MAIN_WH';
  TaxSupplyType _supplyType = TaxSupplyType.intraState;

  final _landedCostController = TextEditingController(text: '0');
  LandedCostAllocationType _landedAllocationType = LandedCostAllocationType.byValue;

  final _initialPaymentController = TextEditingController(text: '0');
  PaymentMethod _paymentMethod = PaymentMethod.cash;

  List<Party> _suppliers = [];
  List<Product> _products = [];
  bool _loadingMasters = true;
  bool _submitting = false;

  final List<_DraftPurchaseLine> _lines = [];

  @override
  void initState() {
    super.initState();
    _loadMasters();
  }

  Future<void> _loadMasters() async {
    final runtime = await ref.read(runtimeProvider.future);
    final orgId = runtime.identity?.organization.id.value ?? 'default_org';

    final parties = await runtime.database.searchParties(orgId, isSupplier: true);
    final prods = await runtime.database.searchProducts(orgId);

    if (mounted) {
      setState(() {
        _suppliers = parties;
        _products = prods;
        _loadingMasters = false;
      });
    }
  }

  void _addLine() {
    if (_products.isEmpty) return;
    setState(() {
      _lines.add(_DraftPurchaseLine(product: _products.first));
    });
  }

  void _removeLine(int index) {
    setState(() {
      _lines.removeAt(index);
    });
  }

  Future<void> _submitPurchase() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a supplier')),
      );
      return;
    }
    if (_lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one line item')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final runtime = await ref.read(runtimeProvider.future);
      final orgId = runtime.identity?.organization.id.value ?? 'default_org';
      final branchId = runtime.identity?.branch.id.value ?? 'branch_1';
      final session = ref.read(authProvider);

      if (session == null) throw const AuthenticationFailure('unauthenticated', 'Not logged in');

      final commandContext = CommandContext(session: session, timestampUtc: DateTime.now());

      final lineInputs = _lines.map((l) {
        final serialList = l.serialsController.text.trim().isEmpty
            ? <String>[]
            : l.serialsController.text
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();

        return PurchaseLineInput(
          productId: l.product.id,
          productName: l.product.name,
          sku: l.product.sku,
          quantity: Quantity.fromUnits(double.parse(l.qtyController.text)),
          unitPurchasePrice: UnitPrice.fromRupees(double.parse(l.priceController.text)),
          taxRate: TaxRate.fromPercentage(l.gstRate),
          serials: serialList,
        );
      }).toList();

      final landedCost = Money.fromRupees(double.tryParse(_landedCostController.text) ?? 0.0);
      final initialPmt = Money.fromRupees(double.tryParse(_initialPaymentController.text) ?? 0.0);

      final useCase = PostPurchaseUseCase(
        purchasingStore: runtime.database,
        inventoryStore: runtime.database,
        accountingStore: runtime.database,
      );

      await useCase.execute(
        commandContext,
        organizationId: orgId,
        branchId: branchId,
        supplierId: _selectedSupplier!.id,
        supplierName: _selectedSupplier!.name,
        externalInvoiceNumber: _extInvoiceNoController.text.trim(),
        invoiceDate: _invoiceDate,
        locationId: _selectedLocationId,
        supplyType: _supplyType,
        lineInputs: lineInputs,
        landedCostTotal: landedCost,
        landedCostAllocationType: _landedAllocationType,
        initialPaymentAmount: initialPmt,
        initialPaymentMethod: _paymentMethod,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase Bill posted successfully!')),
        );
        widget.onPostedSuccess();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingMasters) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Supplier Purchase Bill Capture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<Party>(
                            initialValue: _selectedSupplier,
                            decoration: const InputDecoration(
                              labelText: 'Select Supplier *',
                              border: OutlineInputBorder(),
                            ),
                            items: _suppliers.map((s) {
                              return DropdownMenuItem(value: s, child: Text(s.name));
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedSupplier = val),
                            validator: (val) => val == null ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _extInvoiceNoController,
                            decoration: const InputDecoration(
                              labelText: 'External Supplier Bill No. *',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<TaxSupplyType>(
                            initialValue: _supplyType,
                            decoration: const InputDecoration(
                              labelText: 'Supply Type',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: TaxSupplyType.intraState,
                                child: Text('Intra-State (CGST + SGST)'),
                              ),
                              DropdownMenuItem(
                                value: TaxSupplyType.interState,
                                child: Text('Inter-State (IGST)'),
                              ),
                            ],
                            onChanged: (v) => setState(() => _supplyType = v!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedLocationId,
                            decoration: const InputDecoration(
                              labelText: 'Target Warehouse / Location',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'MAIN_WH', child: Text('Main Warehouse')),
                              DropdownMenuItem(value: 'SHOWROOM', child: Text('Showroom Display')),
                              DropdownMenuItem(value: 'QUARANTINE', child: Text('Quarantine')),
                            ],
                            onChanged: (v) => setState(() => _selectedLocationId = v!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Line Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: _addLine,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Line'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF990000), foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _lines.length,
              itemBuilder: (context, idx) {
                final line = _lines[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<Product>(
                                initialValue: line.product,
                                decoration: const InputDecoration(labelText: 'Product', border: OutlineInputBorder()),
                                items: _products.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                                onChanged: (p) => setState(() => line.product = p!),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                controller: line.qtyController,
                                decoration: const InputDecoration(labelText: 'Qty', border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: line.priceController,
                                decoration: const InputDecoration(labelText: 'Unit Price ₹', border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<double>(
                                initialValue: line.gstRate,
                                decoration: const InputDecoration(labelText: 'GST %', border: OutlineInputBorder()),
                                items: const [
                                  DropdownMenuItem(value: 0.0, child: Text('0%')),
                                  DropdownMenuItem(value: 5.0, child: Text('5%')),
                                  DropdownMenuItem(value: 12.0, child: Text('12%')),
                                  DropdownMenuItem(value: 18.0, child: Text('18%')),
                                  DropdownMenuItem(value: 28.0, child: Text('28%')),
                                ],
                                onChanged: (val) => setState(() => line.gstRate = val!),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeLine(idx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: line.serialsController,
                          decoration: const InputDecoration(
                            labelText: 'Serial Numbers (comma-separated, optional)',
                            border: OutlineInputBorder(),
                            hintText: 'e.g. SN-001, SN-002',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Landed Cost & Payment Defaults', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _landedCostController,
                            decoration: const InputDecoration(
                              labelText: 'Freight / Landed Cost Total (₹)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<LandedCostAllocationType>(
                            initialValue: _landedAllocationType,
                            decoration: const InputDecoration(
                              labelText: 'Allocation Method',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: LandedCostAllocationType.byValue, child: Text('By Line Value')),
                              DropdownMenuItem(value: LandedCostAllocationType.byQuantity, child: Text('By Line Quantity')),
                            ],
                            onChanged: (v) => setState(() => _landedAllocationType = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _initialPaymentController,
                            decoration: const InputDecoration(
                              labelText: 'Initial Payment Amount (₹)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<PaymentMethod>(
                            initialValue: _paymentMethod,
                            decoration: const InputDecoration(
                              labelText: 'Payment Method',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: PaymentMethod.cash, child: Text('Cash')),
                              DropdownMenuItem(value: PaymentMethod.bankTransfer, child: Text('Bank Transfer / NEFT')),
                              DropdownMenuItem(value: PaymentMethod.upi, child: Text('UPI')),
                              DropdownMenuItem(value: PaymentMethod.cheque, child: Text('Cheque')),
                            ],
                            onChanged: (v) => setState(() => _paymentMethod = v!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submitPurchase,
                icon: const Icon(Icons.check_circle),
                label: Text(_submitting ? 'Posting Purchase Bill...' : 'Post Purchase Bill & Update Inventory'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF990000),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftPurchaseLine {
  _DraftPurchaseLine({required this.product});

  Product product;
  final qtyController = TextEditingController(text: '1.0');
  final priceController = TextEditingController(text: '1000.0');
  double gstRate = 18.0;
  final serialsController = TextEditingController();
}

// ---------------------------------------------------------------------
// Tab 3: Supplier Payables & Returns Entry Point
// ---------------------------------------------------------------------

class _SupplierPayablesTab extends ConsumerStatefulWidget {
  const _SupplierPayablesTab();

  @override
  ConsumerState<_SupplierPayablesTab> createState() => _SupplierPayablesTabState();
}

class _SupplierPayablesTabState extends ConsumerState<_SupplierPayablesTab> {
  List<Party> _suppliers = [];
  final Map<String, Money> _balances = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPayables();
  }

  Future<void> _loadPayables() async {
    setState(() => _loading = true);
    final runtime = await ref.read(runtimeProvider.future);
    final orgId = runtime.identity?.organization.id.value ?? 'default_org';

    final suppliers = await runtime.database.searchParties(orgId, isSupplier: true);
    for (final s in suppliers) {
      final bal = await runtime.database.getSupplierOutstandingBalance(
        organizationId: orgId,
        supplierId: s.id,
      );
      _balances[s.id] = bal;
    }

    if (mounted) {
      setState(() {
        _suppliers = suppliers;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Supplier Outstanding Dues & Returns',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: _loadPayables,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Payables'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF990000), foregroundColor: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _suppliers.length,
              itemBuilder: (context, idx) {
                final s = _suppliers[idx];
                final due = _balances[s.id] ?? Money.zero;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.store, color: Color(0xFF990000)),
                    title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('GSTIN: ${s.gstin ?? "N/A"}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Outstanding: ₹${due.inRupees.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: due.paise > 0 ? Colors.red : Colors.green[800],
                          ),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Initiate Purchase Return'),
                                content: Text(
                                  'Purchase Return entry point for ${s.name}.\n\n'
                                  'Note: Complete Purchase Return settlement and debit note posting workflow is pending P08 (Payments, Returns & Expenses).',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.undo),
                          label: const Text('Purchase Return'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
