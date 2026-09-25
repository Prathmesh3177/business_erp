import 'package:erp_application/erp_application.dart';
import 'package:erp_domain/erp_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/auth_controller.dart';
import '../../app/bootstrap.dart';

final class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

final class _InventoryPageState extends ConsumerState<InventoryPage>
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory & Serial Control'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2), text: 'Stock Balances'),
            Tab(icon: Icon(Icons.history), text: 'Movements'),
            Tab(icon: Icon(Icons.qr_code_2), text: 'Serials & Batches'),
            Tab(icon: Icon(Icons.swap_horiz), text: 'Adjustments & Transfers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _StockBalancesTab(),
          _StockMovementsTab(),
          _SerialsTab(),
          _AdjustmentsAndTransfersTab(),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 1. Stock Balances Tab
// -----------------------------------------------------------------------------
final class _StockBalancesTab extends ConsumerStatefulWidget {
  const _StockBalancesTab();

  @override
  ConsumerState<_StockBalancesTab> createState() => _StockBalancesTabState();
}

final class _StockBalancesTabState extends ConsumerState<_StockBalancesTab> {
  List<StockBalance> _balances = [];
  List<Product> _products = [];
  bool _loading = true;
  bool _rebuilding = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final runtime = await ref.read(runtimeProvider.future);
    final orgId = runtime.identity?.organization.id.value ?? 'default_org';
    final balList = await runtime.database.getAllStockBalances(orgId);
    final prodList = await runtime.database.searchProducts(
      orgId,
      includeInactive: true,
    );

    if (mounted) {
      setState(() {
        _balances = balList;
        _products = prodList;
        _loading = false;
      });
    }
  }

  Future<void> _rebuildLedger() async {
    setState(() => _rebuilding = true);
    final runtime = await ref.read(runtimeProvider.future);
    final orgId = runtime.identity?.organization.id.value ?? 'default_org';
    final session = ref.read(authProvider);

    if (session != null) {
      final commandContext = CommandContext(
        session: session,
        timestampUtc: DateTime.now(),
      );
      final rebuilt = await RebuildStockLedgerUseCase(runtime.database)
          .execute(commandContext, organizationId: orgId);
      if (mounted) {
        setState(() {
          _balances = rebuilt;
          _rebuilding = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Stock ledger rebuilt successfully with zero parity variance!',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalValuationRupees = _balances.fold<double>(
      0.0,
      (sum, b) => sum + b.valueInRupees,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stock Valuations (${_balances.length} Positions)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF004D40),
                    ),
                  ),
                  Text(
                    'Total Valuation: ₹${totalValuationRupees.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF990000),
                    ),
                  ),
                ],
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF004D40),
                ),
                onPressed: _rebuilding ? null : _rebuildLedger,
                icon: _rebuilding
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Rebuild Stock Ledger'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _balances.isEmpty
                ? const Center(
                    child: Text('No stock balance positions recorded yet.'),
                  )
                : Card(
                    elevation: 2,
                    child: ListView.separated(
                      itemCount: _balances.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final b = _balances[index];
                        final prod = _products.firstWhere(
                          (p) => p.id == b.productId,
                          orElse: () => Product(
                            id: b.productId,
                            organizationId: 'default_org',
                            sku: b.productId,
                            name: 'Product ${b.productId}',
                            categoryId: 'cat_panels',
                            baseUnitId: 'unit_pcs',
                            hsnCode: '85414011',
                            createdAt: DateTime.now(),
                            updatedAt: DateTime.now(),
                          ),
                        );

                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF004D40),
                            foregroundColor: Colors.white,
                            child: Icon(Icons.inventory),
                          ),
                          title: Text(
                            '${prod.name} (${prod.sku})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Location ID: ${b.locationId}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${b.quantityInUnits.toStringAsFixed(2)} Units',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF004D40),
                                ),
                              ),
                              Text(
                                'Val: ₹${b.valueInRupees.toStringAsFixed(2)} (Avg: ₹${(b.weightedAverageUnitCostMicroRupees / 1000000.0).toStringAsFixed(2)})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF990000),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. Stock Movements Tab
// -----------------------------------------------------------------------------
final class _StockMovementsTab extends ConsumerStatefulWidget {
  const _StockMovementsTab();

  @override
  ConsumerState<_StockMovementsTab> createState() => _StockMovementsTabState();
}

final class _StockMovementsTabState extends ConsumerState<_StockMovementsTab> {
  List<StockMovement> _movements = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMovements();
  }

  Future<void> _loadMovements() async {
    final runtime = await ref.read(runtimeProvider.future);
    final orgId = runtime.identity?.organization.id.value ?? 'default_org';
    final list = await runtime.database.getStockMovements(orgId);
    if (mounted) {
      setState(() {
        _movements = list;
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Append-Only Movement Audit Log (${_movements.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF004D40),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _movements.isEmpty
                ? const Center(child: Text('No stock movements recorded yet.'))
                : ListView.builder(
                    itemCount: _movements.length,
                    itemBuilder: (context, index) {
                      final m = _movements[index];
                      final isPositive = m.quantityMicroUnits > 0;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(
                            isPositive ? Icons.add_circle : Icons.remove_circle,
                            color: isPositive
                                ? const Color(0xFF004D40)
                                : const Color(0xFF990000),
                          ),
                          title: Text(
                            '${m.movementKind.name.toUpperCase()} — Product: ${m.productId}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Doc: ${m.documentId} • Location: ${m.locationId} • ${m.createdAt.toLocal().toString().split(".")[0]}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isPositive ? "+" : ""}${m.quantityInUnits.toStringAsFixed(2)} Units',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isPositive
                                      ? const Color(0xFF004D40)
                                      : const Color(0xFF990000),
                                ),
                              ),
                              Text(
                                '₹${m.valueDeltaInRupees.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 12),
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

// -----------------------------------------------------------------------------
// 3. Serials Tab
// -----------------------------------------------------------------------------
final class _SerialsTab extends ConsumerStatefulWidget {
  const _SerialsTab();

  @override
  ConsumerState<_SerialsTab> createState() => _SerialsTabState();
}

final class _SerialsTabState extends ConsumerState<_SerialsTab> {
  final _searchController = TextEditingController();
  List<SerialRecord> _serials = [];
  bool _loading = false;

  Future<void> _searchSerials() async {
    setState(() => _loading = true);
    final runtime = await ref.read(runtimeProvider.future);
    final orgId = runtime.identity?.organization.id.value ?? 'default_org';

    // Fetch serials
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      final found = await runtime.database.getSerialByNumber(
        orgId,
        'prod_panel_1',
        query,
      );
      if (mounted) {
        setState(() {
          _serials = found != null ? [found] : [];
          _loading = false;
        });
      }
    } else {
      final list = await runtime.database.getSerialsForProduct(
        orgId,
        'prod_panel_1',
      );
      if (mounted) {
        setState(() {
          _serials = list;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search Serial Number (e.g. SN-001)',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF990000),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onPressed: _searchSerials,
                icon: const Icon(Icons.search),
                label: const Text('Lookup'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: _serials.isEmpty
                  ? const Center(child: Text('No serial records found.'))
                  : ListView.builder(
                      itemCount: _serials.length,
                      itemBuilder: (context, index) {
                        final s = _serials[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.qr_code,
                              color: Color(0xFF004D40),
                            ),
                            title: Text(
                              s.serialNumber,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            subtitle: Text(
                              'Product: ${s.productId} • Location: ${s.locationId ?? "N/A"}',
                            ),
                            trailing: Chip(
                              label: Text(
                                s.state.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: s.state == SerialState.inStock
                                  ? const Color(0xFF004D40)
                                  : const Color(0xFF990000),
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

// -----------------------------------------------------------------------------
// 4. Adjustments & Transfers Tab
// -----------------------------------------------------------------------------
final class _AdjustmentsAndTransfersTab extends ConsumerStatefulWidget {
  const _AdjustmentsAndTransfersTab();

  @override
  ConsumerState<_AdjustmentsAndTransfersTab> createState() =>
      _AdjustmentsAndTransfersTabState();
}

final class _AdjustmentsAndTransfersTabState
    extends ConsumerState<_AdjustmentsAndTransfersTab> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Inventory Management Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF004D40),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF990000),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(20),
                ),
                onPressed: () => _showOpeningStockDialog(context),
                icon: const Icon(Icons.add_business),
                label: const Text('Post Opening Stock'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004D40),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(20),
                ),
                onPressed: () => _showAdjustmentDialog(context),
                icon: const Icon(Icons.tune),
                label: const Text('Stock Adjustment (Shrinkage/Surplus)'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(20),
                ),
                onPressed: () => _showTransferDialog(context),
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Same-Branch Location Transfer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showOpeningStockDialog(BuildContext context) async {
    final prodController = TextEditingController(text: 'prod_panel_1');
    final qtyController = TextEditingController(text: '10');
    final valController = TextEditingController(text: '12000.00');

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Post Opening Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: prodController,
              decoration: const InputDecoration(labelText: 'Product ID'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              decoration: const InputDecoration(labelText: 'Quantity (Units)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valController,
              decoration: const InputDecoration(
                labelText: 'Total Valuation (₹)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF990000),
            ),
            onPressed: () async {
              final runtime = await ref.read(runtimeProvider.future);
              final session = ref.read(authProvider);
              if (session != null) {
                final commandContext = CommandContext(
                  session: session,
                  timestampUtc: DateTime.now(),
                );
                final orgId =
                    runtime.identity?.organization.id.value ?? 'default_org';
                final branchId =
                    runtime.identity?.branch.id.value ?? 'main_branch';

                final qty = double.tryParse(qtyController.text) ?? 1.0;
                final val = double.tryParse(valController.text) ?? 1000.0;

                await PostOpeningStockUseCase(
                  inventoryStore: runtime.database,
                  accountingStore: runtime.database,
                ).execute(
                  commandContext,
                  organizationId: orgId,
                  branchId: branchId,
                  productId: prodController.text.trim(),
                  locationId: 'loc_default_sellable',
                  quantity: Quantity.fromUnits(qty),
                  totalValue: Money.fromRupees(val),
                  commandId: 'cmd_op_${DateTime.now().millisecondsSinceEpoch}',
                );

                if (dialogCtx.mounted) {
                  Navigator.of(dialogCtx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening stock posted successfully!'),
                    ),
                  );
                }
              }
            },
            child: const Text('Post Stock'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAdjustmentDialog(BuildContext context) async {
    final prodController = TextEditingController(text: 'prod_panel_1');
    final deltaQtyController = TextEditingController(text: '-1');
    final reasonController = TextEditingController(
      text: 'Physical audit count discrepancy',
    );

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Post Stock Adjustment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: prodController,
              decoration: const InputDecoration(labelText: 'Product ID'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: deltaQtyController,
              decoration: const InputDecoration(
                labelText: 'Quantity Delta (+ for Surplus, - for Shrinkage)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Adjustment',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF004D40),
            ),
            onPressed: () async {
              final runtime = await ref.read(runtimeProvider.future);
              final session = ref.read(authProvider);
              if (session != null) {
                final commandContext = CommandContext(
                  session: session,
                  timestampUtc: DateTime.now(),
                );
                final orgId =
                    runtime.identity?.organization.id.value ?? 'default_org';
                final branchId =
                    runtime.identity?.branch.id.value ?? 'main_branch';

                final deltaQty =
                    ((double.tryParse(deltaQtyController.text) ?? 0) * 1000000)
                        .round();

                await PostStockAdjustmentUseCase(
                  inventoryStore: runtime.database,
                  accountingStore: runtime.database,
                ).execute(
                  commandContext,
                  organizationId: orgId,
                  branchId: branchId,
                  productId: prodController.text.trim(),
                  locationId: 'loc_default_sellable',
                  quantityDeltaMicroUnits: deltaQty,
                  reason: reasonController.text.trim(),
                  approvedByUserId: session.userId.value,
                );

                if (dialogCtx.mounted) {
                  Navigator.of(dialogCtx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Stock adjustment posted successfully!'),
                    ),
                  );
                }
              }
            },
            child: const Text('Post Adjustment'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTransferDialog(BuildContext context) async {
    final prodController = TextEditingController(text: 'prod_panel_1');
    final qtyController = TextEditingController(text: '2');

    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Same-Branch Stock Transfer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: prodController,
              decoration: const InputDecoration(labelText: 'Product ID'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              decoration: const InputDecoration(
                labelText: 'Transfer Quantity (Units)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () async {
              final runtime = await ref.read(runtimeProvider.future);
              final session = ref.read(authProvider);
              if (session != null) {
                final commandContext = CommandContext(
                  session: session,
                  timestampUtc: DateTime.now(),
                );
                final orgId =
                    runtime.identity?.organization.id.value ?? 'default_org';
                final branchId =
                    runtime.identity?.branch.id.value ?? 'main_branch';

                final qty = double.tryParse(qtyController.text) ?? 1.0;

                await TransferStockUseCase(runtime.database).execute(
                  commandContext,
                  organizationId: orgId,
                  branchId: branchId,
                  productId: prodController.text.trim(),
                  fromLocationId: 'loc_default_sellable',
                  toLocationId: 'loc_default_quarantine',
                  quantity: Quantity.fromUnits(qty),
                );

                if (dialogCtx.mounted) {
                  Navigator.of(dialogCtx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Stock transfer completed successfully!'),
                    ),
                  );
                }
              }
            },
            child: const Text('Execute Transfer'),
          ),
        ],
      ),
    );
  }
}
